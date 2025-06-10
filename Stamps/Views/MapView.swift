import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let visitedCountries: [Country]
    @EnvironmentObject var viewModel: CountriesViewModel
    @EnvironmentObject var polygonManager: CountryPolygonManager
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
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
            }
        }
        
        // Add pins for visited cities
        let cityAnnotations = viewModel.visitedCities.compactMap { visitedCity -> CityAnnotation? in
            guard let cityData = visitedCity.cityData else { return nil }
            return CityAnnotation(
                coordinate: cityData.coordinates.clCoordinate,
                title: cityData.name,
                subtitle: cityData.region ?? ""
            )
        }
        mapView.addAnnotations(cityAnnotations)
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
                renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.3)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is CityAnnotation else { return nil }
            
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
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
} 