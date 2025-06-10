import SwiftUI

struct AddCountryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CountriesViewModel
    @State private var searchText = ""
    @State private var selectedDate = Date()
    
    private let countries: [(name: String, code: String)] = Locale.isoRegionCodes.compactMap { code in
        guard let name = Locale.current.localizedString(forRegionCode: code) else { return nil }
        return (name: name, code: code)
    }.sorted { $0.name < $1.name }
    
    var filteredCountries: [(name: String, code: String)] {
        if searchText.isEmpty {
            return countries
        }
        return countries.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List(filteredCountries, id: \.code) { country in
                    Button(action: {
                        let newCountry = Country(
                            name: country.name,
                            code: country.code,
                            visitDate: selectedDate
                        )
                        viewModel.addCountry(newCountry)
                        dismiss()
                    }) {
                        Text(country.name)
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