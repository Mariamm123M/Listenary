from flask import Flask, request, jsonify, send_file
from langdetect import detect
import edge_tts
import asyncio

app = Flask(__name__)

@app.route('/tts', methods=['POST'])
def tts():
    data = request.get_json()
    text = data.get('text')
    gender = data.get('gender', 'male')

    if text:
        audio_file = "speech.mp3"

        lang = detect(text)

        if lang == 'ar':
            voice = "ar-EG-ShakirNeural" if gender.lower() == 'male' else "ar-EG-SalmaNeural"
        else:
            voice = "en-US-GuyNeural" if gender.lower() == 'male' else "en-US-JennyNeural"

        async def generate_tts():
            tts = edge_tts.Communicate(text, voice=voice)
            await tts.save(audio_file)

        asyncio.run(generate_tts())

        return send_file(audio_file, as_attachment=True, download_name="speech.mp3")
    else:
        return jsonify({'error': 'No text provided'}), 400

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5002, debug=True)
