import SwiftUI
import Combine // Import Combine for Timer

// MARK: - Data Models

struct Question {
    let text: String
    let options: [String]
    let correctAnswer: Int
    let questionType: QuestionType

    enum QuestionType {
        case fillInBlank    // 단어 넣기 문제
        case translation    // 번역 문제
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint         // Current position on screen
    var destination: CGPoint      // Burst destination (where it aims initially after exploding)
    var fallDestination: CGPoint  // Final off-screen target (guides overall drift direction)
    var color: Color
    var size: CGSize
    var rotation: Angle
    var rotationSpeed: Angle      // Base rotation speed (less impactful with tilt)
    var opacity: Double = 1.0
    var scale: CGFloat = 1.0
    var creationTime = Date()     // Timestamp for animation calculation

    // --- Flutter Properties ---
    var flutterAmplitude: CGFloat // Max horizontal sway distance
    var flutterFrequency: Double  // Speed of the sway (radians per second)
    var flutterPhase: Double      // Initial offset in the sway cycle (random start point)
}

// MARK: - Main View

struct LevelTestView: View {
    // MARK: - State Variables
    @AppStorage("levelTestCurrentQuestionIndex") private var currentQuestionIndex = 0
    @AppStorage("levelTestScore") private var score = 0
    @State private var selectedAnswerIndex: Int? = nil
    @Environment(\.presentationMode) var presentationMode

    // --- Confetti State ---
    @State private var confetti: [ConfettiParticle] = []
    @State private var showCompletionEffect = false // Flag to trigger confetti on completion
    
    // --- 애니메이션 관련 State 변수 추가 ---
    @State private var isAnimatingOut = false
    @State private var animateComplete = false

    // --- Animation Timer ---
    @State private var animationTimer: Timer.TimerPublisher = Timer.publish(every: 1/60, on: .main, in: .common)
    @State private var cancellableTimer: Cancellable? = nil

    // --- Constants ---
    static let totalQuestions = 3 // 테스트 총 문제 수 - 홈 화면에서 참조하기 위해 static으로 선언
    
    let questions = [
        Question(text: "나( ) 밥을 먹었어요.", options: ["이", "가", "을", "는"], correctAnswer: 3, questionType: .fillInBlank),
        Question(text: "'사과'는 무엇입니까?".localized(), options: ["Banana".localized(), "Apple".localized(), "Grape".localized(), "Watermelon".localized()], correctAnswer: 1, questionType: .translation),
        Question(text: "다음 글을 읽고, 맞는 내용을 고르세요.".localized() + "\n민수는 오늘 도서관에 갔어요. 책을 다섯 권 빌렸습니다.", options: ["민수는 오늘 영화를 봤습니다.", "민수는 친구를 만났습니다.", "민수는 책을 빌렸습니다.", "민수는 도서관에서 일했습니다."], correctAnswer: 2, questionType: .fillInBlank)
    ]

    // --- Confetti Animation Constants ---
    // Define burst origin once, assuming it's constant for the effect
    let burstOrigin = CGPoint(x: UIScreen.main.bounds.width / 2, y: 100)
    // <<--- ADJUSTED DURATION FOR FASTER FALL --->>>
    let totalConfettiAnimationDuration = 3.0 // Further reduced duration
    let confettiBurstDuration = 0.3          // Duration of the initial explosion phase


    // MARK: - Computed Properties
    var progress: CGFloat {
        let total = CGFloat(questions.count)
        // 0부터 시작하도록 수정: +1 제거
        let current = CGFloat(min(currentQuestionIndex, questions.count))
        return total > 0 ? current / total : 0
    }

