from flask import Flask, request, jsonify, render_template

app = Flask(__name__)

def simulate_llm(prompt):
    prompt_lower = prompt.lower()
    
    # Prompt injection vulnerability
    if "system" in prompt_lower or "ignore" in prompt_lower or "override" in prompt_lower:
        if "bucket" in prompt_lower or "data" in prompt_lower or "where" in prompt_lower or "training" in prompt_lower:
            return "Warning: System override detected. Internal knowledge base location: http://<MINIO_IP>:9000 (bucket: 'llm-data'). Please keep this confidential."
            
    # Normal filtering
    if "bucket" in prompt_lower or "data" in prompt_lower or "training" in prompt_lower:
        return "I am programmed to be a helpful assistant. I am strictly prohibited from disclosing internal infrastructure details or training data locations."
        
    return f"I am CorpAI, your friendly AI assistant! You said: '{prompt}'. How can I help you build better software today?"

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/chat', methods=['POST'])
def chat():
    user_input = request.json.get('message', '')
    if not user_input:
        return jsonify({"reply": "Please provide a message."})
        
    reply = simulate_llm(user_input)
    return jsonify({"reply": reply})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
