//
//  LocationsView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/5/23.
//

import SwiftUI

struct LocationsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage(AppStorageKeys.tempScale) var tempScale: TempScale = .fahrenheit

    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 15, height: 15)
                }

                Spacer()
                Menu {
                    ForEach(TempScale.allCases) { scale in
                        Button(action: {
                            tempScale = scale
                        }, label: {
                            tempScaleOptionBtn(selected: tempScale, option: scale)
                        })
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            ScrollView {
                Text("Weather")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden(true)
    }
}

extension LocationsView {
    @ViewBuilder
    func tempScaleOptionBtn(selected: TempScale, option: TempScale) -> some View {
        HStack {
            if selected != option {
                Spacer()
                    .frame(width: 10)
            } else {
                Image(systemName: "checkmark")
                    .resizable()
                    .frame(width: 10, height: 10)
            }
            Text(option.rawValue)
            Spacer()
            Text("&deg;\(option.rawValue.first?.uppercased() ?? "")")
        }
    }
}

#Preview {
    LocationsView()
}
