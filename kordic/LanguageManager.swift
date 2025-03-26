//
//  LanguageManager.swift
//  kordic
//
//  Created by musung on 2025/03/26.
//

import SwiftUI
import Combine

// 앱 전체 언어 환경 관리를 위한 클래스
class LanguageManager: ObservableObject {
    @AppStorage("selectedLanguage") var currentLanguage: String = "English" {
        didSet {
            // 언어가 변경될 때마다 알림
            NotificationCenter.default.post(name: .languageDidChange, object: nil)
        }
    }
    
    static let shared = LanguageManager()
    
    private init() { }
}

// 알림 이름 확장
extension Notification.Name {
    static let languageDidChange = Notification.Name("languageDidChange")
}

// 로컬라이제이션 키에 대한 확장
extension String {
    func localized() -> String {
        let language = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "English"
        
        let translations: [String: [String: String]] = [
            // English translations
            "English": [
                "Learn Korean": "Learn Korean",
                "Hello!": "Hello!",
                "Continue learning Korean": "Continue learning Korean",
                "Start": "Start",
                "Basics 1": "Basics 1",
                "Basics 2": "Basics 2",
                "Review Words": "Review Words",
                "Practice your vocabulary": "Practice your vocabulary",
                "Quiz": "Quiz",
                "Test your knowledge": "Test your knowledge",
                "Settings": "Settings",
                "Language Settings": "Language Settings",
                "Select Language": "Select Language",
                "Display Settings": "Display Settings",
                "Dark Mode": "Dark Mode",
                "Information": "Information",
                "App Version": "App Version"
            ],
            // Japanese translations
            "日本語": [
                "Learn Korean": "韓国語を学ぶ",
                "Hello!": "こんにちは！",
                "Continue learning Korean": "韓国語学習を続ける",
                "Start": "スタート",
                "Basics 1": "基礎 1",
                "Basics 2": "基礎 2",
                "Review Words": "単語復習",
                "Practice your vocabulary": "語彙を練習する",
                "Quiz": "クイズ",
                "Test your knowledge": "知識をテストする",
                "Settings": "設定",
                "Language Settings": "言語設定",
                "Select Language": "言語を選択",
                "Display Settings": "表示設定",
                "Dark Mode": "ダークモード",
                "Information": "情報",
                "App Version": "アプリバージョン"
            ],
            // Korean translations
            "한국어": [
                "Learn Korean": "한국어 배우기",
                "Hello!": "안녕하세요!",
                "Continue learning Korean": "한국어 학습 계속하기",
                "Start": "시작",
                "Basics 1": "기초 1",
                "Basics 2": "기초 2",
                "Review Words": "단어 복습",
                "Practice your vocabulary": "어휘 연습하기",
                "Quiz": "퀴즈",
                "Test your knowledge": "지식 테스트하기",
                "Settings": "설정",
                "Language Settings": "언어 설정",
                "Select Language": "언어 선택",
                "Display Settings": "화면 설정",
                "Dark Mode": "다크 모드",
                "Information": "정보",
                "App Version": "앱 버전"
            ]
        ]
        
        return translations[language]?[self] ?? self
    }
}
