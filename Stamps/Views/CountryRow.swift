import SwiftUI
import UIKit

struct CountryRow: View {
    let country: Country
    @EnvironmentObject var viewModel: CountriesViewModel
    
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        NavigationLink(destination: VisitedCitiesView(country: country)) {
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
        .onAppear {
            impactHeavy.prepare()
        }
    }
} 
