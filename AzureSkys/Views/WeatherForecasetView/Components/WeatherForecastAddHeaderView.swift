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
                Text("Cancel")
            })
            Spacer()
            Button(action: {
                addBtnTapped?()
            }, label: {
                Text("Add")
            })
        }
        .fontWeight(.semibold)
    }
}

#Preview {
    WeatherForecastAddHeaderView()
}
