# Location persistence and iCloud sync

Locations live in the local-only `WeatherLocalCoreData` store. The UI and location services never read a CloudKit-managed store. `CloudKitLocationSync` uses `CKSyncEngine` against the existing `iCloud.com.stokuda.weather` private database.

A location edit and its `LocalSyncAction` are committed in the same Core Data transaction. Each edit gets a revision UUID. Successful per-record server responses clear only the matching revision; a newer edit remains queued. The journal is authoritative if serialized engine state is older than the local database after a crash. Engine state and CKRecord system fields are stored in Core Data, not in location backup files.

Remote changes are applied locally without creating upload actions. Pending local edits take precedence until acknowledged. Server-record conflicts retain the pending local intent, adopt the latest server system fields, and retry. Network and authentication retries are managed by CKSyncEngine. Missing records and deleted zones are handled explicitly.

Turning sync off cancels engine operations without modifying local locations or pending edits. Signing out retains local data and account identity. A different iCloud account pauses sync instead of automatically uploading the previous account's locations. Signing back into the original account allows syncing to resume. Transferring locations to another account requires a future explicit user flow.

## Migration

The old SQLite database is read once through NSPersistentContainer, without a CloudKit mirroring delegate. The original local model version is retained and a V2 model adds revision IDs and cached CloudKit system fields, allowing automatic migration of the previous two-store bridge's locations and pending deletions.

On first activation, the coordinator reads all pages of the old `com.apple.coredata.cloudkit.zone` using CloudKit change tokens. `CD_PlaceEntity` records are imported into the local store without overwriting existing locations or pending deletions. Import failures leave the migration incomplete for retry. Imported locations are queued for the new zone. The old cloud zone and its records are never modified or deleted.

The new zone is `AzureSkysLocations`. Its record type is `AzureSkysPlace`. Record names are the stable saved-place IDs. Fields:

| Field             | CloudKit type                                    |
| ----------------- | ------------------------------------------------ |
| id                | String                                           |
| name              | String                                           |
| formattedAddress  | String                                           |
| latitude          | Double                                           |
| longitude         | Double                                           |
| addressComponents | Bytes (existing address-component JSON encoding) |

## Release validation

1. On an iCloud-enabled development device, verify initial migration, remote-only legacy locations, and interrupted migration retry. Use the CloudKit development environment to create and inspect the new schema.
2. Test two devices with the new version: additions, deletions, edits during uploads, offline edits, relaunch, iCloud disabled in Settings, and sign-out/sign-in. Verify a different account cannot receive the original account's data.
3. Deploy the `AzureSkysPlace` development schema to production in CloudKit Console before releasing the app. Production cannot create the new fields dynamically.
4. Upgrade all participating devices. Older app versions use the old Core Data zone; new versions use the new zone. The one-time import preserves existing data, but it does not provide ongoing synchronization with older versions.

Automated tests exercise the actual local model, migration, record encoding, journal revisions, batch construction, and import/acknowledgement handling. They do not prove live server synchronization or production-schema availability.
