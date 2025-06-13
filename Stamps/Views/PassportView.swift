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
    
    /// Controls the sheet position
    @Binding var sheetPosition: SheetPosition
    
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
                        selectedCity = nil  // Clear city first to trigger map recentering
                        // Use a slight delay to allow the map to recenter before transitioning views
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                selectedCountry = nil
                            }
                        }
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
                                if sheetPosition == .expanded {
                                    sheetPosition = .middle
                                }
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
        VStack(spacing: 0) {
            Text("My Passport")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 16)
            
            ScrollView {
                VStack(spacing: 20) {
                    ProgressCircleView(
                        progress: progress,
                        totalCountries: viewModel.totalCountries
                    )
                    
                    if viewModel.visitedCountries.isEmpty {
                        EmptyStateView()
                            .padding(.top, 20)
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.visitedCountries) { country in
                                Button(action: {
                                    withAnimation {
                                        selectedCountry = country
                                        selectedCity = nil
                                        if sheetPosition == .expanded {
                                            sheetPosition = .middle
                                        }
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
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                        }
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
} 
