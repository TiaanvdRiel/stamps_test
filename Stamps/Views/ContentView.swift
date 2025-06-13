import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = CountriesViewModel()
    @StateObject private var polygonManager = CountryPolygonManager()
    @State private var sheetPosition: SheetPosition = .middle
    @State private var selectedCountry: Country?
    @State private var selectedCity: VisitedCity?
    @State private var showingAddSheet = false
    @State private var tempSelectedLocation: (name: String, coordinate: CLLocationCoordinate2D)?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MapView(
                    visitedCountries: viewModel.visitedCountries,
                    selectedCountry: selectedCountry,
                    selectedCity: selectedCity
//                    showingAddSheet: $showingAddSheet,
//                    tempSelectedLocation: $tempSelectedLocation
                )
                .environmentObject(viewModel)
                .environmentObject(polygonManager)
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    BottomSheetView(
                        position: $sheetPosition,
                        maxHeight: UIScreen.main.bounds.height * 0.8
                    ) {
                        PassportView(
                            selectedCountry: $selectedCountry,
                            selectedCity: $selectedCity,
                            sheetPosition: $sheetPosition
                        )
                        .environmentObject(viewModel)
                        .environmentObject(polygonManager)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            if let location = tempSelectedLocation {
                AddDestinationView(
                    initialSearchText: location.name,
                    coordinate: location.coordinate
                )
                .environmentObject(viewModel)
            } else {
                AddDestinationView()
                    .environmentObject(viewModel)
            }
        }
    }
}
