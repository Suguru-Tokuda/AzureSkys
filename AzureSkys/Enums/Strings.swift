//
//  Strings.swift
//  AzureSkys
//
//  Created by Suguru Tokuda on 10/4/26.
//

import Foundation

enum Strings: String {
    case onboardingICloudSetupTitle = "Set up iCloud access"
    case onboardingICloudSetupStepOne = "Open Settings → your name. Sign in if needed."
    case onboardingICloudSetupStepTwo = "Tap iCloud → See All (or Show All)."
    case onboardingICloudSetupStepThree = "Find AzureSkys and turn on iCloud access."
    case onboardingICloudSetupReturn = "Return here—we’ll check iCloud access automatically."
    case weatherWhereYouAre = "Weather where\nyou are"

    // Runtime identifiers and persistence.
    case uiTestingArgument = "--ui-testing"
    case testConfigurationEnvironmentKey = "XCTestConfigurationFilePath"
    case backdropLayerClassName = "CABackdropLayer"
    case current = "current"
    case locations = "locations"
    case weatherCoreData = "WeatherCoreData"
    case missingPersistentStoreDescription = "WeatherCoreData has no persistent store description."
    case nullDevicePath = "/dev/null"

    // Error messages and localization comments.
    case coreDataSaveError = "Error with saving to core data."
    case save = "save"
    case coreDataFetchError = "Error with fetching from core data."
    case fetch = "fetch"
    case coreDataDeleteError = "Error with deleting from core data."
    case delete = "delete"
    case dataParsingError = "Error in parsing to data."
    case data = "data"
    case filePathError = "Could not find a path to the file."
    case badPath = "badPath"
    case fileSaveError = "Error in saving data."
    case fileRetrieveError = "Error in retrieving data."
    case retrieve = "retrieve"
    case badURLError = "Bad URL Error. Please make sure the URL is valid."
    case badUrl = "badUrl"
    case dataProcessingError = "Data Processing Error"
    case dataParsingErrorComment = "dataParsingError"
    case serverError = "Server Error"
    case serverErrorComment = "serverError"
    case noDataFound = "No data found."
    case noData = "noData"
    case networkConnectionUnavailable = "Network connection unavailable"
    case networkUnavailable = "networkUnavailable"
    case unknownError = "Unknown error."
    case unknown = "unknown"
    case plistParsingError = "Error in parsing a PList."
    case parse = "parse"
    case plistURLError = "Error in finding a url."
    case url = "url"
    case plistPathError = "Error in finding a path."
    case path = "path"
    case plistDataNotFound = "No PList data found."
    case dataNotFound = "dataNotFound"

    // Temperature labels and units.
    case fahrenheit = "Fahrenheit"
    case celsius = "Celsius"
    case fahrenheitSymbol = "°F"
    case celsiusSymbol = "°C"

    // Image assets.
    case weatherBackgroundClearDay = "WeatherBackgroundClearDay"
    case weatherBackgroundClearNight = "WeatherBackgroundClearNight"
    case weatherBackgroundCloudsDay = "WeatherBackgroundCloudsDay"
    case weatherBackgroundCloudsNight = "WeatherBackgroundCloudsNight"
    case weatherBackgroundThunderstormDay = "WeatherBackgroundThunderstormDay"
    case weatherBackgroundDrizzleDay = "WeatherBackgroundDrizzleDay"
    case weatherBackgroundRainDay = "WeatherBackgroundRainDay"
    case weatherBackgroundSnowDay = "WeatherBackgroundSnowDay"
    case weatherBackgroundMistDay = "WeatherBackgroundMistDay"
    case weatherBackgroundSmokeDay = "WeatherBackgroundSmokeDay"
    case weatherBackgroundHazeDay = "WeatherBackgroundHazeDay"
    case weatherBackgroundDustDay = "WeatherBackgroundDustDay"
    case weatherBackgroundFogDay = "WeatherBackgroundFogDay"
    case weatherBackgroundSandDay = "WeatherBackgroundSandDay"
    case weatherBackgroundAshDay = "WeatherBackgroundAshDay"
    case weatherBackgroundSquallDay = "WeatherBackgroundSquallDay"
    case weatherBackgroundTornadoDay = "WeatherBackgroundTornadoDay"

    // Shared display text.
    case today = "Today"
    case empty = ""
    case sun = "Sun"
    case azureSkys = "AzureSkys"

