import SwiftUI

struct StatusListView: View {
    @AppStorage(UserDefaultKeys.tempScale.rawValue) private var tempScale: TempScale = .fahrenheit
    @ScaledMetric(relativeTo: .body) private var cardHeight: CGFloat = 150
    let forecast: Forecast

    private var items: [WeatherStatusItem] {
        WeatherStatusItem.items(for: forecast, tempScale: tempScale)
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .top, spacing: 12) {
                ForEach(items) { item in
                    StatusListCell(
                        iconName: item.iconName,
                        iconBackgroundColor: item.iconColor,
                        topLabel: item.title,
                        parameterString: item.value,
                        footnoteString: item.footnote
                    )
                    .frame(width: 130, height: cardHeight)
                }
            }
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview("Forecast metrics") {
    StatusListView(forecast: PreviewManager.oneCallResponse.current)
        .padding(20)
        .background(Color(red: 0.06, green: 0.18, blue: 0.34))
        .preferredColorScheme(.dark)
}
