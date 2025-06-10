import Foundation
import CoreLocation

struct VisitedCity: Identifiable, Codable, Equatable {
    let id: UUID
    let cityDataId: String
    let countryCode: String
    let visitDate: Date
    
    var cityData: CityDataManager.CityData? {
        CityDataManager.shared.city(withId: cityDataId)
    }
    
    var formattedDate: String {
        visitDate.formatted(date: .abbreviated, time: .omitted)
    }
    
    init(id: UUID = UUID(), cityDataId: String, countryCode: String, visitDate: Date) {
        self.id = id
        self.cityDataId = cityDataId
        self.countryCode = countryCode
        self.visitDate = visitDate
    }
} 