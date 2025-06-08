from flask import Flask, jsonify
from pymongo import MongoClient
import mysql.connector
from bson import ObjectId
from flask_cors import CORS

app = Flask(__name__, static_url_path='/static')
CORS(app)

# Connect to MongoDB
mongo_client = MongoClient("mongodb+srv://mariamsalah0312:mariam%402003@listenary.h2iywhc.mongodb.net/test")
mongo_db = mongo_client["Listenary"]
book_collection = mongo_db["books"]

# Connect to MySQL
mysql_conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="WJ28@krhps",
    database="listenary"
)
mysql_cursor = mysql_conn.cursor()

@app.route('/get_books', methods=['GET'])
def get_books():
    # Fetch all necessary fields from MongoDB
    books = list(book_collection.find({}, {
        "_id": 1,
        "Title": 1,
        "Author": 1,
        "Category": 1,
        "Description": 1,
        "Pages": 1,
        "Language": 1,
        "Rating": 1,
        "Content": 1, 
        "bookImageUrl": 1,  # Assuming you also store rating in MongoDB
    }))
    
    # Convert ObjectId to string and add the fields to the response
    for book in books:
        book['_id'] = str(book['_id'])  # Convert ObjectId to string
        # Ensure all fields are in the JSON response
        book['Description'] = book.get('Description', '')
        book['Pages'] = book.get('Pages', 0)
        book['Language'] = book.get('Language', '')
        book['Rating'] = book.get('Rating', 0.0)
        book['Content'] = book.get('Content', '')
        book['Category'] = book.get('Category', '')
        book['bookImageUrl'] = book.get('bookImageUrl', '') 

    return jsonify(books)

@app.route('/get_book_content/<book_id>', methods=['GET'])
def get_book_content(book_id):
    book = book_collection.find_one({"_id": ObjectId(book_id)}, {"Content": 1})
    if not book:
        return jsonify({"error": "Book not found"}), 404
    return jsonify({"content": book["Content"]})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