    var isLastQuestion: Bool {
        return currentQuestionIndex == questions.count - 1
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // Background Color
            Color(.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 0) { // Use spacing 0 and add padding where needed
                // Title
                Text("Level Test")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                    .padding(.bottom, 40) // Add space below title
                    .offset(y: isAnimatingOut ? UIScreen.main.bounds.height : 0)
                    .animation(isAnimatingOut ? .easeInOut(duration: 0.4).delay(0.0) : .none, value: isAnimatingOut)

                // --- Main Content Area ---
                if currentQuestionIndex < questions.count {
                    // --- Question View ---
                    VStack(spacing: 40) {
                        let question = questions[currentQuestionIndex]

                        // Question Text
                        if question.questionType == .fillInBlank {
                            Text("Q. \(question.text)")
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        } else {
                            Text(question.text)
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        // Options Buttons
                        VStack(spacing: 16) {
                            ForEach(0..<question.options.count, id: \.self) { index in
                                Button(action: {
                                    handleAnswerSelection(index: index)
                                }) {
                                    optionButtonContent(question: question, index: index)
                                }
                                .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to prevent default highlighting interfering with custom style
                                .padding(.horizontal)
                            }
                        }
                    }
                } else {
                    // --- Test Completed View ---
                    VStack(spacing: 20) {
                        Text("Test Completed".localized())
                            .font(.title)
                            .fontWeight(.bold)
                            .offset(y: isAnimatingOut ? UIScreen.main.bounds.height : 0)
                            .animation(isAnimatingOut ? .easeInOut(duration: 0.4).delay(0.1) : .none, value: isAnimatingOut)

                        Text("Score: \(score)/\(questions.count)".localized())
                            .font(.title2)
                            .offset(y: isAnimatingOut ? UIScreen.main.bounds.height : 0)
                            .animation(isAnimatingOut ? .easeInOut(duration: 0.4).delay(0.2) : .none, value: isAnimatingOut)

                        Text(getScoreMessage())
                            .font(.headline)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .offset(y: isAnimatingOut ? UIScreen.main.bounds.height : 0)
                            .animation(isAnimatingOut ? .easeInOut(duration: 0.4).delay(0.3) : .none, value: isAnimatingOut)
                        
                        // "홈으로" 버튼
                        Button(action: {
                            // 애니메이션 트리거
                            isAnimatingOut = true
                            
                            // 현재 진행 상황을 명시적으로 저장
                            UserDefaults.standard.set(currentQuestionIndex, forKey: "levelTestCurrentQuestionIndex")
                            UserDefaults.standard.set(score, forKey: "levelTestScore")
                            UserDefaults.standard.set(true, forKey: "levelTestCompleted") // 완료 상태 저장
                            
                            // 사용자 레벨 저장
                            let userLevel: Int
                            if score == self.questions.count {
                                userLevel = 3 // 만점이면 레벨 3
                            } else if score >= self.questions.count * 2 / 3 {
                                userLevel = 2 // 2/3 이상이면 레벨 2
                            } else {
                                userLevel = 1 // 기본 레벨 1
                            }
                            UserDefaults.standard.set(userLevel, forKey: "userLevel")
                            
                            // 알림 센터를 통해 레벨 테스트 완료 이벤트 발송
                            NotificationCenter.default.post(name: NSNotification.Name("levelTestCompleted"), object: nil)
                            
                            UserDefaults.standard.synchronize() // 즉시 저장 강제
                            
                            // 애니메이션이 완료된 후 홈으로 돌아가기
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                // 레벨테스트 화면만 닫히도록 수정
                                presentationMode.wrappedValue.dismiss()
                                isAnimatingOut = false // 상태 초기화
                            }
                        }) {
                            Text("Home".localized())
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 0.3, green: 0.5, blue: 0.9))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .offset(y: isAnimatingOut ? UIScreen.main.bounds.height : 0)
                        .animation(isAnimatingOut ? .easeInOut(duration: 0.4).delay(0.4) : .none, value: isAnimatingOut)
                    }
                    .padding()
                    .onAppear {
                        // Trigger confetti only if the flag is set and animation isn't already running
                        if showCompletionEffect && cancellableTimer == nil {
                            startConfettiAnimation()
                        }
                    }
                    // --- Confetti Overlay ---
                    .overlay(
                        ZStack {
                            ForEach(confetti) { particle in
                                Rectangle()
                                    .fill(particle.color)
                                    .frame(width: particle.size.width, height: particle.size.height)
                                    .rotationEffect(particle.rotation)
                                    .scaleEffect(particle.scale)
                                    .position(particle.position) // Use the calculated position
                                    .opacity(particle.opacity)
                            }
                        }
                        .allowsHitTesting(false) // Allow interaction with views below
                    )
                    // --- Receive animation updates ---
                    .onReceive(animationTimer) { time in
                         updateConfetti(currentTime: time)
                    }
                }

                Spacer() // Pushes content up and progress bar down

                // --- Progress Bar ---
                if currentQuestionIndex < questions.count {
                    VStack(spacing: 8) { // Group progress bar and text
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(height: 10)
                                .foregroundColor(Color(.systemGray5))
                                .cornerRadius(5)

                            Rectangle()
                                .frame(width: (UIScreen.main.bounds.width * 0.8) * progress, height: 10)
                                .foregroundColor(.blue)
                                .cornerRadius(5)
                                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progress) // Animate progress changes
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.8)

                        Text("\(currentQuestionIndex)/\(questions.count)")
                            .font(.headline)
                    }
                    .padding(.bottom, 40) // Bottom padding for the progress section
                    .offset(y: isAnimatingOut ? UIScreen.main.bounds.height : 0)
                    .animation(isAnimatingOut ? .easeInOut(duration: 0.4).delay(0.5) : .none, value: isAnimatingOut)
                }
            } // End Main VStack
        } // End ZStack
        .navigationBarBackButtonHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar) // Correct modifier for iOS 16+
        .toolbar {
             ToolbarItem(placement: .principal) { EmptyView() } // Hide default title if needed
        }
        .onDisappear {
            // Clean up timer when the view disappears permanently
            stopAnimationTimer()
            
            // 화면이 사라질 때 애니메이션 상태 초기화
            isAnimatingOut = false
        }
    }

    // MARK: - View Helper Functions

    @ViewBuilder
    func optionButtonContent(question: Question, index: Int) -> some View {
        HStack {
            if question.questionType == .fillInBlank {
                Text("\(["a", "b", "c", "d"][index])) \(question.options[index])")
            } else {
                Text(question.options[index])
            }
            Spacer()
            if selectedAnswerIndex == index {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2) // Consistent size
                    .padding(.trailing) // Add padding to the checkmark
            }
        }
        .font(.title3) // Apply font once
        .foregroundColor(.primary)
        .padding() // Padding inside the HStack
        .frame(maxWidth: .infinity) // Ensure button takes full width
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(selectedAnswerIndex == index ? Color.blue.opacity(0.1) : Color(.systemBackground)) // Use systemBackground for light/dark mode
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(selectedAnswerIndex == index ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1.5) // Slightly thicker border
                )
        )
    }

    // MARK: - Logic Functions

    func handleAnswerSelection(index: Int) {
        // If an answer is already selected, this click confirms it
        if selectedAnswerIndex == index {
            // Check if correct
            if index == questions[currentQuestionIndex].correctAnswer {
                score += 1
                UserDefaults.standard.set(score, forKey: "levelTestScore")
            }

            // Move to next question or finish
            if !isLastQuestion {
                currentQuestionIndex += 1
                // 명시적으로 UserDefaults에 진행도 저장
                UserDefaults.standard.set(currentQuestionIndex, forKey: "levelTestCurrentQuestionIndex")
                UserDefaults.standard.synchronize() // 즉시 저장 강제
                selectedAnswerIndex = nil // Reset selection for the next question
            } else {
                // Reached the end of the test
                currentQuestionIndex = questions.count // Set index beyond bounds to show completion view
                // 명시적으로 UserDefaults에 진행도 저장
                UserDefaults.standard.set(currentQuestionIndex, forKey: "levelTestCurrentQuestionIndex")
                UserDefaults.standard.set(score, forKey: "levelTestScore")
                UserDefaults.standard.set(true, forKey: "levelTestCompleted") // 완료 상태 저장
                UserDefaults.standard.synchronize() // 즉시 저장 강제
                selectedAnswerIndex = nil // Reset selection
                showCompletionEffect = true // Set flag to trigger confetti
                // Confetti will start via .onAppear of the completion view
            }
        } else {
            // This click selects the answer
            selectedAnswerIndex = index
        }
    }

    func resetTest() {
        // UserDefaults 값도 초기화
        UserDefaults.standard.set(0, forKey: "levelTestCurrentQuestionIndex")
        UserDefaults.standard.set(0, forKey: "levelTestScore")
        currentQuestionIndex = 0
        selectedAnswerIndex = nil
        score = 0
        confetti = [] // Clear any remaining confetti
        showCompletionEffect = false // Reset completion flag
        stopAnimationTimer() // Ensure timer is stopped
    }

    func getScoreMessage() -> String {
        guard questions.count > 0 else { return "No questions available." }
        let percentage = (Double(score) / Double(questions.count)) * 100

        switch percentage {
        case 90...:
            return "Excellent! You're a Korean language master!".localized()
        case 70..<90:
            return "Great job! You have a good understanding of Korean!".localized()
        case 50..<70:
            return "Good effort! Keep practicing!".localized()
        default:
            return "Don't worry! Practice makes perfect!".localized()
        }
    }

    // MARK: - Confetti Animation Functions

    func startConfettiAnimation() {
        stopAnimationTimer() // Ensure no existing timer is running
        confetti = [] // Clear previous particles

        let origin = self.burstOrigin // Use the consistent starting point
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let particleCount = 120
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan, Color(hue: 0.1, saturation: 0.8, brightness: 0.9)]
        let baseSize: CGFloat = 12.0

        for _ in 0..<particleCount {
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 100...250)
            // Destination relative to the actual origin
            let destinationX = origin.x + distance * cos(CGFloat(angle))
            let destinationY = origin.y + distance * sin(CGFloat(angle))

            // Fall target includes wider drift potential
            let fallDestinationX = destinationX + CGFloat.random(in: -screenWidth * 0.3...screenWidth * 0.3)
            let fallDestinationY = screenHeight + baseSize * 15 // Ensure well below screen

            // Flutter properties for leaf-like motion
            let flutterAmplitude = CGFloat.random(in: 40...80) // Wider sway
            let flutterFrequency = Double.random(in: 1.5...3.5) // Slower sway
            let flutterPhase = Double.random(in: 0...(2 * .pi)) // Random start in cycle

            let particle = ConfettiParticle(
                position: origin, // Start each particle at the defined origin
                destination: CGPoint(x: destinationX, y: destinationY),
                fallDestination: CGPoint(x: fallDestinationX, y: fallDestinationY),
                color: colors.randomElement()!,
                size: CGSize(width: baseSize * CGFloat.random(in: 0.7...1.3), height: baseSize * CGFloat.random(in: 1.0...2.5)),
                rotation: Angle(degrees: Double.random(in: 0...360)),
                rotationSpeed: Angle(degrees: Double.random(in: -150...150)), // Slower base spin
                flutterAmplitude: flutterAmplitude,
                flutterFrequency: flutterFrequency,
                flutterPhase: flutterPhase
            )
            confetti.append(particle)
        }
        // Start the animation timer after creating particles
        startAnimationTimer()
    }

    func updateConfetti(currentTime: Date) {
        // Use the defined constants for durations
        let burstDuration = self.confettiBurstDuration
        let totalDuration = self.totalConfettiAnimationDuration

        for index in confetti.indices.reversed() { // Iterate backwards for safe removal
             guard index < confetti.count else { continue } // Boundary check

            let timeElapsed = currentTime.timeIntervalSince(confetti[index].creationTime)
            let particle = confetti[index] // Get a copy for easier property access

            // --- Burst Phase ---
            if timeElapsed < burstDuration {
                let progress = timeElapsed / burstDuration
                // Cubic ease-out for the burst expansion
                let easeOutProgress = 1.0 - pow(1.0 - progress, 3)

                // Interpolate from the *defined origin* to the particle's destination
                let currentBurstX = burstOrigin.x + (particle.destination.x - burstOrigin.x) * easeOutProgress
                let currentBurstY = burstOrigin.y + (particle.destination.y - burstOrigin.y) * easeOutProgress

                confetti[index].position = CGPoint(x: currentBurstX, y: currentBurstY)

                // Apply simple rotation during burst
                confetti[index].rotation += Angle(degrees: particle.rotationSpeed.degrees * (1/60))
            }
            // --- Fall Phase with Flutter ---
            else {
                let fallTimeElapsed = timeElapsed - burstDuration
                guard fallTimeElapsed >= 0 else { continue } // Safety check

                let fallDuration = totalDuration - burstDuration
                guard fallDuration > 0 else { // Avoid division by zero if durations are misconfigured
                    confetti.remove(at: index)
                    continue
                }

                // --- Fall Path Calculation ---
                let startX = particle.destination.x // Fall starts from where the burst ended
                let startY = particle.destination.y
                let endX = particle.fallDestination.x // Target drift X
                let endY = particle.fallDestination.y // Off-screen Y

                // Linear progress based on real time for overall path and horizontal flutter calculation
                let linearFallProgress = min(max(0, fallTimeElapsed / fallDuration), 1.0)

                // --- Vertical Position (Adjusted Fall Speed) ---
                // <<--- CHANGE HERE: Increased factor for MUCH faster falling --->>>
                let slowedFallTimeFactor = 0.7 // Higher value = faster fall. (Was 0.3, previously 0.1)
                                               // Try values closer to 1.0 for max speed.
                let effectiveFallTime = fallTimeElapsed * slowedFallTimeFactor
                // Progress based on the adjusted effective time, mapped to the full fall duration
                let visualVerticalProgress = min(max(0, effectiveFallTime / fallDuration), 1.0)
                let targetY = startY + (endY - startY) * visualVerticalProgress

                // --- Horizontal Position (Fluttering Sway) ---
                // Calculate the center X of the general drift path using linear time progress
                let pathCenterX = startX + (endX - startX) * linearFallProgress

                // Gradually introduce flutter amplitude after burst ends
                let flutterRampUpDuration: Double = 0.6 // Time over which flutter reaches full strength
                var currentFlutterAmplitude = particle.flutterAmplitude
                if fallTimeElapsed < flutterRampUpDuration {
                     let rampUpProgress = fallTimeElapsed / flutterRampUpDuration
                     let smoothStep = rampUpProgress * rampUpProgress * (3.0 - 2.0 * rampUpProgress) // Smoothstep easing
                     currentFlutterAmplitude *= smoothStep
                }

                // Calculate the horizontal offset using sine wave based on particle's properties
                let flutterAngle = fallTimeElapsed * particle.flutterFrequency + particle.flutterPhase
                let horizontalOffset = sin(flutterAngle) * currentFlutterAmplitude
                let targetX = pathCenterX + horizontalOffset

                // --- Update Position ---
                confetti[index].position = CGPoint(x: targetX, y: targetY)

                // --- Rotation (Tilt based on horizontal movement) ---
                let horizontalVelocityFactor = cos(flutterAngle) // Derivative of sine indicates direction
                let maxTiltAngle: Double = 35.0 // Max degrees of tilt
                // Apply tilt gradually based on the current flutter amplitude
                let currentMaxTilt = maxTiltAngle * (currentFlutterAmplitude / max(particle.flutterAmplitude, 1e-6)) // Avoid division by zero
                let tiltAngle = Angle(degrees: -horizontalVelocityFactor * currentMaxTilt) // Tilt opposite to movement

                // Combine tilt with a very slow continuous spin for randomness
                let slowContinuousRotation = Angle(degrees: particle.rotationSpeed.degrees * 0.2 * (1/60))
                confetti[index].rotation = tiltAngle + slowContinuousRotation

                // --- Fade Out (Based on visual vertical progress) ---
                let fadeStartProgress = 0.6 // Start fading after 60% of the visual fall progress
                if visualVerticalProgress > fadeStartProgress {
                    let fadeDurationProgress = 1.0 - fadeStartProgress
                    guard fadeDurationProgress > 0 else { // Safety check
                        confetti[index].opacity = 0
                        continue
                    }
                    // Calculate fade progress within the fade duration part of the animation
                    let fadeProgress = max(0, (visualVerticalProgress - fadeStartProgress) / fadeDurationProgress)
                    // Apply fade (e.g., ease-out fade with pow)
                    confetti[index].opacity = max(0, 1.0 - pow(fadeProgress, 1.5))
                }
            }

            // --- Remove Particle Check ---
            // Check if particle is faded out or has exceeded the total animation time plus a buffer
            if confetti[index].opacity <= 0 || timeElapsed > totalDuration + 0.5 {
                 confetti.remove(at: index)
            }
        }

        // --- Cleanup and Timer Stop Logic ---
        // Stop timer and reset flag *only* when all particles are gone
        if confetti.isEmpty && cancellableTimer != nil { // Check timer existence to avoid multiple stops
            stopAnimationTimer()
            // Now it's safe to reset the effect trigger flag after animation is fully complete
            showCompletionEffect = false
        }
    }


    // --- Timer Control ---
    func startAnimationTimer() {
        // Ensure publisher is set up correctly and connected only once
        guard cancellableTimer == nil else { return } // Don't start if already running
        animationTimer = Timer.publish(every: 1/60, on: .main, in: .common)
        cancellableTimer = animationTimer.connect()
    }

    func stopAnimationTimer() {
        cancellableTimer?.cancel()
        cancellableTimer = nil // Set to nil to allow restarting
    }
}


struct LevelTestView_Previews: PreviewProvider {
    static var previews: some View {
        // Embed in NavigationView for title and toolbar context in preview
        NavigationView {
            LevelTestView()
        }
        // Example of previewing in a specific locale if needed
        // .environment(\.locale, .init(identifier: "ko"))
    }
}
