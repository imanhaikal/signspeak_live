# TASKS.md: Project Roadmap

**Current Status:** 🚧 Phase 2: The Eye (Vision UI & Overlay Implemented)
**Hackathon Deadline:** 28th February 2026

---

## 📅 Phase 1: Foundation & Setup (Days 1-3)
*Goal: Get the "Hello World" of all Google technologies working.*

- [x] **Repository Setup**
    - [x] Initialize Git repository.
    - [x] Create `README.md`, `REQUIREMENTS.md`, `DESIGN.md`.
    - [x] Set up `.gitignore` for Flutter.
- [x] **Flutter Environment**
    - [x] `flutter create signspeak_live`
    - [x] Set up Android SDK / iOS Podfile.
    - [x] Install essential packages:
        - [x] `camera`
        - [x] `google_generative_ai` (Gemini SDK)
        - [x] `google_mlkit_pose_detection` (MediaPipe wrapper)
        - [x] `speech_to_text`
        - [x] `firebase_core` & `cloud_firestore`
- [x] **Firebase Initialization**
    - [x] Create Project in Firebase Console ("SignSpeak-2026").
    - [x] Register Android/iOS apps (download `google-services.json`).
    - [x] Enable Firestore Database (Test Mode for now).
- [x] **Gemini API Setup**
    - [x] Get API Key from Google AI Studio.
    - [x] Store API Key securely (using `flutter_dotenv` or `--dart-define`).

---

## 👁️ Phase 2: "The Eye" - Vision Pipeline (Days 4-10)
*Goal: Accurately track hands and visualize the skeleton.*

- [x] **Camera Preview**
    - [x] Implement `CameraViewport` widget structure (currently using placeholder).
    - [x] Handle camera permissions on Android/iOS manifest.
    - [x] Implement "Flip Camera" button logic.
- [x] **MediaPipe Integration**
    - [x] Initialize `PoseDetector` / `HandPoseDetector`.
    - [x] Create a Stream that processes camera frames.
    - [x] **Critical:** Extract `PoseLandmark` data (x, y, z coordinates).
- [x] **Visual Debugging (The Overlay)**
    - [x] Create `CustomPainter` to draw lines between landmarks.
    - [x] Verify that the skeleton aligns with the hand on screen.
    - [ ] *Optimization:* Ensure frame rate doesn't drop below 30fps.

---

## 🧠 Phase 3: "The Brain" - Gemini Integration (Days 11-17)
*Goal: Turn coordinate data into meaningful text.*

- [ ] **Data Formatting**
    - [ ] Write a utility function `landmarksToJson()` to convert the stream of coordinates into a clean JSON string.
    - [ ] *Optimization:* Normalize coordinates (0.0 to 1.0) so hand distance doesn't affect accuracy.
- [ ] **Prompt Engineering**
    - [ ] Design the System Instruction: "You are a BIM interpreter..."
    - [ ] Test prompts in Google AI Studio first with dummy coordinate data.
- [ ] **API Connection**
    - [ ] Connect `google_generative_ai` package.
    - [ ] Send the JSON payload to Gemini 1.5 Flash.
    - [ ] Handle the response (Parsing the String).
- [ ] **Latency Management**
    - [ ] Implement a "Debounce" or "Buffer" (only send data every 1-2 seconds or when movement stops).

---

## 🗣️ Phase 4: "The Voice" - Speech & Interaction (Days 18-24)
*Goal: Allow the staff to reply.*

- [ ] **Speech-to-Text (STT)**
    - [ ] Implement `speech_to_text` listener.
    - [ ] Configure locale to `ms_MY` (Bahasa Malaysia) and `en_MY`.
    - [ ] Connect the "Mic Button" UI to the listener start/stop.
- [ ] **Chat Logic**
    - [ ] Create a `Message` model (`text`, `sender`, `timestamp`).
    - [ ] Create a local List to store the conversation history.
    - [x] Bind the List to a `ListView.builder` (The Chat UI).
- [ ] **Cloud Sync (Firebase)**
    - [ ] Write function to save completed sessions to Firestore.
    - [ ] *Privacy:* Ensure no PII (Personally Identifiable Information) is saved, only the transcript.

---

## 🎨 Phase 5: "The Face" - UI/UX Polish (Days 25-30)
*Goal: Make it look like the Prototype (Glassmorphism/Cyber-Noir).*

- [x] **Styling**
    - [x] Implement `BackdropFilter` for the glass effect.
    - [x] Apply the "Inter" font family.
    - [x] Style the Chat Bubbles (Green vs White).
- [x] **Animations**
    - [x] Create the "Scanning Line" animation (`AnimationController`).
    - [x] Add the "Pulse" effect to the "Gemini Active" badge.
    - [x] Add "Typing Indicators" (dots) when Gemini is processing.
- [x] **Responsiveness**
    - [x] Ensure layout works on both Phone and Tablet aspect ratios.

---

## 🧪 Phase 6: Testing & Submission (Final Week)
*Goal: Prove it works and meets Judging Criteria.*

- [ ] **User Testing (Category A: Impact - 15 Points)**
    - [ ] Test with a BIM signer (or learn 5 signs perfectly).
    - [ ] Test in a noisy environment (simulating a hospital).
    - [ ] **Deliverable:** Write down 3 feedback points and how we fixed them.
- [ ] **Demo Video (Category B: Completeness)**
    - [ ] Record screen capture of a full conversation.
    - [ ] Edit video to < 5 minutes.
    - [ ] Voiceover explaining the Google Tech stack.
- [ ] **Code Cleanup**
    - [ ] Add comments to complex logic (specifically the MediaPipe->Gemini bridge).
    - [ ] Create a `SETUP.md` so judges can run it.
- [ ] **Final Submission**
    - [ ] Submit Google Form.
    - [ ] Make GitHub repo Public.

---

## 🚀 Bonus / Stretch Goals (If time permits)
- [ ] **Text-to-Speech (TTS):** Have the phone "speak" the sign language translation out loud for the staff.
- [ ] **Multi-Language Support:** Add a toggle for the staff to speak Mandarin/Tamil (common in Malaysia), translated to English text for the deaf user.
- [ ] **Offline Mode:** Use TensorFlow Lite (TFLite) for basic signs if Internet cuts out (Hybrid approach).