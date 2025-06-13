import SwiftUI
import UIKit

struct CountryRow: View {
    let country: Country
    let onSelect: () -> Void
    @EnvironmentObject var viewModel: CountriesViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            Text(country.flag)
                .font(.title)
                .padding(.trailing, 4)
            VStack(alignment: .leading) {
                Text(country.name)
                    .font(.headline)
                    .foregroundColor(Color(.label))
                HStack {
                    Text(country.formattedDate)
                        .font(.caption)
                    Text("•")
                    Text("\(viewModel.citiesForCountry(country.code).count) cities")
                        .font(.caption)
                }
                .foregroundColor(Color(.secondaryLabel))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(.tertiaryLabel))
                .font(.caption)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .contentShape(Rectangle())
        .background(Color(.systemBackground))
    }
} 
 