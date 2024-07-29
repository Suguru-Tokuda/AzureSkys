//
//  LocationSearchResultListCellView.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/28/23.
//

import SwiftUI

struct LocationSearchResultListCellView: View {
    var prediction: Prediction
    
    var body: some View {
        HStack {
            Text(prediction.description ?? "")
            Spacer()
        }
    }
}

#Preview {
    LocationSearchResultListCellView(prediction: PreviewManager.predictions.first!)
}
