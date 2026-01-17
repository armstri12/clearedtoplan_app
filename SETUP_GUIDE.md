# Setup Guide - Cleared to Plan iPad App

## Prerequisites

### Required Software
- **macOS** 13.0 (Ventura) or later
- **Xcode** 15.0 or later
- **iOS Simulator** (included with Xcode)
- **Physical iPad** (optional but recommended for testing)

### Recommended Tools
- **SF Symbols App** - Browse Apple's icon library
- **Instruments** - Performance profiling
- **RocketSim** - Enhanced simulator features (optional)

### Developer Account
- **Free Account**: Can run on simulator and personal devices (7-day signing)
- **Paid Account** ($99/year): Required for App Store distribution and TestFlight

## Initial Setup

### Step 1: Create Xcode Project

1. Open Xcode
2. Select "Create a new Xcode project"
3. Choose **iOS** → **App**
4. Configure project:
   - **Product Name**: ClearedToPlan
   - **Team**: Select your team
   - **Organization Identifier**: com.yourname.clearedtoplan
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: None (we'll use custom solution)
   - **Include Tests**: ✓ Yes
5. Save to this repository directory

### Step 2: Configure Project Settings

#### General Tab
- **Bundle Identifier**: com.yourname.clearedtoplan
- **Version**: 1.0
- **Build**: 1
- **Deployment Target**: iOS 16.0
- **Supported Destinations**: iPad only
  - Click on "iPhone, iPad" → Select only "iPad"

#### Info Tab
Add these custom entries:
- **Supported interface orientations**:
  - ✓ Portrait
  - ✓ Landscape Left
  - ✓ Landscape Right
  - ☐ Upside Down Portrait (disable)

#### Signing & Capabilities
- **Automatically manage signing**: ✓ Enabled
- **Team**: Select your team
- No additional capabilities needed for MVP

### Step 3: Create Directory Structure

In your Xcode project navigator, create these groups (folders):

```
ClearedToPlan/
├── App/
├── Models/
├── ViewModels/
├── Views/
│   ├── Home/
│   ├── Aircraft/
│   ├── WeightBalance/
│   ├── Performance/
│   ├── Weather/
│   └── NavigationLog/
├── Services/
├── Components/
└── Resources/
```

**Note**: Use "New Group" not "New Folder Reference" to create these.

### Step 4: Add Source Files

Copy the Swift template files from the `swift-templates/` directory into your Xcode project:

1. Drag files into appropriate groups
2. Ensure "Copy items if needed" is checked
3. Ensure "Add to targets: ClearedToPlan" is checked

### Step 5: Configure App Icons

1. Generate icons using an app icon generator (e.g., appicon.co)
2. Drag icon set into Assets.xcassets/AppIcon

### Step 6: Update Info.plist

Add network permissions for weather API:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>aviationweather.gov</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

## Development Workflow

### Running the App

1. **Simulator**:
   - Select an iPad simulator (e.g., iPad Pro 12.9")
   - Press `Cmd + R` to build and run
   - Use `Cmd + Shift + H` to go home
   - Use `Cmd + →` or `Cmd + ←` to rotate

2. **Physical Device**:
   - Connect iPad via USB or WiFi
   - Select device in Xcode toolbar
   - Trust developer certificate on device (first time only)
   - Press `Cmd + R` to build and run

### Debugging Tips

- **Print Statements**: Use `print()` for basic debugging
- **Breakpoints**: Click line number in Xcode to set breakpoint
- **View Hierarchy**: Use Debug View Hierarchy (debug bar button)
- **Memory Graph**: Check for retain cycles
- **Console**: View logs and errors in bottom panel

### Common Simulator Shortcuts

- `Cmd + R` - Build and run
- `Cmd + .` - Stop running
- `Cmd + K` - Toggle keyboard
- `Cmd + Shift + H` - Home button
- `Cmd + S` - Screenshot
- `Cmd + 1/2/3` - Scale simulator window

## File Storage Location

The app stores data in the app's Documents directory:

```swift
FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
```

**Simulator Path**:
```
~/Library/Developer/CoreSimulator/Devices/[DEVICE-ID]/data/Containers/Data/Application/[APP-ID]/Documents/
```

**Device Path**: Access via Xcode → Window → Devices and Simulators → [Your Device] → Installed Apps → ClearedToPlan → Download Container

## Testing

### Unit Tests

Run tests: `Cmd + U`

Example test structure:
```swift
@testable import ClearedToPlan
import XCTest

class CalculationTests: XCTestCase {
    func testDensityAltitude() {
        // Test calculation functions
    }
}
```

### UI Tests

Record UI tests:
1. Click record button in test editor
2. Interact with app
3. Add assertions

### Manual Test Checklist

Before each release:
- [ ] Test on multiple iPad models (if possible)
- [ ] Test portrait and landscape orientations
- [ ] Test with no internet connection (offline mode)
- [ ] Test data persistence (force quit and reopen)
- [ ] Test with real flight planning scenarios
- [ ] Test weight & balance with out-of-limits data
- [ ] Test weather API with valid and invalid station IDs

## Distribution

### TestFlight (Beta Testing)

1. Archive app: Product → Archive
2. Upload to App Store Connect
3. Add external testers (up to 10,000)
4. Share TestFlight link
5. Testers install via TestFlight app

### App Store Release

1. Create app listing in App Store Connect
2. Add screenshots, description, keywords
3. Set pricing (free recommended)
4. Submit for review
5. Respond to any feedback from Apple
6. Release when approved

### Version Updates

1. Increment version or build number
2. Update release notes
3. Archive and upload new build
4. Submit for review

## Troubleshooting

### Common Issues

**"Failed to code sign"**
- Solution: Check signing settings, ensure certificate is valid

**"Simulator not responding"**
- Solution: Device → Erase All Content and Settings

**"App crashes on launch"**
- Solution: Check console for error messages, verify data model compatibility

**"Weather API not working"**
- Solution: Check network connection, verify Info.plist permissions, test URL in browser

**"Data not persisting"**
- Solution: Check file paths, verify write permissions, check for encoding errors

### Getting Help

- **Apple Developer Forums**: developer.apple.com/forums
- **Stack Overflow**: Tag questions with `swift`, `swiftui`, `ios`
- **SwiftUI Documentation**: developer.apple.com/documentation/swiftui
- **Original Web App**: Reference the TypeScript implementation

## Next Steps

1. Complete Xcode project setup (above)
2. Review IMPLEMENTATION_PLAN.md for development roadmap
3. Start with Phase 1: Foundation
4. Build iteratively, test frequently
5. Reference the original web app for business logic

## Useful Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Hacking with Swift](https://www.hackingwithswift.com/)
- [Swift by Sundell](https://www.swiftbysundell.com/)
- [Aviation Weather API Docs](https://aviationweather.gov/data/api/)
- [FAA Weight & Balance Handbook](https://www.faa.gov/regulations_policies/handbooks_manuals/aviation/media/FAA-H-8083-1B.pdf)

---

**Ready to start?** Follow Step 1 above to create your Xcode project!
