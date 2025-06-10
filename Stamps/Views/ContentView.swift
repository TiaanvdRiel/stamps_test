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
    @State private var offset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    @GestureState private var translation: CGFloat = 0
    @State private var isDragging: Bool = false
    
    private let minHeight: CGFloat = 100
    private let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.85
    
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
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                if offset == 0 {
                                    offset = -maxHeight/2
                                } else {
                                    offset = 0
                                }
                            }
                        }
                    
                    // Content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Title
                            Text("My Passport")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            // Stats Row
                            HStack(spacing: 30) {
                                StatView(title: "Countries", value: "\(viewModel.totalCountries)")
                                if let lastVisit = viewModel.lastVisit {
                                    StatView(title: "Last Visit", value: lastVisit.formatted(date: .abbreviated, time: .omitted))
                                }
                            }
                            .padding(.horizontal)
                            
                            if viewModel.visitedCountries.isEmpty {
                                // Empty State
                                Spacer()
                                Text("No destinations added")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 40)
                                Spacer()
                            } else {
                                // Countries List
                                VStack(spacing: 0) {
                                    ForEach(viewModel.visitedCountries) { country in
                                        CountryRow(country: country)
                                        if country.id != viewModel.visitedCountries.last?.id {
                                            Divider()
                                                .padding(.horizontal)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                    }
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { _ in
                                isDragging = true
                            }
                    )
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
            .offset(y: max(-maxHeight, min(0, offset + translation)))
            .gesture(
                DragGesture()
                    .updating($translation) { value, state, _ in
                        if !isDragging {
                            state = value.translation.height
                        }
                    }
                    .onEnded { value in
                        isDragging = false
                        let velocity = value.predictedEndLocation.y - value.location.y
                        let shouldSnap = abs(velocity) > 100
                        
                        let currentOffset = offset + value.translation.height
                        let snapPoints = [0, -maxHeight/2, -maxHeight]
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if shouldSnap {
                                if velocity > 0 {
                                    // Moving down
                                    if currentOffset > -maxHeight/2 {
                                        offset = 0
                                    } else {
                                        offset = -maxHeight/2
                                    }
                                } else {
                                    // Moving up
                                    if currentOffset < -maxHeight/2 {
                                        offset = -maxHeight
                                    } else {
                                        offset = -maxHeight/2
                                    }
                                }
                            } else {
                                // Find closest snap point
                                let closest = snapPoints.min(by: { abs($0 - currentOffset) < abs($1 - currentOffset) }) ?? 0
                                offset = closest
                            }
                        }
                        
                        lastOffset = offset
                    }
            )
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
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
