//
//  AzureSkysBottomBar.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/13/23.
//

import SwiftUI

struct WeatherForecastBottomBar: View {
    @EnvironmentObject var coordinator: MainCoordinator

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .frame(maxHeight: 75)
            HStack {
                Spacer()
                Button(action: {
                    coordinator.goToLocations()
                }, label: {
                    Image(systemName: SystemImages.listBullet.rawValue)
                })
                .accessibilityLabel(Strings.locationsTitle.rawValue)
                .accessibilityIdentifier(Strings.locationsButton.rawValue)
            }
            .padding(EdgeInsets(top: 20, leading: 32, bottom: 24, trailing: 32))
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
    }
}

#Preview {
    WeatherForecastBottomBar()
    .environmentObject(MainCoordinator())
    .preferredColorScheme(.dark)
}
