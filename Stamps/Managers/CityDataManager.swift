import Foundation
import CoreLocation

class CityDataManager {
    static let shared = CityDataManager()
    
    private var allCities: [CityData] = []
    private var citiesByCountry: [String: [CityData]] = [:]
    private var topCities: [CityData] = []
    private var searchIndex: [String: Set<String>] = [:] // Search index mapping lowercase terms to city IDs
    
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
        
        // Search terms for this city
        var searchTerms: Set<String> {
            var terms = Set<String>()
            // Add name terms
            name.lowercased().split(separator: " ").forEach { terms.insert(String($0)) }
            // Add region terms if available
            if let region = region?.lowercased() {
                region.split(separator: " ").forEach { terms.insert(String($0)) }
            }
            // Add country name
            if let countryName = Locale.current.localizedString(forRegionCode: countryCode)?.lowercased() {
                countryName.split(separator: " ").forEach { terms.insert(String($0)) }
            }
            return terms
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
            
            // Build search index
            buildSearchIndex()
            
            print("Loaded \(citiesData.cities.count) cities")
        } catch {
            print("Error loading city data: \(error)")
        }
    }
    
    private func buildSearchIndex() {
        searchIndex.removeAll()
        
        for city in allCities {
            // Get all search terms for this city
            let terms = city.searchTerms
            
            // Add city ID to each term's set
            for term in terms {
                searchIndex[term, default: Set()].insert(city.id)
            }
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
        
        let searchTerms = query.lowercased().split(separator: " ").map(String.init)
        
        // Get matching city IDs for each search term
        var matchingIds: Set<String>?
        
        for term in searchTerms {
            // Find cities that match this term
            let termMatches = searchIndex.filter { key, _ in
                key.contains(term)
            }.values.reduce(into: Set<String>()) { result, ids in
                result.formUnion(ids)
            }
            
            // Intersect with previous results if any
            if let existing = matchingIds {
                matchingIds = existing.intersection(termMatches)
            } else {
                matchingIds = termMatches
            }
            
            // Early exit if no matches
            if matchingIds?.isEmpty ?? true {
                return []
            }
        }
        
        // Convert matching IDs back to cities
        let matchingCities = (matchingIds ?? []).compactMap { id in
            allCities.first { $0.id == id }
        }
        
        // Sort by population and limit results
        return matchingCities
            .sorted { ($0.population ?? 0) > ($1.population ?? 0) }
            .prefix(100)
            .map { $0 }
    }
    
    func searchCities(countryCode: String, query: String) -> [CityData] {
        guard let countryCities = citiesByCountry[countryCode] else { return [] }
        
        if query.isEmpty {
            return countryCities
                .sorted { ($0.population ?? 0) > ($1.population ?? 0) }
                .prefix(100)
                .map { $0 }
        }
        
        let searchTerms = query.lowercased().split(separator: " ")
        return countryCities
            .filter { city in
                searchTerms.allSatisfy { term in
                    city.searchTerms.contains(where: { $0.contains(String(term)) })
                }
            }
            .prefix(100)
            .sorted { ($0.population ?? 0) > ($1.population ?? 0) }
    }
    
    func city(withId id: String) -> CityData? {
        allCities.first { $0.id == id }
    }
} 