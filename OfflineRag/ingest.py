import json
import os
import faiss
import numpy as np
from sentence_transformers import SentenceTransformer
from pypdf import PdfReader

# 1. Initialize Model
print("🚀 Initializing embedding model...")
model = SentenceTransformer("all-MiniLM-L6-v2")

chunks = []
pdf_root = "data"

if not os.path.exists(pdf_root):
    print(f"❌ Error: Folder '{pdf_root}' not found!")
    exit()

# 2. Scan and Extract
print("Scanning data folder...")
for subject in os.listdir(pdf_root):
    subject_path = os.path.join(pdf_root, subject)

    if os.path.isdir(subject_path):
        print(f"📂 Processing subject: {subject}")

        for file in os.listdir(subject_path):
            if file.endswith(".pdf"):
                pdf_path = os.path.join(subject_path, file)
                print(f"   📄 Reading: {file}")

                try:
                    reader = PdfReader(pdf_path)
                    for i, page in enumerate(reader.pages):
                        text = page.extract_text()
                        if text and text.strip():
                            # HACKATHON OPTIMIZATION: 
                            # Instead of one huge page, split into smaller paragraphs
                            paragraphs = text.split('\n\n')
                            for p in paragraphs:
                                clean_p = p.strip()
                                if len(clean_p) > 200: # Ignore tiny noise
                                    # Add subject tag so the AI has context
                                    chunks.append(f"[{subject.upper()}] {clean_p}")
                except Exception as e:
                    print(f"   ⚠️ Skipped {file}: {e}")

if not chunks:
    print("❌ No text found. Check your PDF content!")
    exit()

print(f"✅ Created {len(chunks)} optimized chunks.")

# 3. Save Text Chunks
with open("chunks.json", "w", encoding="utf-8") as f:
    json.dump(chunks, f, ensure_ascii=False, indent=2)

# 4. Create and Save FAISS Index
print("🧠 Generating embeddings (this may take a minute)...")
embeddings = model.encode(chunks, show_progress_bar=True)
embeddings = np.array(embeddings).astype("float32")

dimension = embeddings.shape[1]
index = faiss.IndexFlatL2(dimension)
index.add(embeddings)

# Save as ncert.index to match your main.py
faiss.write_index(index, "ncert.index")

print("\n✨ SUCCESS! Index created with Math, SST, Science, and English.")
print("Now restart your uvicorn server to load the new data.")