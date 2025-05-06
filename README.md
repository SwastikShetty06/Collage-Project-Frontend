<!-- PROJECT BADGES -->
[![Flutter Version](https://img.shields.io/badge/Flutter-3.7.x-blue.svg)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-2.19-green.svg)](https://dart.dev)
[![Build Status](https://img.shields.io/github/actions/workflow/status/yourusername/note_sharing_app_flutter/flutter.yml?branch=main)](https://github.com/yourusername/note_sharing_app_flutter/actions)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

# 📝 Note Sharing App (Flutter)

> A mobile-first Flutter application for seamless uploading, browsing, and sharing of study notes.

---

## 🎯 Table of Contents
1. [About](#about)  
2. [Features](#features)  
3. [Screenshots](#screenshots)  
4. [Tech Stack](#tech-stack)  
5. [Getting Started](#getting-started)  
   - [Prerequisites](#prerequisites)  
   - [Install & Run](#install--run)  
6. [State Management](#state-management)  
7. [Folder Structure](#folder-structure)  
8. [Testing](#testing)  
9. [Contributing](#contributing)  
10. [License](#license)  

---

## 🧐 About
This Flutter frontend powers the Note Sharing App—a platform to upload and discover lecture notes, problem sets, and more. Designed for Android (iOS support planned), it emphasizes smooth infinite scrolling, powerful search, and social features (follow/unfollow).

---

## ✨ Features
- 📤 **Upload** PDFs & images with title & keywords  
- 🔎 **Search** by title or keywords (infinite scroll)  
- 👥 **Social**: follow peers & view a personalized feed  
- 🔄 **Profile**: update college, university, course anytime  
- ⚡ **Performance**: <2 s load on mid-tier Android devices  
- 📱 **Responsive UI** built entirely with Flutter widgets  

---

## 📸 Screenshots
![Browse Notes](screenshots/Browse.png)
![Upload Screen](screenshots/Upload.png)
![Document view screen](docs/screenshots/View.png)

---

## 🛠 Tech Stack
| Layer        | Technology           |
|--------------|----------------------|
| UI           | Flutter & Dart       |
| State Mgmt   | provider             |
| Networking   | dio                  |
| File Picker  | file_picker          |
| External Int | url_launcher, intent |

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.7.x & Dart 2.19  
- Android SDK & emulator or physical device  

### Install & Run
```bash
# 1. Clone frontend repo
git clone https://github.com/yourusername/note_sharing_app_flutter.git
cd note_sharing_app_flutter

# 2. Install dependencies
flutter pub get

# 3. Run on emulator
flutter run
