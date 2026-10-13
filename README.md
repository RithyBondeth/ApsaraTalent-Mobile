<div align="center">

# Apsara Talent — Mobile

**The cross-platform mobile app for Apsara Talent, a recruitment platform that connects professionals and companies.**

![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-0175C2?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white)
![Socket.IO](https://img.shields.io/badge/Socket.IO-010101?style=for-the-badge&logo=socketdotio&logoColor=white)

</div>

---

## Overview

Apsara Talent Mobile is the iOS and Android app for Apsara Talent, a Cambodia-focused hiring platform. It brings the full Apsara Talent experience to mobile: profiles, a discovery feed, matching, applications and interviews, real-time chat and voice calls, and AI-assisted writing tools. It is localized in English and Khmer.

## Features

- **Authentication:** email, phone and OTP login, email verification, password reset, two-factor authentication, and social login through the browser.
- **Role-based sign-up** for employees and companies.
- **Discovery:** profile feed, search, saved searches, favorites, and job details.
- **Matching,** with real-time updates and AI match tools, including interview-prep export.
- **Applications and an employer workflow,** with interview scheduling.
- **Real-time chat** with attachments, plus **voice calls** over WebRTC.
- **AI writing:** cover letters and profile text, with quota tracking.
- **Resume builder and resume import.**
- **Push notifications** through Firebase Cloud Messaging.
- **Profile, settings, theming, moderation, and an admin view.**

## Tech Stack

| Area | Technology |
| --- | --- |
| Framework | Flutter, Dart 3.6 |
| State management | Riverpod |
| Navigation | auto_route |
| Networking | Dio, Socket.IO client, generated gateway client from OpenAPI |
| Real-time calls | flutter_webrtc |
| Push | Firebase Core, Firebase Messaging |
| Storage | flutter_secure_storage |
| Configuration | flutter_dotenv (development, staging, production) |
| CI | GitHub Actions |

## Getting Started

### Prerequisites

- Flutter SDK (Dart 3.6 or newer)
- Xcode for iOS, and Android Studio or the Android SDK for Android
- A running [Apsara Talent API](https://github.com/RithyBondeth/ApsaraTalent-Api)

### Installation

```bash
git clone https://github.com/RithyBondeth/ApsaraTalent-Mobile.git
cd ApsaraTalent-Mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Environment files live in `assets/env/` (`.env.development`, `.env.staging`, `.env.production`).

### Testing

```bash
flutter analyze
flutter test
```

`test/contract/` checks the app against the API's OpenAPI contract in `contracts/openapi.json`.

## Project Structure

```text
ApsaraTalent-Mobile/
├── lib/
│   ├── app/            # App root
│   ├── core/           # configs, network, push, session, themes, validators, localization
│   └── features/
│       ├── auth/  feed/  search/  saved_search/  match/  favorite/  job/
│       ├── application/  chat/  call/  ai/  resume_builder/  resume_import/
│       ├── notification/  profile/  setting/  moderation/  admin/  dashboard/
│       └── career_scope/  navigation/  resources/  splash/  theme/
├── assets/env/         # Per-environment configuration
├── contracts/          # API OpenAPI contract
└── test/
```

## Related Repositories

- [ApsaraTalent-Api](https://github.com/RithyBondeth/ApsaraTalent-Api): the NestJS microservices backend
- [ApsaraTalent-Web](https://github.com/RithyBondeth/ApsaraTalent-Web): the Next.js web app

## Author

**Rithy Bondeth** — Full Stack Developer & AI Engineer

[![Portfolio](https://img.shields.io/badge/Portfolio-0A0A0A?style=for-the-badge&logo=vercel&logoColor=white)](https://bondeth.dev)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/RithyBondeth)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/rithy-bondeth-484073282/)
