import Foundation
import CoreLocation

class CityDataManager {
    static let shared = CityDataManager()
    
    private(set) var cities: [String: [CityData]] = [:] // Grouped by country code
    
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
            
            // Group cities by country code
            cities = Dictionary(grouping: citiesData.cities) { $0.countryCode }
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
    
    func searchCities(countryCode: String, query: String) -> [CityData] {
        let countryCities = cities[countryCode] ?? []
        if query.isEmpty {
            return countryCities
        }
        
        return countryCities.filter { city in
            city.name.localizedCaseInsensitiveContains(query) ||
            (city.region?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
    
    func city(withId id: String) -> CityData? {
        for citiesList in cities.values {
            if let city = citiesList.first(where: { $0.id == id }) {
                return city
            }
        }
        return nil
    }
} 