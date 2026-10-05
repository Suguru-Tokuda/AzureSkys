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
                Text(errorMessage ?? CommonStrings.error)
                    .font(.title3.weight(.bold))
                    .padding(.bottom, 12)
                Button(action: {
                    onRetryBtnTapped?()
                }, label: {
                    Image(systemName: SystemImages.arrowClockwise.rawValue)
                 Text(CommonStrings.retry)
                })
                Spacer()
            }
        }
    }
}

#Preview {
    RetryView(errorMessage: CommonStrings.networkError)
}
