from flask import Flask, render_template, request, jsonify
import requests
import re
import time
from translate import Translator
import logging
from flask_cors import CORS

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Important for Flutter to access the API

# Cache to avoid redundant API calls
_cache = {}
CACHE_TIMEOUT = 3600  # Cache time in seconds

# Enhanced Arabic detection - more comprehensive
def is_arabic(text):
    if not text:
        return False
    # Check for Arabic characters
    arabic_chars = re.findall(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]', text)
    # If more than 30% of non-space characters are Arabic, consider it Arabic text
    non_space_chars = len(re.sub(r'\s', '', text))
    if non_space_chars == 0:
        return False
    return len(arabic_chars) / non_space_chars > 0.3

# Retry HTTP request
def fetch_data_with_retry(url, retries=3, timeout=10):
    for _ in range(retries):
        try:
            response = requests.get(url, timeout=timeout)
            if response.status_code == 200:
                return response.json()
        except requests.exceptions.RequestException:
            pass
        time.sleep(1)
    return None

# Arabic Wikipedia summaries
def get_wikipedia_data(book_title, author_name):
    book_summary_url = f"https://ar.wikipedia.org/api/rest_v1/page/summary/{book_title}"
    book_data = fetch_data_with_retry(book_summary_url)
    book_summary = book_data.get('extract', 'لا توجد نبذة عن الكتاب.') if book_data else 'لا توجد نبذة عن الكتاب.'
    
    author_summary_url = f"https://ar.wikipedia.org/api/rest_v1/page/summary/{author_name}"
    author_data = fetch_data_with_retry(author_summary_url)
    author_bio = author_data.get('extract', 'لا توجد معلومات عن الكاتب.') if author_data else 'لا توجد معلومات عن الكاتب.'

    return {"book_summary": book_summary, "author_bio": author_bio}

# Enhanced translation function with better validation
def translate_to_arabic(text):
    try:
        if not text or is_arabic(text):
            return text
        
        # Use a more reliable translation method
        translator = Translator(to_lang="ar", from_lang="en")
        translated = translator.translate(text)
        
        if not translated or translated == text:
            return text  # Return original if translation fails
            
        # Validate if translation contains Arabic characters
        if is_arabic(translated):
            return translated
        else:
            return text  # Return original if translation doesn't produce Arabic
            
    except Exception as e:
        logger.error(f"Translation error: {str(e)}")
        return text  # Return original text if translation fails

# Translate text from Arabic to English (for better search results)
def translate_to_english(text):
    try:
        if not is_arabic(text):
            return text
            
        translator = Translator(to_lang="en", from_lang="ar")
        translated = translator.translate(text)
        
        if translated and translated != text:
            return translated
        return text
        
    except Exception as e:
        logger.error(f"Translation to English error: {str(e)}")
        return text

# Get localized text based on language mode
def get_localized_text(arabic_text, english_text, is_arabic_mode):
    return arabic_text if is_arabic_mode else english_text

