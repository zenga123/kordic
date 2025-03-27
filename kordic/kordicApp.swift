//
//  kordicApp.swift
//  kordic
//
//  Created by musung on 2025/03/26.
//

import SwiftUI

// 로컬라이제이션 키에 대한 확장
extension String {
    func localized() -> String {
        // UserDefaults에서 선택된 언어 가져오기
        let language = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "English"
        print("현재 선택된 언어: \(language)") // 디버깅용 출력
        
        let translations: [String: [String: String]] = [
            // English translations
            "English": [
                "Learn Korean": "Learn Korean",
                "Hello!": "Hello!",
                "Continue learning Korean": "Continue learning Korean",
                "Start": "Start",
                "Level Test": "Level Test",
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
                "Level Test": "レベルテスト",
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
            ]
        ]
        
        // 선택된 언어에 해당하는 번역이 있으면 반환, 없으면 원본 문자열 반환
        return translations[language]?[self] ?? self
    }
}

@main
struct kordicApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
