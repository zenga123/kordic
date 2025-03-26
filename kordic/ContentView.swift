//
//  ContentView.swift
//  kordic
//
//  Created by musung on 2025/03/26.
//

import SwiftUI

struct ContentView: View {
    @State private var showSettings = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 설정 아이콘
                HStack {
                    Spacer()
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                            .padding()
                    }
                }
                
                // 앱 제목
                Text("Learn Korean")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                    .padding(.top, -30) // 제목을 위로 올림
                
                // 캐릭터 이미지
                Image("korean_girl_character")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 220, height: 220)
                    .padding(.vertical, 10)
                
                // 인사말 텍스트
                Text("Hello!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                
                // 계속 학습 메시지
                Text("Continue learning Korean")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
                
                // 시작 버튼
                Button(action: {
                    // 시작 기능 구현
                }) {
                    Text("Start")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.3, green: 0.5, blue: 0.9))
                        .cornerRadius(30)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                // 학습 카테고리 목록
                VStack(spacing: 15) {
                        // Basics 1
                    LearningCategoryView(
                        icon: "speaker.wave.2.fill",
                        title: "Basics 1",
                        subtitle: "",
                        progress: "0/4",
                        isLocked: false,
                        progressValue: nil
                    )
                    .padding(.bottom, 0)
                    
                    // Basics 2
                    LearningCategoryView(
                        icon: "lock.fill",
                        title: "Basics 2",
                        subtitle: "",
                        progress: "",
                        isLocked: true,
                        progressValue: 0
                    )
                    .padding(.bottom, 0)
                    
                    // Review Words
                    KoreanCharacterCategoryView(
                        title: "Review Words",
                        subtitle: "Practice your vocabulary",
                        koreanChar: "가"
                    )
                    .padding(.bottom, 0)
                    
                    // Quiz
                    QuizCategoryView(
                        title: "Quiz",
                        subtitle: "Test your knowledge"
                    )
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        .edgesIgnoringSafeArea(.bottom)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}
