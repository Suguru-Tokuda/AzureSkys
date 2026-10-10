//
//  LocationsViewModel.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 12/7/23.
//

import SwiftUI
import CoreData
import Combine

@MainActor
class LocationsViewModel: ObservableObject {
    @Published private(set) var places: [SavedPlace] = []
    @Published private(set) var refreshRevision = 0
    private var observedContext: NSManagedObjectContext?
    private var subscriptions = Set<AnyCancellable>()

    struct RefreshID: Equatable {
        let context: ObjectIdentifier
        let revision: Int
    }

    func refreshID(for context: NSManagedObjectContext) -> RefreshID {
        RefreshID(context: ObjectIdentifier(context), revision: refreshRevision)
    }

    func observeChanges(in context: NSManagedObjectContext) {
        guard observedContext !== context else { return }

        observedContext = context
        subscriptions.removeAll()

        for name in [Notification.Name.NSManagedObjectContextDidSave, .NSManagedObjectContextObjectsDidChange] {
            NotificationCenter.default.publisher(for: name)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] notification in
                    guard let self, let changed = notification.object as? NSManagedObjectContext,
                        let current = self.observedContext
                    else { return }

                    let relevant =
                        name == .NSManagedObjectContextDidSave
                        ? changed.persistentStoreCoordinator === current.persistentStoreCoordinator
                        : changed === current
                    if relevant {
                        self.refreshRevision += 1
                    }
                }
                .store(in: &subscriptions)
        }
    }

    func loadPlaces() async {
        do {
            // The store serializes this fetch with cloud-sync reconfiguration.
            let fetched = try await placeCoreDataManager.getPlacesFromDatabase()

            try Task.checkCancellation()
            places = fetched.sorted {
                let comparison = $0.name.localizedStandardCompare($1.name)

                return comparison == .orderedSame ? $0.id < $1.id : comparison == .orderedAscending
            }
        } catch {
            guard !Task.isCancelled else {
                return
            }

            coreDataError = .fetch
        }
    }

    func removePlaces(at offsets: IndexSet) async {
        let selected = offsets.compactMap { places.indices.contains($0) ? places[$0] : nil }

        await removePlaces(selected)
    }

    @Published var coreDataError: CoreDataError?

    private let placeCoreDataManager: PlaceCoreDataActions

    init(placeCoreDataManager: PlaceCoreDataActions) {
        self.placeCoreDataManager = placeCoreDataManager
    }

    func removeCity(results: FetchedResults<PlaceEntity>, indexSet: IndexSet) {
        // Capture the selected places before deletions update the fetched results.
        let places = indexSet.compactMap { SavedPlace(from: results[$0]) }

        Task { [weak self] in
            await self?.removePlaces(places)
        }
    }

    func removePlaces(_ places: [SavedPlace]) async {
        coreDataError = nil

        for place in places {
            do {
                try await placeCoreDataManager.deleteFromDatabase(place: place)
            } catch {
                coreDataError = .delete
            }
        }
    }

    func dismissError() {
        coreDataError = nil
    }
}
