# SignSpeak Live MVP Prototype

A Flutter recreation of a high-fidelity Sign Language Translation interface. This project is currently an **Active MVP Prototype**.

## Development Status

*   ✅ **Phase 1: Foundation** (Complete)
*   ✅ **Phase 5: UI/UX** (Complete)
*   🚧 **Phase 2: Vision Pipeline** (Active)
*   📅 **Phase 3: Gemini Integration** (Upcoming)

## Features

*   🚧 **Real-time Sign Language Recognition:** Leveraging ML Kit for pose detection to interpret sign language gestures. (**In Progress**)
*   ✅ **Text-to-Speech (TTS):** Converts translated text into audible speech for seamless communication. (**Ready**)
*   ✅ **Visual Debugging / Skeleton Overlay:** Includes a MediaPipe overlay simulation to demonstrate hand tracking capabilities. (**Active**)
*   ✅ **Glassmorphic UI & Animations:** A modern, translucent UI design featuring animated typing indicators. (**Active**)
*   **Custom Camera Interface:** Specialized camera implementation for optimal frame capture and processing.
*   **Camera Controls:** Seamlessly switch between front and back cameras with the Flip Camera feature.
*   **Immersive Camera Viewport:** Includes a MediaPipe overlay simulation to demonstrate hand tracking capabilities.
*   **Real-time Scanning Animation:** Engaging visual feedback simulating active scanning processes.
*   **Responsive Layout:** Fluidly adapts to different screen sizes, optimized for mobile devices.

## Tech Stack

*   **Flutter**
*   **Key Packages:**
    *   `phosphor_flutter`
    *   `flutter_animate`
    *   `google_fonts`
    *   `google_mlkit_pose_detection`

## Project Structure

The project follows a feature-first and layered architecture:

*   `assets/`: For images, models, and fonts.
*   `lib/config/`: Configuration and constants.
*   `lib/models/`: Data models (e.g., `RecognitionResult`).
*   `lib/services/`: Business logic (Camera, ML, TTS).
*   `lib/utils/`: Helper utilities.
*   `lib/widgets/`: UI components organized by feature (`camera`, `interaction`, `common`).

## Setup Instructions

Ensure you have the Flutter SDK installed and set up.

1.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

2.  **Run the Application**
    ```bash
    flutter run
    ```

## Testing

This project includes unit and widget tests. To run them:

```bash
flutter test
```

For specific test files:
```bash
flutter test test/services/camera_service_test.dart
flutter test test/widgets/camera/camera_viewport_test.dart
```

### Coverage
- **Camera Service**: Tests camera initialization, flipping, and error handling.
- **Camera Viewport**: Tests camera preview rendering and overlay integration.
- **Interaction Area**: Tests chat input, typing indicators, and message history.

## Screenshots

*(Screenshots of the application interface will be placed here)*
