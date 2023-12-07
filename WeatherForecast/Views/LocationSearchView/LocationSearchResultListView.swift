//
//  LocationSearchResultListView.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 11/28/23.
//

import SwiftUI

struct LocationSearchResultListView: View {
    var predictions: [Prediction] = []
    var onSelect: ((Prediction) -> ())?
    
    var body: some View {
        List {
            ForEach(predictions) { prediction in
                LocationSearchResultListCellView(prediction: prediction)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .onTapGesture {
                        onSelect?(prediction)
                    }
            }
        }
        .listStyle(.plain)
        .padding(.horizontal, 10)
//        ScrollView(.vertical) {
//            LazyVStack {
//                ForEach(predictions) { prediction in
//                    LocationSearchResultListCellView(prediction: prediction)
//                        .onTapGesture {
//                            onSelect?(prediction)
//                        }
//                }
//            }
//        }
//        .padding(.horizontal, 10)
    }
}

#Preview {
    LocationSearchResultListView(predictions: PreviewManager.predictions)
}
