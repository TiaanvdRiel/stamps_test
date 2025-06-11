import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = CountriesViewModel()
    @StateObject private var polygonManager = CountryPolygonManager()
    @State private var showingAddSheet = false
    @State private var sheetPosition: SheetPosition = .middle
    @State private var selectedCountry: Country?
    @State private var selectedCity: VisitedCity?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MapView(
                    visitedCountries: viewModel.visitedCountries,
                    selectedCountry: selectedCountry,
                    selectedCity: selectedCity
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
                            selectedCity: $selectedCity
                        )
                        .environmentObject(viewModel)
                        .environmentObject(polygonManager)
                    }
                    .overlay(alignment: .top) {
                        if sheetPosition != .expanded {
                            AddButton(showingAddSheet: $showingAddSheet, impactMed: UIImpactFeedbackGenerator(style: .medium))
                                .offset(y: -30)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddDestinationView()
                    .environmentObject(viewModel)
                    .environmentObject(polygonManager)
            }
        }
    }
}
