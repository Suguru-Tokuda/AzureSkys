//
//  DismissButton.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 7/7/24.
//

import SwiftUI

struct DismissButton: View {
    var onButtonPress: (() -> ())?

    var body: some View {
        Button {
            onButtonPress?()
        } label: {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 15, height: 15)
        }
    }
}

#Preview {
    DismissButton()
}
