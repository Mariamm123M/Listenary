from flask import Flask, request, jsonify
from nltk.corpus import wordnet
from googletrans import Translator
import nltk

nltk.download('wordnet')
nltk.download('omw-1.4')

app = Flask(__name__)
translator = Translator()

@app.route('/define', methods=['POST'])
def define_word():  # ← شيلنا async
    data = request.get_json()
    word = data.get('word')
    lang = data.get('lang', 'en')

    if not word:
        return jsonify({'error': 'Please provide a word'}), 400

    synsets = wordnet.synsets(word)
    if not synsets:
        return jsonify({'error': f"No definitions found for '{word}'"}), 404

    definitions = [synset.definition() for synset in synsets]
    print("definitions from python", definitions)

    # الترجمة لو اللغة مش انجليزي
    if lang != 'en':
        translated_defs = []
        for d in definitions:
            translated = translator.translate(d, dest=lang)  # ← بدون await
            translated_defs.append(translated.text)
        definitions = translated_defs

    return jsonify({
        'word': word,
        'language': lang,
        'definitions': definitions
    })

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5004, debug=True)
