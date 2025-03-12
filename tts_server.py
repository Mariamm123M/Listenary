from flask import Flask, request, jsonify, send_file
import edge_tts
import asyncio

app = Flask(__name__)

@app.route('/tts', methods=['POST'])
async def tts():
    data = request.get_json()
    text = data.get('text')
    gender = data.get('gender', 'male')  # Default to male if not specified

    if text:
        audio_file = "speech.mp3"

        # Choose voice based on gender
        if gender.lower() == 'male':
            voice = "en-US-GuyNeural"  # Example male voice
        else:
            voice = "en-US-JennyNeural"  # Example female voice

        tts = edge_tts.Communicate(text, voice=voice)
        await tts.save(audio_file)

        # Return the audio file to the client
        return send_file(audio_file, as_attachment=True, download_name="speech.mp3")
    else:
        return jsonify({'error': 'No text provided'}), 400

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5002, debug=True)