//
//  LocationCloudRecord.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/7/26.
//

import CloudKit
import Foundation

// This schema is owned by AzureSkys, separate from Core Data's private CD_* schema.
enum LocationCloudRecord {
    static let zoneID = CKRecordZone.ID(zoneName: "AzureSkysLocations", ownerName: CKCurrentUserDefaultName)
    static let recordType = "AzureSkysPlace"
    static let legacyZoneID = CKRecordZone.ID(
        zoneName: "com.apple.coredata.cloudkit.zone", ownerName: CKCurrentUserDefaultName)

    static func recordID(_ placeID: String) -> CKRecord.ID {
        CKRecord.ID(recordName: placeID, zoneID: zoneID)
    }

    static func make(_ place: SavedPlace, systemFields: Data?) throws -> CKRecord {
        let record: CKRecord
        if let systemFields {
            let decoder = try NSKeyedUnarchiver(forReadingFrom: systemFields)
            decoder.requiresSecureCoding = true
            guard let restored = CKRecord(coder: decoder) else { throw LocationSyncError.invalidRecord }
            decoder.finishDecoding()
            guard restored.recordID == recordID(place.id), restored.recordType == recordType else {
                throw LocationSyncError.invalidRecord
            }
            record = restored
        } else {
            record = CKRecord(recordType: recordType, recordID: recordID(place.id))
        }
        record["id"] = place.id as CKRecordValue
        record["name"] = place.name as CKRecordValue
        record["formattedAddress"] = place.formattedAddress as CKRecordValue
        record["latitude"] = place.latitude as CKRecordValue
        record["longitude"] = place.longitude as CKRecordValue
        record["addressComponents"] = try JSONEncoder().encode(place.addressComponents) as CKRecordValue
        return record
    }

    static func place(from record: CKRecord) throws -> SavedPlace {
        guard record.recordType == recordType, record.recordID.zoneID == zoneID,
            let id = record["id"] as? String, id == record.recordID.recordName,
            let latitude = record["latitude"] as? Double,
            let longitude = record["longitude"] as? Double
        else { throw LocationSyncError.invalidRecord }
        return SavedPlace(
            id: id, name: record["name"] as? String ?? "",
            formattedAddress: record["formattedAddress"] as? String ?? "",
            latitude: latitude, longitude: longitude,
            addressComponents: try components(record["addressComponents"]))
    }

    static func legacyPlace(from record: CKRecord) throws -> SavedPlace? {
        guard record.recordType == "CD_PlaceEntity" else { return nil }
        guard let id = record["CD_id"] as? String else { throw LocationSyncError.invalidRecord }
        return SavedPlace(
            id: id, name: record["CD_name"] as? String ?? "",
            formattedAddress: record["CD_formattedAddress"] as? String ?? "",
            latitude: record["CD_latitude"] as? Double ?? 0,
            longitude: record["CD_longitude"] as? Double ?? 0,
            addressComponents: try components(record["CD_addressComponents"] ?? record["CD_addressComponents_ckAsset"]))
    }

    static func systemFields(of record: CKRecord) -> Data {
        let encoder = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: encoder)
        encoder.finishEncoding()
        return encoder.encodedData
    }

    private static func components(_ value: CKRecordValue?) throws -> [PlaceAddressComponent] {
        guard let value else { return [] }
        let data: Data
        if let stored = value as? Data {
            data = stored
        } else if let asset = value as? CKAsset, let url = asset.fileURL {
            data = try Data(contentsOf: url)
        } else {
            throw LocationSyncError.invalidRecord
        }
        return try JSONDecoder().decode([PlaceAddressComponent].self, from: data)
    }
}

enum LocationSyncError: LocalizedError {
    case differentAccount
    case invalidRecord

    var errorDescription: String? {
        switch self {
        case .differentAccount:
            "Locations are linked to a different iCloud account. Sync is paused; your local locations are retained."
        case .invalidRecord: "A saved location has an invalid CloudKit record."
        }
    }
}
