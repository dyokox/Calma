//  BulletCardView.swift
//  Reusable UI component for the OptInView.swift and OptOutView.swift

import SwiftUI

struct BulletCardView: View {
    let icon: String
    let title: String
    let bullets: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.red.opacity(0.75))
                Text(title)
                    .font(.custom("SFCompactText-Regular", size: 15))
                    .fontWeight(.medium)
                    .foregroundStyle(.blackOff)
            }
            // Bullet Points
            VStack(alignment: .leading, spacing: 6) {
                ForEach(bullets, id: \.self) { bullet in
                    HStack(alignment: .top, spacing: 8) {
                        Text("·")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.red.opacity(0.75))
                            .frame(width: 10)
                            .offset(y: -1)
                        Text(bullet)
                            .font(.custom("SFCompactText-Regular", size: 14))
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground).opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

