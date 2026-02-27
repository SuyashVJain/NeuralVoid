import os
import json
import numpy as np
import faiss
import ollama

# MUST BE AT THE TOP FOR OFFLINE SUCCESS
os.environ['TRANSFORMERS_OFFLINE'] = '1'
os.environ['HF_DATASETS_OFFLINE'] = '1'

from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from sentence_transformers import SentenceTransformer

app = FastAPI()

from fastapi.responses import HTMLResponse

@app.get("/", response_class=HTMLResponse)
async def read_root():
    return """
    <html>
        <head><title>NCERT Offline AI</title></head>
        <body style="font-family: Arial; text-align: center; margin-top: 50px;">
            <h1>🚀 NCERT Offline Tutor is Live</h1>
            <p>The backend is running. Use the <b>/ask</b> endpoint to query the AI.</p>
            <p>Check the API docs here: <a href="/docs">/docs</a></p>
        </body>
    </html>
    """

# --- 1. SYSTEM PROMPT ---
SYSTEM_PROMPT = """
You are an elite NCERT Tutor. Your goal is to help students excel in exams.
- Use ONLY the provided context.
- If the answer isn't there, say: "I'm sorry, that isn't in my current NCERT database."
- Keep answers structured: Use bullet points for steps and bold text for key terms.
"""

# --- 2. LOAD MODELS & DATA ---
# Corrected: Initializing the actual model correctly
print("🚀 Loading Models Offline...")
#embed_model = SentenceTransformer("all-MiniLM-L6-v2", local_files_only=True)
embed_model = SentenceTransformer("all-MiniLM-L6-v2", local_files_only=True)
index = faiss.read_index("ncert.index")
with open("chunks.json", "r", encoding="utf-8") as f:
    chunks = json.load(f)

class Question(BaseModel):
    question: str

# --- 3. RETRIEVAL LOGIC ---
def retrieve_context(query, top_k=3):
    # Fixed: Removed brackets [] from query to avoid TypeError
    query_embedding = embed_model.encode(query)
    
    # Reshape for FAISS search
    vector = np.array([query_embedding]).astype('float32')
    D, I = index.search(vector, top_k)
    
    retrieved = [chunks[idx] for idx in I[0] if idx != -1 and idx < len(chunks)]
    return "\n\n".join(retrieved)[:1500]

# --- 4. THE ASK ENDPOINT ---
@app.post("/ask")
async def ask_question(q: Question):
    context = retrieve_context(q.question)
    full_prompt = f"{SYSTEM_PROMPT}\n\nContext:\n{context}\n\nQuestion: {q.question}"

    async def stream_generator():
        try:
            stream = ollama.generate(
                model='phi3:mini', 
                prompt=full_prompt, 
                stream=True,
                options={
                    'num_ctx': 4096, 
                    'temperature': 0.2,
                    'stop': ["Question:", "Context:"]
                } 
            )
            for chunk in stream:
                yield chunk['response']
        except Exception as e:
            yield f"Error: {str(e)}"

    return StreamingResponse(stream_generator(), media_type="text/plain")

# --- 5. AUTO-RUN CODE ---
if __name__ == "__main__":
    import uvicorn
    import webbrowser
    from threading import Timer

    def open_browser():
        webbrowser.open("http://127.0.0.1:8000")

    print("🚀 Starting Server and opening browser...")
    Timer(1.5, open_browser).start()
    uvicorn.run(app, host="0.0.0.0", port=8000)