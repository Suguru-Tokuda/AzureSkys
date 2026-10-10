//
//  TempBarView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/15/23.
//

import SwiftUI

struct TempBarView: View {
    var minTemp: Double
    var maxTemp: Double
    var cornerRadius: CGFloat = 50
    var height: CGFloat = 7
    var showAnimation: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.gray.opacity(0.4))
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(tempGradientColor)
                    .frame(width: isExpanded ? geometry.size.width : 0)
            }
            .frame(height: height)
            .onAppear {
                withAnimation(showAnimation && !reduceMotion ? .easeIn(duration: 0.8) : nil) {
                    isExpanded = true
                }
            }
            .onDisappear {
                isExpanded = false
            }
        }
    }

    private var tempGradientColor: LinearGradient {
        var tempColors: [TempColor] = []
        var current = minTemp

        if minTemp.isFinite && maxTemp.isFinite && minTemp <= maxTemp {
            while current <= maxTemp {
                let tempColor = TempColor.getTempColor(tempInKelvin: current)

                if !tempColors.contains(tempColor) {
                    tempColors.append(tempColor)
                }

                current += 1
            }
        }

        return LinearGradient(
            colors: tempColors.map { $0.getColor() },
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview {
    TempBarView(minTemp: 285.78, maxTemp: 292.26)
        .preferredColorScheme(.dark)
}
