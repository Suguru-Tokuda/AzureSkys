//
//  AzureSkysBottomBar.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/13/23.
//

import SwiftUI

struct WeatherForecastBottomBar: View {
    var background: LinearGradient
    @EnvironmentObject var coordinator: MainCoordinator

    var body: some View {
        ZStack {
            background
                .opacity(0.95)
                .frame(maxHeight: 75)
            HStack {
                Spacer()
                Button(action: {
                    coordinator.goToLocations()
                }, label: {
                    Image(systemName: "list.bullet")
                })
                .accessibilityLabel("Locations")
                .accessibilityIdentifier("locationsButton")
            }
            .padding(EdgeInsets(top: 20, leading: 32, bottom: 24, trailing: 32))
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
    }
}

#Preview {
    WeatherForecastBottomBar(
        background: Color.skyBlue100
    )
    .environmentObject(MainCoordinator())
    .preferredColorScheme(.dark)
}
