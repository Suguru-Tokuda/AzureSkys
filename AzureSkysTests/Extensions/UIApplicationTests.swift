//
//  UIApplicationTests.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/3/26.
//

import XCTest
import UIKit
@testable import AzureSkys

@MainActor
final class UIApplicationTests: XCTestCase {
    func testHideKeyboardResignsFirstResponder() throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let window = UIWindow(windowScene: scene)
        window.frame = UIScreen.main.bounds
        let controller = UIViewController()
        let field = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        controller.view.addSubview(field)
        window.rootViewController = controller; window.makeKeyAndVisible()
        defer { window.isHidden = true; window.rootViewController = nil }
        XCTAssertTrue(field.becomeFirstResponder())
        UIApplication.shared.hideKeyboard()
        XCTAssertFalse(field.isFirstResponder)
    }
}
