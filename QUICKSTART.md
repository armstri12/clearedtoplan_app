# Quick Start Guide - Cleared to Plan iPad App

This is your roadmap to building the Cleared to Plan iPad app from the web version.

## What You Have

This repository contains:

1. **IMPLEMENTATION_PLAN.md** - Comprehensive development plan with architecture, phases, and technical details
2. **SETUP_GUIDE.md** - Step-by-step Xcode setup instructions and development workflow
3. **swift-templates/** - Ready-to-use Swift code templates for all core components
4. **Todo list** - 12 structured tasks to track your progress

## What You're Building

A native iPad app with these 5 features:
- Aircraft Profiles (manage your planes)
- Weight & Balance Calculator (with graphical envelope)
- Performance Calculator (density altitude, takeoff/landing)
- Weather Briefing (METAR/TAF integration)
- Navigation Log (flight planning with calculations)

## Getting Started (3 Steps)

### Step 1: Create Xcode Project (15 minutes)

1. Open Xcode
2. File → New → Project
3. Choose iOS → App
4. Settings:
   - Product Name: **ClearedToPlan**
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Include Tests: ✓
5. Save in this repository directory

### Step 2: Import Template Code (10 minutes)

1. Create folder structure in Xcode:
   - App/
   - Models/
   - ViewModels/
   - Views/
   - Services/
   - Components/

2. Drag Swift files from `swift-templates/` into Xcode
   - Make sure "Copy items if needed" is checked
   - Make sure "Add to targets: ClearedToPlan" is checked

3. Fix any import errors by ensuring all files are in correct groups

### Step 3: Run the App (5 minutes)

1. Select iPad simulator (e.g., iPad Pro 12.9")
2. Press `Cmd + R` to build and run
3. You should see the home screen with the 5-step workflow

**Congratulations!** You now have a working foundation to build upon.

## Development Phases

Follow the implementation plan in order:

### Phase 1: Foundation (Currently Complete ✓)
The template code provides:
- ✓ Xcode project structure
- ✓ Core data models (Aircraft, WeightBalance, etc.)
- ✓ Storage service (local JSON persistence)
- ✓ Navigation structure (TabView with 5 tabs)
- ✓ Workflow management (FlightSessionViewModel)

### Phase 2: Feature Implementation (Next Steps)

Work through each feature in order:

**1. Aircraft Profiles** (2-3 hours)
- Already has basic CRUD
- Add weight & balance station editor
- Add performance data editor
- Add validation

**2. Weight & Balance** (3-4 hours)
- Implement station weight inputs
- Add real-time CG calculation
- Create graphical envelope using Canvas
- Add within/outside limits indicator

**3. Performance Calculator** (2-3 hours)
- Density altitude is already working
- Add takeoff distance calculator
- Add landing distance calculator
- Implement interpolation logic

**4. Weather Briefing** (2-3 hours)
- Implement WeatherService API calls
- Parse METAR/TAF responses
- Add TAF hourly breakdown
- Handle offline gracefully

**5. Navigation Log** (3-4 hours)
- Add wind calculation logic
- Implement ground speed calculation
- Add time and fuel calculations
- Create totals display

### Phase 3: iPad Optimization (2-3 hours)
- Optimize layouts for landscape
- Add two-column layouts for regular width
- Improve larger screen utilization
- Test multitasking support

### Phase 4: Polish & Testing (2-3 hours)
- Add error handling
- Improve user feedback
- Test with real flight scenarios
- Fix any bugs

**Total Estimated Time: 20-25 hours of development**

## Key Files to Understand

Start by reading these files in this order:

1. **IMPLEMENTATION_PLAN.md** - Overall architecture and strategy
2. **swift-templates/App/ClearedToPlanApp.swift** - App entry point
3. **swift-templates/Models/FlightSession.swift** - Workflow logic
4. **swift-templates/Services/StorageService.swift** - Data persistence
5. **swift-templates/Views/HomeView.swift** - Main UI example

## Common Tasks

### Add a new feature
1. Create model in `Models/`
2. Create ViewModel in `ViewModels/`
3. Create view in `Views/`
4. Add to navigation in `ContentView.swift`

### Save data
```swift
StorageService.shared.save(myObject, key: "myKey")
```

### Load data
```swift
let myObject: MyType? = StorageService.shared.load(key: "myKey")
```

### Mark workflow step complete
```swift
flightSession.completeStep(.weightBalance)
```

### Run calculations
```swift
let da = CalculationService.densityAltitude(
    pressureAltitude: pa,
    temperature: temp
)
```

## Workflow Enforcement

The app enforces a sequential workflow:
1. **Aircraft** - Always accessible
2. **Weight & Balance** - Requires aircraft selected
3. **Performance** - Requires W&B complete
4. **Weather** - Requires performance complete
5. **Nav Log** - Requires weather complete

This is managed by `FlightSessionViewModel` and `WorkflowGuardView`.

## Resources

### Documentation
- Apple SwiftUI: https://developer.apple.com/documentation/swiftui/
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/ipad

### Original Web App
- Repo: https://github.com/armstri12/clearedtoplan
- Reference the TypeScript code for business logic
- Check the React components for UI patterns

### Aviation APIs
- METAR/TAF: https://aviationweather.gov/data/api/
- No authentication required for basic access

## Tips for Success

1. **Build Incrementally**: Get each feature working before moving to the next
2. **Test Often**: Run on simulator after each change
3. **Use Xcode Preview**: Add `#Preview` blocks to see UI changes instantly
4. **Reference Web App**: Copy the calculation logic from TypeScript
5. **Start Simple**: Basic functionality first, polish later
6. **Use Real Data**: Test with actual aircraft specs and flight plans

## Need Help?

1. Check IMPLEMENTATION_PLAN.md for architecture details
2. Check SETUP_GUIDE.md for Xcode-specific issues
3. Review the template code for patterns and examples
4. Search Apple documentation for SwiftUI questions
5. Reference the original web app for business logic

## Next Steps

Choose your path:

**Path A: Follow the Plan** (Recommended)
- Work through Phase 2 features in order
- Use the todo list to track progress
- Reference template code for patterns

**Path B: Customize First**
- Modify the UI styling to match your preferences
- Add your own aircraft data
- Adjust the workflow if needed

**Path C: Deep Dive**
- Read all documentation first
- Study the original web app code
- Plan your own implementation approach

---

**Ready to build?** Open Xcode and start with Step 1 above!

Questions? Review the documentation files in this repo.

Happy coding! ✈️
