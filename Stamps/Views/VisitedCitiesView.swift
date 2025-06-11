import SwiftUI

struct VisitedCitiesView: View {
    let country: Country
    @EnvironmentObject private var viewModel: CountriesViewModel
    @State private var showingAddCity = false
    
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        citiesList
            .navigationTitle(country.name)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showingAddCity) {
                CitySelectionView(country: country)
            }
    }
    
    private var citiesList: some View {
        List {
            Section {
                ForEach(viewModel.citiesForCountry(country.code)) { visitedCity in
                    if let cityData = visitedCity.cityData {
                        CityRowView(
                            cityData: cityData,
                            visitedCity: visitedCity,
                            impactMed: impactMed,
                            onDelete: { viewModel.removeVisitedCity(visitedCity) }
                        )
                    }
                }
            } header: {
                Text("Visited Cities")
            } footer: {
                Text("\(viewModel.citiesForCountry(country.code).count) cities visited")
            }
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                impactLight.impactOccurred()
                showingAddCity = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
} 