//
//  StatusGridViewValueLabelModifier.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/13/23.
//

import SwiftUI

struct StatusGridViewValueLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 28).weight(.regular))
    }
}

extension View {
    func withStatusGridViewValueLabelModifier() -> some View {
        modifier(StatusGridViewValueLabelModifier())
    }
}
