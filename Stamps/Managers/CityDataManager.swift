import Foundation
import CoreLocation

class CityDataManager {
    static let shared = CityDataManager()
    
    private var allCities: [CityData] = []
    private var citiesByCountry: [String: [CityData]] = [:]
    private var topCities: [CityData] = []
    
    struct CityData: Codable, Identifiable, Hashable {
        let id: String
        let name: String
        let countryCode: String
        let coordinates: Coordinates
        let population: Int?
        let region: String?
        
        struct Coordinates: Codable, Hashable {
            let latitude: Double
            let longitude: Double
            
            var clCoordinate: CLLocationCoordinate2D {
                CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
        }
        
        var displayName: String {
            if let region = region {
                return "\(name), \(region)"
            }
            return name
        }
    }
    
    private init() {
        loadCityData()
    }
    
    private func loadCityData() {
        guard let url = Bundle.main.url(forResource: "cities", withExtension: "json") else {
            print("Error: Could not find cities.json in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let citiesData = try decoder.decode(CitiesResponse.self, from: data)
            
            // Store all cities and create indexes
            allCities = citiesData.cities
            citiesByCountry = Dictionary(grouping: citiesData.cities) { $0.countryCode }
            
            // Pre-sort top cities by population
            topCities = allCities
                .sorted { ($0.population ?? 0) > ($1.population ?? 0) }
                .prefix(100)
                .map { $0 }
            
            print("Loaded \(citiesData.cities.count) cities")
        } catch {
            print("Error loading city data: \(error)")
        }
    }
    
    private struct CitiesResponse: Codable {
        let metadata: Metadata
        let cities: [CityData]
        
        struct Metadata: Codable {
            let version: String
            let lastUpdated: String
            let source: String
        }
    }
    
    func searchCities(query: String) -> [CityData] {
        // Return pre-sorted top cities for empty query
        guard !query.isEmpty else {
            return topCities
        }
        
        let searchQuery = query.lowercased()
        
        // Search with a limit to prevent performance issues
        return allCities
            .filter { city in
                city.name.lowercased().contains(searchQuery) ||
                (city.region?.lowercased().contains(searchQuery) ?? false) ||
                (Locale.current.localizedString(forRegionCode: city.countryCode)?.lowercased().contains(searchQuery) ?? false)
            }
            .prefix(100)
            .sorted { ($0.population ?? 0) > ($1.population ?? 0) }
    }
    
    func searchCities(countryCode: String, query: String) -> [CityData] {
        guard let countryCities = citiesByCountry[countryCode] else { return [] }
        
        if query.isEmpty {
            return countryCities
                .sorted { ($0.population ?? 0) > ($1.population ?? 0) }
                .prefix(100)
                .map { $0 }
        }
        
        let searchQuery = query.lowercased()
        return countryCities
            .filter { city in
                city.name.lowercased().contains(searchQuery) ||
                (city.region?.lowercased().contains(searchQuery) ?? false)
            }
            .prefix(100)
            .sorted { ($0.population ?? 0) > ($1.population ?? 0) }
    }
    
    func city(withId id: String) -> CityData? {
        allCities.first { $0.id == id }
    }
} 