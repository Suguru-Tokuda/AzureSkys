import SwiftUI

struct WeatherImageView: View {
    let condition: WeatherCondition
    var partOfDay: PartOfDay = .day
    let width: CGFloat

    var body: some View {
        Image(condition.iconAssetName(partOfDay: partOfDay))
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(width: width, height: width)
            .accessibilityLabel(condition.rawValue)
    }
}

#Preview {
    HStack {
        WeatherImageView(condition: .clear, width: 40)
        WeatherImageView(condition: .clear, partOfDay: .night, width: 40)
        WeatherImageView(condition: .rain, width: 40)
    }
    .padding()
    .background(.blue)
}
