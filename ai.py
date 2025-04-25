from flask import Flask, request, jsonify

app = Flask(__name__)

# Define command keywords for each language
TARGET_WORDS = {
    "en-US": ["define", "translate", "summarize", "pause", "resume", "stop", "bookmark", "increase speed", "slow down"],
    "ar-AR": ["عرف", "ترجم", "لخص", "توقف", "استأنف", "إيقاف", "احفظ علامة", "زِد السرعة", "أبطئ"]
}

# Predefined responses
RESPONSES = {
    "en-US": {
        "pause": "Pausing the playback",
        "define" :"let's define",
        "resume": "Resuming the playback",
        "translate": "Starting translation",
        "summarize": "Summarizing the content",
        "stop": "Stopping the playback",
        "increase speed": "Increasing playback speed",
        "slow down": "Slowing down playback speed.",
        "bookmark": "Bookmark added"
    },
    "ar-AR": {
        "توقف": "تم إيقاف التشغيل",
        "استأنف": "تم استئناف التشغيل",
        "ترجم": "جارٍ بدء الترجمة",
        "لخص": "جارٍ تلخيص المحتوى",
        "إيقاف": "تم إيقاف التشغيل",
        "زِد السرعة": "جارٍ زيادة سرعة التشغيل.",
        "أبطئ": "جارٍ تخفيض سرعة التشغيل",
        "احفظ علامة": "تمت إضافة علامة مرجعية"
    }
}

# Recognize command and extract argument
def recognize_command(text, lang):
    commands = TARGET_WORDS.get(lang, [])
    for command in commands:
        if text.lower().startswith(command.lower()):
            argument = text[len(command):].strip()
            return {
                "command": command,
                "argument": argument if argument else None
            }
    return None

# API route
@app.route('/process_speech', methods=['POST'])
def process_speech():
    data = request.get_json()
    user_speech = data.get('speech')
    lang = data.get('lang')

    command_data = recognize_command(user_speech, lang)

    command = command_data["command"]
    argument = command_data["argument"]

    aiResponse = RESPONSES.get(lang, {}).get(command)

    return jsonify({
        "command": command,
        "argument": argument,
        "aiResponse":  aiResponse
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
