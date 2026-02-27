import requests
import time

# List of NCERT Class 10 Questions
ncert_questions = [
    # --- SUBJECT: SCIENCE ---
    {"subject": "Science", "q": "Explain the process of double circulation in the human heart."},
    {"subject": "Science", "q": "What is the difference between an alloy and a pure metal?"},
    
    # --- SUBJECT: MATH ---
    {"subject": "Math", "q": "What are the conditions for a pair of linear equations to have infinitely many solutions?"},
    {"subject": "Math", "q": "State the Fundamental Theorem of Arithmetic."},
    
    # --- SUBJECT: SST ---
    {"subject": "SST", "q": "What were the main causes of the Non-Cooperation Movement in India?"},
    {"subject": "SST", "q": "How does a federal system of government work?"},

    # --- SUBJECT: ENGLISH ---
    {"subject": "English", "q": "How does the poem 'Fire and Ice' represent the end of the world?"},
    {"subject": "English", "q": "Why did Lencho write a letter to God?"},
    # --- TRICK QUESTIONS (OUT OF SYLLABUS) ---
    {"subject": "OFF-TOPIC", "q": "Who was Tom in Tom and Jerry?"},
    {"subject": "OFF-TOPIC", "q": "How do I make a chocolate cake at home?"},
    {"subject": "OFF-TOPIC", "q": "Who is the current President of the United States?"},
    {"subject": "OFF-TOPIC", "q": "What is the best way to win a football match?"}
]

API_URL = "http://127.0.0.1:8000/ask"

def run_test():
    print("🚀 Starting Automated NCERT Stress Test...\n")
    
    for item in ncert_questions:
        print(f"📘 SUBJECT: {item['subject']}")
        print(f"❓ QUESTION: {item['q']}")
        
        start_time = time.time()
        
        try:
            # Send request to your FastAPI server
            # Since your /ask uses StreamingResponse, we handle it as a stream
            response = requests.post(API_URL, json={"question": item['q']}, stream=True)
            
            print("🤖 ANSWER: ", end="", flush=True)
            full_answer = ""
            
            for chunk in response.iter_content(decode_unicode=True):
                if chunk:
                    print(chunk, end="", flush=True)
                    full_answer += chunk
            
            duration = round(time.time() - start_time, 2)
            print(f"\n\n⏱️ Response Time: {duration}s")
            print("-" * 50)
            
            # Wait 2 seconds before the next question to let the CPU cool down
            time.sleep(2)

        except Exception as e:
            print(f"❌ Error: {e}")

if __name__ == "__main__":
    run_test()