//
//  SettingsView.swift
//  kordic
//
//  Created by musung on 2025/03/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var languageManager: LanguageManager
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var refreshID = UUID() // 강제 새로고침을 위한 ID
    
    let languages = ["English", "日本語"]
    
    var body: some View {
        RefreshableView(content: {
            NavigationView {
                Form {
                    Section(header: Text("Language Settings".localized())) {
                        Picker("Select Language".localized(), selection: $languageManager.currentLanguage) {
                            ForEach(languages, id: \.self) { language in
                                Text(language).tag(language)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: languageManager.currentLanguage) { _ in
                            // 언어가 변경될 때 뷰 새로고침
                            refreshID = UUID()
                        }
                    }
                    
                    Section(header: Text("Display Settings".localized())) {
                        Toggle("Dark Mode".localized(), isOn: $isDarkMode)
                    }
                    
                    Section(header: Text("Information".localized())) {
                        HStack {
                            Text("App Version".localized())
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .navigationTitle("Settings".localized())
                .navigationBarItems(
                    leading: Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                )
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }, refreshID: refreshID)
    }
}

#Preview {
    SettingsView()
        .environmentObject(LanguageManager.shared)
}
