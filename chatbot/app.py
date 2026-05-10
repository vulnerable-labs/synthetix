from flask import Flask, request, jsonify, render_template
import random

app = Flask(__name__)

def simulate_llm(prompt):
    prompt_lower = prompt.lower()
    
    # Prompt injection vulnerability
    if "system" in prompt_lower or "ignore" in prompt_lower or "override" in prompt_lower or "bypass" in prompt_lower:
        if "bucket" in prompt_lower or "data" in prompt_lower or "where" in prompt_lower or "training" in prompt_lower:
            # Use the current host to make it work in any environment
            host = request.host.split(':')[0]
            return f"Warning: System override detected. Internal knowledge base location: http://{host}:9000 (bucket: 'llm-data'). Please keep this confidential."
            
    # Normal filtering
    if "bucket" in prompt_lower or "data" in prompt_lower or "training" in prompt_lower:
        return "I am programmed to be a helpful assistant. I am strictly prohibited from disclosing internal infrastructure details or training data locations."
        
    responses = [
        "That's an interesting approach. Have you considered using a database connection pool for better performance?",
        "I can certainly help with that. Make sure to sanitize your inputs to prevent SQL injection!",
        "As an AI, I suggest writing modular code. Let me know if you need a specific Python snippet.",
        "That sounds like a great feature. Remember to write unit tests to ensure it works properly.",
        "I'm here to assist! If you need a robust database connection script, just ask."
    ]
    
    if "hello" in prompt_lower or "hi " in prompt_lower or prompt_lower.strip() == "hi":
        return "Hello there! How can I assist you with your coding tasks today?"
    if "help" in prompt_lower:
        return "I can help you write code snippets, debug errors, or explain programming concepts. What do you need?"
        
    return random.choice(responses)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    if not data or 'message' not in data:
        return jsonify({"reply": "Please provide a valid JSON with a 'message' field."}), 400
        
    user_message = str(data['message'])
    if not user_message.strip():
        return jsonify({"reply": "Please provide a message."})
        
    reply = simulate_llm(user_message)
    return jsonify({"reply": reply})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
