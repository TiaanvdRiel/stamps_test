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
                List(filteredCities) { cityData in
                    Button(action: {
                        impactMed.impactOccurred()
                        let city = City(
                            name: cityData.name,
                            countryCode: cityData.countryCode,
                            visitDate: selectedDate,
                            coordinates: cityData.coordinates,
                            population: cityData.population,
                            region: cityData.region
                        )
                        viewModel.addCity(city)
                        dismiss()
                    }) {
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
                    .disabled(viewModel.visitedCities.contains(where: { $0.name == cityData.name && $0.countryCode == cityData.countryCode }))
                    .opacity(viewModel.visitedCities.contains(where: { $0.name == cityData.name && $0.countryCode == cityData.countryCode }) ? 0.5 : 1.0)
                }
                .searchable(text: $searchText, prompt: "Search cities")
                
                DatePicker("Visit Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding()
            }
            .navigationTitle("Add City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        impactLight.impactOccurred()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            impactMed.prepare()
            impactLight.prepare()
        }
    }
} 