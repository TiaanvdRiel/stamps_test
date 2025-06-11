# Stamps - Travel Tracking App

Stamps is an iOS app that helps users track their travel history by marking visited countries and cities on a map. The app features a design similar to Apple Maps, with visited countries outlined and cities marked with pins.

## Features

### Map View
- Interactive world map showing visited countries and cities
- Countries highlighted with blue outlines
- City markers with detailed information
- Smooth map interactions and animations

### Travel Tracking
- Add visited countries and cities
- Track visit dates
- View travel statistics
- Manage visited locations

### Bottom Sheet Interface
- Apple Maps-style bottom sheet
- Three positions: collapsed, middle, and expanded
- Smooth drag interactions
- Dynamic content transitions

### Statistics
- Total countries visited (out of 195)
- Total cities visited
- Most visited country
- Last visit date

## Recent Changes

### 2024-03-20
- Enhanced deletion functionality:
  - Improved swipe-to-delete sensitivity and reliability
  - Added context menu support for item deletion
  - Implemented native iOS-style deletion interactions
  - Added haptic feedback for better user experience
  - Fixed list item background colors for better visual integration

### 2024-03-19
- Implemented new PassportView for better sheet navigation
- Added country detail view within the sheet
- Improved city list display and interactions
- Reorganized view components for better maintainability

### Code Organization
- Created dedicated CityRowView component
- Improved navigation handling in bottom sheet
- Separated search interface components
- Enhanced view hierarchy and state management

## Project Structure

```
Stamps/
├── Views/
│   ├── PassportView.swift         # Main passport interface
│   ├── AddDestinationView.swift   # Add new locations
│   ├── BottomSheetView.swift      # Bottom sheet container
│   ├── CityRowView.swift          # City list item component
│   ├── MapView.swift             # Map interface
│   └── SheetComponents.swift      # Shared sheet components
├── Models/
│   ├── Country.swift             # Country data model
│   ├── City.swift               # City data model
│   └── VisitedCity.swift        # Visited city tracking
├── ViewModels/
│   ├── CountriesViewModel.swift   # Main data management
│   └── CityManager.swift         # City data handling
└── Managers/
    └── CityDataManager.swift     # City database management
```

## Technical Details

### Data Management
- UserDefaults for persistent storage
- Efficient city search with debouncing
- Optimized data structures for performance

### UI/UX
- SwiftUI implementation
- Native iOS design patterns
- Haptic feedback integration
- Smooth animations and transitions

### Map Features
- Country polygon rendering
- City pin annotations
- Custom map styling
- Efficient overlay management

## Future Improvements

- Core Data migration for better data management
- iCloud sync support
- Enhanced search capabilities
- Photo attachment support
- Trip planning features
- Social sharing capabilities

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Getting Started

1. Clone the repository
2. Open `Stamps.xcodeproj` in Xcode
3. Build and run the project

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
