import SwiftUI
import UIKit

struct CountryRow: View {
    let country: Country
    @EnvironmentObject var viewModel: CountriesViewModel
    
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        HStack {
            Text(country.flag)
                .font(.title)
            Text(country.name)
                .font(.body)
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
        .onAppear {
            impactHeavy.prepare()
        }
    }
} 
