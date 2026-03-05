<div align="center">

# 🧠 NeuralVoid

### Offline AI Learning Companion for Class 10 Students

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![AI Powered](https://img.shields.io/badge/AI-Gemma%203%201B-8B5CF6?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev/gemma)
[![License](https://img.shields.io/badge/License-MIT-22C55E?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-black?style=for-the-badge)](https://flutter.dev)

*Bringing intelligent, private, and fully offline AI tutoring to every student — no internet required.*

</div>

---

## 📖 Overview

**NeuralVoid** is a cross-platform Flutter application that delivers a powerful AI-driven learning experience entirely on-device. Built for Class 10 students in India, it leverages a locally-running **Gemma 3 1B** language model paired with a custom **RAG (Retrieval-Augmented Generation)** pipeline trained on NCERT educational content — giving students accurate, curriculum-aligned answers without ever needing an internet connection.

No subscriptions. No data collection. No connectivity dependency. Just intelligence, available anywhere.

---

## ✨ Features

- **🔒 100% Offline** — All AI inference runs locally on-device using Gemma 3 1B. Student data never leaves the device.
- **📚 NCERT-Aligned RAG** — Custom retrieval system built on NCERT Class 10 textbook content, powered by FAISS vector search and SentenceTransformers embeddings.
- **🇮🇳 Hindi Language Support** — Integrated Google MLKit translation pipeline for seamless Hindi ↔ English interaction.
- **⚡ Fast Semantic Search** — FAISS-backed vector similarity search retrieves the most relevant curriculum chunks before generating answers.
- **🎯 Curriculum-Focused** — Constrained to Class 10 subjects, ensuring responses stay on-topic and educationally accurate.
- **📱 Cross-Platform** — Runs natively on Android and iOS from a single Flutter codebase.

---

## 🏗️ Architecture

```
NeuralVoid
├── Flutter UI Layer          # Dart/Flutter frontend (Material 3)
│   ├── Chat Interface
│   ├── Subject Navigator
│   └── Settings & Preferences
│
├── AI Inference Layer        # On-device LLM execution
│   └── Gemma 3 1B            # Quantized model via local inference runtime
│
├── RAG Pipeline              # Retrieval-Augmented Generation
│   ├── FAISS Vector Store    # Fast approximate nearest-neighbor search
│   ├── SentenceTransformers  # Semantic embedding of queries & chunks
│   └── NCERT Corpus          # Preprocessed Class 10 textbook content
│
└── Translation Layer         # Multilingual support
    └── Google MLKit          # On-device Hindi ↔ English translation
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| Mobile Framework | Flutter 3.x + Dart |
| On-Device LLM | Gemma 3 1B (quantized) |
| Vector Search | FAISS |
| Embeddings | SentenceTransformers |
| Translation | Google MLKit |
| ML Infrastructure | Python (FastAPI backend / preprocessing) |
| Desktop Support | Linux, macOS, Windows (Flutter desktop) |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / Xcode (for device deployment)
- Python `>=3.9` (for RAG preprocessing pipeline)

### Installation

```bash
# Clone the repository
git clone https://github.com/SuyashVJain/NeuralVoid.git
cd NeuralVoid

# Install Flutter dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

### Model Setup

The Gemma 3 1B model weights are not included in the repository due to size constraints. To set up the model:

1. Download the quantized Gemma 3 1B weights from [Google's model page](https://ai.google.dev/gemma)
2. Place the model file in the designated assets directory (see `lib/config/` for path configuration)
3. Rebuild the app — inference will run fully on-device

### RAG Pipeline (Python)

```bash
# Navigate to the RAG preprocessing scripts
cd rag/

# Install Python dependencies
pip install -r requirements.txt

# Run the NCERT corpus embedding pipeline
python embed_corpus.py

# Start the local FastAPI inference server (development only)
python server.py
```

---

## 📁 Project Structure

```
NeuralVoid/
├── lib/                    # Dart source code
│   ├── main.dart           # App entry point
│   ├── screens/            # UI screens
│   ├── widgets/            # Reusable components
│   ├── services/           # AI, RAG, and translation services
│   └── config/             # App configuration & constants
├── android/                # Android platform code
├── ios/                    # iOS platform code
├── linux/                  # Linux desktop support
├── macos/                  # macOS desktop support
├── windows/                # Windows desktop support
├── web/                    # Web platform support
├── test/                   # Unit and widget tests
├── pubspec.yaml            # Flutter dependencies
└── README.md
```

---

## 🎯 Roadmap

- [ ] Subject-specific chat modes (Math, Science, Social Studies, English)
- [ ] Diagram and formula rendering with LaTeX support
- [ ] Spaced repetition flashcard system
- [ ] Progress tracking and weak-topic identification
- [ ] Voice input/output via on-device STT/TTS
- [ ] Offline model download manager in-app
- [ ] Class 9 curriculum expansion

---

## 🌍 Impact

NeuralVoid is built with a clear social mission: **democratizing AI-powered education** for the 250+ million students in India who lack reliable internet access. By running entirely offline on commodity Android devices, NeuralVoid can reach students in rural and semi-urban areas — bringing curriculum-aligned AI tutoring to those who need it most.

---

## 🤝 Contributing

Contributions are welcome! If you'd like to improve NeuralVoid:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add your feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

For major changes, please open an issue first to discuss what you'd like to change.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Suyash V. Jain**
- GitHub: [@SuyashVJain](https://github.com/SuyashVJain)

---

<div align="center">
  <sub>Built with ❤️ for students who deserve better tools.</sub>
</div>
