import Foundation
import CoreLocation

struct Country: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let code: String
    let visitDate: Date
    var coordinates: [CLLocationCoordinate2D]
    
    var formattedDate: String {
        visitDate.formatted(date: .abbreviated, time: .omitted)
    }
    
    var flag: String {
        // Convert country code to flag emoji
        let base: UInt32 = 127397 // This is the Unicode offset for regional indicator symbols
        var flagString = ""
        
        // Convert two-letter country code to flag emoji
        for scalar in code.uppercased().unicodeScalars {
            if let scalarValue = UnicodeScalar(base + scalar.value) {
                flagString.append(String(scalarValue))
            }
        }
        
        return flagString
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, code, visitDate, coordinates
    }
    
    init(name: String, code: String, visitDate: Date, coordinates: [CLLocationCoordinate2D] = []) {
        self.id = UUID()
        self.name = name
        self.code = code
        self.visitDate = visitDate
        self.coordinates = coordinates
    }
    
    static func == (lhs: Country, rhs: Country) -> Bool {
        lhs.code == rhs.code
    }
}

// Extension to handle CLLocationCoordinate2D encoding/decoding
extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
} 
