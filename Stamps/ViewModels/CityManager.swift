import Foundation
import CoreLocation

class CityManager: ObservableObject {
    @Published private(set) var allCities: [String: [CityData]] = [:] // Grouped by country code
    
    struct CityData: Codable, Identifiable {
        let id: String  // Using name + countryCode as unique identifier
        let name: String
        let countryCode: String
        let coordinates: CLLocationCoordinate2D
        let population: Int?
        let region: String?
        
        var displayName: String {
            if let region = region {
                return "\(name), \(region)"
            }
            return name
        }
        
        init(name: String, countryCode: String, coordinates: CLLocationCoordinate2D, population: Int? = nil, region: String? = nil) {
            self.id = "\(name)_\(countryCode)"
            self.name = name
            self.countryCode = countryCode
            self.coordinates = coordinates
            self.population = population
            self.region = region
        }
    }
    
    init() {
        loadCityDatabase()
    }
    
    func citiesForCountry(_ countryCode: String) -> [CityData] {
        return allCities[countryCode] ?? []
    }
    
    private func loadCityDatabase() {
        guard let url = Bundle.main.url(forResource: "world-cities", withExtension: "json") else {
            print("Error: world-cities.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let cities = try JSONDecoder().decode([CityData].self, from: data)
            
            // Group cities by country code
            allCities = Dictionary(grouping: cities) { $0.countryCode }
            print("Successfully loaded \(cities.count) cities")
        } catch {
            print("Error loading city database: \(error)")
        }
    }
    
    func searchCities(in countryCode: String, query: String) -> [CityData] {
        let cities = citiesForCountry(countryCode)
        if query.isEmpty {
            return cities
        }
        return cities.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
} 