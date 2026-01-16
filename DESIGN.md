# DESIGN.md: SignSpeak Live

## 1. Design Philosophy
**"Accessibility through Clarity"**
The interface is designed for high-stress environments (hospitals, police stations). It prioritizes high contrast, large typography, and clear visual feedback loops to ensure both the Deaf user and the Hearing staff member are confident that communication is happening.

### 1.1 Aesthetic Direction (MVP)
*   **Theme:** "Cyber-Noir Utility" – Dark mode to reduce eye strain and make the camera feed/text pop.
*   **Visual Style:** Glassmorphism for overlays to keep context (camera feed) visible behind UI elements.
*   **Motion:** Subtle pulsing animations (Green for "Active/Safe", White for "Processing") to indicate AI state without distracting the user.

---

## 2. UI Design System
*Based on the HTML/CSS Prototype.*

### 2.1 Color Palette
| Color Name | Hex Code | Usage |
| :--- | :--- | :--- |
| **Void Black** | `#000000` | Main Background, maximize contrast. |
| **Glass Surface** | `rgba(255, 255, 255, 0.1)` | Chat bubbles, Control panels. |
| **Signal Green** | `#22c55e` | "Gemini Active" status, Confidence indicators. |
| **Text White** | `#FFFFFF` | Primary text (Deaf user focus). |
| **Muted Gray** | `#6b7280` | Secondary metadata (timestamps, labels). |

### 2.2 Typography
*   **Font Family:** `Inter` (Google Fonts).
*   **Rationale:** Chosen for high legibility on digital screens, specifically for distinguishing similar characters (I/l/1) which is crucial for official data entry (IC numbers, etc.).

### 2.3 Iconography
*   **Library:** Phosphor Icons (Flutter package: `phosphor_flutter`).
*   **Key Icons:** `hand-waving` (App Logo), `microphone-fill` (Speech Input), `arrows-clockwise` (Camera Flip).

---

## 3. User Experience (UX) Flow

### 3.1 The "Interpreter Loop"
The screen is split into two logical zones: **Visual Input (Top)** and **Conversation History (Bottom)**.

1.  **State: Listening (Default)**
    *   Camera is active.
    *   Overlay shows skeletal tracking (MediaPipe) to confirm the system "sees" the hands.
    *   Badge reads: `GEMINI VISION ACTIVE`.

2.  **State: Signing Detected**
    *   User performs BIM gestures.
    *   A "Scanning line" animation traverses the camera feed.
    *   **Feedback:** As gestures are recognized, a ghost text appears: *"Processing..."*

3.  **State: Translation displayed**
    *   Gemini returns the string.
    *   Message appears in a **Glass Bubble (Left Aligned)**.
    *   Metadata shows: `Detected from Sign • 98% confidence`.

4.  **State: Staff Response**
    *   Staff holds the **Big White Mic Button**.
    *   Button ripples visually.
    *   Speech-to-Text converts audio to text.
    *   Message appears in a **White Bubble (Right Aligned)**.

---

## 4. System Architecture
This architecture minimizes latency by processing visual data locally before sending it to the cloud.

```mermaid
graph TD
    A[Camera Feed] -->|Frames| B(MediaPipe Service / On-Device)
    B -->|Extracts (x,y,z)| C{Hand Detected?}
    C -- Yes --> D[Landmark Vectorizer]
    D -->|JSON Payload| E[Gemini 3 Flash API]
    E -->|Translation String| F[Flutter UI]
    G[Staff Microphone] -->|Audio Stream| H[Google Cloud Speech-to-Text]
    H -->|Transcription| F
    F -->|Log Session| I[Firebase Firestore]
```

### 4.1 Component Breakdown

#### A. The Vision Pipeline (Flutter + MediaPipe)
Instead of streaming heavy video to the cloud, we process locally.
*   **Input:** Camera stream (`CameraPreview` widget).
*   **Processor:** `google_mlkit_pose_detection` or `mediapipe_flutter`.
*   **Output:** A list of 21 landmark coordinates per hand, sampled at 15fps.
*   **Optimization:** We only send the *change* in vectors to Gemini to save tokens.

#### B. The Translation Engine (Gemini 3 Flash)
*   **Why Flash?** We need speed (low latency) over complex reasoning.
*   **System Prompt:**
    > "You are a real-time interpreter for Bahasa Isyarat Malaysia (BIM). You will receive a JSON sequence of hand vector coordinates. Interpret the gesture into a concise English sentence. If the gesture is unclear, return null."

#### C. The Speech Engine
*   **Tool:** `speech_to_text` (Flutter plugin).
*   **Configuration:** `localeId: 'ms_MY'` (Malay) or `en_MY` (Malaysian English) to handle local accents effectively.

---

## 5. Data Models (Firebase)
*To fulfill the "Privacy" and "Analytics" requirements.*

We do **not** store video or audio. We only store the text transcripts for analytics.

**Collection:** `sessions`
```json
{
  "session_id": "uuid_12345",
  "timestamp": "2026-02-28T10:00:00Z",
  "location": "Hospital Kuala Lumpur",
  "interaction_count": 15,
  "messages": [
    {
      "sender": "user_sign",
      "content": "I need to renew my IC.",
      "confidence": 0.98,
      "timestamp": "..."
    },
    {
      "sender": "staff_voice",
      "content": "Do you have the police report?",
      "timestamp": "..."
    }
  ]
}
```

---

## 6. Implementation Strategy (Flutter)

