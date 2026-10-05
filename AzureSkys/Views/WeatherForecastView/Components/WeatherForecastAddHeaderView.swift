//
//  AzureSkysAddHeaderView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/5/23.
//

import SwiftUI

struct WeatherForecastAddHeaderView: View {
    var cancelBtnTapped: (() -> ())?
    var addBtnTapped: (() -> ())?

    var body: some View {
        HStack {
            Button(action: {
                cancelBtnTapped?()
            }, label: {
                Text(Strings.cancel.rawValue)
                    .shadow(
                        color: .black.opacity(0.5),
                        radius: 3,
                        x: 0,
                        y: 2
                    )
            })
            Spacer()
            Button(action: {
                addBtnTapped?()
            }, label: {
                Text(Strings.add.rawValue)
                    .shadow(
                        color: .black.opacity(0.5),
                        radius: 3,
                        x: 0,
                        y: 2
                    )
            })
        }
        .fontWeight(.semibold)
    }
}

#Preview {
    WeatherForecastAddHeaderView()
}