# Main book details function with enhanced Arabic support
def full_book_details(query):
    result = {
        "title": "",
        "author": "",
        "publish_year": "",
        "description": "",
        "subjects": "",
        "cover_url": "",
        "author_bio": "",
        "birth_date": "",
        "death_date": "",
        "other_books_by_author": [],
        "related_books": [],
        "error": ""
    }

    # Determine if query is in Arabic
    arabic_mode = is_arabic(query)
    result["is_arabic"] = arabic_mode
    
    logger.debug(f"Query: {query}, Arabic mode: {arabic_mode}")
    
    # For Arabic queries, try both Arabic and English search
    search_queries = [query]
    if arabic_mode:
        # Add English translation of the query for broader search
        english_query = translate_to_english(query)
        if english_query != query:
            search_queries.append(english_query)
    
    books_found = []
    
    # Search with multiple queries
    for search_query in search_queries:
        search_url = f"https://openlibrary.org/search.json?q={search_query}&limit=20"
        search_data = fetch_data_with_retry(search_url)
        
        if search_data and "docs" in search_data and search_data["docs"]:
            if arabic_mode:
                # For Arabic mode, prefer books with Arabic language or Arabic in title/author
                arabic_books = []
                other_books = []
                
                for book in search_data["docs"]:
                    has_arabic_lang = 'language' in book and any('ara' in lang for lang in book.get("language", []))
                    has_arabic_title = is_arabic(book.get("title", ""))
                    has_arabic_author = any(is_arabic(author) for author in book.get("author_name", []))
                    
                    if has_arabic_lang or has_arabic_title or has_arabic_author:
                        arabic_books.append(book)
                    else:
                        other_books.append(book)
                
                books_found.extend(arabic_books + other_books[:5])  # Prefer Arabic books
            else:
                books_found.extend(search_data["docs"])
        
        if books_found:
            break  # Stop searching if we found books
    
    if not books_found:
        result["error"] = get_localized_text(
            "❌ لم يتم العثور على نتائج.",
            "❌ No books found.",
            arabic_mode
        )
        return result

    # Use the first book found
    book = books_found[0]
    
    # Extract basic information
    title = book.get("title", "")
    author = book.get("author_name", [""])[0] if book.get("author_name") else ""
    
    # Translate to Arabic if in Arabic mode and text is not already Arabic
    if arabic_mode:
        result["title"] = translate_to_arabic(title) if title else get_localized_text("غير متوفر", "N/A", True)
        result["author"] = translate_to_arabic(author) if author else get_localized_text("غير معروف", "Unknown", True)
    else:
        result["title"] = title or "N/A"
        result["author"] = author or "Unknown"
    
    result["publish_year"] = str(book.get("first_publish_year", "")) if book.get("first_publish_year") else ""
    
    # Handle subjects
    subjects = book.get("subject", [])
    if subjects:
        subject_list = subjects[:5]
        if arabic_mode:
            translated_subjects = [translate_to_arabic(subj) for subj in subject_list]
            result["subjects"] = ", ".join([s for s in translated_subjects if s])
        else:
            result["subjects"] = ", ".join(subject_list)
    
    # Cover image
    cover_id = book.get("cover_i")
    if cover_id:
        result["cover_url"] = f"https://covers.openlibrary.org/b/id/{cover_id}-L.jpg"

    work_key = book.get("key", "")
    author_key = book.get("author_key", [""])[0]

    # Get extended work description
    if work_key:
        work_details = fetch_data_with_retry(f"https://openlibrary.org{work_key}.json")
        if work_details:
            desc = work_details.get("description", "")
            if isinstance(desc, dict):
                desc = desc.get("value", "")
            
            if desc:
                if arabic_mode and not is_arabic(desc):
                    result["description"] = translate_to_arabic(desc)
                else:
                    result["description"] = desc
            
            # Additional subjects from work details
            if not result["subjects"] and work_details.get("subjects"):
                work_subjects = work_details.get("subjects", [])[:10]
                if arabic_mode:
                    translated_subjects = [translate_to_arabic(subj) for subj in work_subjects]
                    result["subjects"] = ", ".join([s for s in translated_subjects if s])
                else:
                    result["subjects"] = ", ".join(work_subjects)

    # Get author information
    if author_key:
        author_url = f"https://openlibrary.org/authors/{author_key}.json"
        author_data = fetch_data_with_retry(author_url)
        if author_data:
            bio = author_data.get("bio", "")
            if isinstance(bio, dict):
                bio = bio.get("value", "")
            
            if bio:
                if arabic_mode and not is_arabic(bio):
                    result["author_bio"] = translate_to_arabic(bio)
                else:
                    result["author_bio"] = bio
            
            result["birth_date"] = author_data.get("birth_date", "")
            result["death_date"] = author_data.get("death_date", "")

        # Get other works by the author
        works_url = f"https://openlibrary.org/authors/{author_key}/works.json"
        works_data = fetch_data_with_retry(works_url)
        if works_data and "entries" in works_data:
            other_titles = [entry["title"] for entry in works_data["entries"] 
                          if entry.get("title") and entry.get("title") != book.get("title")]
            
            if other_titles:
                if arabic_mode:
                    translated_titles = [translate_to_arabic(title) for title in other_titles[:10]]
                    cleaned_titles = list(set([t for t in translated_titles if t and t != title]))
                    result["other_books_by_author"] = cleaned_titles[:5] if cleaned_titles else [get_localized_text("لا توجد كتب أخرى متوفرة للمؤلف.", "No other books available by this author.", True)]
                else:
                    result["other_books_by_author"] = other_titles[:5]

    # If Arabic mode and still missing description, try Wikipedia
    if arabic_mode and not result["description"]:
        original_title = book.get("title", "")
        original_author = book.get("author_name", [""])[0] if book.get("author_name") else ""
        
        wiki_data = get_wikipedia_data(original_title, original_author)
        if wiki_data.get("book_summary") != 'لا توجد نبذة عن الكتاب.':
            result["description"] = wiki_data.get("book_summary", "")
        if not result["author_bio"] and wiki_data.get("author_bio") != 'لا توجد معلومات عن الكاتب.':
            result["author_bio"] = wiki_data.get("author_bio", "")

    # Get related books
    if subjects:
        all_related = []
        for subject in subjects[:3]:  # Limit to avoid too many API calls
            subject_clean = subject.replace(' ', '_').replace('/', '_')
            sub_url = f"https://openlibrary.org/subjects/{subject_clean}.json?limit=10"
            sub_data = fetch_data_with_retry(sub_url)
            if sub_data and sub_data.get("works"):
                all_related.extend(sub_data.get("works", []))

        if all_related:
            # Score books based on subject overlap
            score = {}
            for work in all_related:
                work_title = work.get("title")
                if not work_title or work_title == book.get("title"):
                    continue
                
                work_subjects = set(work.get("subject", []))
                subject_set = set(subjects)
                match_score = len(work_subjects.intersection(subject_set))
                
                if match_score > 0:
                    score[work_title] = match_score

            if score:
                sorted_books = sorted(score.items(), key=lambda x: x[1], reverse=True)
                related_titles = [title for title, _ in sorted_books[:5]]

                if arabic_mode:
                    translated_related = [translate_to_arabic(title) for title in related_titles]
                    result["related_books"] = [t for t in translated_related if t]
                else:
                    result["related_books"] = related_titles

    # Ensure we have some default values for Arabic mode
    if arabic_mode:
        if not result["title"]:
            result["title"] = "غير متوفر"
        if not result["author"]:
            result["author"] = "غير معروف"
        if not result["description"]:
            result["description"] = "لا توجد نبذة متاحة عن هذا الكتاب."
        if not result["author_bio"]:
            result["author_bio"] = "لا توجد معلومات متاحة عن هذا المؤلف."
        if not result["other_books_by_author"]:
            result["other_books_by_author"] = ["لا توجد كتب أخرى متوفرة للمؤلف."]

    return result

