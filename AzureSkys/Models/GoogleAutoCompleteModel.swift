//
//  GoogleAutoCompleteModel.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/28/23.
//

import Foundation

struct GoogleAutoCompleteModel: Decodable {
    var predictions: [Prediction]?
    var status: String?
}

struct Prediction: Decodable, Identifiable {
    var id: UUID = UUID()
    var description: String?
    var placeId: String
    var structuredFormatting: StructuredFormatting?
    
    enum CodingKeys: String, CodingKey {
        case description
        case placeId = "place_id"
        case structuredFormatting = "structured_formatting"
    }
    
    init(id: UUID, description: String? = nil, placeId: String, structuredFormatting: StructuredFormatting? = nil, types: [String]? = nil) {
        self.id = id
        self.description = description
        self.placeId = placeId
        self.structuredFormatting = structuredFormatting
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.placeId = try container.decode(String.self, forKey: .placeId)
        self.structuredFormatting = try container.decodeIfPresent(StructuredFormatting.self, forKey: .structuredFormatting)
    }
}

struct StructuredFormatting: Decodable {
    var mainText: String?
    var secondaryText: String?

    enum CodingKeys: String, CodingKey {
        case mainText = "main_text"
        case secondaryText = "secondary_text"
    }
}
