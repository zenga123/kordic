//
//  SettingsView.swift
//  kordic
//
//  Created by musung on 2025/03/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let languages = ["English", "日本語"]
    var onLanguageChange: (() -> Void)? // 언어 변경 콜백
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Language Settings".localized())) {
                    Picker("Select Language".localized(), selection: $selectedLanguage) {
                        ForEach(languages, id: \.self) { language in
                            Text(language).tag(language)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedLanguage) { newValue in
                        print("언어 변경됨: \(newValue)")
                        
                        // UserDefaults에 직접 저장 (확실하게)
                        UserDefaults.standard.set(newValue, forKey: "selectedLanguage")
                        UserDefaults.standard.synchronize()
                        
                        // 콜백 호출
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onLanguageChange?()
                        }
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
    }
}

#Preview {
    SettingsView(onLanguageChange: nil)
}