### 6.1 Folder Structure
```text
lib/
├── main.dart
├── config/
│   ├── theme.dart          // AppColors, AppTextStyles
│   └── assets.dart         // Path constants
├── services/
│   ├── camera_service.dart // MediaPipe stream
│   ├── gemini_service.dart // Gemini 3 Flash API
│   ├── speech_service.dart // STT Logic
│   └── permission_service.dart // Handle Camera/Mic permissions
├── ui/
│   ├── screens/
│   │   └── home_screen.dart // Main Split View
│   └── widgets/
│       ├── camera_view.dart // Layer 1 & 2 (Video + Skeleton + ScanLine)
│       ├── chat_panel.dart  // Layer 3 (Glass History + Controls)
│       ├── glass_bubble.dart // Reusable Message Bubble
│       ├── pulse_ring.dart   // Mic Animation
│       └── skeleton_overlay.dart // CustomPainter
└── utils/
    └── landmark_parser.dart // Vector -> JSON
```

### 6.2 Widget Tree Hierarchy
The app uses a `Stack` to layer the UI over the camera feed.

```dart
Scaffold
  └── Stack
      ├── Positioned.fill (Layer 1: Camera)
      │   └── CameraPreview
      │
      ├── Positioned.fill (Layer 2: Vision Overlays)
      │   └── Stack
      │       ├── CustomPaint (SkeletonPainter)
      │       ├── AnimatedScanLine (SlideTransition)
      │       ├── Positioned(top, left) -> Header (Gradient)
      │       ├── Positioned(bottom, left) -> "Gemini Active" Badge
      │       └── Positioned(top, right) -> Mode Indicator
      │
      └── Positioned(bottom) (Layer 3: Interaction)
          └── Container (Black, Rounded Top)
              └── Column
                  ├── DragHandle
                  ├── Expanded(ListView) -> Chat History
                  └── ControlBar (Mic, Keyboard, Flip)
```

---

## 7. Prototype Specifications (From HTML/CSS)

### 7.1 Style Constants (`lib/config/theme.dart`)

**Colors (Mapped from Tailwind/CSS):**
| Name | Hex | CSS/Tailwind Ref | Usage |
| :--- | :--- | :--- | :--- |
| `voidBlack` | `Color(0xFF000000)` | `bg-black`, `#000000` | Main Background |
| `glassWhite` | `Color(0x1AFFFFFF)` | `rgba(255,255,255,0.1)` | Bubbles, Panels |
| `glassBorder` | `Color(0x1AFFFFFF)` | `border-white/10` | Borders |
| `signalGreen` | `Color(0xFF22C55E)` | `text-green-500`, `#22c55e` | Active Status |
| `textPrimary` | `Color(0xFFFFFFFF)` | `text-white` | Main Text |
| `textSecondary`| `Color(0x66FFFFFF)` | `text-white/40` | Metadata, Timestamps |

**Typography (Google Fonts 'Inter'):**
*   **Body:** `GoogleFonts.inter(fontSize: 14, height: 1.5, color: Colors.white)`
*   **Header:** `GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18)`
*   **Caption:** `GoogleFonts.inter(fontSize: 10, letterSpacing: 0.5, uppercase: true)`

**Icons (Phosphor Flutter):**
*   Logo: `PhosphorIcons.handWaving`
*   Settings: `PhosphorIcons.gear`
*   Keyboard: `PhosphorIcons.keyboard`
*   Mic: `PhosphorIcons.microphoneFill`
*   Flip: `PhosphorIcons.arrowsClockwise`

### 7.2 Component Details

#### A. Glassmorphism Bubble (`.glass-message-received`)
*   **Widget:** `ClipRRect` + `BackdropFilter` + `Container`.
*   **Blur:** `sigmaX: 12`, `sigmaY: 12`.
*   **Border:** `Border.all(color: AppColors.glassBorder)`.
*   **Gradient:** None (Flat transparent white per prototype).
*   **Border Radius:** `BorderRadius.only(topLeft: 18, topRight: 18, bottomRight: 18, bottomLeft: 4)`.

#### B. Scan Line Animation (`.animate-scan`)
*   **Controller:** `AnimationController` (duration: 2s, repeat).
*   **Widget:** `AnimatedBuilder` driving a `Positioned` widget's `top` property from `0.0` to `1.0` (relative to height).
*   **Visual:** `Container(height: 2, decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.white, blurRadius: 10)]))`.

#### C. Skeleton Overlay (`svg class="skeleton-overlay"`)
*   **Widget:** `CustomPaint` with `CustomPainter`.
*   **Logic:**
    *   Input: `List<PoseLandmark>`.
    *   Draw `Circle` (radius 4, white) for each landmark.
    *   Draw `Line` (strokeWidth 2, white) connecting landmarks.
    *   Opacity: `0.7`.

#### D. Microphone Pulse (`@keyframes pulse-ring`)
*   **Controller:** `AnimationController` (duration: 1.5s, repeat, reverse: true).
*   **Widget:** `ScaleTransition` + `FadeTransition` on a white circular `Container` behind the main button.

### 7.3 Required Packages (Confirmed)
All necessary packages are present in `pubspec.yaml`:
- `flutter`: Core
- `google_fonts`: For "Inter"
- `phosphor_flutter`: For Icons
- `flutter_animate`: For simple entrance animations (bounce, fade)
- `camera`: Video feed
- `google_mlkit_pose_detection`: Landmarks

---

## 8. Judge's Corner: Why this Design Wins
1.  **Multimodal Integration:** We aren't just wrapping a chatbot. We are combining **Vision** (MediaPipe), **LLM** (Gemini), and **Audio** (STT) in a single fluid interface.
2.  **Local-First AI:** By using MediaPipe on-device, we demonstrate an understanding of **Edge AI** principles (reducing cloud costs and latency), which is a "Senior Developer" trait.
3.  **SDG Centric:** The UI is specifically accessible. The high contrast and clear text specifically target SDG 10 (Reduced Inequalities).
