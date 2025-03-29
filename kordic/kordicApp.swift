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
        
        let translations: [String: [String: String]] = [
            // English translations
            "English": [
                "Learn Korean": "Learn Korean",
                "Hello!": "Hello!",
                "Continue learning Korean": "Continue learning Korean",
                "Start": "Start",
                "Level Test": "Level Test",
                "Basics 1": "Basics 1",
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
                "App Version": "App Version",
                "Complete Level Test to unlock Basics 1": "Complete Level Test to unlock Basics 1",
                "Complete Level Test to unlock Review Words": "Complete Level Test to unlock Review Words",
                "Complete Level Test to unlock Quiz": "Complete Level Test to unlock Quiz",
                "Next": "Next",
                "See Results": "See Results",
                "Test Completed": "Test Completed",
                "Score: ": "Score: ",
                "Start Again": "Start Again",
                
                // 점수 메시지
                "Excellent! You're a Korean language master!": "Excellent! You're a Korean language master!",
                "Great job! You have a good understanding of Korean!": "Great job! You have a good understanding of Korean!",
                "Good effort! Keep practicing!": "Good effort! Keep practicing!",
                "Don't worry! Practice makes perfect!": "Don't worry! Practice makes perfect!",
                // 문제 번역
                "'사과'는 무엇입니까?": "What is '사과'?",
                // 과일 번역
                "Banana": "Banana",
                "Apple": "Apple",
                "Grape": "Grape",
                "Watermelon": "Watermelon"
            ],
            // Japanese translations
            "日本語": [
                "Learn Korean": "韓国語を学ぶ",
                "Hello!": "こんにちは！",
                "Continue learning Korean": "韓国語学習を続ける",
                "Start": "スタート",
                "Level Test": "レベルテスト",
                "Basics 1": "基礎 1",
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
                "App Version": "アプリバージョン",
                "Complete Level Test to unlock Basics 1": "レベルテストを完了して基礎 1をアンロック",
                "Complete Level Test to unlock Review Words": "レベルテストを完了して単語復習をアンロック",
                "Complete Level Test to unlock Quiz": "レベルテストを完了してクイズをアンロック",
                "Next": "次へ",
                "See Results": "結果を見る",
                "Test Completed": "テスト完了",
                "Score: ": "スコア：",
                "Start Again": "もう一度始める",
                
                // 점수 메시지
                "Excellent! You're a Korean language master!": "素晴らしい！あなたは韓国語のマスターです！",
                "Great job! You have a good understanding of Korean!": "よくできました！韓国語をよく理解しています！",
                "Good effort! Keep practicing!": "頑張りました！練習を続けましょう！",
                "Don't worry! Practice makes perfect!": "心配しないで！練習が完璧を作ります！",
                // 문제 번역
                "'사과'는 무엇입니까?": "'사과'は何ですか？",
                // 과일 번역
                "Banana": "バナナ",
                "Apple": "りんご",
                "Grape": "ぶどう",
                "Watermelon": "スイカ"
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
