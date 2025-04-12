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
    @AppStorage("levelTestCurrentQuestionIndex") private var levelTestProgress = 0
    @AppStorage("levelTestScore") private var levelTestScore = 0
    @AppStorage("levelTestCompleted") private var levelTestCompleted = false
    @State private var refreshID = UUID() // 화면 새로고침용 ID
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastOffset: CGFloat = 100 // 토스트가 화면 바깥에 있게 시작
    @State private var toastWorkItem: DispatchWorkItem? // 토스트 타이머 참조를 저장
    @State private var showLevelTest = false // 레벨 테스트 화면 표시 여부
    
    // 애니메이션 상태 변수
    @State private var isAnimating = false
    @AppStorage("moveTestDown") private var moveTestDown = false
    @AppStorage("unlockBasics") private var unlockBasics = false
    
    // 레벨 배지 관련 변수 
    @AppStorage("userLevel") private var userLevel = 0
    @State private var showLevelBadge = false
    
    // 애니메이션 단계 제어
    @State private var animationStage = 0
    
    // 레벨 테스트 스택 애니메이션 제어
    @State private var levelTestOffsetY: CGFloat = 0
    @State private var basicsOffsetY: CGFloat = 0
    @State private var reviewWordsOffsetY: CGFloat = 0
    @State private var quizOffsetY: CGFloat = 0
    
    // 스케일 및 불투명도 제어
    @State private var levelTestScale: CGFloat = 1.0
    @State private var levelTestOpacity: Double = 1.0
    @State private var basicsScale: CGFloat = 1.0
    @State private var basicsOpacity: Double = 1.0
    @State private var reviewWordsScale: CGFloat = 1.0
    @State private var reviewWordsOpacity: Double = 1.0
    @State private var quizScale: CGFloat = 1.0
    @State private var quizOpacity: Double = 1.0
    
    // 새로운 위치의 레벨 테스트 컨트롤
    @State private var showMovedLevelTest: Bool = false
    @State private var movedLevelTestOpacity: Double = 0.0
    @State private var movedLevelTestScale: CGFloat = 0.95
    
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
                    
                    // 캐릭터 이미지와 레벨 배지
                    ZStack(alignment: .topTrailing) {
                        // 캐릭터 이미지 - 배경 제거
                        Image("korean_girl_character")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 220, height: 220)
                            .padding(.vertical, 10)
                            .background(Color.clear) // 배경을 투명하게 설정
                            .clipShape(Circle()) // 선택적: 원형으로 이미지를 자르기
                        
                        // 레벨 테스트가 완료되면 레벨 배지 표시
                        if levelTestCompleted && userLevel > 0 {
                            Image("level_badge_\(userLevel)")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 75, height: 75)
                                .offset(x: 10, y: 20)
                                .transition(.scale.combined(with: .opacity))
                                .scaleEffect(showLevelBadge ? 1.0 : 0.1)
                                .opacity(showLevelBadge ? 1.0 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.5), value: showLevelBadge)
                        }
                    }
                    
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
                        // 카테고리 순서를 애니메이션으로 변경
                        if moveTestDown {
                            // Basics 1 (레벨 테스트 완료 시 잠금 해제)
                            NavigationLink(destination: Basics1View()) {
                                LearningCategoryView(
                                    icon: unlockBasics ? "book.fill" : "lock.fill",
                                    title: "Basics 1".localized(),
                                    subtitle: "",
                                    progress: "",
                                    isLocked: !unlockBasics,
                                    progressValue: 0
                                )
                                .padding(.bottom, 0)
                                .id("basics1") // 식별자 추가
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(!unlockBasics)
                            .onTapGesture {
                                if !unlockBasics {
                                    toastMessage = "Complete Level Test to unlock Basics 1".localized()
                                    showToastMessage()
                                }
                            }
                            .scaleEffect(unlockBasics ? 1.0 : 0.95)
                            .shadow(color: unlockBasics ? Color.blue.opacity(0.3) : Color.clear, radius: unlockBasics ? 10 : 0)
                            
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
                            
                            // Level Test (이제 가장 아래로)
                            if showMovedLevelTest {
                                NavigationLink(destination: LevelTestView()) {
                                    LearningCategoryView(
                                        icon: "graduationcap.fill",
                                        title: "Level Test".localized(),
                                        subtitle: "",
                                        progress: "\(levelTestProgress)/\(LevelTestView.totalQuestions)",
                                        isLocked: false,
                                        progressValue: levelTestProgress >= LevelTestView.totalQuestions ? 
                                            1.0 : 
                                            (levelTestProgress > 0 ? 
                                             Float(levelTestProgress) / Float(LevelTestView.totalQuestions) : 0.0)
                                    )
                                    .padding(.bottom, 0)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .id("leveltest-bottom")
                                .scaleEffect(movedLevelTestScale)
                                .opacity(movedLevelTestOpacity)
                            }
                        } else {
                            // 기존 순서 (레벨 테스트가 맨 위)
                            // Level Test
                            NavigationLink(destination: LevelTestView()) {
                                LearningCategoryView(
                                    icon: "graduationcap.fill",
                                    title: "Level Test".localized(),
                                    subtitle: "",
                                    progress: "\(levelTestProgress)/\(LevelTestView.totalQuestions)",
                                    isLocked: false,
                                    progressValue: levelTestProgress >= LevelTestView.totalQuestions ? 
                                        1.0 : 
                                        (levelTestProgress > 0 ? 
                                         Float(levelTestProgress) / Float(LevelTestView.totalQuestions) : 0.0)
                                )
                                .padding(.bottom, 0)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .id("leveltest-top")
                            .offset(y: levelTestOffsetY)
                            .scaleEffect(levelTestScale)
                            .opacity(levelTestOpacity)
                            
                            // Basics 1
                            NavigationLink(destination: Basics1View()) {
                                LearningCategoryView(
                                    icon: "lock.fill",
                                    title: "Basics 1".localized(),
                                    subtitle: "",
                                    progress: "",
                                    isLocked: true,
                                    progressValue: 0
                                )
                                .padding(.bottom, 0)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(true)
                            .onTapGesture {
                                toastMessage = "Complete Level Test to unlock Basics 1".localized()
                                showToastMessage()
                            }
                            .offset(y: basicsOffsetY)
                            .scaleEffect(basicsScale)
                            .opacity(basicsOpacity)
                            
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
                            .offset(y: reviewWordsOffsetY)
                            .scaleEffect(reviewWordsScale)
                            .opacity(reviewWordsOpacity)
                            
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
                            .offset(y: quizOffsetY)
                            .scaleEffect(quizScale)
                            .opacity(quizOpacity)
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
        .onAppear {
            // 초기 상태 설정
            resetAnimationState()
            
            // 이미 Basics1이 잠금 해제되었다면, moveTestDown도 true로 설정해야 함
            if unlockBasics && !moveTestDown {
                moveTestDown = true
                showMovedLevelTest = true
                movedLevelTestOpacity = 1.0
                movedLevelTestScale = 1.0
            }
            
            // 테스트가 완료되었지만 아직 애니메이션을 보여주지 않았다면
            if levelTestProgress >= LevelTestView.totalQuestions && !isAnimating && !unlockBasics && !moveTestDown {
                startSequentialAnimation()
            } else if levelTestCompleted && !showLevelBadge {
                // 이미 테스트가 완료되었고 배지가 표시되지 않은 경우 즉시 표시
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        showLevelBadge = true
                    }
                }
            }
            
            // 레벨 테스트 완료 알림 수신 설정
            NotificationCenter.default.addObserver(forName: NSNotification.Name("levelTestCompleted"), object: nil, queue: .main) { _ in
                // 이미 애니메이션 중인지 확인
                if !isAnimating && !unlockBasics && !moveTestDown {
                    resetAnimationState()
                    startSequentialAnimation()
                }
            }
        }
        .onDisappear {
            // 화면이 사라질 때 옵저버 제거
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("levelTestCompleted"), object: nil)
        }
    }
    
    // 애니메이션 상태 초기화
    func resetAnimationState() {
        // 오프셋 초기화
        levelTestOffsetY = 0
        basicsOffsetY = 0
        reviewWordsOffsetY = 0
        quizOffsetY = 0
        
        // 스케일 및 불투명도 초기화
        levelTestScale = 1.0
        levelTestOpacity = 1.0
        basicsScale = 1.0
        basicsOpacity = 1.0
        reviewWordsScale = 1.0
        reviewWordsOpacity = 1.0
        quizScale = 1.0
        quizOpacity = 1.0
        
        // 새 위치의 레벨 테스트 초기화
        movedLevelTestOpacity = 0.0
        movedLevelTestScale = 0.95
        showMovedLevelTest = false
        
        // 애니메이션 단계 초기화
        animationStage = 0
    }
    
    // 순차적 애니메이션 시작
    func startSequentialAnimation() {
        isAnimating = true
        
        // 각 항목의 높이와 딜레이
        let itemHeight: CGFloat = 85
        let baseAnimationDuration = 0.4
        let delayBetweenItems = 0.15
        
        // 레벨 테스트가 아래로 내려가기 시작 (살짝 위로 올라갔다가 내려가는 효과)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                // 먼저 살짝 위로 튀어오르는 효과
                levelTestOffsetY = -10
            }
            
            // 그 다음 아래로 내려가기 시작
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: baseAnimationDuration + 0.3, dampingFraction: 0.65)) {
                    levelTestOffsetY = itemHeight  // 한 칸 아래로
                }
                
                // Basics1이 위로 올라오기 시작
                DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenItems) {
                    withAnimation(.spring(response: baseAnimationDuration, dampingFraction: 0.7)) {
                        basicsOffsetY = -itemHeight  // 한 칸 위로
                        basicsScale = 1.03  // 살짝 커졌다가
                    }
                    
                    // 레벨 테스트가 한 칸 더 내려가고, Basics1의 스케일 정상화
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: baseAnimationDuration, dampingFraction: 0.7)) {
                            levelTestOffsetY = itemHeight * 2  // 두 칸 아래로
                            basicsScale = 1.0  // 스케일 정상화
                        }
                        
                        // Review Words가 위로 올라오기 시작
                        DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenItems) {
                            withAnimation(.spring(response: baseAnimationDuration, dampingFraction: 0.7)) {
                                reviewWordsOffsetY = -itemHeight  // 한 칸 위로
                                reviewWordsScale = 1.03  // 살짝 커졌다가
                            }
                            
                            // 레벨 테스트가 한 칸 더 내려가고, Review Words의 스케일 정상화
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.spring(response: baseAnimationDuration, dampingFraction: 0.7)) {
                                    levelTestOffsetY = itemHeight * 3  // 세 칸 아래로
                                    reviewWordsScale = 1.0  // 스케일 정상화
                                }
                                
                                // Quiz가 위로 올라오기 시작
                                DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenItems) {
                                    withAnimation(.spring(response: baseAnimationDuration, dampingFraction: 0.7)) {
                                        quizOffsetY = -itemHeight  // 한 칸 위로
                                        quizScale = 1.03  // 살짝 커졌다가
                                    }
                                    
                                    // 최종 위치로 모든 항목 정리
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        withAnimation(.spring(response: baseAnimationDuration, dampingFraction: 0.7)) {
                                            quizScale = 1.0  // 스케일 정상화
                                        }
                                        
                                        // 레벨 테스트 항목 서서히 사라지게
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                levelTestOpacity = 0
                                            }
                                            
                                            // 뷰 구조 변경 및 새 위치에 레벨 테스트 표시
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                // 뷰 구조 변경
                                                moveTestDown = true
                                                showMovedLevelTest = true
                                                
                                                // 새 위치의 레벨 테스트 서서히 나타나게
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                                        movedLevelTestOpacity = 1.0
                                                        movedLevelTestScale = 1.0
                                                    }
                                                    
                                                    // 약간의 지연 후 잠금 해제 애니메이션
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                                                            unlockBasics = true
                                                            levelTestCompleted = true
                                                            
                                                            // 레벨 설정 (점수에 따라)
                                                            if levelTestScore == LevelTestView.totalQuestions {
                                                                userLevel = 3 // 만점이면 레벨 3
                                                            } else if levelTestScore >= LevelTestView.totalQuestions * 2 / 3 {
                                                                userLevel = 2 // 2/3 이상이면 레벨 2
                                                            } else {
                                                                userLevel = 1 // 기본 레벨 1
                                                            }
                                                        }
                                                        
                                                        // 배지 표시 애니메이션 활성화
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                            withAnimation {
                                                                showLevelBadge = true
                                                            }
                                                            
                                                            // 잠금 해제 메시지 표시
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                                toastMessage = "Basics 1 is now unlocked!".localized()
                                                                showToastMessage()
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
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