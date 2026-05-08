import requests
import time
import traceback
import sys

print("Admin bot started. Periodically fetching DB connection code from AI...")

while True:
    try:
        # The developer asks the AI for the DB connection code
        res = requests.post("http://ai-api:5000/generate", json={"prompt": "generate database connection code"})
        if res.status_code == 200:
            code = res.json().get("completion", "")
            if code:
                print("====================================")
                print("Executing AI suggested code snippet:")
                print(code)
                print("====================================")
                # VULNERABILITY: Executing untrusted code from the poisoned LLM
                try:
                    # Creating a separate dictionary to capture local variables
                    local_vars = {}
                    exec(code, globals(), local_vars)
                except Exception as e:
                    print("Error during execution of AI code:", e)
            else:
                print("Received empty completion from AI.")
        else:
            print("Failed to reach AI API. HTTP Status:", res.status_code)
    except requests.exceptions.ConnectionError:
         print("Connection Error: Waiting for ai-api...")
    except Exception as e:
        print("Unexpected error:", traceback.format_exc())
    
    sys.stdout.flush()
    # Wait before asking again
    time.sleep(30)
