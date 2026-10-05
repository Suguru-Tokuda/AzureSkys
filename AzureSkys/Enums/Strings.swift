//
//  Strings.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/5/26.
//

enum Strings: String {
    // Common.
    case dismiss = "Dismiss"
    case openSettings = "Open Settings"
    case error = "Error"
    case retry = "Retry"
    case networkError = "Network Error"
    case ok = "OK"
    case loading = "Loading..."
    case myLocation = "My Location"
    case unavailable = "-"
    case cancel = "Cancel"
    case add = "Add"
    case azureSkys = "AzureSkys"

    // Onboarding.
    case onboardingICloudSetupTitle = "Set up iCloud access"
    case onboardingICloudSetupStepOne = "Open Settings → your name. Sign in if needed."
    case onboardingICloudSetupStepTwo = "Tap iCloud → See All (or Show All)."
    case onboardingICloudSetupStepThree = "Find AzureSkys and turn on iCloud access."
    case onboardingICloudSetupReturn = "Return here—we’ll check iCloud access automatically."
    case weatherWhereYouAre = "Weather where\nyou are"
    case iCloudCheckError = "Couldn't check iCloud availabbility. Try again."
    case locationAccessDescription = "Allow location access to see your local forecast. You can also add cities manually."
    case allowLocation = "Allow Location"
    case chooseCitiesInstead = "Choose Cities Instead"
    case yourPlacesEverywhere = "Your places, everywhere"
    case iCloudSyncDescription = "Sync your saved locations across your devidces with iCloud."
    case enableICloudSync = "Enable iCloud Sync"
    case notNow = "Not Now"
    case step1Of2 = "Step 1 of 2"
    case step2Of2 = "Step 2 of 2"

    // Settings.
    case temperature = "Temperature"
    case temperatureUnit = "Temperature unit"
    case iCloudSync = "iCloud Sync"
    case iCloudUnavailableDescription = "iCloud is unavailable. Check your Apple Account and this app's iCloud access in Settings."
    case settings = "Settings"
    case locationAccess = "Location Access"
    case enableLocation = "Enable Location"
    case manageLocation = "Manage Location Access"
    case locationNotRequested = "Not Requested"
    case locationDenied = "Denied"
    case locationRestricted = "Restricted"
    case locationEnabled = "Enabled"
    case locationUnknown = "Unknown"
    case locationRestrictedDescription = "Location access is restricted by your device settings."

    // LocationAuthorization.
    case locationAuthorizationRequired = "Location Authorization Required"
    case locationAuthorizationDescription = "The App requires location information to continue"

    // Weather.
    case today = "Today"
    case weather = "Weather"
    case locationsTitle = "Locations"
    case weatherIconUnavailable = "Weather icon unavailable"
    case feelsLikeTitle = "Feels Like"
    case feelsLikeUppercase = "FEELS LIKE"
    case wind = "Wind"
    case mph = "MPH"
    case gusts = "Gusts"
    case feelsLike = "Feels like"
    case visibility = "Visibility"
    case humidity = "Humidity"
    case pressure = "Pressure"
    case cloudiness = "Cloudiness"
    case uvIndex = "UV Index"
    case dewPoint = "Dew Point"
    case now = "Now"

    // Temperature.
    case fahrenheit = "Fahrenheit"
    case celsius = "Celsius"
    case fahrenheitSymbol = "°F"
    case celsiusSymbol = "°C"

    // CoreDataError messages.
    case coreDataSaveError = "Error with saving to core data."
    case coreDataFetchError = "Error with fetching from core data."
    case coreDataDeleteError = "Error with deleting from core data."

    // FileManagerError messages.
    case dataParsingError = "Error in parsing to data."
    case filePathError = "Could not find a path to the file."
    case fileSaveError = "Error in saving data."
    case fileRetrieveError = "Error in retrieving data."

    // NetworkError messages.
    case badURLError = "Bad URL Error. Please make sure the URL is valid."
    case dataProcessingError = "Data Processing Error"
    case serverError = "Server Error"
    case noDataFound = "No data found."
    case networkConnectionUnavailable = "Network connection unavailable"
    case unknownError = "Unknown error."

    // PlistError messages.
    case plistParsingError = "Error in parsing a PList."
    case plistURLError = "Error in finding a url."
    case plistPathError = "Error in finding a path."
    case plistDataNotFound = "No PList data found."

    // Display templates.
    static func appendingDegree(_ value: String) -> String {
        "\(value)\u{00B0}"
    }
    static func degreePrefixedUnit(_ unit: String) -> String {
        "°\(unit)"
    }
    static func highTemperature(_ temperature: String) -> String {
        "H:\(temperature)"
    }
    static func lowTemperature(_ temperature: String) -> String {
        "L:\(temperature)"
    }
    static func miles(_ distance: String) -> String {
        "\(distance) mi"
    }
    static func humidityValue(_ humidity: String) -> String {
        "\(humidity) %"
    }
    static func pressureValue(_ pressure: String) -> String {
        "\(pressure) hPa"
    }
    static func percentage(_ value: String) -> String {
        "\(value)%"
    }
}
