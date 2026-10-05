//
//  OnboardingLocationCard.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import SwiftUI

struct OnboardingLocationCard: View {
    var city: String = PreviewManager.Strings.cupertino
    var temperature: String = PreviewManager.Strings.previewHotTemperature
    var weatherSymbol: String = SystemImages.cloudFill.rawValue

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(Strings.myLocation.rawValue)
                    .font(.caption)
                Text(city)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            OnboardingWeatherSummary(symbol: weatherSymbol, temperature: temperature)
        }
        .padding(20)
        .modifier(OnboardingWeatherCardStyle())
        .accessibilityElement(children: .combine)
    }
}

struct OnboardingSyncCard: View {
    var firstCity: String = PreviewManager.Strings.cupertino
    var firstTemperature: String = PreviewManager.Strings.previewHotTemperature
    var firstWeatherSymbol: String = SystemImages.cloudSunFill.rawValue
    var secondCity: String = PreviewManager.Strings.houston
    var secondTemperature: String = PreviewManager.Strings.previewVeryHotTemperature
    var secondWeatherSymbol: String = SystemImages.cloudFill.rawValue

    var body: some View {
        VStack(spacing: 12) {
            cityRow(firstCity, temperature: firstTemperature, symbol: firstWeatherSymbol)

            Rectangle()
                .fill(.white.opacity(0.25))
                .frame(height: 1)
                .accessibilityHidden(true)

            cityRow(secondCity, temperature: secondTemperature, symbol: secondWeatherSymbol)
        }
        .padding(20)
        .modifier(OnboardingWeatherCardStyle())
    }

    private func cityRow(_ city: String, temperature: String, symbol: String) -> some View {
        HStack(spacing: 16) {
            Text(city)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)

            OnboardingWeatherSummary(symbol: symbol, temperature: temperature)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct OnboardingWeatherSummary: View {
    let symbol: String
    let temperature: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .yellow)
                .font(.system(size: 28))
                .frame(width: 36)
                .accessibilityHidden(true)

            Text(temperature)
                .font(.title2)
                .monospacedDigit()
                .fixedSize()
        }
    }
}

#Preview {
    OnboardingSyncCard()
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            GeometryReader { geometry in
                Image(ImageAssets.onboardingSky.rawValue)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
        }
        .preferredColorScheme(.light)
}
