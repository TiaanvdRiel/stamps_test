import SwiftUI
import UIKit

struct CountryRow: View {
    let country: Country
    let onSelect: () -> Void
    @EnvironmentObject var viewModel: CountriesViewModel
    
    var body: some View {
        HStack {
            Text(country.flag)
                .font(.title)
                .padding(.trailing, 4)
            VStack(alignment: .leading) {
                Text(country.name)
                    .font(.headline)
                HStack {
                    Text(country.formattedDate)
                        .font(.caption)
                    Text("•")
                    Text("\(viewModel.citiesForCountry(country.code).count) cities")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .background(Color.clear)
    }
} 
 