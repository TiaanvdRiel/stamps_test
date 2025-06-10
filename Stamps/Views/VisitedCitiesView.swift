import SwiftUI

struct VisitedCitiesView: View {
    let country: Country
    @EnvironmentObject private var viewModel: CountriesViewModel
    @State private var showingAddCity = false
    
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        List {
            Section {
                ForEach(viewModel.citiesForCountry(country.code)) { visitedCity in
                    if let cityData = visitedCity.cityData {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(cityData.name)
                                    .font(.headline)
                                if let region = cityData.region {
                                    Text(region)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Text(visitedCity.formattedDate)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if let population = cityData.population {
                                Text(formatPopulation(population))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                impactMed.impactOccurred()
                                viewModel.removeVisitedCity(visitedCity)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            } header: {
                Text("Visited Cities")
            } footer: {
                Text("\(viewModel.citiesForCountry(country.code).count) cities visited")
            }
        }
        .navigationTitle(country.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    impactLight.impactOccurred()
                    showingAddCity = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCity) {
            CitySelectionView(country: country)
        }
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