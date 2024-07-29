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
            if let errorMessage {
                VStack {
                    Text(errorMessage)
                        .font(.title3.weight(.bold))
                        .padding(.top, 100)
                    Spacer()
                }
            }

            Button(action: {
                onRetryBtnTapped?()
            }, label: {
             Text("Retry")
            })
            .buttonStyle(OpenSettingsBtnStyle(
                backgroundColor: .night1,
                foregroundColor: .white)
            )
        }
    }
}

#Preview {
    RetryView(errorMessage: "Network Error")
}
