//
//  LocationManager.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 11/27/23.
//


import CoreLocation

class LocationManager: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var locationAuthorized: Bool?
    
    let locationManager: CLLocationManager
    
    init(startAutomatically: Bool = true, locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.delegate = self
        if startAutomatically {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        currentLocation = latestLocation
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            break
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
    }
}
