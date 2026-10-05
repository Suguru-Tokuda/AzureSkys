import SwiftUI

struct BackGroundView: View {
    var body: some View {
        GeometryReader { geometry in
            Image(ImageAssets.weatherBackgroundClearNight.rawValue)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .overlay {
                    LinearGradient(
                        colors: [.black.opacity(0.25), Color(red: 0.01, green: 0.04, blue: 0.12).opacity(0.75)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    BackGroundView()
}
