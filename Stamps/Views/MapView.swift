import SwiftUI
import MapKit

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
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = country.name
            request.region = mapView.region
            
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                guard let response = response else { return }
                
                for item in response.mapItems {
                    if let countryName = item.placemark.country,
                       countryName.lowercased() == country.name.lowercased() {
                        if let coordinate = item.placemark.location?.coordinate {
                            let overlay = MKCircle(center: coordinate, radius: 100000)
                            mapView.addOverlay(overlay)
                        }
                    }
                }
            }
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
            if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.3)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
} 