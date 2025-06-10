import SwiftUI

struct CitiesView: View {
    let country: Country
    @EnvironmentObject var viewModel: CountriesViewModel
    @StateObject private var cityManager = CityManager()
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedDate = Date()
    
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    var filteredCities: [CityManager.CityData] {
        cityManager.searchCities(in: country.code, query: searchText)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                citiesList
                datePicker
            }
            .navigationTitle("Add City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
        .onAppear {
            impactMed.prepare()
            impactLight.prepare()
        }
    }
    
    private var citiesList: some View {
        List(filteredCities) { cityData in
            CityRowView(
                cityData: cityData,
                isDisabled: viewModel.visitedCities.contains(where: { visitedCity in
                    visitedCity.cityData?.name == cityData.name && visitedCity.countryCode == cityData.countryCode 
                }),
                onSelect: { addCity(cityData) }
            )
        }
        .searchable(text: $searchText, prompt: "Search cities")
    }
    
    private var datePicker: some View {
        DatePicker("Visit Date", selection: $selectedDate, displayedComponents: .date)
            .datePickerStyle(.compact)
            .padding()
    }
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                impactLight.impactOccurred()
                dismiss()
            }
        }
    }
    
    private func addCity(_ cityData: CityManager.CityData) {
        impactMed.impactOccurred()
        let visitedCity = VisitedCity(
            cityDataId: cityData.id,
            countryCode: cityData.countryCode,
            visitDate: selectedDate
        )
        viewModel.addVisitedCity(visitedCity)
        dismiss()
    }
}

private struct CityRowView: View {
    let cityData: CityManager.CityData
    let isDisabled: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading) {
                    Text(cityData.name)
                        .font(.headline)
                    if let region = cityData.region {
                        Text(region)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if let population = cityData.population {
                    Text("\(population)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .contentShape(Rectangle())
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
} 