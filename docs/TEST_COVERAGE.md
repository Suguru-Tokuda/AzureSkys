# Test coverage

Measured October 3, 2026 on iPhone 18 Pro Max, iOS 27.0 Simulator.

| Metric | Result |
| --- | --- |
| Application line coverage before expansion | 79.95% (3,087 / 3,861 lines) |
| Application line coverage after expansion | 96.09% (3,713 / 3,864 lines) |
| Unit tests | 126 passed |
| UI tests | 4 passed |
| Failed / skipped tests | 0 / 0 |
| Production Swift files with matching test files | 78 / 78 |

Coverage is for **AzureSkys.app**, excluding test targets. No production files or uncovered lines were excluded to increase the percentage. The denominator changed slightly as dependencies became injectable and two bugs were fixed.

## What the tests check

Service tests use synthetic responses and verify endpoint construction, decoding, transport failures, missing configuration, and server errors. View-model tests exercise loading, failures, recovery, cancellation, replacement requests, refresh scheduling, and object release. Persistence tests use isolated stores; location and settings tests use injected system interfaces. Value tests cover conversions, formatting, decoding, and boundaries.

Every production Swift file has a matching test file. Many SwiftUI tests are rendering smoke tests or comparisons between displayed states, rather than golden-image visual regression tests. Four UI tests exercise dismissing locations, canceling a preview, saving/selecting a place, and retrying a failed search. A file per source file is an organizational choice; meaningful behavior assertions remain more important than file count.

## Remaining limits

151 executable lines remain uncovered. These include SwiftUI interaction closures (such as swipe deletion and scroll callbacks), alternate authorization/navigation branches, default live dependency construction, previews, and defensive error paths. Real external APIs, device permission dialogs, and OS settings behavior are not exercised by the deterministic suite. Line coverage does not establish complete branch coverage or visual correctness.

The legacy fixed-offset date conversion is characterized by tests; its timezone behavior is unchanged.

## Reproduce

The shared scheme enables coverage for Product → Test in Xcode. From the terminal:

```sh
xcodebuild -project AzureSkys.xcodeproj -scheme AzureSkys \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro Max' \
  CODE_SIGNING_ALLOWED=NO -parallel-testing-enabled NO \
  -enableCodeCoverage YES -collect-test-diagnostics never \
  -resultBundlePath /tmp/AzureSkys-coverage.xcresult test

xcrun xccov view --report /tmp/AzureSkys-coverage.xcresult
```

Use an installed simulator and a new result-bundle path for each run. This measurement came from `/tmp/AzureSkys-final-coverage-20261003.xcresult`.

## Per-file coverage

A dash means Xcode reported no executable lines for that file. Declaration-only files still have contract tests. Percentages below are rounded.

