//
//  LaunchView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 7/7/24.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        ZStack {
            Color.launchScreen
                .ignoresSafeArea()
            VStack {
                Image("Sun")
                    .resizable()
                    .frame(width: 100, height: 100, alignment: .center)
                Text("AzureSky")
                    .foregroundStyle(Color.launchScreenText)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
    }
}

#Preview {
    LaunchView()
}
