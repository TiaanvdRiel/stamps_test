import Foundation
import MapKit
import SwiftUI

class CountriesViewModel: ObservableObject {
    @Published var visitedCountries: [Country] = []
    @Published var selectedCountry: Country?
    
    private let saveKey = "visitedCountries"
    
    init() {
        loadCountries()
    }
    
    func addCountry(_ country: Country) {
        visitedCountries.append(country)
        saveCountries()
    }
    
    func removeCountry(_ country: Country) {
        visitedCountries.removeAll { $0.id == country.id }
        saveCountries()
    }
    
    private func saveCountries() {
        if let encoded = try? JSONEncoder().encode(visitedCountries) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadCountries() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Country].self, from: data) {
            visitedCountries = decoded
        }
    }
    
    var totalCountries: Int {
        visitedCountries.count
    }
    
    var lastVisit: Date? {
        visitedCountries.map { $0.visitDate }.max()
    }
    
    var mostVisitedRegion: String? {
        // This is a placeholder - you might want to implement actual region detection
        return "Europe"
    }
} 