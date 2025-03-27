//
//  QuizCategoryView.swift
//  kordic
//
//  Created by musung on 2025/03/26.
//

import SwiftUI

// 퀴즈 카테고리 뷰
struct QuizCategoryView: View {
    let title: String
    let subtitle: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // 퀴즈 아이콘
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.3, green: 0.5, blue: 0.9))
                    .frame(width: 54, height: 54)
                
                Image(systemName: "questionmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // 제목과 부제목
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isDarkMode ? .white : Color(red: 0.2, green: 0.2, blue: 0.3))
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isDarkMode ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    QuizCategoryView(
        title: "Quiz",
        subtitle: "Test your knowledge"
    )
    .padding()
}
