//
//  LocationAuthorizationRequestView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/14/23.
//

import SwiftUI

struct LocationAuthorizationRequestView: View {
    private let settingsManager = SettingsManager()

    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "location.circle.fill")
                    .resizable()
                    .frame(width: 75, height: 75)
                    .padding(.top, 100)
                Text("Location Authorization Required")
                    .font(.title3.weight(.bold))
                    .padding(.top, 50)
                    
                Text("The App requires location information to continue")
                    .font(.callout)
                Spacer()
            }

            Button(action: {
                settingsManager.navigateToSettings()
            }, label: {
                Text("Open Settings")
            })
            .buttonStyle(OpenSettingsBtnStyle(
                backgroundColor: .night1,
                foregroundColor: .white)
            )
        }
    }
}

#Preview {
    LocationAuthorizationRequestView()
        .preferredColorScheme(.dark)
}
