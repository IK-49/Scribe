from flask import Flask, jsonify
from transformers import GPT2LMHeadModel, GPT2Tokenizer
import random
import json
import os
from datetime import datetime

app = Flask(__name__)

model_name = 'gpt2'
model = GPT2LMHeadModel.from_pretrained(model_name)
tokenizer = GPT2Tokenizer.from_pretrained(model_name)

PROMPT_FILE = 'test123132.json'

def generate_prompt(seed_text, max_length=50):
    input_ids = tokenizer.encode(seed_text, return_tensors='pt')
    output = model.generate(
        input_ids,
        max_length=max_length,
        num_return_sequences=1,
        no_repeat_ngram_size=2,
        early_stopping=True
    )

    generated_text = tokenizer.decode(output[0], skip_special_tokens=True)
    print(generated_text)
    response = generated_text[len(seed_text):].strip()
    return response

def get_current_prompt():
    if os.path.exists(PROMPT_FILE):
        print("file exists")
        with open(PROMPT_FILE, 'r') as file:
            data = json.load(file)
            stored_date = datetime.strptime(data['date'], '%Y-%m-%d').date()
            if stored_date == datetime.now().date():
                return data['prompt']
    
    seed_texts = [
        "I like asking questions about books. an example question is:  "
    ]
    seed_text = random.choice(seed_texts)
    new_prompt = generate_prompt(seed_text)
    
    with open(PROMPT_FILE, 'w') as file:
        json.dump({'date': datetime.now().strftime('%Y-%m-%d'), 'prompt': new_prompt}, file)
    
    return new_prompt

@app.route('/pick', methods=['GET'])
def pick():
    todays_pick = get_current_prompt()
    return jsonify({"todaysPick": todays_pick})

if __name__ == '__main__':
    app.run(debug=True)
