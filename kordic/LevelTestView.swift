import SwiftUI

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

// 컨페티 파티클 구조체
struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var rotation: Double
    var opacity: Double = 1.0
    var scale: CGFloat = 1.0
}

struct LevelTestView: View {
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswerIndex: Int? = nil
    @State private var score = 0
    @Environment(\.presentationMode) var presentationMode
    @State private var confetti: [ConfettiParticle] = []
    @State private var showCompletionEffect = false
    
    let questions = [
        Question(text: "나( ) 밥을 먹었어요.", options: ["이", "가", "을", "는"], correctAnswer: 1, questionType: .fillInBlank),
        Question(text: "'사과'는 무엇입니까?".localized(), options: ["Banana".localized(), "Apple".localized(), "Grape".localized(), "Watermelon".localized()], correctAnswer: 1, questionType: .translation),
        Question(text: "학교( ) 갔어요.", options: ["이", "가", "을", "에"], correctAnswer: 3, questionType: .fillInBlank),
        Question(text: "선생님( ) 말했어요.", options: ["이", "가", "께서", "을"], correctAnswer: 2, questionType: .fillInBlank)
    ]
    
    var progress: CGFloat {
        let total = CGFloat(questions.count)
        let current = CGFloat(currentQuestionIndex + 1)
        return current / total
    }
    
