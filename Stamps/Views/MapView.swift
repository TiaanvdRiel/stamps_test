import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let visitedCountries: [Country]
    @EnvironmentObject var viewModel: CountriesViewModel
    @EnvironmentObject var polygonManager: CountryPolygonManager
    var selectedCountry: Country?
    var selectedCity: VisitedCity?
    @State private var temporaryPolygons: [MKPolygon] = []
    @State private var temporaryCountryName: String?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // Enable points of interest and labels
        mapView.pointOfInterestFilter = .includingAll
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(tapGesture)
        
        // Set initial region to show most of the world
        let initialRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 150, longitudeDelta: 150)
        )
        mapView.setRegion(initialRegion, animated: false)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Remove existing overlays and annotations
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        // Add overlays for visited countries
        for country in visitedCountries {
            let polygons = polygonManager.polygonsForCountry(country.name)
            if !polygons.isEmpty {
                mapView.addOverlays(polygons)
                
                // If this is the selected country, center the map on it
                if let selectedCountry = selectedCountry, country.code == selectedCountry.code {
                    let boundingMapRect = polygons.reduce(MKMapRect.null) { rect, overlay in
                        rect.union(overlay.boundingMapRect)
                    }
                    
                    // Calculate the offset to position the country in the upper third
                    let verticalOffset = boundingMapRect.size.height * 0.7
                    let offsetRect = MKMapRect(
                        x: boundingMapRect.midX - boundingMapRect.size.width * 0.6,
                        y: boundingMapRect.midY - boundingMapRect.size.height * 0.6 + verticalOffset,
                        width: boundingMapRect.size.width * 1.2,
                        height: boundingMapRect.size.height * 1.2
                    )
                    
                    mapView.setVisibleMapRect(offsetRect, animated: true)
                }
            }
        }
        
        // Add temporary overlays for unvisited selected country
        if !temporaryPolygons.isEmpty {
            mapView.addOverlays(temporaryPolygons)
        }
        
        // Add pins for visited cities
        let cityAnnotations = viewModel.visitedCities.compactMap { visitedCity -> CityAnnotation? in
            guard let cityData = visitedCity.cityData else { return nil }
            let annotation = CityAnnotation(
                coordinate: cityData.coordinates.clCoordinate,
                title: cityData.name,
                subtitle: cityData.region ?? "",
                visitedCity: visitedCity
            )
            
            // If this is the selected city, select and center on it
            if let selectedCity = selectedCity, selectedCity.id == visitedCity.id {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    mapView.selectAnnotation(annotation, animated: true)
                    
                    // Calculate region that positions the city in the upper third
                    let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    let centerLatitude = annotation.coordinate.latitude - span.latitudeDelta * 0.3
                    let region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: centerLatitude,
                            longitude: annotation.coordinate.longitude
                        ),
                        span: span
                    )
                    mapView.setRegion(region, animated: true)
                }
            }
            
            return annotation
        }
        mapView.addAnnotations(cityAnnotations)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: MapView
        private let impactLight = UIImpactFeedbackGenerator(style: .light)
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            let point = gesture.location(in: mapView)
            
            // Convert tap point to map coordinate
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            // Search for tapped location
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                guard let self = self else { return }
                if let placemark = placemarks?.first, let countryName = placemark.country {
                    self.impactLight.impactOccurred()
                    
                    DispatchQueue.main.async {
                        // Get country polygons
                        let polygons = self.parent.polygonManager.polygonsForCountry(countryName)
                        if !polygons.isEmpty {
                            // Check if the country is already visited
                            if let visitedCountry = self.parent.visitedCountries.first(where: { $0.name == countryName }) {
                                // For visited countries, update the selection in the view model
                                withAnimation {
                                    self.parent.temporaryPolygons = []
                                    self.parent.temporaryCountryName = nil
                                    self.parent.viewModel.selectedCountry = visitedCountry
                                }
                            } else {
                                // For unvisited countries, show white highlight
                                self.parent.temporaryPolygons = polygons
                                self.parent.temporaryCountryName = countryName
                            }
                            
                            // Center the map on the country
                            let boundingMapRect = polygons.reduce(MKMapRect.null) { rect, overlay in
                                rect.union(overlay.boundingMapRect)
                            }
                            
                            let verticalOffset = boundingMapRect.size.height * 0.7
                            let offsetRect = MKMapRect(
                                x: boundingMapRect.midX - boundingMapRect.size.width * 0.6,
                                y: boundingMapRect.midY - boundingMapRect.size.height * 0.6 + verticalOffset,
                                width: boundingMapRect.size.width * 1.2,
                                height: boundingMapRect.size.height * 1.2
                            )
                            
                            mapView.setVisibleMapRect(offsetRect, animated: true)
                        }
                    }
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                
                // Check if this is a temporary polygon (unvisited selected country)
                if parent.temporaryPolygons.contains(where: { $0 === polygon }) {
                    renderer.fillColor = UIColor.white.withAlphaComponent(0.15)
                    renderer.strokeColor = UIColor.white
                    renderer.lineWidth = 2
                    return renderer
                }
                
                // Regular visited country polygon
                renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.3)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 2
                
                // If this is a selected visited country, use dotted line
                if let selectedCountry = parent.selectedCountry {
                    let polygons = parent.polygonManager.polygonsForCountry(selectedCountry.name)
                    if polygons.contains(where: { $0 === polygon }) {
                        renderer.lineDashPattern = [4, 4]
                    }
                }
                
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let cityAnnotation = annotation as? CityAnnotation else { return nil }
            
            let identifier = "CityPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            if let markerView = annotationView as? MKMarkerAnnotationView {
                markerView.markerTintColor = .systemRed
                markerView.glyphImage = UIImage(systemName: "building.2.fill")
            }
            
            return annotationView
        }
    }
}

class CityAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let visitedCity: VisitedCity
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, visitedCity: VisitedCity) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.visitedCity = visitedCity
        super.init()
    }
} 
