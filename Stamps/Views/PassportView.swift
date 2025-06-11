import SwiftUI
import UIKit

/// Main view for displaying the user's travel passport, including visited countries and cities
struct PassportView: View {
    // MARK: - Dependencies & State
    
    /// Access to the shared countries view model
    @EnvironmentObject var viewModel: CountriesViewModel
    
    /// Currently selected country for detail view
    @Binding var selectedCountry: Country?
    
    /// Currently selected city for detail view
    @Binding var selectedCity: VisitedCity?
    
    /// Controls the visibility of the add destination sheet
    @State private var showingAddSheet = false
    
    // MARK: - Constants
    
    /// Total number of recognized countries in the world
    private let totalPossibleCountries = 195
    
    /// Haptic feedback generator for button interactions
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    // MARK: - Computed Properties
    
    /// Calculates the progress as a percentage of visited countries
    private var progress: Double {
        Double(viewModel.visitedCountries.count) / Double(totalPossibleCountries)
    }
    
    // MARK: - Body
    
    var body: some View {
        // Conditionally show either country detail or main passport content
        Group {
            if let country = selectedCountry {
                countryDetailContent(country)
            } else {
                mainPassportContent
            }
        }
        // Add button overlay positioned at the top
        .overlay(alignment: .top) {
            AddButton(showingAddSheet: $showingAddSheet, impactMed: impactMed)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 20)
                .offset(y: -120)
        }
        // Modal sheet for adding new destinations
        .sheet(isPresented: $showingAddSheet) {
            AddDestinationView()
                .environmentObject(viewModel)
        }
    }
    
    // MARK: - Supporting Views
    
    /// Content displayed when viewing a specific country's details
    @ViewBuilder
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
    
    /// Main content showing the list of visited countries
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
                                selectedCity = nil
                            }
                        }) {
                            CountryRow(country: country, onSelect: {})
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                impactMed.impactOccurred()
                                viewModel.removeCountry(country)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                impactMed.impactOccurred()
                                viewModel.removeCountry(country)
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
} 