import SwiftUI

struct AddDestinationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var countriesViewModel: CountriesViewModel
    @State private var selectedTab = 0
    @State private var countrySearchText = ""
    @State private var citySearchText = ""
    @State private var filteredCities: [CityDataManager.CityData] = []
    @State private var isSearching = false
    @State private var selectedDate = Date()
    
    private let searchDebouncer = Debouncer(delay: 0.3)
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Select View", selection: $selectedTab) {
                    Text("Countries").tag(0)
                    Text("Cities").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                TabView(selection: $selectedTab) {
                    CountrySearchView(
                        searchText: $countrySearchText,
                        selectedDate: $selectedDate,
                        dismiss: dismiss
                    )
                    .tag(0)
                    
                    CitySearchView(
                        searchText: $citySearchText,
                        filteredCities: filteredCities,
                        isSearching: isSearching
                    )
                    .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Add Destination")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: citySearchText) { newValue in
            isSearching = true
            searchDebouncer.debounce {
                filteredCities = CityDataManager.shared.searchCities(query: newValue)
                isSearching = false
            }
        }
        .onAppear {
            // Load initial top cities
            filteredCities = CityDataManager.shared.searchCities(query: "")
        }
    }
}

// MARK: - Supporting Views
private struct CountrySearchView: View {
    @Binding var searchText: String
    @Binding var selectedDate: Date
    let dismiss: DismissAction
    @EnvironmentObject private var countriesViewModel: CountriesViewModel
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    private let countries: [Country] = {
        Locale.isoRegionCodes.compactMap { code -> Country? in
            guard let name = Locale.current.localizedString(forRegionCode: code) else { return nil }
            return Country(
                name: name,
                code: code,
                visitDate: Date(),
                coordinates: []
            )
        }.sorted { $0.name < $1.name }
    }()
    
    var filteredCountries: [Country] {
        if searchText.isEmpty {
            return countries
        }
        return countries.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(filteredCountries) { country in
                    CountryRowView(
                        country: country,
                        isDisabled: countriesViewModel.visitedCountries.contains(where: { $0.code == country.code }),
                        onSelect: {
                            addCountry(country)
                            dismiss()
                        }
                    )
                }
            }
            .searchable(text: $searchText, prompt: "Search countries")
            
            DatePicker("Visit Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding()
        }
    }
    
    private func addCountry(_ country: Country) {
        impactMed.impactOccurred()
        let newCountry = Country(
            name: country.name,
            code: country.code,
            visitDate: selectedDate,
            coordinates: []
        )
        countriesViewModel.addCountry(newCountry)
    }
}

private struct CitySearchView: View {
    @Binding var searchText: String
    let filteredCities: [CityDataManager.CityData]
    let isSearching: Bool
    @EnvironmentObject private var countriesViewModel: CountriesViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack {
            List {
                if isSearching {
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(filteredCities) { city in
                        CityRowView(
                            cityData: city,
                            isDisabled: countriesViewModel.visitedCities.contains(where: { visitedCity in
                                visitedCity.cityData?.name == city.name && 
                                visitedCity.countryCode == city.countryCode
                            }),
                            onSelect: {
                                addCity(city)
                                dismiss()
                            }
                        )
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search cities globally")
            .listStyle(PlainListStyle())
            
            DatePicker("Visit Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding()
        }
    }
    
    private func addCity(_ cityData: CityDataManager.CityData) {
        impactMed.impactOccurred()
        
        // If the country isn't visited yet, add it
        if !countriesViewModel.visitedCountries.contains(where: { $0.code == cityData.countryCode }) {
            if let countryName = Locale.current.localizedString(forRegionCode: cityData.countryCode) {
                let country = Country(
                    name: countryName,
                    code: cityData.countryCode,
                    visitDate: selectedDate,
                    coordinates: []
                )
                countriesViewModel.addCountry(country)
            }
        }
        
        // Add the city
        let visitedCity = VisitedCity(
            cityDataId: cityData.id,
            countryCode: cityData.countryCode,
            visitDate: selectedDate
        )
        countriesViewModel.addVisitedCity(visitedCity)
    }
}

// MARK: - Helper Classes
private class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func debounce(action: @escaping () -> Void) {
        workItem?.cancel()
        let newWorkItem = DispatchWorkItem(block: action)
        workItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }
}

// MARK: - Row Views
private struct CountryRowView: View {
    let country: Country
    let isDisabled: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(country.flag)
                    .font(.title2)
                Text(country.name)
                    .foregroundColor(.primary)
            }
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

private struct CityRowView: View {
    let cityData: CityDataManager.CityData
    let isDisabled: Bool
    let onSelect: () -> Void
    
    private var countryFlag: String {
        let base: UInt32 = 127397
        var flagString = ""
        for scalar in cityData.countryCode.uppercased().unicodeScalars {
            if let scalarValue = UnicodeScalar(base + scalar.value) {
                flagString.append(String(scalarValue))
            }
        }
        return flagString
    }
    
    private var countryName: String {
        Locale.current.localizedString(forRegionCode: cityData.countryCode) ?? cityData.countryCode
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(cityData.name)
                            .font(.headline)
                        Text(countryFlag)
                    }
                    Text(countryName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if let region = cityData.region {
                        Text(region)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if let population = cityData.population {
                    Text(formatPopulation(population))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
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