    var isLastQuestion: Bool {
        return currentQuestionIndex == questions.count - 1
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack {
                // Title만 표시
                Text("Level Test")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                VStack(spacing: 40) {
                    if currentQuestionIndex < questions.count {
                        let question = questions[currentQuestionIndex]
                        
                        if question.questionType == .fillInBlank {
                            Text("Q. \(question.text)")
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.top, 20)
                        } else {
                            Text(question.text)
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.top, 20)
                        }
                        
                        VStack(spacing: 16) {
                            ForEach(0..<question.options.count, id: \.self) { index in
                                Button(action: {
                                    // 이미 선택한 항목을 다시 선택하면 다음으로 진행
                                    if selectedAnswerIndex == index {
                                        if selectedAnswerIndex == questions[currentQuestionIndex].correctAnswer {
                                            score += 1
                                        }
                                        
                                        if !isLastQuestion {
                                            currentQuestionIndex += 1
                                            selectedAnswerIndex = nil
                                        } else {
                                            // 마지막 문제 이후 결과 화면으로
                                            currentQuestionIndex = questions.count
                                            showCompletionEffect = true
                                        }
                                    } else {
                                        // 처음 선택하면 선택 상태만 변경
                                        selectedAnswerIndex = index
                                    }
                                }) {
                                    HStack {
                                        if question.questionType == .fillInBlank {
                                            Text("\(["a", "b", "c", "d"][index])) \(question.options[index])")
                                                .font(.title3)
                                                .foregroundColor(.primary)
                                                .padding()
                                        } else {
                                            Text(question.options[index])
                                                .font(.title3)
                                                .foregroundColor(.primary)
                                                .padding()
                                        }
                                        Spacer()
                                        
                                        // 선택된 항목에 체크 표시
                                        if selectedAnswerIndex == index {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.title2)
                                                .padding(.trailing)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedAnswerIndex == index ? Color.blue.opacity(0.1) : Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(selectedAnswerIndex == index ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    } else {
                        // 테스트 완료 화면
                        VStack(spacing: 20) {
                            Text("Test Completed".localized())
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Score: \(score)/\(questions.count)".localized())
                                .font(.title2)
                            
                            // 점수에 따른 메시지
                            Text(getScoreMessage())
                                .font(.headline)
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: {
                                // 처음으로 돌아가기
                                currentQuestionIndex = 0
                                selectedAnswerIndex = nil
                                score = 0
                                confetti = []
                            }) {
                                Text("Start Again".localized())
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                        }
                        .padding()
                        .onAppear {
                            if showCompletionEffect {
                                startConfettiAnimation()
                            }
                        }
                        .overlay(
                            ZStack {
                                ForEach(confetti) { particle in
                                    Circle()
                                        .fill(particle.color)
                                        .frame(width: particle.size, height: particle.size)
                                        .position(particle.position)
                                        .scaleEffect(particle.scale)
                                        .opacity(particle.opacity)
                                }
                            }
                        )
                    }
                }
                
                Spacer()
                
                if currentQuestionIndex < questions.count {
                    // 프로그레스 바
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(height: 10)
                            .foregroundColor(Color(.systemGray5))
                            .cornerRadius(5)
                        
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width * 0.8 * progress, height: 10)
                            .foregroundColor(.blue)
                            .cornerRadius(5)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progress)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    .padding(.bottom, 10)
                    
                    Text("\(currentQuestionIndex + 1)/\(questions.count)")
                        .font(.headline)
                        .padding(.bottom, 40)
                    
                    // 하단 다음 버튼 제거
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden)
        .toolbar {
            // 기본 뒤로가기 버튼은 숨기지 않고 스와이프 제스처가 작동하도록 함
            ToolbarItem(placement: .principal) {
                EmptyView()
            }
        }
    }
    
    // 점수에 따른 메시지 반환
    func getScoreMessage() -> String {
        let percentage = (Double(score) / Double(questions.count)) * 100
        
        if percentage >= 90 {
            return "Excellent! You're a Korean language master!"
        } else if percentage >= 70 {
            return "Great job! You have a good understanding of Korean!"
        } else if percentage >= 50 {
            return "Good effort! Keep practicing!"
        } else {
            return "Don't worry! Practice makes perfect!"
        }
    }
    
    // 아주 기초적인 폭죽 애니메이션
    func startConfettiAnimation() {
        // 파티클 수 (적게 유지)
        let particleCount = 10
        
        // 화면 중앙
        let centerX = UIScreen.main.bounds.width / 2
        let centerY = UIScreen.main.bounds.height / 3 // 화면 상단 1/3 지점에서 터짐
        
        // 파티클 배열 생성
        var newConfetti: [ConfettiParticle] = []
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple]
        
        // 파티클 생성
        for _ in 0..<particleCount {
            let color = colors.randomElement()!
            
            let particle = ConfettiParticle(
                position: CGPoint(x: centerX, y: centerY), // 모두 같은 위치에서 시작
                color: color,
                size: 12, // 고정 크기
                rotation: 0,
                opacity: 1.0,
                scale: 1.0
            )
            
            newConfetti.append(particle)
        }
        
        confetti = newConfetti
        
        // 파티클을 사방으로 퍼뜨림
        for i in 0..<particleCount {
            // 360도 범위에서 균일하게 각도 배분
            let angle = Double(i) * (2 * Double.pi / Double(particleCount))
            let distance: CGFloat = 50 // 고정된 거리
            
            // 퍼진 후 위치 계산
            let x = centerX + distance * CGFloat(cos(angle))
            let y = centerY + distance * CGFloat(sin(angle))
            
            // 퍼지는 애니메이션
            withAnimation(.easeOut(duration: 0.5)) {
                confetti[i].position = CGPoint(x: x, y: y)
            }
            
            // 낙하 애니메이션 (퍼짐 후 0.5초 후에 시작)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.linear(duration: 1.5)) { // 선형 낙하 (가장 기초적)
                    // 낙하 위치는 화면 밖으로
                    confetti[i].position.y = UIScreen.main.bounds.height + 20
                }
            }
            
            // 사라지는 효과 (낙하 시작 후 1초 후에 시작)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.linear(duration: 0.5)) {
                    confetti[i].opacity = 0
                }
            }
        }
        
        // 애니메이션 종료 후 정리
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            confetti = []
        }
    }
}

struct LevelTestView_Previews: PreviewProvider {
    static var previews: some View {
        LevelTestView()
    }
}
