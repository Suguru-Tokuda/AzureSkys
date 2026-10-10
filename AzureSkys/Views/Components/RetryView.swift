//
//  RetryView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 1/21/24.
//

import SwiftUI

struct RetryView: View {
    var errorMessage: String?
    var onRetryBtnTapped: (() -> ())?

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Text(errorMessage ?? Strings.error.rawValue)
                    .font(.title3.weight(.bold))
                    .padding(.bottom, 12)
                Button(
                    action: {
                        onRetryBtnTapped?()
                    },
                    label: {
                        Image(systemName: SystemImages.arrowClockwise.rawValue)
                        Text(Strings.retry.rawValue)
                    }
                )
                Spacer()
            }
        }
    }
}

#Preview {
    RetryView(errorMessage: Strings.networkError.rawValue)
}
