import SwiftUI

struct AddCountryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: CountriesViewModel
    @State private var searchText = ""
    @State private var selectedDate = Date()
    
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    private let countries: [Country] = {
        Locale.isoRegionCodes.compactMap { code -> Country? in
            guard let name = Locale.current.localizedString(forRegionCode: code) else { return nil }
            return Country(
                name: name,
                code: code,
                visitDate: Date(),
                coordinates: []
            )
        }.sorted { $0.name < $1.name }
    }()
    
    var filteredCountries: [Country] {
        if searchText.isEmpty {
            return countries
        }
        return countries.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                countriesList
                datePicker
            }
            .navigationTitle("Add Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
        .onAppear {
            impactMed.prepare()
        }
    }
    
    private var countriesList: some View {
        List(filteredCountries) { country in
            CountryRowView(
                country: country,
                isDisabled: viewModel.visitedCountries.contains(where: { $0.code == country.code }),
                onSelect: { addCountry(country) }
            )
        }
        .searchable(text: $searchText, prompt: "Search countries")
    }
    
    private var datePicker: some View {
        DatePicker("Visit Date", selection: $selectedDate, displayedComponents: .date)
            .datePickerStyle(.compact)
            .padding()
    }
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                impactMed.impactOccurred()
                dismiss()
            }
        }
    }
    
    private func addCountry(_ country: Country) {
        impactMed.impactOccurred()
        let newCountry = Country(
            name: country.name,
            code: country.code,
            visitDate: selectedDate,
            coordinates: []
        )
        viewModel.addCountry(newCountry)
        dismiss()
    }
}

private struct CountryRowView: View {
    let country: Country
    let isDisabled: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(country.flag)
                    .font(.title2)
                Text(country.name)
                    .foregroundColor(.primary)
            }
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
} 