//
//  LocationAuthorizationRequestView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/14/23.
//

import SwiftUI

struct LocationAuthorizationRequestView: View {
    let settingsManager: SettingsManager

    var body: some View {
        ZStack {
            VStack {
                Image(systemName: SystemImages.locationCircleFill.rawValue)
                    .resizable()
                    .frame(width: 75, height: 75)
                    .padding(.top, 100)
                Text(Strings.locationAuthorizationRequired.rawValue)
                    .font(.title3.weight(.bold))
                    .padding(.top, 50)

                Text(Strings.locationAuthorizationDescription.rawValue)
                    .font(.callout)
                Spacer()
            }

            Button(
                action: {
                    settingsManager.navigateToSettings()
                },
                label: {
                    Text(Strings.openSettings.rawValue)
                }
            )
            .buttonStyle(
                OpenSettingsBtnStyle(
                    backgroundColor: .night1,
                    foregroundColor: .white
                )
            )
        }
    }
}

#Preview {
    LocationAuthorizationRequestView(settingsManager: AppDependencies.preview().settingsManager)
        .preferredColorScheme(.dark)
}
