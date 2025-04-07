from flask import Flask, request, jsonify

app = Flask(__name__)

# Define target words in multiple languages
TARGET_WORDS = {
    "en-US": {"pause", "resume", "translate", "summarize", "stop", "increase speed", "slow down", "bookmark", "go to page X"},
    "ar-AR": {"توقف", "استأنف", "ترجم", "لخص", "إيقاف", "زِد السرعة", "أبطئ", "احفظ علامة", "انتقل إلى الصفحة [رقم]"}
}

# Function to recognize commands
def recognize_command(text, lang):
    if lang in TARGET_WORDS:
        for word in TARGET_WORDS[lang]:
            if word in text:
                print(f"Detected command: {word}")
                return word
    return None

# Function to generate a response based on the detected command
def generate_response(command, lang):
    if not command:
        return "No command detected"

    # Define responses for each command
    responses = {
        "en-US": {
            "pause": "Pausing the playback",
            "resume": "Resuming the playback",
            "translate": "Starting translation",
            "summarize": "Summarizing the content",
            "stop": "Stopping the playback",
            "increase speed": "Increasing playback speed",
            "slow down": "Slowing down playback speed.",
            "bookmark": "Bookmark added",
            "go to page X": "Navigating to the specified page"
        },
        "ar-AR": {
            "توقف": "تم إيقاف التشغيل",
            "استأنف": "تم استئناف التشغيل",
            "ترجم": "جارٍ بدء الترجمة",
            "لخص": "جارٍ تلخيص المحتوى",
            "إيقاف": "تم إيقاف التشغيل",
            "زِد السرعة": "جارٍ زيادة سرعة التشغيل.",
            "أبطئ": "جارٍ تخفيض سرعة التشغيل",
            "احفظ علامة": "تمت إضافة علامة مرجعية",
            "انتقل إلى الصفحة [رقم]": "جارٍ الانتقال إلى الصفحة المحددة"
        }
    }

    # Return the response based on the detected command and language
    return responses.get(lang, {}).get(command, "Unknown command")

# Route to process speech
@app.route('/process_speech', methods=['POST'])
def process_speech():
    data = request.get_json()
    user_speech = data.get('speech')
    lang = data.get('lang')
    
    # Recognize command
    command = recognize_command(user_speech, lang)

    # Generate response
    response = generate_response(command, lang)

    return jsonify({
        "command": command if command else "No command detected",
        "response": response
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')