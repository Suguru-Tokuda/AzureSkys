//
//  ColorTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import SwiftUI
@testable import AzureSkys

@MainActor
final class ColorTests: XCTestCase {
    func testGradientPresetsRenderVisibleColor() async throws {
        let gradients: [LinearGradient] = [Color.skyBlue100, Color.skyBlue90, Color.skyBlue80, Color.skyBlue70, Color.skyBlue60, Color.skyBlue50, Color.skyBlue40, Color.skyBlue30, Color.skyBlue20, Color.skyBlue10, Color.clearNight100, Color.clearNight90, Color.clearNight80, Color.clearNight70, Color.clearNight60, Color.clearNight50, Color.clearNight40, Color.clearNight30, Color.clearNight20, Color.clearNight10, Color.cloudyDay100, Color.cloudyDay90, Color.cloudyDay80, Color.cloudyDay70, Color.cloudyDay60, Color.cloudyDay50, Color.cloudyDay40, Color.cloudyDay30, Color.cloudyDay20, Color.cloudyDay10, Color.cloudyNight100, Color.cloudyNight90, Color.cloudyNight80, Color.cloudyNight70, Color.cloudyNight60, Color.cloudyNight50, Color.cloudyNight40, Color.cloudyNight30, Color.cloudyNight20, Color.cloudyNight10]
        for gradient in gradients { assertVisibleContent(try await renderSnapshot(gradient.frame(height: 100))) }
    }
}
