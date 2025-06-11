# Stamps - Travel Tracking App Specification

## Overview
Stamps is a SwiftUI app that helps users track their travel history by marking visited countries and cities on a map. The app features a design similar to Apple Maps, with visited countries outlined and cities marked with pins.

## Current Implementation Status

### ✅ Completed Features

#### Core Architecture
- MVVM architecture with clear separation of concerns
- Persistent storage using UserDefaults for visited countries and cities
- Efficient data management with debouncing for search operations

#### Map View
- Interactive map showing visited countries and cities
- Country outlines with blue highlighting for visited countries
- City pins with custom annotations
- Initial map region set to show most of the world

#### Bottom Sheet
- Expandable bottom sheet with three positions (collapsed, middle, expanded)
- Progress circle showing percentage of visited countries (out of 195)
- Statistics display:
  - Total countries visited
  - Total cities visited
  - Last visit date
  - Most visited country

#### Add Destination Feature
- Floating action button to add new destinations
- Sheet-based UI for adding countries and cities
- Segmented control to switch between country and city search
- Search functionality for both countries and cities
- Date picker for visit date
- Prevention of duplicate entries

#### Data Models
- Country model with name, code, visit date, and coordinates
- City model with name, country code, coordinates, population, and region
- Visited city tracking with reference to city data

### 🚧 Areas for Improvement

1. **Map Interaction**
   - Add zoom to region when selecting a country
   - Implement city pin clustering for better performance
   - Add interactive elements to country polygons

2. **Search Experience**
   - Implement better city search with autocomplete
   - Add recent searches
   - Add favorite/frequently visited places

3. **Data Management**
   - Move from UserDefaults to Core Data for better scalability
   - Implement proper error handling for data operations
   - Add data backup and sync capabilities

4. **UI/UX**
   - Add animations for state transitions
   - Implement haptic feedback for more interactions
   - Add loading states for data operations

### 🆕 Features To Be Implemented

1. **My Passport View**
   - Dedicated view for travel statistics
   - Visual representation of travel history
   - Achievements and milestones
   - Share functionality for travel stats

2. **Country Detail View**
   - List of visited cities in the country
   - Country-specific statistics
   - Photos and notes for visits
   - Timeline of visits

3. **City Detail View**
   - Visit history
   - Photo gallery
   - Notes and memories
   - Local attractions and points of interest

4. **Trip Planning**
   - Future trips planning
   - Trip itineraries
   - Integration with calendar
   - Travel recommendations

5. **Social Features**
   - Share travels with friends
   - Compare travel statistics
   - Collaborative trip planning
   - Travel challenges and goals

## Technical Requirements

### Data Storage
- Migrate to Core Data for persistent storage
- Implement proper data migration strategy
- Add support for iCloud sync

### Performance
- Optimize map rendering for large datasets
- Implement proper caching mechanisms
- Reduce memory footprint

### Security
- Implement data encryption for sensitive information
- Add authentication for social features
- Secure API endpoints

### Testing
- Unit tests for view models
- UI tests for critical user flows
- Performance testing for map operations

## Design Guidelines

### Colors
- Use system colors for consistency
- Maintain proper contrast ratios
- Support dark mode

### Typography
- Use system fonts
- Maintain readable text sizes
- Proper hierarchy in information display

### Layout
- Support all iOS devices and orientations
- Follow iOS Human Interface Guidelines
- Maintain consistent spacing and alignment

## Future Considerations

1. **Platform Expansion**
   - macOS version
   - iPad-optimized interface
   - watchOS companion app

2. **Integration Opportunities**
   - Flight tracking APIs
   - Weather services
   - Local recommendations
   - Travel booking services

3. **Monetization**
   - Premium features
   - Subscription model
   - In-app purchases

## Development Priorities

1. **Short Term (1-2 Weeks)**
   - Complete My Passport view
   - Implement country detail view
   - Add basic photo support
   - Improve search performance

