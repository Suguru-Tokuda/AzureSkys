import SwiftUI

struct WeatherPanelModifier: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .background {
                shape.fill(.ultraThinMaterial).opacity(0.45)
                shape.fill(Color(red: 0.08, green: 0.18, blue: 0.34).opacity(0.28))
                shape.fill(
                    LinearGradient(
                        colors: [.white.opacity(0.14), .white.opacity(0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .overlay {
                shape.strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0.07)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            }
    }
}
