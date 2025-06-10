from flask import Flask, request, jsonify
from pymongo import MongoClient
from flask_cors import CORS
 # Allow all origins (for development only)

app = Flask(__name__)
CORS(app) 

# MongoDB setup
client = MongoClient("mongodb+srv://mariamsalah0312:mariam%402003@listenary.h2iywhc.mongodb.net/test")
db = client["Listenary"]
notes_collection = db["notes"]

@app.route("/api/notes", methods=["GET"])
def get_notes():
    user_id = request.args.get("userId")
    book_id = request.args.get("bookId")

    if not user_id or not book_id:
        return jsonify({"error": "Missing userId or bookId"}), 400

    notes_cursor = notes_collection.find({
        "userId": user_id,
        "bookId": book_id
    })

    notes = []
    for note in notes_cursor:
        notes.append({
            "userId": note["userId"],
            "bookId": note["bookId"],  
            "sentenceIndex": note["sentenceIndex"],
            "noteContent": note["noteContent"],
            "color": note["color"]
        })

    return jsonify(notes), 200


@app.route("/api/notes", methods=["POST"])
def save_note():
    data = request.get_json()

    required_fields = ["userId", "bookId", "booktitle", "sentenceIndex", "noteContent", "color", "isPinned"]
    if not all(field in data for field in required_fields):
        return jsonify({"error": "Missing one or more required fields"}), 400

    result = notes_collection.update_one(
        {
            "userId": data["userId"],
            "bookId": data["bookId"],
            "sentenceIndex": data["sentenceIndex"]
        },
        {"$set": {
            "noteContent": data["noteContent"],
            "color": data["color"]
        }},
        upsert=True
    )

    return jsonify({"message": "Note saved successfully"}), 200


@app.route("/api/notes", methods=["DELETE"])
def delete_note():
    data = request.get_json()
    print("Delete request data:", data)  # 👈 Add this to debug

    required_fields = ["userId", "bookId", "sentenceIndex"]
    if not all(field in data for field in required_fields):
        return jsonify({"error": "Missing one or more required fields"}), 400

    result = notes_collection.delete_one({
        "userId": data["userId"],
        "bookId": str(data["bookId"]),
        "sentenceIndex": data["sentenceIndex"]
    })

    print("MongoDB deletion result:", result.raw_result)  # 👈 Debug print

    if result.deleted_count == 0:
        return jsonify({"message": "Note not found"}), 404

    return jsonify({"message": "Note deleted successfully"}), 200


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5001)
    result = notes_collection.update_one(...)
print("MongoDB Update Result:", result.raw_result)  # Check if upsert worked
