import SwiftUI

struct AddCountryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: CountriesViewModel
    @State private var searchText = ""
    @State private var selectedDate = Date()
    
    private let countries: [Country] = Locale.isoRegionCodes.compactMap { code in
        guard let name = Locale.current.localizedString(forRegionCode: code) else { return nil }
        return Country(name: name, code: code)
    }.sorted { $0.name < $1.name }
    
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    var filteredCountries: [Country] {
        if searchText.isEmpty {
            return countries
        }
        return countries.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List(filteredCountries) { country in
                    Button(action: {
                        impactMed.impactOccurred()
                        viewModel.addCountry(country)
                        dismiss()
                    }) {
                        HStack {
                            Text(country.flag)
                                .font(.title2)
                            Text(country.name)
                                .foregroundColor(.primary)
                        }
                    }
                    .disabled(viewModel.visitedCountries.contains(where: { $0.code == country.code }))
                    .opacity(viewModel.visitedCountries.contains(where: { $0.code == country.code }) ? 0.5 : 1.0)
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
                        impactMed.impactOccurred()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            impactMed.prepare()
        }
    }
} 