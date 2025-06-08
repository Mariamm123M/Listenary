from pymongo import MongoClient
import mysql.connector
import os
import shutil

# Connect to MongoDB
mongo_client = MongoClient("mongodb+srv://mariamsalah0312:mariam%402003@listenary.h2iywhc.mongodb.net/test")
mongo_db = mongo_client["Listenary"]
book_collection = mongo_db["books"]

# Connect to MySQL
mysql_conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="WJ28@krhps",
    database="listenary",
    charset="utf8mb4"
)
mysql_cursor = mysql_conn.cursor()

# Helper: Copy image to static folder and return the public URL
def copy_image_to_static(original_path):
    static_folder = os.path.join(os.getcwd(), "static")  # assumes script runs from project root
    os.makedirs(static_folder, exist_ok=True)
    
    filename = os.path.basename(original_path)
    target_path = os.path.join(static_folder, filename)
    
    # Only copy if not already present
    if not os.path.exists(target_path):
        shutil.copyfile(original_path, target_path)

    # Return the URL that the Flutter app can use
    return f"http://127.0.0.1:5000/static/{filename}"

# Function to insert book content and metadata
def insert_book_from_txt(txt_path, title, author, category, description, language, pages, rating, image_path):
    try:
        # Read the .txt book content
        with open(txt_path, 'r', encoding='utf-8', errors='ignore') as file:
            text_content = file.read()

        # Copy image and generate public URL
        image_url = copy_image_to_static(image_path)

        # Insert book content into MongoDB
        book_doc = {
            "Title": title,
            "Author": author,
            "Category": category,
            "Description": description,
            "Language": language,
            "Pages": pages,
            "Rating": rating,
            "Content": text_content,
            "bookImageUrl": image_url 
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
    image_path = input("Enter full path to the image (e.g., F:\\...\\elayam.png): ")

    insert_book_from_txt(txt_path, title, author, category, description, language, pages, rating, image_path)
