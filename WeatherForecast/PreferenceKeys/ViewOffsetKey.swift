//
//  ViewOffsetKey.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/14/23.
//

import SwiftUI

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
