from flask import Flask, jsonify
import random
import json
import os
from datetime import datetime

app = Flask(__name__)

PROMPT_FILE = 'prompts.json'


prompts = [
    "What book are you currently reading?",
    "What's your all-time favorite book and why?",
    "Do you prefer fiction or non-fiction?",
    "What book would you recommend for a long weekend?",
    "Who is your favorite author and what makes their books special?",
    "What's the most recent book you've read that you would recommend?",
    "Are there any books you're looking forward to reading this year?",
    "What genre do you find yourself gravitating towards the most?",
    "What's a book you think everyone should read at least once?",
    "What book has had the most impact on your life?"
]

def get_current_prompt():
    if os.path.exists(PROMPT_FILE):
        with open(PROMPT_FILE, 'r') as file:
            data = json.load(file)
            stored_date = datetime.strptime(data['date'], '%Y-%m-%d').date()
            if stored_date == datetime.now().date():
                return data['prompt']
    

    selected_prompt = random.choice(prompts)
    
    with open(PROMPT_FILE, 'w') as file:
        json.dump({'date': datetime.now().strftime('%Y-%m-%d'), 'prompt': selected_prompt}, file)
    
    return selected_prompt

@app.route('/pick', methods=['GET'])
def pick():
    todays_pick = get_current_prompt()
    return jsonify({"todaysPick": todays_pick})

if __name__ == '__main__':
    app.run(debug=True)
