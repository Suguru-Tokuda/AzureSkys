// WeatherFormatting.swift
// Constants owned by WeatherFormatting.

enum WeatherFormatting {
    static let timeFormat = "hh:mm"
    static let hourFormat = "ha"
    static let wholeNumberFormat = "%.0f"
    static func appendingDegree(_ value: String) -> String {
        "\(value)\u{00B0}"
    }
    static func degreePrefixedUnit(_ unit: String) -> String {
        "°\(unit)"
    }
    static func highTemperature(_ temperature: String) -> String {
        "H:\(temperature)"
    }
    static func lowTemperature(_ temperature: String) -> String {
        "L:\(temperature)"
    }
    static func miles(_ distance: String) -> String {
        "\(distance) mi"
    }
    static func humidityValue(_ humidity: String) -> String {
        "\(humidity) %"
    }
    static func pressureValue(_ pressure: String) -> String {
        "\(pressure) hPa"
    }
    static func percentage(_ value: String) -> String {
        "\(value)%"
    }
}
