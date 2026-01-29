# LiteWorship

**LiteWorship** is a modern, streamlined worship presentation software built with Flutter. It features a unique "Jukebox Mode" that allows for instant, schedule-free navigation and projection of songs and scriptures.

![Status](https://img.shields.io/badge/Status-Active-success)
![Platform](https://img.shields.io/badge/Platform-Windows-blue)

## 🚀 Key Features

*   **🎵 Jukebox Mode**: Forget complex playlists. Just search and click any song or scripture to load it instantly.
*   **📖 Smart Bible Search**: Intelligent parsing supports queries like `1cor 13:4`, `jn 3 16`, or `Genesis 1`.
    *   *Includes Roman Numeral support (e.g., "1 Kings" maps to "I Kings").*
*   **⚡ Double-Enter Workflow**:
    *   **Press Enter Once**: Loads the verse into the **Preview** panel.
    *   **Press Enter Again**: Immediately pushes the verse **LIVE** to the projector.
*   **🖥️ Dual-Screen Architecture**:
    *   **Dashboard**: A control center for the operator.
    *   **Projector View**: A browser-based render target (Chrome at `localhost:8080`) that ensures text is beautiful and auto-scaled.
*   **📐 Auto-Fit Typography**: Projector text automatically scales to fill the screen without overflow, regardless of verse length.

## 🛠️ Getting Started

### Prerequisites

*   **Flutter SDK** (Channel stable)
*   **Chrome Browser** (for the projector output)

### Running the App

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/liteworship.git
    cd LiteWorship
    ```

2.  **Run in Release Mode** (Recommended for performance):
    ```bash
    flutter run --release
    ```

3.  **Launch Projector**:
    *   Open Google Chrome.
    *   Navigate to `http://localhost:8080`.
    *   Press `F11` to make the browser fullscreen on your secondary display/projector.

## 🖱️ Usage Guide

1.  **Search**: Use the sidebar to find Bible verses or Songs.
    *   *Tip: Use standard abbreviations like "Mt" for Matthew or "Rev" for Revelation.*
2.  **Preview**: Click an item or press Enter. It appears in the top-left Preview panel.
3.  **Go Live**:
    *   Click the **"GO LIVE"** button.
    *   **OR** Press **Enter** a second time in the search box.
4.  **Clear Screen**: Click the "Clear" icon or toggle "GO LIVE" off.

## 🏗️ Architecture

*   **Frontend**: Flutter (Windows Desktop target)
*   **State Management**: Riverpod
*   **Projector Communication**: WebSockets (embedded server in the Flutter app talks to the HTML/JS projector page).
*   **Data**: JSON-based Bible (KJV) and standard song databases.

## 📝 License

This project is licensed under the MIT License.
