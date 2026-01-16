# REQUIREMENTS.md: SignSpeak Live

## 1. Project Overview
**Project Name:** SignSpeak Live
**Tagline:** Bridging the communication gap between the Deaf community and public services using Real-Time AI.
**SDG Alignment:**
*   **Goal 10:** Reduced Inequalities (Empowering the deaf community).
*   **Goal 3:** Good Health and Well-being (Improving communication in hospital settings).
*   **Goal 16:** Peace, Justice, and Strong Institutions (Access to government services).

## 2. Problem Statement
Deaf individuals in Malaysia face significant barriers when accessing essential services (hospitals, police stations, UTCs) because most counter staff do not understand **Bahasa Isyarat Malaysia (BIM)**. This leads to misdiagnosis, legal misunderstandings, and social exclusion.

## 3. The Solution (MVP)
A dual-interface tablet application placed at service counters.
1.  **Facing the User:** Captures sign language gestures via camera and displays transcribed text from the staff.
2.  **Facing the Staff:** Displays the translated text (from the user's signs) and captures spoken audio to transcribe back to the user.

---

## 4. Technical Stack (Google Ecosystem Exclusive)
*Per KitaHack Rules: We are exclusively using Google AI and Developer Technologies.*

| Component | Technology | Reasoning (For Judges) |
| :--- | :--- | :--- |
| **Frontend** | **Flutter** | For building a responsive, cross-platform UI (Tablet/Web) with high-performance camera access. |
| **Visual AI** | **MediaPipe** (Google) | For on-device, low-latency extraction of hand landmarks and skeletal pose data. |
| **Generative AI** | **Gemini 3 Flash** | To interpret the sequence of skeletal data/landmarks into coherent sentences (Sign Language Translation). *Chosen for speed.* |
| **Speech AI** | **Google Cloud Speech-to-Text** | To convert the counter staff's spoken words into text for the deaf user. |
| **Backend** | **Firebase** | For authentication, hosting the web app, and logging usage metrics (Firestore). |

---

## 5. Functional Requirements (MVP Scope)

### A. Sign Language to Text (The "Hard" Part)
- [ ] **Camera Input:** App must access the device camera with permission.
- [ ] **Landmark Detection:** Implement **MediaPipe Hands** to detect hand coordinates (x, y, z) in real-time.
- [ ] **Gesture Processing:**
    -   *Strategy:* Capture frames every 0.5 seconds or capture landmark vectors.
    -   *Processing:* Send this data to **Gemini API**.
    -   *Prompt Engineering:* "Analyze these hand coordinates/frame. The user is using Bahasa Isyarat Malaysia. Translate the gesture to English/Malay text."
- [ ] **Output:** Display the translated text on the screen for the staff member.

### B. Speech to Text (The "Easy" Part)
- [ ] **Microphone Input:** Button for staff to press when speaking.
- [ ] **Transcription:** Use **Google Cloud Speech-to-Text API** or **Flutter `speech_to_text`** (which wraps Google's engine on Android) to transcribe audio.
- [ ] **Display:** Show the text in large font for the deaf user.

### C. User Interface (UI)
- [ ] **Split View / Toggle View:** Mode for "Listening" (Staff speaking) vs "Watching" (User signing).
- [ ] **Visual Feedback:** A visual indicator (green ring) showing the camera is active and tracking hands.

---

## 6. Development Roadmap (Timeline: Jan 20 - Feb 28)

### Phase 1: Setup & Hello World (Week 1)
- [ ] Initialize Flutter Project.
- [ ] Connect Firebase (Auth & Firestore).
- [ ] create a "Hello World" that opens the camera and overlays MediaPipe skeleton on hands.

### Phase 2: Core AI Integration (Week 2-3)
- [ ] **Input Pipeline:** Feed MediaPipe landmarks into a prompt structure for Gemini.
- [ ] **Gemini Integration:** Connect to Vertex AI/Google AI Studio API.
- [ ] **Test Case:** Successfully translate 3 basic BIM signs (e.g., "Sakit" (Sick), "IC" (Identity Card), "Bantu" (Help)).

### Phase 3: Speech & UI Polish (Week 4)
- [ ] Implement Speech-to-Text for the staff side.
- [ ] Create a "Service Counter" style UI (Clean, high contrast).

### Phase 4: User Testing & Verification (Crucial for 15 Points)
- [ ] **User Test 1:** Find a BIM speaker (or learn the specific signs perfectly) to test accuracy.
- [ ] **User Test 2:** Simulate a noisy environment to test Speech-to-Text accuracy.
- [ ] **Documentation:** Record video evidence of the app working.

---

## 7. Data Flow Architecture
1.  **Video Stream** -> **Flutter App**
2.  **Flutter App** -> **MediaPipe** (Extracts Hand Landmarks locally)
3.  **Landmark Data (JSON)** -> **Gemini 3 Flash (via API)**
4.  **Gemini** -> Returns **String** ("Patient has a fever")
5.  **Flutter UI** -> Updates Text Box.

---

## 8. Success Metrics (For Judging)
*   **Latency:** Translation occurs within 3 seconds of the gesture finishing.
*   **Accuracy:** Correctly identifies at least 10 key BIM gestures relevant to a government counter context.
*   **Scalability:** The code structure allows adding new gesture dictionaries (e.g., American Sign Language) simply by changing the Gemini System Prompt, without retraining a whole model.

---

## 9. Submission Checklist (Handbook Compliance)
- [ ] **AI Usage:** Is Gemini used? (Yes, for context interpretation).
- [ ] **Google Tech:** Is Firebase/GCP used? (Yes).
- [ ] **Video:** Is the demo video under 5 mins?
- [ ] **Repo:** Is this README and setup instructions clear?
- [ ] **Testing:** Did we include the "Feedback" section in the final report?

---

### 💡 Hackathon Tip: Handling the "Video" Challenge
*Streaming live video to Gemini is bandwidth-heavy and slow.*
**The Winning Hack:** Don't stream the video. Use **MediaPipe** on the phone/tablet to turn the hand movements into "stick figure coordinates." Send *text data* of those coordinates to Gemini.
*   **Why?** It's extremely fast, uses almost no data, and works on bad internet (rural Malaysia).
*   **Prompt to Gemini:** "Here is a sequence of hand coordinates over 2 seconds. Based on BIM syntax, what does this signify?"

***

**Copy-paste the above into a file named `REQUIREMENTS.md` in the root of your GitHub repository.** This shows the judges you are professional, organized, and strictly following the rules.