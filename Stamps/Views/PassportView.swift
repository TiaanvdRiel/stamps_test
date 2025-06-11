import SwiftUI
import UIKit

struct PassportView: View {
    @EnvironmentObject var viewModel: CountriesViewModel
    @Binding var selectedCountry: Country?
    @Binding var selectedCity: VisitedCity?
    
    private let totalPossibleCountries = 195
    
    private var progress: Double {
        Double(viewModel.visitedCountries.count) / Double(totalPossibleCountries)
    }
    
    var body: some View {
        Group {
            if let country = selectedCountry {
                countryDetailContent(country)
            } else {
                mainPassportContent
            }
        }
    }
    
    private var mainPassportContent: some View {
        VStack(spacing: 20) {
            Text("My Passport")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                ProgressCircleView(
                    progress: progress,
                    totalCountries: viewModel.visitedCountries.count
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
                List {
                    ForEach(viewModel.visitedCountries) { country in
                        Button(action: {
                            withAnimation {
                                selectedCountry = country
                                selectedCity = nil // Clear selected city when selecting a country
                            }
                        }) {
                            CountryRow(country: country, onSelect: {})
                                .environmentObject(viewModel)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                viewModel.removeCountry(country)
                                if selectedCountry?.code == country.code {
                                    selectedCountry = nil
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                viewModel.removeCountry(country)
                                if selectedCountry?.code == country.code {
                                    selectedCountry = nil
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    private func countryDetailContent(_ country: Country) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(action: {
                    withAnimation {
                        selectedCountry = nil
                        selectedCity = nil
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
            
            List {
                ForEach(viewModel.citiesForCountry(country.code)) { visitedCity in
                    if let cityData = visitedCity.cityData {
                        Button(action: {
                            withAnimation {
                                selectedCity = visitedCity
                            }
                        }) {
                            CityRowView(
                                cityData: cityData,
                                visitedCity: visitedCity,
                                impactMed: UIImpactFeedbackGenerator(style: .medium),
                                onDelete: {}
                            )
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                viewModel.removeVisitedCity(visitedCity)
                                if selectedCity?.id == visitedCity.id {
                                    selectedCity = nil
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                viewModel.removeVisitedCity(visitedCity)
                                if selectedCity?.id == visitedCity.id {
                                    selectedCity = nil
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
    }
} 