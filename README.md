# kordic

kordic은 SwiftUI로 개발된 한국어 학습 앱입니다. 사용자가 체계적으로 한국어 기초를 학습할 수 있도록 설계되었습니다.
(기초 학습까지 구현)

## 주요 기능

*   **단계별 학습:** "Basics 1"부터 시작하는 구조화된 학습 경로를 제공합니다.
*   **모듈 기반 학습:** 인사말, 숫자와 시간, 일상 대화, 음식 주문, 장소와 길 찾기 등 다양한 주제의 모듈로 구성되어 있습니다.
*   **학습 진도 관리:** `UserDefaults`를 사용하여 각 모듈의 학습 진행 상황을 추적하고, 이전 모듈 완료 시 다음 모듈 잠금을 해제하는 기능을 제공합니다.
*   **인터랙티브 학습 세션:** 잠금 해제된 모듈을 탭하면 모달(Sheet) 형태로 단어 카드 학습 세션(`ModuleLessonView`)이 제공됩니다.
*   **단어 카드:** 학습 세션 내에서 한국어 단어/문장, 영어 번역, 발음 가이드, 관련 이미지 또는 아이콘이 포함된 카드를 통해 학습합니다.
*   **레벨 테스트 (추정):** 앱의 다른 부분(`ContentView`, `LevelTestView`)에 사용자의 한국어 수준을 평가하고 학습 콘텐츠 잠금을 해제하는 레벨 테스트 기능이 포함된 것으로 보입니다.
*   **다크 모드 지원:** 사용자의 시스템 설정 또는 앱 내 설정에 따라 라이트 모드와 다크 모드를 지원합니다.
*   **커스텀 토스트 메시지:** 모듈 잠금 상태 등 사용자에게 필요한 정보를 알려주는 토스트 메시지 시스템을 갖추고 있습니다.

## 사용된 기술

*   SwiftUI
*   Foundation
*   UserDefaults (학습 진도 저장)

## 실행 방법

1.  프로젝트 저장소를 로컬 환경에 복제(Clone)합니다.
2.  Xcode를 사용하여 `kordic.xcodeproj` 파일을 엽니다.
3.  시뮬레이터 또는 실제 기기를 선택합니다.
4.  Xcode 메뉴에서 Product > Run (단축키: Cmd+R)을 선택하여 앱을 빌드하고 실행합니다.

## 프로젝트 구조 (주요 파일)

*   `kordicApp.swift`: 앱의 진입점 (Entry Point)
*   `ContentView.swift`: 앱의 메인 화면, 학습 카테고리 표시 및 네비게이션 관리
*   `Basics1View.swift`: "Basics 1" 학습 섹션 화면, 모듈 목록 표시
*   `ModuleProgressManager.swift`: 학습 모듈의 진행률 및 잠금 상태를 관리하는 싱글톤 클래스
*   `ModuleLessonView.swift` (내부 구조체): 각 모듈의 학습 세션(단어 카드 넘기기)을 담당하는 뷰
*   `LearningCategoryView.swift` / `KoreanCharacterCategoryView.swift` / `QuizCategoryView.swift`: 메인 화면의 각 학습 카테고리 항목을 표시하는 뷰
*   `LevelTestView.swift`: 사용자 레벨 테스트 관련 뷰
