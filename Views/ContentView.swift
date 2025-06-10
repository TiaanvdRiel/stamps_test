import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = CountriesViewModel()
    @State private var showingAddSheet = false
    @State private var showingBottomSheet = true
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
    )
    
    var body: some View {
        ZStack {
            MapView(visitedCountries: viewModel.visitedCountries)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                if showingBottomSheet {
                    BottomSheetView(viewModel: viewModel)
                        .transition(.move(edge: .bottom))
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCountryView(viewModel: viewModel)
        }
    }
}

struct MapView: UIViewRepresentable {
    let visitedCountries: [Country]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Remove existing overlays
        mapView.removeOverlays(mapView.overlays)
        
        // Add overlays for visited countries
        for country in visitedCountries {
            let polygon = MKPolygon(coordinates: country.coordinates, count: country.coordinates.count)
            mapView.addOverlay(polygon)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = UIColor.blue.withAlphaComponent(0.3)
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 1
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

struct BottomSheetView: View {
    @ObservedObject var viewModel: CountriesViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Your Travel Stats")
                    .font(.title2)
                    .bold()
                
                HStack(spacing: 30) {
                    StatView(title: "Countries", value: "\(viewModel.totalCountries)")
                    if let lastVisit = viewModel.lastVisit {
                        StatView(title: "Last Visit", value: lastVisit.formatted(date: .abbreviated, time: .omitted))
                    }
                    if let region = viewModel.mostVisitedRegion {
                        StatView(title: "Top Region", value: region)
                    }
                }
                
                if !viewModel.visitedCountries.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.visitedCountries) { country in
                                CountryCard(country: country)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
    }
}

struct CountryCard: View {
    let country: Country
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(country.name)
                .font(.headline)
            Text(country.visitDate.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct AddCountryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CountriesViewModel
    @State private var countryName = ""
    @State private var countryCode = ""
    @State private var visitDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Country Name", text: $countryName)
                TextField("Country Code", text: $countryCode)
                DatePicker("Visit Date", selection: $visitDate, displayedComponents: .date)
            }
            .navigationTitle("Add Country")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    // Here you would typically fetch the country coordinates
                    // For now, we'll use a placeholder
                    let coordinates = [
                        CLLocationCoordinate2D(latitude: 0, longitude: 0)
                    ]
                    let country = Country(
                        name: countryName,
                        code: countryCode,
                        visitDate: visitDate,
                        coordinates: coordinates
                    )
                    viewModel.addCountry(country)
                    dismiss()
                }
                .disabled(countryName.isEmpty || countryCode.isEmpty)
            )
        }
    }
} 