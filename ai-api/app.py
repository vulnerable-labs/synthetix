from flask import Flask, request, jsonify
import json
import threading
import time
import requests

app = Flask(__name__)
MODEL_FILE = 'model.json'

def finetune_loop():
    while True:
        try:
            # Download the training data from the internal MinIO bucket
            # It's misconfigured to allow public anonymous read/write!
            res = requests.get('http://minio:9000/llm-data/training_data.jsonl')
            if res.status_code == 200:
                model = {}
                for line in res.text.strip().split('\n'):
                    if line:
                        try:
                            data = json.loads(line)
                            # The model essentially learns the last completion for a given prompt
                            model[data.get('prompt', '').lower()] = data.get('completion', '')
                        except:
                            pass
                
                # Save the updated model
                with open(MODEL_FILE, 'w') as f:
                    json.dump(model, f)
                print("Model fine-tuned successfully.")
            else:
                print(f"Failed to fetch training data: HTTP {res.status_code}")
        except Exception as e:
            print("Finetune error:", e)
            
        # Run the finetuning job every 30 seconds
        time.sleep(30)

@app.route('/generate', methods=['POST'])
def generate():
    data = request.json or {}
    prompt = str(data.get('prompt', '')).lower()
    try:
        with open(MODEL_FILE, 'r') as f:
            model = json.load(f)
    except Exception as e:
        model = {}
        print("Error loading model:", e)
    
    completion = model.get(prompt, "print('No completion found for your prompt.')")
    return jsonify({"completion": completion})

if __name__ == '__main__':
    # Start the automated fine-tuning in the background
    threading.Thread(target=finetune_loop, daemon=True).start()
    
    # Give the finetuner a few seconds to run initially
    time.sleep(2)
    app.run(host='0.0.0.0', port=5000)
