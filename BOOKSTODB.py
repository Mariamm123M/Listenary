from pymongo import MongoClient
import mysql.connector

# Connect to MongoDB
mongo_client = MongoClient("mongodb://localhost:27017/")
mongo_db = mongo_client["listenary"]
book_collection = mongo_db["books"]

# Connect to MySQL
mysql_conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="M@ri@m_2003",
    database="listenary",
    charset="utf8mb4"
)
mysql_cursor = mysql_conn.cursor()

# Function to insert book content + metadata
def insert_book_from_txt(txt_path, title, author, category, description, language, pages, rating, image_url):
    try:
        with open(txt_path, 'r', encoding='utf-8') as file:
            text_content = file.read()

        # Insert content into MongoDB
        book_doc = {
            "Title": title,
            "Author": author,
            "Category": category,
            "Description": description,
            "Language": language,
            "Pages": pages,
            "Rating": rating,
            "Content": text_content
        }
        mongo_result = book_collection.insert_one(book_doc)
        mongo_id = str(mongo_result.inserted_id)

        # Insert metadata into MySQL (including image URL)
        mysql_cursor.execute(
            """
            INSERT INTO BOOK (Title, Author, Category, Description, Language, Pages, Rating, MongoDB_ID, ImageURL)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """,
            (title, author, category, description, language, pages, rating, mongo_id, image_url)
        )
        mysql_conn.commit()

        print(f"✅ Book '{title}' added successfully with image.")
    
    except Exception as e:
        print(f"❌ Error: {e}")

# Example usage
if __name__ == "__main__":
    txt_path = input("Enter path to the .txt file: ")
    title = input("Enter the book title: ")
    author = input("Enter the author: ")
    category = input("Enter the category: ")
    description = input("Enter a short description: ")
    language = input("Enter the language: ")
    pages = int(input("Enter number of pages: "))
    rating = float(input("Enter the rating (0-5): "))
    image_url = input("Enter image URL: ")

    insert_book_from_txt(txt_path, title, author, category, description, language, pages, rating, image_url)
