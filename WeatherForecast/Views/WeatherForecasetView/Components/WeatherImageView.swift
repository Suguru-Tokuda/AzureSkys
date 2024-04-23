//
//  WeatherImageView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/15/23.
//

import SwiftUI

struct WeatherImageView: View {
    @EnvironmentObject var fileManager: LocalFileManager
    @State var imageLoaded = false
    @State var image: UIImage?

    let icon: String
    let width: CGFloat
    

    var body: some View {
        ZStack {
            if imageLoaded {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: width, height: width)
                }
            } else {
                ProgressView()
                    .frame(width: width, height: width)
            }
        }
        .task {
            await loadImage()
        }
    }
}

extension WeatherImageView {
    func loadImage() async {
        do {
            if let img = try fileManager.getImage(name: icon) {
                DispatchQueue.main.async {
                    self.image = img
                    self.imageLoaded = true
                }
            }
        } catch {
            
        }
        
        // check if
        if self.image == nil {
            guard let url = URL(string: Constants.weatherIconURL.replacingOccurrences(of: "ICON_CODE", with: icon)) else {
                return
            }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let img = UIImage(data: data) else { return }
                
                try fileManager.saveImage(image: img, name: icon)

                DispatchQueue.main.async {
                    self.image = img
                    self.imageLoaded = true
                }

            } catch {
                
            }
        }
    }
}

#Preview {
    WeatherImageView(
        icon: "01d",
        width: 40
    )
    .environmentObject(LocalFileManager())
}
