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
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    @State private var refreshID = UUID() // 화면 새로고침용 ID
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastOffset: CGFloat = 100 // 토스트가 화면 바깥에 있게 시작
    @State private var toastWorkItem: DispatchWorkItem? // 토스트 타이머 참조를 저장
    @State private var showLevelTest = false // 레벨 테스트 화면 표시 여부
    
    var body: some View {
        NavigationView {
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
                                .foregroundColor(.blue) // 항상 파란색으로 고정
                                .padding()
                        }
                    }
                    
                    // 앱 제목
                    Text("Learn Korean".localized())
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.2, green: 0.2, blue: 0.3))
                        .padding(.top, -30) // 제목을 위로 올림
                    
                    // 캐릭터 이미지 - 배경 제거
                    Image("korean_girl_character")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 220, height: 220)
                        .padding(.vertical, 10)
                        .background(Color.clear) // 배경을 투명하게 설정
                        .clipShape(Circle()) // 선택적: 원형으로 이미지를 자르기
                    
                    // 인사말 텍스트
                    Text("Hello!".localized())
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.2, green: 0.2, blue: 0.3))
                    
                    // 계속 학습 메시지
                    Text("Continue learning Korean".localized())
                        .font(.system(size: 24))
                        .foregroundColor(isDarkMode ? Color.gray : Color(red: 0.4, green: 0.4, blue: 0.5))
                    
                    // 시작 버튼
                    NavigationLink(destination: LevelTestView()) {
                        Text("Start".localized())
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
                        // Level Test
                        NavigationLink(destination: LevelTestView()) {
                            LearningCategoryView(
                                icon: "graduationcap.fill",
                                title: "Level Test".localized(),
                                subtitle: "",
                                progress: "0/4",
                                isLocked: false,
                                progressValue: nil
                            )
                            .padding(.bottom, 0)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Basics 1
                        LearningCategoryView(
                            icon: "lock.fill",
                            title: "Basics 1".localized(),
                            subtitle: "",
                            progress: "",
                            isLocked: true,
                            progressValue: 0
                        )
                        .padding(.bottom, 0)
                        .onTapGesture {
                            toastMessage = "Complete Level Test to unlock Basics 1".localized()
                            showToastMessage()
                        }
                        
                        // Review Words
                        KoreanCharacterCategoryView(
                            title: "Review Words".localized(),
                            subtitle: "Practice your vocabulary".localized(),
                            koreanChar: "가",
                            isLocked: true
                        )
                        .padding(.bottom, 0)
                        .onTapGesture {
                            toastMessage = "Complete Level Test to unlock Review Words".localized()
                            showToastMessage()
                        }
                        
                        // Quiz
                        QuizCategoryView(
                            title: "Quiz".localized(),
                            subtitle: "Test your knowledge".localized(),
                            isLocked: true
                        )
                        .onTapGesture {
                            toastMessage = "Complete Level Test to unlock Quiz".localized()
                            showToastMessage()
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .navigationBarHidden(true)
            }
            .id(refreshID) // 고유 ID를 통해 뷰를 새로고침
            .sheet(isPresented: $showSettings) {
                SettingsView(onLanguageChange: {
                    // 언어 변경 시 화면 새로고침
                    refreshID = UUID()
                })
            }
            .background(isDarkMode ? Color.black : Color(red: 0.98, green: 0.98, blue: 0.98))
            .edgesIgnoringSafeArea(.bottom)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .overlay(
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        
                        // 토스트 메시지
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.white)
                                .padding(.trailing, 5)
                            Text(toastMessage)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(red: 0.3, green: 0.5, blue: 0.9))
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                        .opacity(showToast ? 1 : 0)
                        .offset(y: toastOffset)
                    }
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // 토스트 메시지 표시 함수
    func showToastMessage() {
        // 이전 작업이 있다면 취소
        toastWorkItem?.cancel()
        
        // 이미 토스트가 보이고 있는 경우
        if showToast {
            // 기존 토스트 애니메이션 중단하고 새 메시지로 바로 교체
            toastMessage = toastMessage
            
            // 새로운 사라짐 타이머 설정
            let newWorkItem = DispatchWorkItem {
                // 아래로 내려가는 애니메이션
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    self.toastOffset = 100
                }
                
                // 애니메이션 완료 후 토스트 숨김
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showToast = false
                    // 다음 표시를 위해 오프셋 초기화
                    self.toastOffset = 100
                }
            }
            
            // 새 타이머 저장 및 실행
            toastWorkItem = newWorkItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: newWorkItem)
            
            return
        }
        
        // 새로운 토스트 표시 (이전에 표시되지 않았던 경우)
        showToast = true
        
        // 바닥에서 올라오는 애니메이션
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            toastOffset = 0
        }
        
        // 3초 후 사라짐 - 작업 아이템으로 생성하여 나중에 취소 가능하도록 함
        let workItem = DispatchWorkItem {
            // 아래로 내려가는 애니메이션
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                self.toastOffset = 100
            }
            
            // 애니메이션 완료 후 토스트 숨김
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showToast = false
                // 다음 표시를 위해 오프셋 초기화
                self.toastOffset = 100
                self.toastWorkItem = nil
            }
        }
        
        // 작업 아이템 저장 및 실행
        toastWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: workItem)
    }
}

#Preview {
    ContentView()
}
