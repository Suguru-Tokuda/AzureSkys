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
    var session: URLSession = .shared

    var body: some View {
        ZStack {
            if loadedIcon != icon || isLoading {
                ProgressView()
            } else if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: SystemImages.cloud.rawValue)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
                    .accessibilityLabel(Strings.weatherIconUnavailable.rawValue)
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

        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains(LaunchArguments.uiTestingArgument) {
            image = UIImage(systemName: SystemImages.cloud.rawValue)
            return
        }
        #endif

        // Missing or corrupt cache entries fall through to a download.
        if let cachedImage = try? fileManager.getImage(name: icon) {
            image = cachedImage
            return
        }

        guard let url = URL(string: Constants.weatherIconURL.replacingOccurrences(of: WeatherImageViewConstants.iconCodePlaceholder, with: icon)) else {
            return
        }

        do {
            let request = URLRequest(url: url, timeoutInterval: 15)
            let (data, response) = try await session.data(for: request)
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
    WeatherImageView(icon: PreviewManager.Strings.clearDayIcon, width: 40)
        .environmentObject(LocalFileManager())
}

private enum WeatherImageViewConstants {
    static let iconCodePlaceholder = "ICON_CODE"
}
