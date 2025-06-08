from flask import Flask, request, jsonify
import re
import spacy
from collections import Counter, defaultdict
from sumy.parsers.plaintext import PlaintextParser
from sumy.nlp.tokenizers import Tokenizer
from sumy.summarizers.lsa import LsaSummarizer
from typing import Tuple, Dict, List  


app = Flask(__name__)


nlp = spacy.load("en_core_web_md")
nlp.add_pipe('sentencizer')

summarizer = LsaSummarizer()
summarizer.stop_words = [' ']  

def standardize_character_name(name: str) -> str:
    """توحيد شكل أسماء الشخصيات"""
    name = re.sub(r'(Mr\.|Mrs\.|Ms\.|Dr\.|Prof\.)', '', name)
    parts = [part for part in name.split() if part]
    return ' '.join(parts[:2]).title() if len(parts) >= 2 else name.title()

def extract_character_appearances(text: str, max_sentences: int = 5) -> Tuple[Dict, Dict]:
    """استخراج الشخصيات والجمل التي ظهروا فيها"""
    doc = nlp(text)
    characters = Counter()
    character_appearances = defaultdict(list)
    
    for sent in doc.sents:
        for ent in sent.ents:
            if ent.label_ == "PERSON":
                standardized_name = standardize_character_name(ent.text)
                characters[standardized_name] += 1
                if len(character_appearances[standardized_name]) < max_sentences:
                    clean_sent = re.sub(r'\s+', ' ', sent.text).strip()
                    character_appearances[standardized_name].append(clean_sent)
    
    return characters, character_appearances

def infer_character_role(name: str, count: int, appearances: List[str], total_mentions: int) -> str:
    """تحديد دور الشخصية بناء على السياق"""
    context = ' '.join(appearances[:3]).lower()
    name_lower = name.lower()
    
    if any(term in context for term in ['protagonist', 'main character', 'hero', 'heroine']):
        return 'main'
    if any(term in context for term in ['villain', 'antagonist']):
        return 'antagonist'
    if any(word.lower() in ['i', 'me', 'my', 'mine'] for word in name.split()):
        return 'main'
    if any(title in name_lower for title in ['king', 'queen', 'president', 'leader']):
        return 'important'
    if count > total_mentions * 0.1:
        return 'main'
    elif count > total_mentions * 0.05:
        return 'supporting'
    
    return 'minor'

def summarize_text(text: str, sentence_count: int = 2) -> str:
    """إنشاء ملخص للسياق الخاص بالشخصية"""
    try:
        parser = PlaintextParser.from_string(text, Tokenizer("english"))
        summary = summarizer(parser.document, sentence_count)
        return ' '.join(str(sentence) for sentence in summary)
    except:
        # Fallback إذا فشل الاختصار
        sentences = [s.strip() for s in re.split(r'[.!?]', text) if s.strip()]
        return ' '.join(sentences[:2])

@app.route('/extract_characters', methods=['POST'])
def api_extract_characters():
    """نقطة النهاية لاستخراج الشخصيات"""
    data = request.get_json()
    
    if not data or 'text' not in data:
        return jsonify({'error': 'No text provided'}), 400
    
    text = data['text']
    
    try:
        # استخراج الشخصيات من النص
        characters, appearances = extract_character_appearances(text)
        total_mentions = sum(characters.values())
        
        # تحضير النتيجة
        result = []
        for name, count in characters.most_common(5):  # أهم 5 شخصيات
            role = infer_character_role(name, count, appearances[name], total_mentions)
            summary = summarize_text(' '.join(appearances[name][:3]))
            
            result.append({
                'name': name,
                'mentions': count,
                'role': role,
                'summary': summary,
                'appearances': appearances[name][:3]  # أول 3 جمل ظهر فيها
            })
        
        return jsonify({
            'status': 'success',
            'count': len(result),
            'characters': result
        })
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/test', methods=['GET'])
def test_endpoint():
    """نقطة نهاية للاختبار"""
    return jsonify({
        'status': 'running',
        'message': 'Character extraction service is working'
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)