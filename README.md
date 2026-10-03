# AzureSkys (iOS App)

AzureSkys is a sleek and intuitive weather app for iOS. With AzureSkys, you can search for weather updates by location, save your favorite locations, and effortlessly switch between Celsius and Fahrenheit temperature displays.

## Features
- **Search Locations**: Find current weather conditions for any location worldwide.
- **Save Locations**: Bookmark frequently checked locations for quick access.
- **Temperature Toggle**: Easily switch between Celsius and Fahrenheit displays.

## Technologies Used
- **SwiftUI**: For a modern and declarative UI experience.
- **Combine**: To manage asynchronous events seamlessly.
- **Network**: For reliable and efficient API calls.
- **CoreLocation**: To access and use device location services.
- **CoreData**: For persistent storage of saved locations.

## Architecture
AzureSkys follows the **MVVM-C (Model-View-ViewModel-Coordinator)** architecture pattern, ensuring clean and maintainable code.

## App Store
[Download AzureSkys on the App Store](https://apps.apple.com/us/app/azureskys/id6511211335)

## Tests

The shared `AzureSkys` scheme includes `AzureSkysTests` and `AzureSkysUITests`.
Run both suites in Xcode with **Product → Test** (`⌘U`) on an iPhone simulator,
or use:

```sh
xcodebuild -project AzureSkys.xcodeproj -scheme AzureSkys \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro Max' \
  CODE_SIGNING_ALLOWED=NO -enableCodeCoverage YES test
```

Choose an installed simulator name if yours differs. Add
`-only-testing:AzureSkysTests` or `-only-testing:AzureSkysUITests` to run one suite.

Unit tests cover request state, error mapping, navigation, saved-place persistence,
replaceable search, refresh scheduling, object release, and network responses.
Network tests use an isolated `URLSession` with a stub protocol.
UI tests pass `--ui-testing` to select fixture services, a fresh temporary store,
and a known location without requesting location access or calling external APIs.
The `--search-fails-once` argument exercises search retry. These launch switches
are enabled only in Debug builds.

There is a matching unit-test file for each of the 78 production Swift files.
The expanded suite passes 126 unit tests and four UI tests, with **96.09% application
line coverage**. See [the coverage report](docs/TEST_COVERAGE.md) for per-file
results, reproduction commands, and the limits of rendering smoke tests.