2. **Medium Term (1-2 Months)**
   - Migrate to Core Data
   - Implement city detail view
   - Add basic social features
   - Improve map interactions

3. **Long Term (3+ Months)**
   - Add trip planning features
   - Implement sync capabilities
   - Expand to additional platforms
   - Add premium features

## Recent Changes (March 20-21, 2024)

### Map and Navigation Improvements
- Fixed map centering functionality for countries and cities
- Positioned selected items in upper third of screen to account for bottom sheet
- Added proper animation and padding for map transitions

### UI/UX Enhancements
- Fixed bottom sheet behavior and animations
- Restored "My Passport" heading in PassportView
- Fixed progress circle calculation (using correct total of 195 countries)
- Improved add button positioning and behavior:
  - Moved button into PassportView content
  - Positioned button to float above sheet using offset
  - Button now moves naturally with sheet
  - Maintains visibility across all views (main, country detail, city detail)
  - Matches Apple Maps-style design
- Refined sheet header design:
  - Centered pull handle with subtle opacity (0.3)
  - Styled close button to match native apps (opacity 0.4)
  - Fixed padding and alignment for consistent spacing
  - Improved overall visual hierarchy

### Code Organization
- Moved selection state (selectedCountry, selectedCity) to ContentView
- Implemented proper bindings between views
- Separated components into dedicated files
- Fixed duplicate component declarations
- Improved sheet and button state management

### Bug Fixes
- Fixed duplicate sheet rendering by consolidating logic in ContentView
- Resolved issues with sheet position tracking
- Fixed city deletion behavior
- Improved swipe-to-delete reliability
- Fixed add button disappearing in city detail view

## Completed Tasks
- [x] Basic map functionality
- [x] Country and city tracking
- [x] Bottom sheet implementation
- [x] Add destination interface
- [x] Basic statistics display
- [x] Delete functionality
- [x] UI polish and refinements
- [x] Sheet animations and interactions
- [x] Add button positioning and behavior
- [x] View hierarchy organization

## Remaining Tasks

### High Priority
1. Map Interactions
   - [ ] Add zoom controls
   - [ ] Implement double-tap to zoom
   - [ ] Add user location tracking (optional)

2. Data Management
   - [ ] Implement data persistence
   - [ ] Add data export/import functionality
   - [ ] Add backup/restore features

3. Search and Filtering
   - [ ] Add search functionality for visited places
   - [ ] Implement filters (by date, continent, etc.)
   - [ ] Add sorting options for countries and cities

### Medium Priority
1. UI Enhancements
   - [ ] Add animations for country/city additions and deletions
   - [ ] Implement dark mode support
   - [ ] Add haptic feedback for more interactions

2. Statistics
   - [ ] Add more detailed travel statistics
   - [ ] Create timeline view of travels
   - [ ] Add visualization of travel patterns

3. Sharing
   - [ ] Add ability to share travel stats
   - [ ] Implement social sharing features
   - [ ] Create shareable travel cards

### Low Priority
1. Additional Features
   - [ ] Add notes/memories for each place
   - [ ] Implement photo attachments
   - [ ] Add travel planning features

2. Performance
   - [ ] Optimize map rendering for large datasets
   - [ ] Improve city search performance
   - [ ] Add caching for frequently accessed data

3. Accessibility
   - [ ] Implement VoiceOver support
   - [ ] Add dynamic type support
   - [ ] Improve keyboard navigation

## Technical Specifications

### Data Models
- Country
  - name: String
  - code: String
  - visitDate: Date
  - coordinates: [CLLocationCoordinate2D]

- VisitedCity
  - cityData: CityData?
  - countryCode: String
  - visitDate: Date

### Views
- ContentView: Main container view
- MapView: Displays visited locations
- PassportView: Shows travel statistics and lists
- BottomSheetView: Handles sheet interactions
- AddDestinationView: Country/city selection interface

### ViewModels
- CountriesViewModel: Manages travel data
- CountryPolygonManager: Handles map polygons

### Dependencies
- SwiftUI
- MapKit
- CoreLocation 