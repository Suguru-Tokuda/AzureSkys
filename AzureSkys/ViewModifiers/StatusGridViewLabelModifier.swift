//
//  StatusGridViewModifiers.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/13/23.
//

import SwiftUI

struct StatusGridViewLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.footnote.weight(.semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.white.opacity(0.5))
    }
}

extension View {
    func withStatusGridViewLabelModifier() -> some View {
        modifier(StatusGridViewLabelModifier())
    }
}
