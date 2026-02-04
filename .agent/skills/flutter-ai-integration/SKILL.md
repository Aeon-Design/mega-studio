---
name: flutter-ai-integration
description: Integration of On-Device AI models (Gemini Nano, LiteRT) and cloud AI APIs into Flutter apps.
---

# 🧠 Flutter AI Integration

## 📱 On-Device AI (Edge)

### Gemini Nano
Google's most efficient model for on-device tasks.
- **Use Case:** Smart reply, summarization, proofreading *without internet*.
- **Package:** `google_generative_ai` (check for edge support availability).

### LiteRT (formerly TensorFlow Lite)
For running custom ML models (Image Class, Object Detect).
- **Package:** `tflite_flutter`
- **Workflow:**
    1.  Train model (Python/TFLite).
    2.  Quantize for Mobile (int8).
    3.  Load `.tflite` asset in Flutter.
    4.  Run inference in an Isolate to avoid UI lag.

## ☁️ Cloud AI (GenAI SDK)
- **Gemini API:** Use `google_generative_ai` for multimodal tasks (Text+Image -> Text).
- **Design:** Always handle latency. Show "Thinking..." animations. Stream responses for better UX.

## 🛡️ Privacy First
- Prefer **On-Device** processing for sensitive user data (messages, health).
- Only use Cloud AI for non-sensitive, heavy compute tasks.
