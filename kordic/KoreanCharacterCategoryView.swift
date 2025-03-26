//
//  KoreanCharacterCategoryView.swift
//  kordic
//
//  Created by musung on 2025/03/26.
//

import SwiftUI

// 한국어 문자 카테고리 뷰 (가 아이콘)
struct KoreanCharacterCategoryView: View {
    let title: String
    let subtitle: String
    let koreanChar: String
    
    var body: some View {
        HStack(spacing: 15) {
            // 한국어 문자 아이콘
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.3, green: 0.5, blue: 0.9))
                    .frame(width: 50, height: 50)
                
                Text(koreanChar)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // 제목과 부제목
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    KoreanCharacterCategoryView(
        title: "Review Words",
        subtitle: "Practice your vocabulary",
        koreanChar: "가"
    )
    .padding()
}