# Flask route for web interface
@app.route('/', methods=['GET', 'POST'])
def home():
    book_data = None
    if request.method == 'POST':
        query = request.form.get('query')
        if query:
            book_data = full_book_details(query)
    return render_template('merged_book_info.html', book=book_data)

# API endpoint for Flutter with enhanced Arabic support
@app.route('/search', methods=['POST'])
def search_api():
    try:
        data = request.get_json()
        if not data or 'query' not in data:
            return jsonify({
                "result": "Error: Missing query parameter", 
                "book_data": None
            }), 400
        
        query = data['query'].strip()
        if not query:
            return jsonify({
                "result": "Error: Empty query", 
                "book_data": None
            }), 400
            
        logger.debug(f"Received search query: {query}")
        
        book_data = full_book_details(query)
        
        if book_data.get("error"):
            return jsonify({
                "result": book_data["error"], 
                "book_data": None
            }), 200
        
        # Create appropriate response message based on language
        is_arabic = book_data.get("is_arabic", False)
        if is_arabic:
            message = f"تم العثور على معلومات عن كتاب: {book_data['title']}"
        else:
            message = f"Found information about: {book_data['title']}"
        
        return jsonify({
            "result": message, 
            "book_data": book_data
        }), 200
        
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        return jsonify({
            "result": "Error processing request", 
            "book_data": None
        }), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5006, debug=True)