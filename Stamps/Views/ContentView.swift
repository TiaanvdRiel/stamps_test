import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = CountriesViewModel()
    @State private var showingAddSheet = false
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
                
                // Bottom Sheet with Add Button
                BottomSheetView(viewModel: viewModel, showingAddSheet: $showingAddSheet)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCountryView(viewModel: viewModel)
        }
    }
}

struct BottomSheetView: View {
    @ObservedObject var viewModel: CountriesViewModel
    @Binding var showingAddSheet: Bool
    @State private var translation: CGFloat = 0
    @State private var offset: CGFloat = 0  // Start at 0 (collapsed)
    @State private var isDragging = false
    
    // Snap points matching Apple Maps
    private let collapsedHeight: CGFloat = 100
    private let halfHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    private let fullHeight: CGFloat = UIScreen.main.bounds.height * 0.9
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                // Add Button
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .offset(y: -70)
                
                // Bottom Sheet
                VStack(spacing: 0) {
                    // Handle
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 40, height: 5)
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        // Stats Row
                        HStack(spacing: 30) {
                            StatView(title: "Countries", value: "\(viewModel.totalCountries)")
                            if let lastVisit = viewModel.lastVisit {
                                StatView(title: "Last Visit", value: lastVisit.formatted(date: .abbreviated, time: .omitted))
                            }
                            if let region = viewModel.mostVisitedRegion {
                                StatView(title: "Top Region", value: region)
                            }
                        }
                        .padding(.horizontal)
                        
                        if !viewModel.visitedCountries.isEmpty {
                            // Countries List
                            List {
                                ForEach(viewModel.visitedCountries) { country in
                                    CountryRow(country: country)
                                }
                            }
                            .listStyle(PlainListStyle())
                        }
                    }
                    .padding(.bottom)
                }
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                        
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.systemBackground).opacity(0.8))
                    }
                )
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .offset(y: max(-fullHeight, min(0, offset + translation)))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        // Allow dragging in both directions
                        translation = value.translation.height
                    }
                    .onEnded { value in
                        isDragging = false
                        let velocity = value.predictedEndLocation.y - value.location.y
                        let shouldSnap = abs(velocity) > 100
                        
                        let currentOffset = offset + translation
                        
                        if shouldSnap {
                            if velocity > 0 {
                                // Moving down - snap to closest lower point
                                if currentOffset > -halfHeight {
                                    offset = 0
                                } else {
                                    offset = -halfHeight
                                }
                            } else {
                                // Moving up - snap to closest higher point
                                if currentOffset < -halfHeight {
                                    offset = -fullHeight
                                } else {
                                    offset = -halfHeight
                                }
                            }
                        } else {
                            // Find closest snap point
                            let snapPoints = [0, -halfHeight, -fullHeight]
                            let closest = snapPoints.min(by: { abs($0 - currentOffset) < abs($1 - currentOffset) }) ?? 0
                            offset = closest
                        }
                        
                        translation = 0
                    }
            )
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: isDragging)
        }
        .ignoresSafeArea(edges: .bottom)
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

struct CountryRow: View {
    let country: Country
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(country.name)
                    .font(.headline)
                Text(country.visitDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
