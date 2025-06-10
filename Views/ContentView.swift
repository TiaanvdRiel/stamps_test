import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = CountriesViewModel()
    @State private var showingAddCountry = false
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
                
                // Bottom Sheet
                BottomSheetView(viewModel: viewModel)
                    .frame(height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                    .padding()
            }
            
            // Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddCountry = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .background(Circle().fill(.white))
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingAddCountry) {
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
        VStack(spacing: 16) {
            Text("Your Travel Stats")
                .font(.title2)
                .bold()
            
            HStack(spacing: 30) {
                StatView(title: "Countries", value: "\(viewModel.totalCountries)")
                StatView(title: "Last Visit", value: viewModel.lastVisit?.formatted(date: .abbreviated, time: .omitted) ?? "Never")
                StatView(title: "Top Region", value: viewModel.mostVisitedRegion ?? "None")
            }
        }
        .padding()
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
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