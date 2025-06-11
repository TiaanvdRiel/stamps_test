import SwiftUI
import UIKit

struct PassportView: View {
    @EnvironmentObject private var viewModel: CountriesViewModel
    @State private var selectedCountry: Country?
    private let totalCountries = 195
    
    private var progress: Double {
        Double(viewModel.totalCountries) / Double(totalCountries)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("My Passport")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if selectedCountry == nil {
                // Main passport view
                mainPassportContent
            } else if let country = selectedCountry {
                // Country detail view
                countryDetailContent(country)
            }
        }
    }
    
    private var mainPassportContent: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                ProgressCircleView(
                    progress: progress,
                    totalCountries: viewModel.totalCountries
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    StatView(
                        title: "Total Cities",
                        value: "\(viewModel.totalVisitedCities)",
                        icon: "building.2.fill"
                    )
                    
                    if let lastVisit = viewModel.lastVisit {
                        StatView(
                            title: "Last Visit",
                            value: lastVisit.formatted(date: .abbreviated, time: .omitted),
                            icon: "calendar"
                        )
                    }
                    
                    if let mostVisited = viewModel.mostVisitedCountry {
                        StatView(
                            title: "Most Visited",
                            value: "\(mostVisited.name) (\(viewModel.citiesPerCountry[mostVisited.code] ?? 0))",
                            icon: "star.fill"
                        )
                    }
                }
            }
            .padding(.horizontal)
            
            if viewModel.visitedCountries.isEmpty {
                EmptyStateView()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.visitedCountries) { country in
                            CountryRow(country: country, onSelect: {
                                withAnimation {
                                    selectedCountry = country
                                }
                            })
                            if country.id != viewModel.visitedCountries.last?.id {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func countryDetailContent(_ country: Country) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(action: {
                    withAnimation {
                        selectedCountry = nil
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            HStack {
                Text(country.flag)
                    .font(.title)
                Text(country.name)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            Text("Visited \(viewModel.citiesForCountry(country.code).count) cities")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    let cities = viewModel.citiesForCountry(country.code)
                    ForEach(cities) { visitedCity in
                        if let cityData = visitedCity.cityData {
                            VStack {
                                CityRowView(
                                    cityData: cityData,
                                    visitedCity: visitedCity,
                                    impactMed: UIImpactFeedbackGenerator(style: .medium),
                                    onDelete: { viewModel.removeVisitedCity(visitedCity) }
                                )
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                
                                if visitedCity.id != cities.last?.id {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct StatView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }
} 