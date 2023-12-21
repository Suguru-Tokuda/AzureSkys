//
//  StatusGridView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/13/23.
//

import SwiftUI

struct StatusGridView: View {
    @AppStorage(UserDefaultKeys.tempScale.rawValue) var tempScale: TempScale = .fahrenheit
    var forecast: Forecast
    var background: LinearGradient
    var parentViewWidth: CGFloat
    let columns = Array(repeating: GridItem(), count: 2)
    
    var body: some View {
        let width: CGFloat = parentViewWidth / CGFloat(columns.count) * 0.85

        LazyVGrid(columns: columns, spacing: 15) {
            WindStatusGridViewCell(
                width: width,
                background: background,
                wind: Wind(speed: forecast.windSpeed, 
                            gust: forecast.windGust,
                            deg: forecast.windDeg))
            
            StatusGridCellView(
                width: width,
                background: background,
                icon: "thermometer.medium",
                title: "Feels like",
                value: "\(forecast.feelsLike.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())")
            
            if let visibility = forecast.visibility {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: "eye.fill",
                    title: "Visibility",
                    value: "\(visibility.toMiles()) mi")
            }
            
            if let humidity = forecast.humidity {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: "humidity.fill",
                    title: "Humidity",
                    value: "\(humidity) %")
            }
            
            if let pressure = forecast.pressure {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: "gauge.with.dots.needle.50percent",
                    title: "Pressure",
                    value: "\(pressure) hPa")
            }
            
            if let clouds = forecast.clouds {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: "cloud.fill",
                    title: "Cloudiness",
                    value: "\(clouds)%")
            }
            
            if let uvi = forecast.uvi {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: "sun.max",
                    title: "UV Index",
                    value: "\(uvi)")
            }
            
            if let dewPoint = forecast.dewPoint {
                StatusGridCellView(
                    width: width,
                    background: background,
                    icon: "drop.fill",
                    title: "Dew Point",
                    value: "\(dewPoint.getDegree(tempScale: tempScale).formatDouble(maxFractions: 0).appendDegree())")

            }
        }
    }
}

#Preview {
    StatusGridView(
        forecast: PreviewManager.oneCallResponse.current,
        background: Color.skyBlue,
        parentViewWidth: 430
    )
    .preferredColorScheme(.dark)
}
