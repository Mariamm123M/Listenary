from flask import Flask, request, jsonify
from nltk.corpus import wordnet
from googletrans import Translator
import nltk
import requests

nltk.download('wordnet')
nltk.download('omw-1.4')

app = Flask(__name__)
translator = Translator()

# دالة لاستخراج تعريف من ويكيبيديا للكلمات العربية
def get_short_arabic_definition(word):
    url = f"https://ar.wikipedia.org/api/rest_v1/page/summary/{word}"
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        return data.get("extract", "تعريف غير متاح.")
    else:
        return "لا يوجد تعريف في الويكيبديا"

# دالة API
@app.route('/define', methods=['POST'])
def define_word():
    data = request.get_json()
    word = data.get('word')
    wordLang = data.get('wordLang', 'en')  # لغة الكلمة (يتم تحديدها من Flutter)

    if not word:
        print(word)
        return jsonify({'error': 'Please provide a word'}), 400

    definitions = []

    # لو الكلمة عربية، نجيب تعريف من ويكيبيديا
    if wordLang == 'ar':
        print(wordLang)
        definition = get_short_arabic_definition(word)
        definitions = [definition]

    # لو الكلمة إنجليزية، نستخدم WordNet
    elif wordLang == 'en':
        synsets = wordnet.synsets(word)
        if not synsets:
            return jsonify({'error': f"No definitions found for '{word}'"}), 404
        definitions = [synset.definition() for synset in synsets]

    return jsonify({
        'word': word,
        'definitions': definitions
    })

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5004, debug=True)
