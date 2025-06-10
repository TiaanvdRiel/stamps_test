import Foundation
import MapKit

class CountryPolygonManager: ObservableObject {
    @Published var countryPolygons: [String: [MKPolygon]] = [:]
    
    init() {
        loadCountryPolygons()
    }
    
    private func loadCountryPolygons() {
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "geojson") else {
            print("Error: countries.geojson not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let features = try MKGeoJSONDecoder().decode(data)
            
            for case let feature as MKGeoJSONFeature in features {
                guard let properties = feature.properties,
                      let propertyDict = try? JSONSerialization.jsonObject(with: properties) as? [String: Any],
                      let countryName = propertyDict["name"] as? String else {
                    continue
                }
                
                let polygons = feature.geometry.compactMap { geometry -> [MKPolygon] in
                    if let polygon = geometry as? MKPolygon {
                        return [polygon]
                    } else if let multiPolygon = geometry as? MKMultiPolygon {
                        // Handle each polygon in the multipolygon
                        return multiPolygon.polygons.map { $0 as! MKPolygon }
                    }
                    return []
                }.flatMap { $0 } // Flatten the array of arrays
                
                if !polygons.isEmpty {
                    countryPolygons[countryName] = polygons
                }
            }
            print("Successfully loaded \(countryPolygons.count) country polygons")
        } catch {
            print("Error loading or parsing GeoJSON: \(error)")
        }
    }
    
    func polygonsForCountry(_ countryName: String) -> [MKPolygon] {
        return countryPolygons[countryName] ?? []
    }
} 