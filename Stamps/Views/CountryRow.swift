import SwiftUI
import UIKit

struct CountryRow: View {
    let country: Country
    let onSelect: () -> Void
    @EnvironmentObject var viewModel: CountriesViewModel
    
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(country.flag)
                    .font(.title)
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
                    .padding(.trailing, 4)
                Button(action: {
                    impactHeavy.impactOccurred()
                    viewModel.removeCountry(country)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            impactHeavy.prepare()
        }
    }
} 
 