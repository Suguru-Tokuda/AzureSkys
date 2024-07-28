//
//  TempBarView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/15/23.
//

import SwiftUI

struct TempBarView: View {
    var currentTemp: Double
    var minTemp: Double
    var maxTemp: Double
    var showCurentTemp: Bool = false
    var cornerRadius: CGFloat = 50
    var height: CGFloat = 7

    var showAnimation: Bool = true
    @State var tempGradientColor: LinearGradient?
    @State var colorSet = false
    @State var tempBarWidth: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.gray.opacity(0.4))
                    .frame(height: height)
                    .zIndex(1.0)
                if let tempGradientColor {
                    withAnimation {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(tempGradientColor)
                            .frame(height: height)
                            .frame(width: tempBarWidth, alignment: .leading)
                            .zIndex(1.1)
                            .transition(.scale(scale: tempBarWidth))
                            .animation(showAnimation ? .easeIn(duration: 0.8) : .none, 
                                       value: tempBarWidth)
                            .onAppear {
                                self.setBarAnimation(width: geometry.size.width)
                            }
                    }
                }
            }
        }
        .onAppear {
            setColorGradient(minTemp: minTemp, maxTemp: maxTemp)
        }
    }
}

extension TempBarView {
    func setColorGradient(minTemp: Double, maxTemp: Double) {
        var tempColors: [TempColor] = []
        var current = minTemp
        
        while current <= maxTemp {
            let tempColor = TempColor.getTempColor(tempInKelvin: current)
            
            if !tempColors.contains(tempColor) {
                tempColors.append(tempColor)
            }
            
            current += 1
        }
        
        DispatchQueue.main.async {
            self.tempGradientColor = LinearGradient(colors: tempColors.map { $0.getColor() }, startPoint: .leading, endPoint: .trailing)
        }
        self.colorSet = true
    }
    
    func setBarAnimation(width: CGFloat) {
        if let _ = tempGradientColor {
            var current: CGFloat = 0
            
            while current < width {
                DispatchQueue.main.async {
                    self.tempBarWidth = current
                }
                current += 1
            }
        }
    }
}

#Preview {
    TempBarView(currentTemp: 289.32, minTemp: 285.78, maxTemp: 292.26)
        .preferredColorScheme(.dark)
}
