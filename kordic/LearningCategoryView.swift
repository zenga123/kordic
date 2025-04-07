//
//  LearningCategoryView.swift
//  kordic
//
//  Created by musung on 2025/03/26.
//

import SwiftUI

// 기본 학습 카테고리 뷰 컴포넌트
struct LearningCategoryView: View {
    let icon: String  // 아이콘 이름 (SF Symbol)
    let title: String  // 카테고리 제목
    let subtitle: String  // 카테고리 부제목
    let progress: String  // 진행 상태 (예: "0/4")
    let isLocked: Bool  // 잠금 여부
    let progressValue: Float?  // 진행률 (0.0 ~ 1.0, nil이면 표시 안 함)
    
    @Environment(\.colorScheme) var colorScheme
    
    var isDarkMode: Bool {
        return colorScheme == .dark
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // 아이콘
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isLocked ? Color.gray.opacity(0.3) : Color(red: 0.3, green: 0.5, blue: 0.9))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isLocked ? .gray : .white)
            }
            
            // 제목과 부제목
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isLocked ? .gray : (isDarkMode ? .white : Color(red: 0.2, green: 0.2, blue: 0.3)))
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // 진행 상태 바 배경 (회색 선)
                if !isLocked {
                    // 진행 상태가 있을 때만 배경 표시줄 추가
                    if progressValue == nil || progressValue! <= 0 {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                            .cornerRadius(3)
                            .padding(.top, 4)
                    }
                }
                
                // 진행 상태 표시줄 (파란색 부분)
                if !isLocked && progressValue != nil && progressValue! > 0 {
                    ZStack(alignment: .leading) {
                        // 배경 바
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        // 실제 진행 바
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(Color(red: 0.3, green: 0.5, blue: 0.9))
                                .frame(width: progressValue! >= 0.99 ? 
                                       geometry.size.width : // 완료 시 부모 너비 전체 사용
                                       geometry.size.width * CGFloat(progressValue!), 
                                       height: 6)
                                .cornerRadius(3)
                        }
                        .frame(height: 6) // 높이 고정
                    }
                    .padding(.top, 4)
                }
            }
            
            Spacer()
            
            // 진행 상태 또는 잠금 아이콘
            if isLocked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            } else if !progress.isEmpty {
                Text(progress)
                    .foregroundColor(.gray)
            }
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
    VStack(spacing: 20) {
        LearningCategoryView(
            icon: "speaker.wave.2.fill",
            title: "Basics 1",
            subtitle: "First steps",
            progress: "0/4",
            isLocked: false,
            progressValue: 0.3
        )
        
        LearningCategoryView(
            icon: "lock.fill",
            title: "Basics 2",
            subtitle: "Next level",
            progress: "",
            isLocked: true,
            progressValue: nil
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
