import SwiftUI
import Foundation

// 전역 싱글톤 상태 관리자
class ModuleProgressManager: ObservableObject {
    static let shared = ModuleProgressManager()
    
    // UserDefaults 키
    private let MODULE_PROGRESS_KEY_PREFIX = "moduleProgress_"
    private let MODULE_LOCKED_KEY_PREFIX = "moduleLocked_"
    
    @Published var refreshTrigger = UUID()
    
    private init() {
        initializeModulesIfNeeded()
    }
    
    // 최초 실행 시 모듈 초기화
    func initializeModulesIfNeeded() {
        let defaults = UserDefaults.standard
        let isInitialized = defaults.bool(forKey: "modulesInitialized")
        
        if !isInitialized {
            // 첫 번째 모듈은 잠금 해제 상태로 설정
            defaults.set(0.0, forKey: MODULE_PROGRESS_KEY_PREFIX + "0")
            defaults.set(false, forKey: MODULE_LOCKED_KEY_PREFIX + "0")
            
            // 나머지 모듈은 잠금 상태로 설정
            for i in 1..<5 {
                defaults.set(0.0, forKey: MODULE_PROGRESS_KEY_PREFIX + "\(i)")
                defaults.set(true, forKey: MODULE_LOCKED_KEY_PREFIX + "\(i)")
            }
            
            // 초기화 완료 표시
            defaults.set(true, forKey: "modulesInitialized")
            defaults.synchronize()
        }
    }
    
    // 모듈 진행도 가져오기
    func getModuleProgress(_ index: Int) -> Float {
        return UserDefaults.standard.float(forKey: MODULE_PROGRESS_KEY_PREFIX + "\(index)")
    }
    
    // 모듈 잠금 상태 가져오기
    func isModuleLocked(_ index: Int) -> Bool {
        return UserDefaults.standard.bool(forKey: MODULE_LOCKED_KEY_PREFIX + "\(index)")
    }
    
    // 모듈 완료 처리
    func completeModule(_ index: Int) {
        print("모듈 \(index) 완료 처리")
        
        // 현재 모듈을 완료 상태로 설정
        UserDefaults.standard.set(1.0, forKey: MODULE_PROGRESS_KEY_PREFIX + "\(index)")
        
        // 다음 모듈의 잠금을 해제 (있는 경우)
        if index + 1 < 5 {
            UserDefaults.standard.set(false, forKey: MODULE_LOCKED_KEY_PREFIX + "\(index + 1)")
        }
        
        // 강제 동기화 및 UI 갱신 트리거
        UserDefaults.standard.synchronize()
        
        // UI 갱신 트리거
        DispatchQueue.main.async {
            self.refreshTrigger = UUID()
            // NotificationCenter.default.post(name: NSNotification.Name("moduleProgressUpdated"), object: nil) // 홈 화면 강제 이동 문제 해결을 위해 주석 처리
        }
    }
    
    // 총 진행률 계산
    func calculateTotalProgress() -> Int {
        var totalProgress: Float = 0.0
        let moduleCount = 5
        
        for i in 0..<moduleCount {
            totalProgress += getModuleProgress(i)
        }
        
        return moduleCount > 0 ? Int((totalProgress / Float(moduleCount)) * 100) : 0
    }
    
    // 완료된 모듈 수
    func getCompletedModulesCount() -> Int {
        var count = 0
        for i in 0..<5 {
            if getModuleProgress(i) >= 1.0 {
                count += 1
            }
        }
        return count
    }
}