    // API parameters and resource names.
    case dayIconMarker = "d"
    case autocompleteJson = "autocomplete/json"
    case input = "input"
    case types = "types"
    case citiesFilter = "(cities)"
    case fields = "fields"
    case autocompleteFields = "place_id,description"
    case detailsJson = "details/json"
    case placeid = "placeid"
    case placeDetailFields = "geometry,formatted_address,name,place_id,address_components"
    case key = "key"
    case oneCallPath = "/data/3.0/onecall"
    case reverseGeocodePath = "/geo/1.0/reverse"
    case currentWeatherPath = "/data/2.5/weather"
    case lat = "lat"
    case lon = "lon"
    case appid = "appid"
    case exclude = "exclude"
    case minutely = "minutely"
    case apiKeys = "ApiKeys"
    case plist = "plist"
    case searchFailsOnceArgument = "--search-fails-once"
    case weatherAPIEndpoint = "https://api.openweathermap.org"
    case googleAPIBaseURL = "https://maps.googleapis.com/maps/api/place/"
    case weatherIconURL = "https://openweathermap.org/img/wn/ICON_CODE@2x.png"
    case dateFormat = "yyyy-MM-dd HH:mm:ss"
    case placeIDPredicate = "id == %@"
    case placeEntity = "PlaceEntity"

    // Preview data.
    case atlanta = "Atlanta"
    case previewCountryCode = "US"
    case georgia = "Georgia"
    case americaNewYork = "America/New_York"
    case clear = "Clear"
    case clearSky = "clear sky"
    case clearDayIcon = "01d"
    case previewDailySummary = "Expect a day of partly cloudy with clear spells"
    case previewForecastDate1 = "2023-11-27 21:00:00"
    case previewForecastDate2 = "2023-11-28 21:00:00"
    case previewForecastDate3 = "2023-11-29 21:00:00"
    case previewForecastDate4 = "2023-11-230 21:00:00"
    case cupertino = "Cupertino"
    case chicagoILUSA = "Chicago IL, USA"
    case previewPlaceID = "ChIJ7cv00DwsDogRAMDACa2m4K8"
    case chicago = "Chicago"
    case previewRegion = "IL, USA"
    case previewFormattedAddress = "Chicago, IL, USA"
    case locality = "locality"
    case political = "political"
    case cookCounty = "Cook County"
    case dministrativeAreaLevel2 = "dministrative_area_level_2"
    case illinois = "Illinois"
    case previewStateCode = "IL"
    case dministrativeAreaLevel1 = "dministrative_area_level_1"
    case unitedState = "United State"
    case country = "country"

    // Onboarding, settings, and accessibility.
    case hasSeenOnboarding = "hasSeenOnboarding"
    case iCloudCheckError = "Couldn't check iCloud availabbility. Try again."
    case dismiss = "Dismiss"
    case dismissButton = "dismissButton"
    case locationAuthorizationRequired = "Location Authorization Required"
    case locationAuthorizationDescription = "The App requires location information to continue"
    case openSettings = "Open Settings"
    case error = "Error"
    case retry = "Retry"
    case networkError = "Network Error"
    case ok = "OK"
    case loading = "Loading..."
    case myLocation = "My Location"
    case timeFormat = "hh:mm"
    case unavailable = "-"
    case weather = "Weather"
    case previewHotTemperature = "94°"
    case houston = "Houston"
    case previewVeryHotTemperature = "105°"
    case onboardingSky = "OnboardingSky"
    case locationAccessDescription = "Allow location access to see your local forecast. You can also add cities manually."
    case allowLocation = "Allow Location"
    case chooseCitiesInstead = "Choose Cities Instead"
    case yourPlacesEverywhere = "Your places, everywhere"
    case iCloudSyncDescription = "Sync your saved locations across your devidces with iCloud."
    case enableICloudSync = "Enable iCloud Sync"
    case notNow = "Not Now"
    case step1Of2 = "Step 1 of 2"
    case step2Of2 = "Step 2 of 2"
    case temperature = "Temperature"
    case temperatureUnit = "Temperature unit"
    case iCloudSync = "iCloud Sync"
    case iCloudUnavailableDescription = "iCloud is unavailable. Check your Apple Account and this app's iCloud access in Settings."
    case settings = "Settings"
    case cancel = "Cancel"
    case add = "Add"
    case locationsTitle = "Locations"
    case locationsButton = "locationsButton"
    case weatherIconUnavailable = "Weather icon unavailable"
    case iconCodePlaceholder = "ICON_CODE"
    case feelsLikeTitle = "Feels Like"
    case feelsLikeUppercase = "FEELS LIKE"
    case previewFeelsLikeTemperature = "44°"
    case previewTemperature = "40°"
    case wind = "Wind"
    case wholeNumberFormat = "%.0f"
    case mph = "MPH"
    case gusts = "Gusts"
    case feelsLike = "Feels like"
    case visibility = "Visibility"
    case humidity = "Humidity"
    case pressure = "Pressure"
    case cloudiness = "Cloudiness"
    case uvIndex = "UV Index"
    case dewPoint = "Dew Point"
    case weatherScroll = "weatherScroll"
    case now = "Now"
    case hourFormat = "ha"

    // Values are formatted by the caller before being inserted into these templates.
    static func savedLocationID(_ placeID: String) -> String {
        "saved:\(placeID)"
    }

    static func forecastRouteID(_ locationID: String) -> String {
        "forecast:\(locationID)"
    }

    static func unresolvedError(_ error: String, _ userInfo: String) -> String {
        "Unresolved error \(error), \(userInfo)"
    }

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
