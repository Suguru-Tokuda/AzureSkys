//
//  LocationManager.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/27/23.
//

import Combine
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published var currentLocation: CLLocation?
    @Published var locationAuthorized: Bool?
    var locationAuthorizedPublisher = PassthroughSubject<Bool?, Never>()

    let locationManager: CLLocationManager

    init(startAutomatically: Bool = false, locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.delegate = self
        locationManagerDidChangeAuthorization(locationManager)
        if startAutomatically {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        currentLocation = latestLocation
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch authorizationStatus {
        case .notDetermined:
            locationAuthorized = nil
        case .restricted:
            locationAuthorized = false
            break
        case .denied:
            locationAuthorized = false
            break
        case .authorizedAlways:
            locationAuthorized = true
            break
        case .authorizedWhenInUse:
            locationAuthorized = true
            break
        @unknown default:
            locationAuthorized = false
            break
        }

        if locationAuthorized == true {
            manager.startUpdatingLocation()
        } else {
            manager.stopUpdatingLocation()
        }

        locationAuthorizedPublisher.send(locationAuthorized)
    }
}
