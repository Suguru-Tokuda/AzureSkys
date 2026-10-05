import SwiftUI

/// A forecast metric with a stable identity for collection updates.
struct WeatherStatusItem: Identifiable {
    enum Kind: CaseIterable {
        case wind, feelsLike, visibility, humidity, pressure, cloudiness, uvIndex, dewPoint
    }

    let id: Kind
    let iconName: String
    let iconColor: Color
    let title: String
    let value: String
    var footnote: String? = nil

    static func items(for forecast: Forecast, tempScale: TempScale) -> [WeatherStatusItem] {
        Kind.allCases.compactMap { kind in
            switch kind {
            case .wind:
                return WeatherStatusItem(
                    id: kind, iconName: SystemImages.wind.rawValue, iconColor: .mint,
                    title: Strings.wind.rawValue,
                    value: "\(forecast.windSpeed.formatDouble(maxFractions: 0)) \(Strings.mph.rawValue)",
                    footnote: forecast.windGust.map {
                        "\(Strings.gusts.rawValue): \($0.formatDouble(maxFractions: 0)) \(Strings.mph.rawValue)"
                    }
                )
            case .feelsLike:
                return WeatherStatusItem(
                    id: kind, iconName: SystemImages.thermometerMedium.rawValue, iconColor: .orange,
                    title: Strings.feelsLike.rawValue,
                    value: forecast.feelsLike.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree()
                )
            case .visibility:
                guard let visibility = forecast.visibility else { return nil }
                return WeatherStatusItem(
                    id: kind, iconName: SystemImages.eyeFill.rawValue, iconColor: .cyan,
                    title: Strings.visibility.rawValue,
                    value: Strings.miles(String(describing: visibility.toMiles()))
                )
            case .humidity:
                guard let humidity = forecast.humidity else { return nil }
                return WeatherStatusItem(
                    id: kind, iconName: SystemImages.humidityFill.rawValue, iconColor: .cyan,
                    title: Strings.humidity.rawValue, value: Strings.humidityValue(String(humidity))
                )
            case .pressure:
                guard let pressure = forecast.pressure else { return nil }
                return WeatherStatusItem(
                    id: kind, iconName: SystemImages.gaugeWithDotsNeedle50Percent.rawValue, iconColor: .purple,
                    title: Strings.pressure.rawValue, value: Strings.pressureValue(String(pressure))
                )
            case .cloudiness:
                guard let clouds = forecast.clouds else { return nil }
                return WeatherStatusItem(
                    id: kind, iconName: SystemImages.cloudFill.rawValue, iconColor: .white,
                    title: Strings.cloudiness.rawValue, value: Strings.percentage(String(clouds))
                )
            case .uvIndex:
                guard let uvi = forecast.uvi else { return nil }
                return WeatherStatusItem(
                    id: kind, iconName: SystemImages.sunMax.rawValue, iconColor: .yellow,
                    title: Strings.uvIndex.rawValue, value: String(describing: uvi)
                )
            case .dewPoint:
                guard let dewPoint = forecast.dewPoint else { return nil }
                return WeatherStatusItem(
                    id: kind, iconName: SystemImages.dropFill.rawValue, iconColor: .teal,
                    title: Strings.dewPoint.rawValue,
                    value: dewPoint.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree()
                )
            }
        }
    }
}
