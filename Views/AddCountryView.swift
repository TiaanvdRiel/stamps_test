import SwiftUI

struct AddCountryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CountriesViewModel
    @State private var searchText = ""
    @State private var selectedDate = Date()
    
    private let countries = Locale.isoRegionCodes.compactMap { code in
        Locale.current.localizedString(forRegionCode: code)
    }.sorted()
    
    var filteredCountries: [String] {
        if searchText.isEmpty {
            return countries
        }
        return countries.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List(filteredCountries, id: \.self) { country in
                    Button(action: {
                        let newCountry = Country(name: country, visitDate: selectedDate)
                        viewModel.addCountry(newCountry)
                        dismiss()
                    }) {
                        Text(country)
                    }
                }
                .searchable(text: $searchText, prompt: "Search countries")
                
                DatePicker("Visit Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding()
            }
            .navigationTitle("Add Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
} 