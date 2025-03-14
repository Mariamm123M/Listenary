from flask import Flask, request, jsonify
from flask_cors import CORS
import pytesseract
from PIL import Image
import pymysql
import pymongo

app = Flask(__name__)
CORS(app)

# MySQL Connection
mysql_conn = pymysql.connect(
    host='localhost',
    user='root',
    password='M@ri@m_2003',
    database='Listenary'
)

# MongoDB Connection
mongo_client = pymongo.MongoClient("mongodb://localhost:27017/")
mongo_db = mongo_client["Listenary"]

@app.route('/upload', methods=['POST'])
def upload_image():
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400
    if file:
        image = Image.open(file.stream)
        text = pytesseract.image_to_string(image)
        # Save to MongoDB
        mongo_db.uploads.insert_one({"filename": file.filename, "text": text})
        return jsonify({"text": text}), 200

if __name__ == '__main__':
    app.run(debug=True)