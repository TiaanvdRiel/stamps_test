import Foundation
import CoreLocation

struct City: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let countryCode: String
    let visitDate: Date
    let coordinates: CLLocationCoordinate2D
    let population: Int?  // Optional as not all cities might have this data
    let region: String?   // State/Province/Region (optional)
    
    var formattedDate: String {
        visitDate.formatted(date: .abbreviated, time: .omitted)
    }
    
    init(id: UUID = UUID(), name: String, countryCode: String, visitDate: Date, coordinates: CLLocationCoordinate2D, population: Int? = nil, region: String? = nil) {
        self.id = id
        self.name = name
        self.countryCode = countryCode
        self.visitDate = visitDate
        self.coordinates = coordinates
        self.population = population
        self.region = region
    }
    
    static func == (lhs: City, rhs: City) -> Bool {
        lhs.id == rhs.id
    }
} 