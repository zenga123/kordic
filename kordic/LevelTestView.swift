import SwiftUI

struct Question {
    let text: String
    let options: [String]
    let correctAnswer: Int
}

struct LevelTestView: View {
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswerIndex: Int? = nil
    @State private var score = 0
    @Environment(\.presentationMode) var presentationMode
    
    let questions = [
        Question(text: "나( ) 밥을 먹었어요.", options: ["이", "가", "을", "는"], correctAnswer: 1),
        Question(text: "책( ) 읽었어요.", options: ["이", "을", "는", "에서"], correctAnswer: 1),
        Question(text: "학교( ) 갔어요.", options: ["이", "가", "을", "에"], correctAnswer: 3),
        Question(text: "선생님( ) 말했어요.", options: ["이", "가", "께서", "을"], correctAnswer: 2)
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
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // 설정 버튼 액션
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                
                Text("Level Test")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                VStack(spacing: 40) {
                    if currentQuestionIndex < questions.count {
                        let question = questions[currentQuestionIndex]
                        
                        Text("Q. \(question.text)")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            ForEach(0..<question.options.count, id: \.self) { index in
                                Button(action: {
                                    selectedAnswerIndex = index
                                }) {
                                    HStack {
                                        Text("\(["a", "b", "c", "d"][index])) \(question.options[index])")
                                            .font(.title3)
                                            .foregroundColor(.primary)
                                            .padding()
                                        Spacer()
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
                            Text("테스트 완료")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("점수: \(score)/\(questions.count)")
                                .font(.title2)
                            
                            Button(action: {
                                // 처음으로 돌아가기
                                currentQuestionIndex = 0
                                selectedAnswerIndex = nil
                                score = 0
                            }) {
                                Text("다시 시작")
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
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    .padding(.bottom, 10)
                    
                    Text("\(currentQuestionIndex + 1)/\(questions.count)")
                        .font(.headline)
                        .padding(.bottom, 40)
                    
                    if selectedAnswerIndex != nil {
                        Button(action: {
                            if selectedAnswerIndex == questions[currentQuestionIndex].correctAnswer {
                                score += 1
                            }
                            
                            if !isLastQuestion {
                                currentQuestionIndex += 1
                                selectedAnswerIndex = nil
                            } else {
                                // 마지막 문제 이후 결과 화면으로
                                currentQuestionIndex = questions.count
                            }
                        }) {
                            Text(isLastQuestion ? "결과 보기" : "다음")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct LevelTestView_Previews: PreviewProvider {
    static var previews: some View {
        LevelTestView()
    }
}
