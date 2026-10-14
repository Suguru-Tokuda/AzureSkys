# iCloud location sync

Saved locations use `NSPersistentCloudKitContainer` with the `WeatherCoreData` model and the `iCloud.com.stokuda.weather` private database. Core Data owns record serialization, persistent history, imports, exports, conflict handling, and network retries.

The iCloud setting reloads the same SQLite store with `cloudKitContainerOptions` enabled or disabled. Local locations remain available with sync off. Background saves are serialized against store replacement, and the UI receives the replacement view context. In-memory previews and tests never enable mirroring. Completed Core Data sync events supply errors shown in Settings; Core Data does not expose the former custom journal's pending-upload count.

`AppDependencies` opens the local persistence stack, constructs `PlaceCoreDataManager` to migrate and reconcile saved locations, and then enables CloudKit mirroring according to the saved preference. The manager owns migration and observes successful CloudKit import/export events, checking against the current container so observation survives sync toggles. It also reconciles before saves and list reads. `PersistenceController` owns only stack loading, replacement, serialized context work, and sync-error reporting; it has no place-specific dependency or maintenance hook. It saves ordinary Core Data deletions, so mirroring removes redundant cloud records too. An existing CloudKit record is preferred over a new local duplicate; when several cloud records exist, the lexicographically smallest record name survives on every device. Local-only duplicates are collapsed before export. The list fetch no longer filters duplicate rows.

CloudKit mirroring does not support unique constraints. Two offline devices can still create separate records for the same place; reconciliation removes the extras after those records meet. Two-device testing must verify that both devices keep the same cloud record and that duplicate deletions reach CloudKit.

At first launch after this change, locations from `WeatherCoreData.local.sqlite` are copied into the original `WeatherCoreData.sqlite` store before mirroring starts. The newer local store is authoritative, including deletions, and a persistent-store metadata marker prevents repeating the migration. The source store is retained. The local model versions remain bundled so existing stores can be read.

Records in the former custom `AzureSkysLocations` zone are not imported by Core Data. Installed devices migrate their saved local locations; a fresh installation can restore records from Core Data's `com.apple.coredata.cloudkit.zone`, but cannot restore locations that exist only in the former custom zone.

Validate syncing, deletion propagation, account changes, and offline edits on two devices sharing an iCloud account. Before release, verify the Core Data schema is deployed to production in CloudKit Console. Simulator tests verify local persistence and migration; they do not verify live iCloud uploads.
