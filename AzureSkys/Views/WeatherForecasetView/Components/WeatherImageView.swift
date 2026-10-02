//
//  WeatherImageView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/15/23.
//

import SwiftUI

struct WeatherImageView: View {
    @EnvironmentObject var fileManager: LocalFileManager
    @State private var image: UIImage?
    @State private var loadedIcon: String?
    @State private var isLoading = true

    let icon: String
    let width: CGFloat

    var body: some View {
        ZStack {
            if loadedIcon != icon || isLoading {
                ProgressView()
            } else if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "cloud")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Weather icon unavailable")
            }
        }
        .frame(width: width, height: width)
        .task(id: icon) {
            await loadImage(for: icon)
        }
    }

    @MainActor
    private func loadImage(for icon: String) async {
        guard !Task.isCancelled else { return }
        loadedIcon = icon
        image = nil
        isLoading = true
        defer {
            // A cancelled load must not change the replacement load's state.
            if !Task.isCancelled {
                isLoading = false
            }
        }

        // Missing or corrupt cache entries fall through to a download.
        if let cachedImage = try? fileManager.getImage(name: icon) {
            image = cachedImage
            return
        }

        guard let url = URL(string: Constants.weatherIconURL.replacingOccurrences(of: "ICON_CODE", with: icon)) else {
            return
        }

        do {
            let request = URLRequest(url: url, timeoutInterval: 15)
            let (data, response) = try await URLSession.shared.data(for: request)
            try Task.checkCancellation()
            guard let response = response as? HTTPURLResponse,
                  (200..<300).contains(response.statusCode),
                  let downloadedImage = UIImage(data: data) else {
                return
            }

            image = downloadedImage
            // Cache failures should never prevent displaying a valid image.
            try? fileManager.saveImage(image: downloadedImage, name: icon)
        } catch {
            // Non-cancellation failures finish loading and show the fallback.
        }
    }
}

#Preview {
    WeatherImageView(icon: "01d", width: 40)
        .environmentObject(LocalFileManager())
}
