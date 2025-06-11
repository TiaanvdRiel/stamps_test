import SwiftUI

struct CityRowView: View {
    let cityData: CityDataManager.CityData
    let visitedCity: VisitedCity
    let impactMed: UIImpactFeedbackGenerator
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(cityData.name)
                    .font(.headline)
                if let region = cityData.region {
                    Text(region)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Text(visitedCity.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let population = cityData.population {
                Text(formatPopulation(population))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                impactMed.impactOccurred()
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func formatPopulation(_ population: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if population >= 1_000_000 {
            let millions = Double(population) / 1_000_000
            return String(format: "%.1fM", millions)
        } else if population >= 1_000 {
            let thousands = Double(population) / 1_000
            return String(format: "%.1fK", thousands)
        } else {
            return formatter.string(from: NSNumber(value: population)) ?? "\(population)"
        }
    }
} 