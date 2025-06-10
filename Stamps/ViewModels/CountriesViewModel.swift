import Foundation
import MapKit
import SwiftUI

class CountriesViewModel: ObservableObject {
    @Published var visitedCountries: [Country] = []
    @Published var visitedCities: [VisitedCity] = []
    @Published var selectedCountry: Country?
    @Published var selectedCity: City?
    
    private let countriesSaveKey = "visitedCountries"
    private let citiesSaveKey = "visitedCities"
    
    init() {
        loadCountries()
        loadCities()
    }
    
    // MARK: - Country Methods
    
    func addCountry(_ country: Country) {
        visitedCountries.append(country)
        saveCountries()
    }
    
    func removeCountry(_ country: Country) {
        visitedCountries.removeAll { $0.id == country.id }
        // Also remove all cities from this country
        visitedCities.removeAll { $0.countryCode == country.code }
        saveCountries()
        saveCities()
    }
    
    private func saveCountries() {
        if let encoded = try? JSONEncoder().encode(visitedCountries) {
            UserDefaults.standard.set(encoded, forKey: countriesSaveKey)
        }
    }
    
    private func loadCountries() {
        if let data = UserDefaults.standard.data(forKey: countriesSaveKey) {
            if let decoded = try? JSONDecoder().decode([Country].self, from: data) {
            visitedCountries = decoded
        }
    }
    }
    
    // MARK: - City Methods
    
    func addVisitedCity(_ city: VisitedCity) {
        visitedCities.append(city)
        saveCities()
    }
    
    func removeVisitedCity(_ city: VisitedCity) {
        visitedCities.removeAll { $0.id == city.id }
        saveCities()
    }
    
    func citiesForCountry(_ countryCode: String) -> [VisitedCity] {
        visitedCities.filter { $0.countryCode == countryCode }
            .sorted { $0.visitDate > $1.visitDate }
    }
    
    private func saveCities() {
        if let encoded = try? JSONEncoder().encode(visitedCities) {
            UserDefaults.standard.set(encoded, forKey: citiesSaveKey)
        }
    }
    
    private func loadCities() {
        if let data = UserDefaults.standard.data(forKey: citiesSaveKey) {
            if let decoded = try? JSONDecoder().decode([VisitedCity].self, from: data) {
                visitedCities = decoded
            }
        }
    }
    
    // MARK: - Statistics
    
    var totalCountries: Int {
        visitedCountries.count
    }
    
    var totalVisitedCities: Int {
        visitedCities.count
    }
    
    var citiesPerCountry: [String: Int] {
        Dictionary(grouping: visitedCities) { $0.countryCode }
            .mapValues { $0.count }
    }
    
    var lastVisit: Date? {
        let lastCountry = visitedCountries.max(by: { $0.visitDate < $1.visitDate })?.visitDate
        let lastCity = visitedCities.max(by: { $0.visitDate < $1.visitDate })?.visitDate
        return [lastCountry, lastCity].compactMap { $0 }.max()
    }
    
    var mostVisitedCountry: Country? {
        let countryCounts = Dictionary(grouping: visitedCities) { $0.countryCode }
            .mapValues { $0.count }
        guard let maxCountryCode = countryCounts.max(by: { $0.value < $1.value })?.key else { return nil }
        return visitedCountries.first { $0.code == maxCountryCode }
    }
} 