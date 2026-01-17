# Cleared to Plan - iPad App Implementation Plan

## Project Overview

This is a native iPad application built with **Swift and SwiftUI** that replicates and enhances the functionality of the [Cleared to Plan web application](https://github.com/armstri12/clearedtoplan). The app provides VFR pilots with a comprehensive flight planning toolset optimized for iPad.

## Technology Stack

- **Platform**: iOS 16+ (iPad focused)
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Data Storage**: Local storage (UserDefaults for settings, FileManager for complex data)
- **Architecture**: MVVM (Model-View-ViewModel) with Combine
- **Weather API**: AviationWeather.gov (NOAA)
- **Dependencies**: Minimal - prefer native Swift libraries

## Core Features (From Original Web App)

1. **Aircraft Profiles** - Store and manage aircraft with weight & balance and performance data
2. **Weight & Balance Calculator** - Real-time calculations with graphical envelope display
3. **Performance Calculator** - Density altitude and takeoff/landing distance calculations
4. **Weather Briefing** - Live METAR/TAF data with hourly forecast breakdowns
5. **Navigation Log** - Detailed flight plan builder with fuel and time calculations

## App Architecture

### Project Structure
```
ClearedToPlan/
├── App/
│   ├── ClearedToPlanApp.swift          # App entry point
│   └── ContentView.swift               # Root view with navigation
├── Models/
│   ├── Aircraft.swift                  # Aircraft profile model
│   ├── WeightBalance.swift             # W&B data structures
│   ├── Performance.swift               # Performance calculation models
│   ├── Weather.swift                   # METAR/TAF models
│   ├── NavigationLog.swift             # Nav log models
│   └── FlightSession.swift             # Workflow state management
├── ViewModels/
│   ├── AircraftViewModel.swift
│   ├── WeightBalanceViewModel.swift
│   ├── PerformanceViewModel.swift
│   ├── WeatherViewModel.swift
│   └── NavigationLogViewModel.swift
├── Views/
│   ├── Home/
│   │   └── HomeView.swift
│   ├── Aircraft/
│   │   ├── AircraftListView.swift
│   │   ├── AircraftDetailView.swift
│   │   └── AircraftFormView.swift
│   ├── WeightBalance/
│   │   ├── WeightBalanceView.swift
│   │   └── EnvelopeChartView.swift
│   ├── Performance/
│   │   └── PerformanceView.swift
│   ├── Weather/
│   │   ├── WeatherBriefingView.swift
│   │   └── MetarTafRowView.swift
│   └── NavigationLog/
│       ├── NavigationLogView.swift
│       └── LegDetailView.swift
├── Services/
│   ├── StorageService.swift            # Local data persistence
│   ├── WeatherService.swift            # Weather API integration
│   └── CalculationService.swift        # Math utilities
├── Components/
│   ├── WorkflowProgressView.swift      # Progress indicator
│   └── CommonUIComponents.swift        # Reusable UI elements
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

### Design Patterns

1. **MVVM (Model-View-ViewModel)**
   - Models: Pure data structures conforming to Codable
   - ViewModels: ObservableObject classes managing business logic
   - Views: SwiftUI views observing ViewModels

2. **Repository Pattern**
   - StorageService abstracts data persistence
   - Easy to swap storage implementations (UserDefaults → Core Data if needed)

3. **Service Layer**
   - WeatherService handles all API calls
   - CalculationService provides reusable math functions

4. **Sequential Workflow**
   - FlightSession tracks completion of each planning step
   - WorkflowGuard prevents skipping required steps

## Data Models

### Aircraft Profile
```swift
struct Aircraft: Codable, Identifiable {
    let id: UUID
    var name: String
    var registration: String
    var type: String

    // Weight & Balance
    var emptyWeight: Double
    var emptyArm: Double
    var stations: [Station]
    var envelope: [CGPoint]

    // Performance
    var performanceData: PerformanceData
}
```

### Weight & Balance
```swift
struct Station: Codable, Identifiable {
    let id: UUID
    var name: String
    var weight: Double
    var arm: Double
}

struct WeightBalanceResult {
    var totalWeight: Double
    var totalMoment: Double
    var cg: Double
    var isWithinLimits: Bool
}
```

### Performance Data
```swift
struct PerformanceData: Codable {
    var takeoffGroundRoll: [DataPoint]      // [(altitude, distance)]
    var takeoffOver50Ft: [DataPoint]
    var landingGroundRoll: [DataPoint]
    var landingOver50Ft: [DataPoint]
}
```

### Weather
```swift
struct WeatherReport: Codable {
    var station: String
    var metar: String
    var taf: String?
    var fetchedAt: Date
}
```

### Navigation Log
```swift
struct NavigationLeg: Codable, Identifiable {
    let id: UUID
    var from: String
    var to: String
    var altitude: Int
    var course: Int
    var distance: Double
    var windDirection: Int
    var windSpeed: Int
    // Calculated fields
    var groundSpeed: Double
    var timeEnRoute: TimeInterval
    var fuelBurn: Double
}
```

## Implementation Phases

### Phase 1: Foundation (Tasks 1-5)
**Goal**: Set up project infrastructure and core systems

1. **Xcode Project Setup**
   - Create new iOS App project targeting iPad
   - Configure deployment target (iOS 16+)
   - Set up app icons and launch screen
   - Configure Info.plist (permissions, orientations)

2. **Data Models**
   - Create all model structs conforming to Codable
   - Add Identifiable conformance for SwiftUI
   - Include proper initializers and defaults

3. **Storage Service**
   - Implement StorageService protocol
   - Use FileManager for JSON persistence
   - Add error handling and data migration support
   - Create helper methods (save, load, delete)

4. **Navigation Structure**
   - Create main TabView with 5 tabs
   - Set up NavigationStack for each feature
   - Design home screen layout
   - Add SF Symbols icons for tabs

5. **Workflow Management**
   - Create FlightSession ObservableObject
   - Track completion status for each step
   - Implement WorkflowGuard view modifier
   - Build WorkflowProgressView indicator

### Phase 2: Feature Implementation (Tasks 6-10)
**Goal**: Build all 5 core features

6. **Aircraft Profiles**
   - List view with all saved aircraft
   - Detail view showing complete profile
   - Form view for create/edit operations
   - Delete with swipe gesture
   - Input validation

7. **Weight & Balance Calculator**
   - Input form for station weights
   - Real-time calculation display
   - Graphical envelope using Canvas API
   - Visual indication of CG position
   - Within/outside limits warning

8. **Performance Calculator**
   - Density altitude calculator
   - Pressure altitude and temperature inputs
   - Takeoff distance calculator
   - Landing distance calculator
   - Interpolation between data points

9. **Weather Briefing**
   - Station identifier input (ICAO)
   - Fetch METAR/TAF from AviationWeather.gov
   - Parse and display formatted data
   - Hourly forecast breakdown for TAF
   - Timestamp and refresh capability
   - Handle offline mode gracefully

10. **Navigation Log**
    - Add/edit/delete legs
    - Input: waypoints, altitude, course, distance, winds
    - Auto-calculate: ground speed, time, fuel
    - Display totals (distance, time, fuel)
    - Support reordering legs
    - Print/export functionality (future)

### Phase 3: iPad Optimization (Task 11)
**Goal**: Leverage iPad capabilities for better UX

- **Landscape Mode**: Optimize layouts for wide screens
- **Split View**: Use two-column layouts where appropriate
- **Larger Canvas**: Bigger charts and graphs
- **Keyboard Shortcuts**: Add iPad keyboard support
- **Apple Pencil**: Support for annotations (future enhancement)
- **Multitasking**: Ensure app works well in Split View/Slide Over
- **Pointer Support**: Proper hover effects and interactions

### Phase 4: Documentation (Task 12)
**Goal**: Provide clear setup and usage instructions

- Create README.md with project overview
- Document build/run instructions
- Add usage guide for pilots
- Include architecture documentation
- Provide contribution guidelines

## Key Technical Considerations

### Data Persistence Strategy

**Option 1: JSON Files + FileManager** (Recommended for MVP)
- Simple to implement
- Easy to debug (readable files)
- Good for small to medium data
- Used by the web app (localStorage equivalent)

```swift
class StorageService {
    private let fileManager = FileManager.default
    private let documentsDirectory = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first!

    func save<T: Codable>(_ object: T, to filename: String) throws {
        let url = documentsDirectory.appendingPathComponent(filename)
        let data = try JSONEncoder().encode(object)
        try data.write(to: url)
    }

    func load<T: Codable>(from filename: String) throws -> T {
        let url = documentsDirectory.appendingPathComponent(filename)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

**Option 2: Core Data** (Future enhancement if needed)
- Better for complex relationships
- Overkill for this app's simple data model
- Consider for version 2.0 if adding cloud sync

### Weather API Integration

The web app uses a Cloudflare Worker proxy. For the iPad app:

**Direct API Approach** (Recommended)
- Call AviationWeather.gov directly
- Endpoint: `https://aviationweather.gov/cgi-bin/data/metar.php?ids=KXXX`
- TAF: `https://aviationweather.gov/cgi-bin/data/taf.php?ids=KXXX`
- No CORS issues in native apps
- Handle network errors gracefully

```swift
class WeatherService {
    func fetchMETAR(station: String) async throws -> String {
        let url = URL(string: "https://aviationweather.gov/cgi-bin/data/metar.php?ids=\(station)&format=raw")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return String(data: data, encoding: .utf8) ?? ""
    }
}
```

### Calculation Algorithms

Port the math utilities from the web app:

1. **Weight & Balance**
   - Moment = Weight × Arm
   - Total CG = Total Moment / Total Weight
   - Point-in-polygon test for envelope

2. **Density Altitude**
   - DA = PA + (120 × (OAT - ISA))
   - ISA = 15°C - (2°C × PA/1000ft)

3. **Performance Interpolation**
   - Linear interpolation between data points
   - Handle edge cases (below/above chart limits)

4. **Navigation Calculations**
   - Ground Speed = TAS ± headwind/tailwind component
   - Wind correction angle calculations
   - Time = Distance / Ground Speed
   - Fuel = Time × Fuel Flow

## UI/UX Guidelines

### Design Principles
1. **Clarity**: Large, readable fonts (pilots use this in flight)
2. **Simplicity**: Minimize taps, maximize information density
3. **Reliability**: Offline-first, graceful degradation
4. **Safety**: Clear warnings when outside limits

### Color Scheme
- **Primary**: Aviation blue (#0066CC)
- **Success**: Green for "within limits"
- **Warning**: Yellow for cautions
- **Danger**: Red for "outside limits"
- **Background**: Light mode default, support dark mode

### Typography
- **Headings**: SF Pro Display (Bold, 24-32pt)
- **Body**: SF Pro Text (Regular, 16-18pt)
- **Data**: SF Pro Mono (Medium, 14-16pt) for numbers

### iPad-Specific Layouts

**Compact Width** (iPad in Split View)
- Stack vertically
- Single-column lists
- Full-width forms

**Regular Width** (iPad full screen)
- Two-column layouts
- Side-by-side forms and results
- Larger charts and graphs

## Testing Strategy

1. **Unit Tests**
   - Test all calculation functions
   - Verify data model encoding/decoding
   - Test storage service operations

2. **UI Tests**
   - Test navigation flow
   - Verify workflow enforcement
   - Test form validation

3. **Integration Tests**
   - Test weather API integration
   - Test data persistence
   - Test offline behavior

4. **Manual Testing**
   - Test on multiple iPad models
   - Test in different orientations
   - Test in Split View/Slide Over
   - Test with real flight planning scenarios

## Deployment

1. **Development**
   - Run on simulator and physical iPad
   - Use Xcode debugging tools
   - Test with TestFlight for beta testing

2. **Distribution Options**
   - **App Store**: Full public release
   - **TestFlight**: Beta testing with pilots
   - **Ad Hoc**: Limited distribution (up to 100 devices)
   - **Enterprise**: If for a specific organization

3. **Requirements for App Store**
   - Apple Developer account ($99/year)
   - App Store listing (description, screenshots, keywords)
   - Privacy policy (even for local-only apps)
   - App review process (typically 1-2 days)

## Future Enhancements

- **Cloud Sync**: Optional iCloud backup of aircraft profiles
- **Export**: PDF export of navigation logs and flight plans
- **Charts**: Integrate sectional charts and airport diagrams
- **Apple Watch**: Quick weather checks on watch
- **Widgets**: Home screen widgets for saved airports
- **Siri Integration**: "What's the weather at KXXX?"
- **Multiple Flight Plans**: Save and manage multiple planned flights

## Resources

- [Apple Human Interface Guidelines - iPad](https://developer.apple.com/design/human-interface-guidelines/ipad)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [AviationWeather.gov API](https://aviationweather.gov/data/api/)
- [Original Web App Repository](https://github.com/armstri12/clearedtoplan)

## Success Criteria

The iPad app will be considered complete when:
1. All 5 core features are functional and tested
2. Data persists correctly between app launches
3. Weather API integration works reliably
4. App performs well on iPad (smooth, responsive)
5. Workflow enforcement matches web app behavior
6. App handles offline mode gracefully (except weather)
7. UI is optimized for iPad screen sizes
8. Documentation is complete and accurate

---

**Next Steps**: Begin with Phase 1, Task 1 - Setting up the Xcode project structure.
