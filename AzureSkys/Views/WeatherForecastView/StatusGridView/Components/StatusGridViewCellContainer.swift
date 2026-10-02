//
//  StatusGridViewCellContainer.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/11/23.
//

import SwiftUI

struct StatusGridViewCellContainer<Content: View>: View {
    var width: CGFloat
    var background: LinearGradient
    let content: Content
    
    init(width: CGFloat, background: LinearGradient, @ViewBuilder content: () -> Content) {
        self.width = width
        self.background = background
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(background.opacity(0.8))
                .frame(width: width, height: width)
                .shadow(color: .black.opacity(0.25), radius: 10, x: 5, y: 4)
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(.white.opacity(0.5))
                        .blendMode(.overlay)
                }
            content
                .padding(.vertical, 15)
                .padding(.horizontal, 10)
                .frame(width: width, height: width)
        }
    }
}

#Preview {
    StatusGridViewCellContainer(
        width: 150,
        background: Color.skyBlue100
    ) {
        VStack {
            HStack {
                Image(systemName: "thermometer.medium")
                Text("FEELS LIKE")
            }
                .withStatusGridViewLabelModifier()
            Text("40°")
                .withStatusGridViewValueLabelModifier()
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
    }
    .preferredColorScheme(.dark)
}
