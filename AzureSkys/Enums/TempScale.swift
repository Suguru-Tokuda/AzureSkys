//
//  Degree.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/4/23.
//

import Foundation

enum TempScale: String, CaseIterable, Identifiable {
    case fahrenheit = "Fahrenheight", celsius = "Celsius"
    
    var id: String { self.rawValue }
}
