from flask import Flask, request, jsonify
import requests
from bs4 import BeautifulSoup
import os
import pdfplumber
from pdf2image import convert_from_path
import pytesseract

app = Flask(__name__)

def extract_clean_text(url):
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36"
    }

    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        response.encoding = response.apparent_encoding

        if not response.encoding or response.encoding.lower() not in ["utf-8", "utf8"]:
            response.encoding = "utf-8"

        soup = BeautifulSoup(response.text, "html.parser")

        for tag in soup(["script", "style", "header", "footer", "nav", "aside"]):
            tag.decompose()

        main_content = soup.find("article") or soup.find("main") or soup.body

        paragraphs = [
            p.get_text().strip() for p in main_content.find_all(["p", "h1", "h2", "h3", "h4", "h5", "h6"])
            if p.get_text().strip()
        ]

        formatted_text = "\n\n".join(paragraphs)

        return formatted_text
    else:
        return f"Failed to retrieve the page. Status code: {response.status_code}"

def download_pdf(url, save_path="temp.pdf"):
    response = requests.get(url, stream=True)
    if response.status_code == 200:
        with open(save_path, "wb") as pdf_file:
            for chunk in response.iter_content(1024):
                pdf_file.write(chunk)
        return save_path
    else:
        raise Exception(f"Failed to download PDF. Status code: {response.status_code}")

def extract_clean_text_from_pdf(pdf_path, use_ocr=False):
    text = []

    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            page_text = page.extract_text()

            if page_text and not use_ocr:
                cleaned_text = "\n\n".join(
                    line.strip() for line in page_text.split("\n") if line.strip()
                )
                text.append(cleaned_text)
            elif use_ocr:
                images = convert_from_path(pdf_path)
                for img in images:
                    ocr_text = pytesseract.image_to_string(img, lang="ara+eng")
                    text.append(ocr_text.strip())

    return "\n\n".join(text) if text else "No readable text found in the PDF."

@app.route('/process-link', methods=['POST'])
def process_link():
    data = request.get_json()
    link = data.get('link')

    if not link:
        return jsonify({'error': 'No link provided'}), 400

    try:
        if link.lower().endswith('.pdf'):
            # Handle PDF
            temp_pdf = download_pdf(link)
            use_ocr = data.get('ocr', False)
            result = extract_clean_text_from_pdf(temp_pdf, use_ocr=use_ocr)
            os.remove(temp_pdf)
        else:
            # Handle HTML
            result = extract_clean_text(link)

        return jsonify({'text': result})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
