import SwiftUI

struct CitySelectionView: View {
    let country: Country
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: CountriesViewModel
    @State private var searchText = ""
    @State private var selectedDate = Date()
    
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    var filteredCities: [CityDataManager.CityData] {
        CityDataManager.shared.searchCities(countryCode: country.code, query: searchText)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    DatePicker("Visit Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                Section {
                    ForEach(filteredCities) { city in
                        Button(action: {
                            impactMed.impactOccurred()
                            addCity(city)
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(city.name)
                                        .font(.headline)
                                    if let region = city.region {
                                        Text(region)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if let population = city.population {
                                    Text(formatPopulation(population))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                } header: {
                    if !searchText.isEmpty && filteredCities.isEmpty {
                        Text("No cities found")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search cities")
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
    }
    
    private func addCity(_ cityData: CityDataManager.CityData) {
        let visitedCity = VisitedCity(
            cityDataId: cityData.id,
            countryCode: cityData.countryCode,
            visitDate: selectedDate
        )
        viewModel.addVisitedCity(visitedCity)
        dismiss()
    }
    
    private func formatPopulation(_ population: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if population >= 1_000_000 {
            let millions = Double(population) / 1_000_000
            return String(format: "%.1fM", millions)
        } else if population >= 1_000 {
            let thousands = Double(population) / 1_000
            return String(format: "%.1fK", thousands)
        } else {
            return formatter.string(from: NSNumber(value: population)) ?? "\(population)"
        }
    }
} 