//
//  LocationAuthorizationRequestView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/14/23.
//

import SwiftUI

struct LocationAuthorizationRequestView: View {
    var body: some View {
        ZStack {
            VStack {
                Text("Location Authorization Required")
                    .font(.title3.weight(.bold))
                    .padding(.top, 100)
                Text("The App requires location information to continue")
                    .font(.callout)
                Spacer()
            }

            Button(action: {
                handleOpenSettingsBtnTap()
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

extension LocationAuthorizationRequestView {
    func handleOpenSettingsBtnTap() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl) { _ in }
        }
    }
}

#Preview {
    LocationAuthorizationRequestView()
        .preferredColorScheme(.dark)
}
