Tether 🌍❤️

A Relationship Companion for Long-Distance Couples

⸻

📖 Overview

Tether is a fully custom-built iOS application designed to help long-distance couples stay emotionally and digitally connected. Unlike generic location-sharing or messaging apps, Tether blends real-time location tracking, in-app messaging, and collaborative mini-games, all tailored specifically for relationship engagement.

This was a personal, passion-driven project, built from the ground up to explore backend integration, real-time data sync, and SwiftUI-based iOS architecture patterns.

⸻

🎯 Motivation

Research shows that up to 60% of long-distance relationships struggle or fail due to lack of engagement, infrequent communication, and emotional distance.
Tether’s goal is to reduce emotional friction by making small daily interactions fun, easy, and meaningful.

This project also served as a sandbox for me to strengthen my skills in:
	•	Full-stack mobile development
	•	Firebase backend integration
	•	Real-time location services
	•	Reactive UI architecture with Combine
	•	Persistent local storage using CoreData

⸻

🛠️ Tech Stack
Layer                    Technology
Frontend UI              SwiftUI (Using MVVM + Combine)
Backend Services         Firebase (Firestore + Authentication)
Location Services        CoreLocation Framework
Local Storage            CoreData
Build/Dev Tools          XCode, Firebase Console, Swift Package Manager

🧱 Architecture Design

Tether follows a MVVM (Model-View-ViewModel) architecture, using Combine for state management and data flow between Firebase and SwiftUI views.

Major App Modules:
	•	Authentication Module
	•	Firebase Auth for user signup, login, and session handling.
	•	Location Sharing Module
	•	Uses CoreLocation for real-time user coordinates.
	•	Firebase Firestore triggers updates to the partner’s app instance in near-real-time.
	•	Messaging Module
	•	Lightweight chat system using Firestore document collections.
	•	Includes read receipts and timestamped message history.
	•	Mini-Games / Interaction Module
	•	Simple game state management (e.g., daily question challenges, emoji reaction games).
	•	Backend game state synced across both users’ devices.
	•	User Customization Module
	•	Allows avatar selection, theme changes, and relationship-specific UI tweaks.
	•	Stored in Firebase and mirrored in local CoreData cache for offline persistence.

⸻

🌟 Features
	•	🔴 Live Location Sharing
Partners can toggle location sharing on/off, with real-time updates reflected in the app.
	•	💬 In-App Messaging
Text-based chat with real-time syncing. Built using Firestore’s real-time listeners.
	•	🎮 Couple Interaction Minigames
Designed as lightweight daily engagement tools—like “Daily Check-in,” emoji-based quizzes, or collaborative goal setting.
	•	🎨 Custom Avatars & Themes
Allow users to personalize the look and feel of their app experience.
	•	📲 Offline Support with CoreData
App remains functional even during network disruptions. Data auto-syncs when reconnected.

⸻

🚀 Development Challenges & Solutions
Challenge

1. Real-time data sync across two user accounts
Sol: Used Firestore's real-time listeners with Combine publishers tp emsure state consistency

2. Managing simultaneous UI updates across multiple screens
Sol: Adopted MVVM + Combine pipeline for modular state flow

3. Handling location permission edge cases
Sol: Integrated CoreLocation fail-safes and graceful error handling UI


🧠 Key Learnings
	•	Working with Firebase SDK for iOS, including authentication, Firestore, and storage.
	•	Implementing reactive UI with Combine in SwiftUI.
	•	Managing real-time data streams and multi-user synchronization logic.
	•	Designing offline-first user experiences with CoreData fallback strategies.

⸻

🔮 Roadmap / Next Steps
	•	📲 Push Notification Integration (using Firebase Cloud Messaging)
	•	📈 Analytics Dashboard (user engagement tracking)
	•	💡 Expanded minigame library (more interactive couple activities)
	•	✅ Preparing for TestFlight beta launch

⸻

⭐️ Final Notes

Tether was built for fun, learning, and solving a real-world emotional need. Feel free to explore the codebase, and reach out with feedback or questions.
