//
//  View.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/11/23.
//

import SwiftUI

extension View {
    func backgroundBlur(radius: CGFloat = 3, opaque: Bool = false) -> some View {
        self
            .background(
                Blur(radius: radius, opaque: opaque)
            )
    }
}
