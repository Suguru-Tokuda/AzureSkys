import XCTest
@testable import AzureSkys

final class WeatherStatusItemTests: XCTestCase {
    func testCompleteForecastIncludesAllMetricsInGridOrder() throws {
        let items = WeatherStatusItem.items(for: try TestFixtures.oneCall().current, tempScale: .fahrenheit)

        XCTAssertEqual(items.map(\.id), WeatherStatusItem.Kind.allCases)
        XCTAssertNotNil(items.first?.footnote)
    }

    func testMissingOptionalMetricsAreOmitted() throws {
        var object = try TestFixtures.object(TestFixtures.oneCallData)
        var current = object["current"] as! [String: Any]

        for key in ["visibility", "humidity", "pressure", "clouds", "uvi", "dew_point", "wind_gust"] {
            current.removeValue(forKey: key)
        }

        object["current"] = current

        let forecast = try JSONDecoder().decode(WeatherForecastOneCallResponse.self, from: TestFixtures.data(object))
            .current
        let items = WeatherStatusItem.items(for: forecast, tempScale: .fahrenheit)

        XCTAssertEqual(items.map(\.id), [.wind, .feelsLike])
        XCTAssertNil(items.first?.footnote)
    }
}