| Production file | Matching unit test | Executable line coverage |
| --- | --- | --- |
| [AzureSkysApp.swift](../AzureSkys/AzureSkysApp.swift) | [AzureSkysAppTests.swift](../AzureSkysTests/App/AzureSkysAppTests.swift) | 100.00% (16/16) |
| [OpenSettingsBtnStyle.swift](../AzureSkys/ButtonStyles/OpenSettingsBtnStyle.swift) | [OpenSettingsBtnStyleTests.swift](../AzureSkysTests/ButtonStyles/OpenSettingsBtnStyleTests.swift) | 100.00% (9/9) |
| [Blur.swift](../AzureSkys/Components/Blur.swift) | [BlurTests.swift](../AzureSkysTests/Components/BlurTests.swift) | 85.71% (12/14) |
| [ContentView.swift](../AzureSkys/ContentView.swift) | [ContentViewTests.swift](../AzureSkysTests/App/ContentViewTests.swift) | 94.74% (18/19) |
| [MainCoordinator.swift](../AzureSkys/Coordinator/MainCoordinator.swift) | [MainCoordinatorTests.swift](../AzureSkysTests/Coordinator/MainCoordinatorTests.swift) | 97.78% (44/45) |
| [PersistenceController.swift](../AzureSkys/CoreData/PersistenceController.swift) | [PersistenceControllerTests.swift](../AzureSkysTests/CoreData/PersistenceControllerTests.swift) | 88.46% (23/26) |
| [CoreDataError.swift](../AzureSkys/Enums/CoreDataError.swift) | [CoreDataErrorTests.swift](../AzureSkysTests/Enums/CoreDataErrorTests.swift) | 100.00% (10/10) |
| [FileManagerError.swift](../AzureSkys/Enums/FileManagerError.swift) | [FileManagerErrorTests.swift](../AzureSkysTests/Enums/FileManagerErrorTests.swift) | 100.00% (12/12) |
| [LoadingStatus.swift](../AzureSkys/Enums/LoadingStatus.swift) | [LoadingStatusTests.swift](../AzureSkysTests/Enums/LoadingStatusTests.swift) | — |
| [NetworkError.swift](../AzureSkys/Enums/NetworkError.swift) | [NetworkErrorTests.swift](../AzureSkysTests/Enums/NetworkErrorTests.swift) | 100.00% (34/34) |
| [PlistError.swift](../AzureSkys/Enums/PlistError.swift) | [PlistErrorTests.swift](../AzureSkysTests/Enums/PlistErrorTests.swift) | 100.00% (12/12) |
| [RequestState.swift](../AzureSkys/Enums/RequestState.swift) | [RequestStateTests.swift](../AzureSkysTests/Enums/RequestStateTests.swift) | 100.00% (24/24) |
| [TempColor.swift](../AzureSkys/Enums/TempColor.swift) | [TempColorTests.swift](../AzureSkysTests/Enums/TempColorTests.swift) | 100.00% (33/33) |
| [TempScale.swift](../AzureSkys/Enums/TempScale.swift) | [TempScaleTests.swift](../AzureSkysTests/Enums/TempScaleTests.swift) | 100.00% (7/7) |
| [UserDefaultKeys.swift](../AzureSkys/Enums/UserDefaultKeys.swift) | [UserDefaultKeysTests.swift](../AzureSkysTests/Enums/UserDefaultKeysTests.swift) | — |
| [WeatherCondition.swift](../AzureSkys/Enums/WeatherCondition.swift) | [WeatherConditionTests.swift](../AzureSkysTests/Enums/WeatherConditionTests.swift) | 100.00% (71/71) |
| [Weekdays.swift](../AzureSkys/Enums/Weekdays.swift) | [WeekdaysTests.swift](../AzureSkysTests/Enums/WeekdaysTests.swift) | 100.00% (20/20) |
| [Color.swift](../AzureSkys/Extensions/Color.swift) | [ColorTests.swift](../AzureSkysTests/Extensions/ColorTests.swift) | — |
| [Date.swift](../AzureSkys/Extensions/Date.swift) | [DateTests.swift](../AzureSkysTests/Extensions/DateTests.swift) | 100.00% (12/12) |
| [Double.swift](../AzureSkys/Extensions/Double.swift) | [DoubleTests.swift](../AzureSkysTests/Extensions/DoubleTests.swift) | 95.24% (20/21) |
| [Int.swift](../AzureSkys/Extensions/Int.swift) | [IntTests.swift](../AzureSkysTests/Extensions/IntTests.swift) | 92.00% (23/25) |
| [String.swift](../AzureSkys/Extensions/String.swift) | [StringTests.swift](../AzureSkysTests/Extensions/StringTests.swift) | 100.00% (17/17) |
| [UIApplication.swift](../AzureSkys/Extensions/UIApplication.swift) | [UIApplicationTests.swift](../AzureSkysTests/Extensions/UIApplicationTests.swift) | 100.00% (3/3) |
| [View.swift](../AzureSkys/Extensions/View.swift) | [ViewTests.swift](../AzureSkysTests/Extensions/ViewTests.swift) | 100.00% (6/6) |
| [LaunchView.swift](../AzureSkys/Launch/Views/LaunchView.swift) | [LaunchViewTests.swift](../AzureSkysTests/Launch/Views/LaunchViewTests.swift) | 100.00% (37/37) |
| [ApiKeyModel.swift](../AzureSkys/Models/ApiKeyModel.swift) | [ApiKeyModelTests.swift](../AzureSkysTests/Models/ApiKeyModelTests.swift) | — |
| [GoogleAutoCompleteModel.swift](../AzureSkys/Models/GoogleAutoCompleteModel.swift) | [GoogleAutoCompleteModelTests.swift](../AzureSkysTests/Models/GoogleAutoCompleteModelTests.swift) | 100.00% (13/13) |
| [GooglePlaceDetailsResponse.swift](../AzureSkys/Models/GooglePlaceDetailsResponse.swift) | [GooglePlaceDetailsResponseTests.swift](../AzureSkysTests/Models/GooglePlaceDetailsResponseTests.swift) | 100.00% (15/15) |
| [SavedPlace.swift](../AzureSkys/Models/SavedPlace.swift) | [SavedPlaceTests.swift](../AzureSkysTests/Models/SavedPlaceTests.swift) | — |
| [WeatherForecastCurrentResponse.swift](../AzureSkys/Models/WeatherForecastCurrentResponse.swift) | [WeatherForecastCurrentResponseTests.swift](../AzureSkysTests/Models/WeatherForecastCurrentResponseTests.swift) | — |
| [WeatherForecastOneCallResponse.swift](../AzureSkys/Models/WeatherForecastOneCallResponse.swift) | [WeatherForecastOneCallResponseTests.swift](../AzureSkysTests/Models/WeatherForecastOneCallResponseTests.swift) | 100.00% (2/2) |
| [WeatherForecastResponse.swift](../AzureSkys/Models/WeatherForecastResponse.swift) | [WeatherForecastResponseTests.swift](../AzureSkysTests/Models/WeatherForecastResponseTests.swift) | 94.12% (96/102) |
| [WeatherGeocode.swift](../AzureSkys/Models/WeatherGeocode.swift) | [WeatherGeocodeTests.swift](../AzureSkysTests/Models/WeatherGeocodeTests.swift) | — |
| [ViewOffsetKey.swift](../AzureSkys/PreferenceKeys/ViewOffsetKey.swift) | [ViewOffsetKeyTests.swift](../AzureSkysTests/PreferenceKeys/ViewOffsetKeyTests.swift) | 100.00% (3/3) |
| [PlacesService.swift](../AzureSkys/Services/PlacesService.swift) | [PlacesServiceTests.swift](../AzureSkysTests/Services/PlacesServiceTests.swift) | 100.00% (46/46) |
| [WeatherService.swift](../AzureSkys/Services/WeatherService.swift) | [WeatherServiceTests.swift](../AzureSkysTests/Services/WeatherServiceTests.swift) | 100.00% (47/47) |
| [ApiKeyManager.swift](../AzureSkys/Utilities/ApiKeyManager.swift) | [ApiKeyManagerTests.swift](../AzureSkysTests/Utilities/ApiKeyManagerTests.swift) | 95.56% (43/45) |
| [AppDependencies.swift](../AzureSkys/Utilities/AppDependencies.swift) | [AppDependenciesTests.swift](../AzureSkysTests/Utilities/AppDependenciesTests.swift) | 82.76% (72/87) |
| [Constants.swift](../AzureSkys/Utilities/Constants.swift) | [ConstantsTests.swift](../AzureSkysTests/Utilities/ConstantsTests.swift) | — |
| [LocalFileManager.swift](../AzureSkys/Utilities/LocalFileManager.swift) | [LocalFileManagerTests.swift](../AzureSkysTests/Utilities/LocalFileManagerTests.swift) | 100.00% (33/33) |
| [LocationManager.swift](../AzureSkys/Utilities/LocationManager.swift) | [LocationManagerTests.swift](../AzureSkysTests/Utilities/LocationManagerTests.swift) | 94.44% (34/36) |
| [NetworkManager.swift](../AzureSkys/Utilities/NetworkManager.swift) | [NetworkManagerTests.swift](../AzureSkysTests/Utilities/NetworkManagerTests.swift) | 97.37% (111/114) |
| [PlaceCoreDataManager.swift](../AzureSkys/Utilities/PlaceCoreDataManager.swift) | [PlaceCoreDataManagerTests.swift](../AzureSkysTests/Utilities/PlaceCoreDataManagerTests.swift) | 100.00% (109/109) |
| [PreviewManager.swift](../AzureSkys/Utilities/PreviewManager.swift) | [PreviewManagerTests.swift](../AzureSkysTests/Utilities/PreviewManagerTests.swift) | — |
| [RefreshScheduler.swift](../AzureSkys/Utilities/RefreshScheduler.swift) | [RefreshSchedulerTests.swift](../AzureSkysTests/Utilities/RefreshSchedulerTests.swift) | 100.00% (43/43) |
| [SettingsManager.swift](../AzureSkys/Utilities/SettingsManager.swift) | [SettingsManagerTests.swift](../AzureSkysTests/Utilities/SettingsManagerTests.swift) | 81.82% (9/11) |
| [CurrentWeatherForecastViewModel.swift](../AzureSkys/ViewModels/CurrentWeatherForecastViewModel.swift) | [CurrentWeatherForecastViewModelTests.swift](../AzureSkysTests/ViewModels/CurrentWeatherForecastViewModelTests.swift) | 99.02% (101/102) |
| [LocationForecastViewModel.swift](../AzureSkys/ViewModels/LocationForecastViewModel.swift) | [LocationForecastViewModelTests.swift](../AzureSkysTests/ViewModels/LocationForecastViewModelTests.swift) | 98.17% (107/109) |
| [LocationsViewModel.swift](../AzureSkys/ViewModels/LocationsViewModel.swift) | [LocationsViewModelTests.swift](../AzureSkysTests/ViewModels/LocationsViewModelTests.swift) | 59.26% (16/27) |
| [WeatherForecastViewModel.swift](../AzureSkys/ViewModels/WeatherForecastViewModel.swift) | [WeatherForecastViewModelTests.swift](../AzureSkysTests/ViewModels/WeatherForecastViewModelTests.swift) | 98.61% (142/144) |
| [StatusGridViewLabelModifier.swift](../AzureSkys/ViewModifiers/StatusGridViewLabelModifier.swift) | [StatusGridViewLabelModifierTests.swift](../AzureSkysTests/ViewModifiers/StatusGridViewLabelModifierTests.swift) | 100.00% (9/9) |
| [StatusGridViewValueLabelModifier.swift](../AzureSkys/ViewModifiers/StatusGridViewValueLabelModifier.swift) | [StatusGridViewValueLabelModifierTests.swift](../AzureSkysTests/ViewModifiers/StatusGridViewValueLabelModifierTests.swift) | 100.00% (7/7) |
| [DismissButton.swift](../AzureSkys/Views/Components/DismissButton.swift) | [DismissButtonTests.swift](../AzureSkysTests/Views/Components/DismissButtonTests.swift) | 100.00% (19/19) |
| [LocationAuthorizationRequestView.swift](../AzureSkys/Views/Components/LocationAuthorizationRequestView.swift) | [LocationAuthorizationRequestViewTests.swift](../AzureSkysTests/Views/Components/LocationAuthorizationRequestViewTests.swift) | 95.77% (68/71) |
| [RetryView.swift](../AzureSkys/Views/Components/RetryView.swift) | [RetryViewTests.swift](../AzureSkysTests/Views/Components/RetryViewTests.swift) | 100.00% (53/53) |
| [LocationSearchResultListCellView.swift](../AzureSkys/Views/LocationSearchView/LocationSearchResultListCellView.swift) | [LocationSearchResultListCellViewTests.swift](../AzureSkysTests/Views/LocationSearchView/LocationSearchResultListCellViewTests.swift) | 90.91% (10/11) |
| [LocationSearchResultListView.swift](../AzureSkys/Views/LocationSearchView/LocationSearchResultListView.swift) | [LocationSearchResultListViewTests.swift](../AzureSkysTests/Views/LocationSearchView/LocationSearchResultListViewTests.swift) | 97.30% (36/37) |
| [LocationListView.swift](../AzureSkys/Views/LocationsView/LocationListView.swift) | [LocationListViewTests.swift](../AzureSkysTests/Views/LocationsView/LocationListViewTests.swift) | 91.80% (112/122) |
| [LocationViewCell.swift](../AzureSkys/Views/LocationsView/LocationViewCell.swift) | [LocationViewCellTests.swift](../AzureSkysTests/Views/LocationsView/LocationViewCellTests.swift) | 96.18% (302/314) |
| [LocationsView.swift](../AzureSkys/Views/LocationsView/LocationsView.swift) | [LocationsViewTests.swift](../AzureSkysTests/Views/LocationsView/LocationsViewTests.swift) | 94.32% (349/370) |
| [HighLowTemperatures.swift](../AzureSkys/Views/WeatherForecastView/Components/HighLowTemperatures.swift) | [HighLowTemperaturesTests.swift](../AzureSkysTests/Views/WeatherForecastView/Components/HighLowTemperaturesTests.swift) | 100.00% (12/12) |
| [TempBarView.swift](../AzureSkys/Views/WeatherForecastView/Components/TempBarView.swift) | [TempBarViewTests.swift](../AzureSkysTests/Views/WeatherForecastView/Components/TempBarViewTests.swift) | 98.75% (79/80) |
| [WeatherForecastAddHeaderView.swift](../AzureSkys/Views/WeatherForecastView/Components/WeatherForecastAddHeaderView.swift) | [WeatherForecastAddHeaderViewTests.swift](../AzureSkysTests/Views/WeatherForecastView/Components/WeatherForecastAddHeaderViewTests.swift) | 100.00% (41/41) |
| [WeatherForecastBottomBar.swift](../AzureSkys/Views/WeatherForecastView/Components/WeatherForecastBottomBar.swift) | [WeatherForecastBottomBarTests.swift](../AzureSkysTests/Views/WeatherForecastView/Components/WeatherForecastBottomBarTests.swift) | 100.00% (52/52) |
| [WeatherForecastHeaderView.swift](../AzureSkys/Views/WeatherForecastView/Components/WeatherForecastHeaderView.swift) | [WeatherForecastHeaderViewTests.swift](../AzureSkysTests/Views/WeatherForecastView/Components/WeatherForecastHeaderViewTests.swift) | 98.63% (72/73) |
| [WeatherImageView.swift](../AzureSkys/Views/WeatherForecastView/Components/WeatherImageView.swift) | [WeatherImageViewTests.swift](../AzureSkysTests/Views/WeatherForecastView/Components/WeatherImageViewTests.swift) | 98.82% (84/85) |
| [StatusGridCellTitleView.swift](../AzureSkys/Views/WeatherForecastView/StatusGridView/Components/StatusGridCellTitleView.swift) | [StatusGridCellTitleViewTests.swift](../AzureSkysTests/Views/WeatherForecastView/StatusGridView/Components/StatusGridCellTitleViewTests.swift) | 100.00% (11/11) |
| [StatusGridCellView.swift](../AzureSkys/Views/WeatherForecastView/StatusGridView/Components/StatusGridCellView.swift) | [StatusGridCellViewTests.swift](../AzureSkysTests/Views/WeatherForecastView/StatusGridView/Components/StatusGridCellViewTests.swift) | 100.00% (30/30) |
| [StatusGridViewCellContainer.swift](../AzureSkys/Views/WeatherForecastView/StatusGridView/Components/StatusGridViewCellContainer.swift) | [StatusGridViewCellContainerTests.swift](../AzureSkysTests/Views/WeatherForecastView/StatusGridView/Components/StatusGridViewCellContainerTests.swift) | 100.00% (42/42) |
| [WindStatusGridViewCell.swift](../AzureSkys/Views/WeatherForecastView/StatusGridView/Components/WindStatusGridViewCell.swift) | [WindStatusGridViewCellTests.swift](../AzureSkysTests/Views/WeatherForecastView/StatusGridView/Components/WindStatusGridViewCellTests.swift) | 100.00% (190/190) |
| [StatusGridView.swift](../AzureSkys/Views/WeatherForecastView/StatusGridView/StatusGridView.swift) | [StatusGridViewTests.swift](../AzureSkysTests/Views/WeatherForecastView/StatusGridView/StatusGridViewTests.swift) | 99.32% (146/147) |
| [WeatherDailyForecastListCellView.swift](../AzureSkys/Views/WeatherForecastView/WeatherDailyForecastListView/WeatherDailyForecastListCellView.swift) | [WeatherDailyForecastListCellViewTests.swift](../AzureSkysTests/Views/WeatherForecastView/WeatherDailyForecastListView/WeatherDailyForecastListCellViewTests.swift) | 98.41% (62/63) |
| [WeatherDailyForecastListView.swift](../AzureSkys/Views/WeatherForecastView/WeatherDailyForecastListView/WeatherDailyForecastListView.swift) | [WeatherDailyForecastListViewTests.swift](../AzureSkysTests/Views/WeatherForecastView/WeatherDailyForecastListView/WeatherDailyForecastListViewTests.swift) | 93.33% (14/15) |
| [WeatherForecastMainView.swift](../AzureSkys/Views/WeatherForecastView/WeatherForecastMainView.swift) | [WeatherForecastMainViewTests.swift](../AzureSkysTests/Views/WeatherForecastView/WeatherForecastMainViewTests.swift) | 63.64% (7/11) |
| [WeatherForecastScrollView.swift](../AzureSkys/Views/WeatherForecastView/WeatherForecastScrollView.swift) | [WeatherForecastScrollViewTests.swift](../AzureSkysTests/Views/WeatherForecastView/WeatherForecastScrollViewTests.swift) | 95.89% (140/146) |
| [WeatherForecastView.swift](../AzureSkys/Views/WeatherForecastView/WeatherForecastView.swift) | [WeatherForecastViewTests.swift](../AzureSkysTests/Views/WeatherForecastView/WeatherForecastViewTests.swift) | 86.40% (197/228) |
| [WeatherThreeHourlyForecastListView.swift](../AzureSkys/Views/WeatherForecastView/WeatherThreeHourlyForecastListView/WeatherThreeHourlyForecastListView.swift) | [WeatherThreeHourlyForecastListViewTests.swift](../AzureSkysTests/Views/WeatherForecastView/WeatherThreeHourlyForecastListView/WeatherThreeHourlyForecastListViewTests.swift) | 100.00% (39/39) |
| [WeatherThreeHourlyForecastListViewCell.swift](../AzureSkys/Views/WeatherForecastView/WeatherThreeHourlyForecastListView/WeatherThreeHourlyForecastListViewCell.swift) | [WeatherThreeHourlyForecastListViewCellTests.swift](../AzureSkysTests/Views/WeatherForecastView/WeatherThreeHourlyForecastListView/WeatherThreeHourlyForecastListViewCellTests.swift) | 100.00% (25/25) |