struct Basics1View: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastOffset: CGFloat = 100
    @State private var toastWorkItem: DispatchWorkItem?
    @State private var showLessonView = false
    @State private var selectedModuleIndex = 0
    @State private var refreshID = UUID() // 강제 새로고침을 위한 ID
    @State private var isPresented = false // 모달 표시 여부 제어
    @Environment(\.presentationMode) var presentationMode
    
    // 상태 관리자
    // @ObservedObject private var progressManager = ModuleProgressManager.shared // 주석 처리
    @EnvironmentObject var progressManager: ModuleProgressManager // EnvironmentObject로 변경
    
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
        let pronunciation: String
        let image: String
        
        @Environment(\.colorScheme) var colorScheme
        
        var isDarkMode: Bool {
            return colorScheme == .dark
        }
        
        var body: some View {
            VStack(spacing: 15) {
                // 한국어 단어
                Text(koreanWord)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(isDarkMode ? .white : Color(red: 0.2, green: 0.2, blue: 0.3))
                
                // 발음 가이드
                Text("[\(pronunciation)]")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
                
                // 이미지
                if UIImage(named: image) != nil {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .cornerRadius(10)
                } else if image.hasPrefix("systemName:") {
                    // SF Symbol 이미지 사용
                    let symbolName = String(image.dropFirst(11)) // "systemName:" 접두사 제거
                    Image(systemName: symbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                } else {
                    // 기본 이미지
                    Image(systemName: "text.bubble")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
                
                // 번역/의미
                Text(translation)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isDarkMode ? .white.opacity(0.8) : Color(red: 0.3, green: 0.3, blue: 0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 8)
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
        }
    }
    
    // 모듈 학습 세션 뷰
    struct ModuleLessonView: View {
        let moduleTitle: String
        let moduleIndex: Int
        let onComplete: (Int) -> Void // 모듈 인덱스를 전달하는 콜백
        let onDismiss: () -> Void // 닫기 버튼 누를 때 호출될 콜백
        
        // 모듈 인덱스에 따라 다른 단어 세트 반환
        // (koreanWord, translation, pronunciation, image)
        var moduleLessonWords: [(String, String, String, String)] {
            switch moduleIndex {
            case 0: // 인사(Greetings)
                return [
                    ("시작합니다", "Let's start", "shi-jak-ham-ni-da", "systemName:play.circle"),
                    ("안녕하세요", "Hello", "an-nyeong-ha-se-yo", "systemName:hand.wave"),
                    ("감사합니다", "Thank you", "gam-sa-ham-ni-da", "systemName:heart"),
                    ("미안합니다", "I'm sorry", "mi-an-ham-ni-da", "systemName:face.smiling"),
                    ("반갑습니다", "Nice to meet you", "ban-gap-seum-ni-da", "systemName:person.2")
                ]
            case 1: // 숫자와 시간(Numbers & Time)
                return [
                    ("시작합니다", "Let's start", "shi-jak-ham-ni-da", "systemName:play.circle"),
                    ("하나, 둘, 셋", "One, Two, Three", "ha-na, dul, set", "systemName:number"),
                    ("오후 세시", "3 PM", "o-hu se-shi", "systemName:clock"),
                    ("일주일", "One week", "il-ju-il", "systemName:calendar"),
                    ("지금 몇 시에요?", "What time is it now?", "ji-geum myeot shi-e-yo?", "systemName:clock.fill")
                ]
            case 2: // 일상 대화(Daily Conversation)
                return [
                    ("시작합니다", "Let's start", "shi-jak-ham-ni-da", "systemName:play.circle"),
                    ("오늘 기분이 어때요?", "How do you feel today?", "o-neul gi-bun-i eo-ttae-yo?", "systemName:face.smiling"),
                    ("날씨가 좋아요", "The weather is nice", "nal-ssi-ga jo-a-yo", "systemName:sun.max"),
                    ("어디 가요?", "Where are you going?", "eo-di ga-yo?", "systemName:figure.walk"),
                    ("내일 봐요", "See you tomorrow", "nae-il bwa-yo", "systemName:hand.wave")
                ]
            case 3: // 음식 및 주문(Food & Ordering)
                return [
                    ("시작합니다", "Let's start", "shi-jak-ham-ni-da", "systemName:play.circle"),
                    ("물 주세요", "Water please", "mul ju-se-yo", "systemName:drop"),
                    ("맛있어요", "It's delicious", "ma-shi-sseo-yo", "systemName:hand.thumbsup"),
                    ("얼마예요?", "How much is it?", "eol-ma-ye-yo?", "systemName:wonsign.circle"),
                    ("메뉴 주세요", "Menu please", "me-nyu ju-se-yo", "systemName:doc.text")
                ]
            case 4: // 장소 및 방향(Places & Directions)
                return [
                    ("시작합니다", "Let's start", "shi-jak-ham-ni-da", "systemName:play.circle"),
                    ("어디예요?", "Where is it?", "eo-di-ye-yo?", "systemName:mappin"),
                    ("왼쪽으로 가세요", "Go left", "oen-jjok-eu-ro ga-se-yo", "systemName:arrow.left"),
                    ("멀어요?", "Is it far?", "meo-reo-yo?", "systemName:map"),
                    ("지하철역", "Subway station", "ji-ha-cheol-yeok", "systemName:tram")
                ]
            default:
                return [
                    ("시작합니다", "Let's start", "shi-jak-ham-ni-da", "systemName:play.circle"),
                    ("샘플 단어", "Sample word", "sam-peul dan-eo", "systemName:text.bubble"),
                    ("샘플 문장", "Sample sentence", "sam-peul mun-jang", "systemName:text.bubble")
                ]
            }
        }
        
        @State private var currentIndex = 0
        @State private var slideFromRight = true // true이면 오른쪽에서 왼쪽으로, false이면 왼쪽에서 오른쪽으로
        @AppStorage("isDarkMode") private var isDarkMode = false
        
        var body: some View {
            VStack(spacing: 20) {
                // 상단 헤더
                HStack {
                    Button(action: {
                        // 모달 닫기
                        onDismiss()
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
                    
                    // 진행 카운터 (0/N부터 시작)
                    Text("\(currentIndex)/\(moduleLessonWords.count - 1)")
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
                    
                    // 진행 바 표시 로직 (0%부터 시작)
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: currentIndex == moduleLessonWords.count - 1 ? 
                               // 마지막 단어일 경우 100% 채우기
                               UIScreen.main.bounds.width - 32 : // 양쪽 패딩 16씩 고려
                               // 그 외의 경우 비율에 맞게 채우기 (0부터 시작)
                               UIScreen.main.bounds.width * CGFloat(Float(currentIndex) / Float(moduleLessonWords.count - 1)),
                               height: 6)
                        .cornerRadius(3)
                        .opacity(currentIndex > 0 ? 1 : 0) // 0/N일 때는 보이지 않음
                }
                .padding(.horizontal)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentIndex)
                
                Spacer()
                
                // 항상 단어 카드 또는 시작 화면 표시
                if !moduleLessonWords.isEmpty && currentIndex < moduleLessonWords.count {
                    if currentIndex == 0 {
                        // 시작 화면일 때 간단한 안내 표시
                        VStack(spacing: 20) {
                            Image(systemName: "play.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("시작하기")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("오른쪽 버튼을 눌러 학습을 시작하세요.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
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
                    } else {
                        // 실제 단어 카드 표시 (currentIndex가 1 이상일 때)
                        WordCardView(
                            koreanWord: moduleLessonWords[currentIndex].0,
                            translation: moduleLessonWords[currentIndex].1,
                            pronunciation: moduleLessonWords[currentIndex].2,
                            image: moduleLessonWords[currentIndex].3
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: slideFromRight ? .trailing : .leading),
                            removal: .move(edge: slideFromRight ? .leading : .trailing)
                        ))
                        .id("card-\(currentIndex)") // 애니메이션을 위한 고유 ID
                    }
                }
                
                Spacer()
                
                // 항상 네비게이션 버튼 표시
                HStack(spacing: 40) {
                    // 이전 버튼
                    Button(action: {
                        if currentIndex > 0 {
                            slideFromRight = false // 이전 페이지가 왼쪽에서 들어오고, 현재 페이지는 오른쪽으로 나감
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
                        if currentIndex < moduleLessonWords.count - 1 {
                            slideFromRight = true // 다음 페이지가 오른쪽에서 들어오고, 현재 페이지는 왼쪽으로 나감
                            withAnimation {
                                currentIndex += 1
                            }
                        } else {
                            // 마지막 카드일 경우 완료 처리 및 닫기
                            onComplete(moduleIndex) // 완료 콜백 호출
                            onDismiss()             // 모달 닫기 호출
                        }
                    }) {
                        Image(systemName: currentIndex < moduleLessonWords.count - 1 ? "arrow.right.circle.fill" : "checkmark.circle.fill")
                            .font(.system(size: 46))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(isDarkMode ? Color.black : Color(red: 0.98, green: 0.98, blue: 0.98))
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    // 모듈 데이터 정의
    var modules: [LearningModule] {
        [
            LearningModule(
                title: "Greetings",
                subtitle: "Basic greetings and introductions",
                icon: "bubble.left.fill",
                koreanCharacter: "안",
                progress: progressManager.getModuleProgress(0),
                isLocked: progressManager.isModuleLocked(0)
            ),
            LearningModule(
                title: "Numbers & Time",
                subtitle: "Learn to count and tell time",
                icon: "number",
                koreanCharacter: "일",
                progress: progressManager.getModuleProgress(1),
                isLocked: progressManager.isModuleLocked(1)
            ),
            LearningModule(
                title: "Daily Conversation",
                subtitle: "Everyday expressions",
                icon: "text.bubble.fill",
                koreanCharacter: "말",
                progress: progressManager.getModuleProgress(2),
                isLocked: progressManager.isModuleLocked(2)
            ),
            LearningModule(
                title: "Food & Ordering",
                subtitle: "Restaurant vocabulary",
                icon: "fork.knife",
                koreanCharacter: "밥",
                progress: progressManager.getModuleProgress(3),
                isLocked: progressManager.isModuleLocked(3)
            ),
            LearningModule(
                title: "Places & Directions",
                subtitle: "Locations and getting around",
                icon: "map.fill",
                koreanCharacter: "길",
                progress: progressManager.getModuleProgress(4),
                isLocked: progressManager.isModuleLocked(4)
            )
        ]
    }
    
    var body: some View {
        ZStack {
            // 메인 콘텐츠
            ScrollView {
                VStack(spacing: 25) {
                    Spacer()
                        .frame(height: 20) // 네비게이션 바 아래 공간
                    
                    // 진행 상황 요약
                    HStack(spacing: 20) {
                        // 완료한 모듈 수
                        VStack {
                            Text("\(progressManager.getCompletedModulesCount())")
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
                            Text("\(progressManager.calculateTotalProgress())%")
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
                        ForEach(0..<modules.count, id: \.self) { index in
                            ModuleCardView(module: modules[index]) {
                                handleModuleTap(index)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .id(refreshID) // 강제 새로고침을 위한 ID
                }
                .padding(.bottom, 30)
            }
            .background(isDarkMode ? Color.black : Color(red: 0.98, green: 0.98, blue: 0.98))
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle("Basics 1", displayMode: .large)
            // 핵심 변경 - 네비게이션 백 버튼 숨기지 않음
            .navigationBarBackButtonHidden(false)
            .onAppear {
                // 화면 갱신 트리거
                refreshID = UUID()
            }
            .onChange(of: progressManager.refreshTrigger) { _ in
                // 상태 관리자의 트리거 변화에 따라 화면 갱신
                refreshID = UUID()
            }
            
            // 모달이 표시된 경우 반투명 오버레이
            if showLessonView {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .zIndex(1)
                    .onTapGesture {
                        // 백그라운드 탭 비활성화
                    }
                
                ModuleLessonView(
                    moduleTitle: modules[selectedModuleIndex].title,
                    moduleIndex: selectedModuleIndex,
                    onComplete: { index in
                        // 직접 완료 처리
                        progressManager.completeModule(index)
                    },
                    onDismiss: {
                        // 핵심 변경 - 명시적 닫기 함수
                        withAnimation {
                            showLessonView = false
                        }
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(isDarkMode ? Color.black : Color(red: 0.98, green: 0.98, blue: 0.98))
                )
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showLessonView)
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
    func handleModuleTap(_ index: Int) {
        let module = modules[index]
        if module.isLocked {
            toastMessage = "Complete previous module to unlock"
            showToastMessage()
        } else {
            selectedModuleIndex = index
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