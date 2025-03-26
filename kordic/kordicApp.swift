//
//  kordicApp.swift
//  kordic
//
//  Created by musung on 2025/03/26.
//

import SwiftUI

@main
struct kordicApp: App {
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(languageManager)
        }
    }
}
