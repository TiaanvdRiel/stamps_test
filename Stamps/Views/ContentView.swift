import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = CountriesViewModel()
    @StateObject private var polygonManager = CountryPolygonManager()
    @State private var showingAddSheet = false
    
    var body: some View {
        ZStack {
            MapView(visitedCountries: viewModel.visitedCountries)
                .environmentObject(viewModel)
                .environmentObject(polygonManager)
                .ignoresSafeArea()
            
            BottomSheetView(viewModel: viewModel, showingAddSheet: $showingAddSheet)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCountryView()
                .environmentObject(viewModel)
        }
    }
}
