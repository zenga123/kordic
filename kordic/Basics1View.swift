import SwiftUI

struct Basics1View: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastOffset: CGFloat = 100
    @State private var toastWorkItem: DispatchWorkItem?
    @State private var showLessonView = false
    @Environment(\.presentationMode) var presentationMode
    
    // 모듈 데이터 모델
    struct LearningModule: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let icon: String
        let koreanCharacter: String
        var progress: Float
        var isLocked: Bool
    }
    
    // 카드 뷰 컴포넌트 - 학습 모듈에 사용
    struct ModuleCardView: View {
        let module: LearningModule
        let onTap: () -> Void
        
        @Environment(\.colorScheme) var colorScheme
        
        var isDarkMode: Bool {
            return colorScheme == .dark
        }
        
        var body: some View {
            Button(action: onTap) {
                HStack(spacing: 15) {
                    // 왼쪽: 한글 문자 또는 아이콘
                    ZStack {
                        Circle()
                            .fill(module.isLocked ? Color.gray.opacity(0.3) : Color(red: 0.3, green: 0.5, blue: 0.9))
                            .frame(width: 60, height: 60)
                        
                        if module.koreanCharacter.isEmpty {
                            Image(systemName: module.icon)
                                .font(.title)
                                .foregroundColor(module.isLocked ? .gray : .white)
                        } else {
                            Text(module.koreanCharacter)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(module.isLocked ? .gray : .white)
                        }
                    }
                    
                    // 중앙: 제목과 부제목
                    VStack(alignment: .leading, spacing: 4) {
                        Text(module.title.localized())
                            .font(.headline)
                            .foregroundColor(module.isLocked ? .gray : (isDarkMode ? .white : Color(red: 0.2, green: 0.2, blue: 0.3)))
                        
                        Text(module.subtitle.localized())
                            .font(.subheadline)
                            .foregroundColor(module.isLocked ? .gray.opacity(0.7) : .secondary)
                        
                        // 진행 상태 바
                        if !module.isLocked {
                            ZStack(alignment: .leading) {
                                // 배경 바
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 6)
                                    .cornerRadius(3)
                                
                                // 실제 진행 바 - progress가 0보다 큰 경우에만 표시
                                if module.progress > 0 {
                                    GeometryReader { geometry in
                                        Rectangle()
                                            .fill(Color(red: 0.3, green: 0.5, blue: 0.9))
                                            .frame(width: module.progress >= 0.99 ?
                                                   geometry.size.width : // 완료 시 부모 너비 전체 사용
                                                   geometry.size.width * CGFloat(module.progress),
                                                   height: 6)
                                            .cornerRadius(3)
                                    }
                                    .frame(height: 6) // 높이 고정
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    
                    Spacer()
                    
                    // 오른쪽: 잠금 아이콘 또는 화살표
                    if module.isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                    } else {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isDarkMode ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(module.isLocked ? Color.gray.opacity(0.3) : Color.blue.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: module.isLocked ? Color.clear : Color.blue.opacity(0.1), radius: 5, x: 0, y: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // 학습 단어 카드 컴포넌트
    struct WordCardView: View {
        let koreanWord: String
        let translation: String
        let image: String
        
        @Environment(\.colorScheme) var colorScheme
        @State private var isFlipped = false
        
        var isDarkMode: Bool {
            return colorScheme == .dark
        }
        
        var body: some View {
            VStack {
                ZStack {
                    // 앞면 (한국어)
                    VStack(spacing: 15) {
                        Text(koreanWord)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(isDarkMode ? .white : Color(red: 0.2, green: 0.2, blue: 0.3))
                        
                        Image(image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .cornerRadius(10)
                        
                        Button(action: {
                            // 소리 재생 기능 (추후 구현)
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(Color.blue))
                        }
                    }
                    .opacity(isFlipped ? 0 : 1)
                    .rotation3DEffect(
                        .degrees(isFlipped ? 180 : 0),
                        axis: (x: 0.0, y: 1.0, z: 0.0)
                    )
                    
                    // 뒷면 (번역)
                    VStack(spacing: 15) {
                        Text(translation.localized())
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(isDarkMode ? .white : Color(red: 0.2, green: 0.2, blue: 0.3))
                        
                        Image(image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .cornerRadius(10)
                            .opacity(0.7)
                        
                        Text(koreanWord)
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isDarkMode ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color(red: 0.95, green: 0.95, blue: 0.95))
                            )
                    }
                    .opacity(isFlipped ? 1 : 0)
                    .rotation3DEffect(
                        .degrees(isFlipped ? 0 : -180),
                        axis: (x: 0.0, y: 1.0, z: 0.0)
                    )
                }
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isDarkMode ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
                .onTapGesture {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        isFlipped.toggle()
                    }
                }
            }
        }
    }
    
    // 모듈 학습 세션 뷰
    struct ModuleLessonView: View {
        let moduleTitle: String
        
        // 샘플 데이터
        let words = [
            ("안녕하세요", "Hello", "greeting_image"),
            ("감사합니다", "Thank you", "thankyou_image"),
            ("네", "Yes", "yes_image")
        ]
        
        @State private var currentIndex = 0
        @Environment(\.presentationMode) var presentationMode
        @AppStorage("isDarkMode") private var isDarkMode = false
        
        var body: some View {
            VStack(spacing: 20) {
                // 상단 헤더
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text(moduleTitle.localized())
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    // 진행 카운터
                    Text("\(currentIndex + 1)/\(words.count)")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 15)
                
                // 진행 상태 바
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    // currentIndex가 0보다 큰 경우에만 진행 바 표시
                    if currentIndex > 0 {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: UIScreen.main.bounds.width * CGFloat(Float(currentIndex) / Float(words.count)), height: 6)
                            .cornerRadius(3)
                    }
                }
                .padding(.horizontal)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentIndex)
                
                Spacer()
                
                // 현재 단어 카드
                if !words.isEmpty && currentIndex < words.count {
                    WordCardView(
                        koreanWord: words[currentIndex].0,
                        translation: words[currentIndex].1,
                        image: words[currentIndex].2
                    )
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    .id("card-\(currentIndex)") // 애니메이션을 위한 고유 ID
                }
                
                Spacer()
                
                // 네비게이션 버튼
                HStack(spacing: 40) {
                    // 이전 버튼
                    Button(action: {
                        if currentIndex > 0 {
                            withAnimation {
                                currentIndex -= 1
                            }
                        }
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 46))
                            .foregroundColor(currentIndex > 0 ? .blue : .gray.opacity(0.5))
                    }
                    .disabled(currentIndex == 0)
                    
                    // 다음 버튼
                    Button(action: {
                        if currentIndex < words.count - 1 {
                            withAnimation {
                                currentIndex += 1
                            }
                        } else {
                            // 마지막 카드일 경우 완료 처리
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Image(systemName: currentIndex < words.count - 1 ? "arrow.right.circle.fill" : "checkmark.circle.fill")
                            .font(.system(size: 46))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
            .background(isDarkMode ? Color.black : Color(red: 0.98, green: 0.98, blue: 0.98))
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    @State private var modules = [
        LearningModule(title: "Greetings", subtitle: "Basic greetings and introductions", icon: "bubble.left.fill", koreanCharacter: "안", progress: 0.0, isLocked: false),
        LearningModule(title: "Numbers & Time", subtitle: "Learn to count and tell time", icon: "number", koreanCharacter: "일", progress: 0.0, isLocked: true),
        LearningModule(title: "Daily Conversation", subtitle: "Everyday expressions", icon: "text.bubble.fill", koreanCharacter: "말", progress: 0.0, isLocked: true),
        LearningModule(title: "Food & Ordering", subtitle: "Restaurant vocabulary", icon: "fork.knife", koreanCharacter: "밥", progress: 0.0, isLocked: true),
        LearningModule(title: "Places & Directions", subtitle: "Locations and getting around", icon: "map.fill", koreanCharacter: "길", progress: 0.0, isLocked: true)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Spacer()
                    .frame(height: 20) // 네비게이션 바 아래 공간
                
                // 진행 상황 요약
                HStack(spacing: 20) {
                    // 완료한 모듈 수
                    VStack {
                        Text("0")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("Completed".localized())
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(isDarkMode ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    
                    // 전체 진행률
                    VStack {
                        Text("0%")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.green)
                        
                        Text("Progress".localized())
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(isDarkMode ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    
                    // 학습 스트릭
                    VStack {
                        Text("1")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("Day Streak".localized())
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(isDarkMode ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                }
                .padding(.horizontal)
                
                // 모듈 목록 제목
                HStack {
                    Text("Learning Modules".localized())
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(isDarkMode ? .white : Color(red: 0.2, green: 0.2, blue: 0.3))
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // 모듈 목록
                VStack(spacing: 15) {
                    ForEach(modules) { module in
                        ModuleCardView(module: module) {
                            handleModuleTap(module)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .background(isDarkMode ? Color.black : Color(red: 0.98, green: 0.98, blue: 0.98))
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitle("Basics 1", displayMode: .large)
        .navigationBarBackButtonHidden(false)
        .fullScreenCover(isPresented: $showLessonView) {
            if let module = modules.first(where: { !$0.isLocked }) {
                ModuleLessonView(moduleTitle: module.title)
            }
        }
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
    
    // 모듈 탭 처리 함수
    func handleModuleTap(_ module: LearningModule) {
        if module.isLocked {
            toastMessage = "Complete previous module to unlock"
            showToastMessage()
        } else {
            showLessonView = true
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

struct Basics1View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Basics1View()
        }
    }
}