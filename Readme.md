# Cleared to Plan - iPad App

A native iPad flight planning application for VFR pilots, built with Swift and SwiftUI.

## Overview

This is a native iOS version of the [Cleared to Plan web application](https://github.com/armstri12/clearedtoplan), optimized for iPad with offline-first capabilities and a touch-friendly interface.

## Features

- **Aircraft Profiles** - Manage multiple aircraft with complete weight & balance and performance data
- **Weight & Balance Calculator** - Real-time calculations with graphical CG envelope display
- **Performance Calculator** - Density altitude and takeoff/landing distance calculations
- **Weather Briefing** - Live METAR/TAF data from AviationWeather.gov
- **Navigation Log** - Comprehensive flight plan builder with automatic calculations
- **Offline Mode** - All data stored locally, works without internet (except weather)
- **Sequential Workflow** - Enforced 5-step process ensures complete flight planning

## Tech Stack

- **Platform**: iOS 16+ (iPad focused)
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM with Combine
- **Data Storage**: Local JSON files (FileManager)
- **Weather API**: AviationWeather.gov (NOAA)

## Getting Started

### Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- iPad simulator or physical iPad for testing

**Windows Users:** See [MACINCLOUD_SETUP.md](MACINCLOUD_SETUP.md) for cloud Mac setup (~$30-50/month)

### Quick Start

1. **Read the Quick Start Guide**
   ```
   See QUICKSTART.md for 3-step setup (30 minutes)
   ```

2. **Create Xcode Project**
   ```
   Open Xcode → New Project → iOS App → SwiftUI
   Name: ClearedToPlan
   ```

3. **Import Template Code**
   ```
   Drag swift-templates/ files into your Xcode project
   ```

4. **Build and Run**
   ```
   Select iPad simulator → Cmd + R
   ```

## Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Fast 3-step setup guide
- **[IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)** - Comprehensive development plan with architecture details
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Detailed Xcode setup and development workflow
- **[MACINCLOUD_SETUP.md](MACINCLOUD_SETUP.md)** - Windows users guide for cloud Mac development

## Project Structure

```
ClearedToPlan/
├── App/                    # App entry point and root views
├── Models/                 # Data models (Aircraft, WeightBalance, etc.)
├── ViewModels/            # Business logic and state management
├── Views/                 # SwiftUI views for each feature
├── Services/              # Storage, weather API, calculations
└── Components/            # Reusable UI components
```

## Development Roadmap

See the todo list and IMPLEMENTATION_PLAN.md for detailed tasks:

### Phase 1: Foundation ✓
- [x] Create documentation and planning
- [ ] Set up Xcode project
- [ ] Import template code

### Phase 2: Features (Next)
- [ ] Complete Aircraft Profiles
- [ ] Build Weight & Balance Calculator
- [ ] Implement Performance Calculator
- [ ] Add Weather Briefing
- [ ] Create Navigation Log

### Phase 3: Optimization
- [ ] iPad-specific UI improvements
- [ ] Landscape mode optimization
- [ ] Testing and bug fixes

## Template Code Included

The `swift-templates/` directory contains ready-to-use code:

- Core data models for all features
- Storage service for local persistence
- Workflow management system
- Calculation utilities
- Placeholder views for all 5 features
- Navigation structure

## Contributing

This is a personal project, but suggestions and feedback are welcome through issues or pull requests.

## License

MIT License - See LICENSE file for details

## Acknowledgments

- Based on the [Cleared to Plan web app](https://github.com/armstri12/clearedtoplan)
- Weather data from [AviationWeather.gov](https://aviationweather.gov)
- Icons from SF Symbols (Apple)

## Contact

For questions or feedback, open an issue in this repository.

---

**Ready to start building?** Check out [QUICKSTART.md](QUICKSTART.md)!
