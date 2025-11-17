# Blueprint: 북토크 시티 (BookTalk City) - 최종 MVP

## 1. 🎯 프로젝트 방향성: 책으로 시작하는 지역 공론장

독서를 매개로 한 지역 커뮤니티, 구조화된 토론, 그리고 지속가능한 수익 모델을 결합한 "독서 기반 시민 토론 플랫폼"입니다.

## 2. 📊 핵심 컨셉

*   **당근 스타일 모임 기능:** 동네 기반의 쉽고 빠른 독서 모임 생성 및 참여.
*   **GitHub PR 스타일 토론:** "독서 노트(Book Request)"를 통한 깊이 있고 구조화된 토론.
*   **Create-to-Earn (C2E) 수익 모델:** 활동을 통해 포인트를 획득하고 사용하는 지속가능한 경제 시스템.

## 3. 🏗️ MVP 기능 설계

### **Phase 1: 핵심 기능 (완료)**
*   앱 기본 구조, 테마, 사용자 인증, 홈 화면, Book Request(BR) 시스템 구현 완료.

### **Phase 2: 토론 고도화 (완료)**
*   BR 상세 페이지, 댓글(Reply) 기능, 사용자 프로필 기능 구현 완료.

### **Phase 3: 수익 모델 및 확장 (완료)**

*   **C2E (Create-to-Earn) 포인트 시스템 도입 (완료)**
    *   데이터 모델링, 포인트 지급/차감 로직(트랜잭션), UI 통합 완료.

*   **독서 모임 생성/참여 기능 (1단계 완료)**
    *   **데이터 모델:** `Meeting` 클래스를 `lib/models/meeting.dart`에 정의했습니다.
    *   **모임 생성 화면:** `CreateMeetingScreen`을 구현하여 사용자가 모임의 제목, 소개, 장소, 시간, 최대 인원 등을 설정할 수 있도록 했습니다.
    *   **서비스 로직:** `FirestoreService`에 `createMeeting` 메소드를 추가하여, 주최자를 자동으로 참여자에 포함시키는 새로운 모임을 생성하는 로직을 구현했습니다.
    *   **UI/라우팅 통합:** `go_router`에 `/create-meeting` 경로를 추가하고, `HomeScreen`의 `FloatingActionButton` 시스템을 개편하여 BR 작성과 모임 생성을 분리했습니다.

### **향후 확장 계획**

*   **모임 상세/참여:** `MeetingDetailScreen`을 만들어 모임 참여/탈퇴, 참여자 목록 확인 기능을 구현합니다.
*   **실시간 채팅:** 각 모임별로 실시간 채팅방을 제공합니다.
*   **AI 어시스턴트:** BR 요약, 토론 주제 제안 등 AI 기능을 도입합니다.
*   **고급 검색/필터링:** 지역, 책, 모임 유형별로 검색하는 기능을 추가합니다.

## 4. 💻 기술 스택

*   **Cross-Platform Framework:** Flutter
*   **Backend & DB:** Firebase (Authentication, Firestore)
*   **State Management:** Provider
*   **Routing:** go_router
*   **UI/Styling:** Material 3, google_fonts, intl

## 5. 📂 최종 프로젝트 구조

```
lib/
├── main.dart, router.dart, firebase_options.dart
|
├── models/
│   ├── book_request.dart, reply.dart, user_model.dart, meeting.dart
|
├── providers/
│   └── theme_provider.dart
|
├── services/
│   ├── auth_service.dart, firestore_service.dart
|
├── screens/
│   ├── home_screen.dart, login_screen.dart, create_br_screen.dart,
│   │   br_detail_screen.dart, profile_screen.dart, create_meeting_screen.dart
|
└── widgets/
    └── content_card.dart
```
