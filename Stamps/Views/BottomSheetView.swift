import SwiftUI
import MapKit

internal struct BottomSheetView: View {
    @ObservedObject var viewModel: CountriesViewModel
    @Binding var showingAddSheet: Bool
    @State private var currentHeight: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    // Haptic feedback generators
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - Constants
    private let totalCountries = 195
    private var collapsedHeight: CGFloat { 120 }
    private var middleHeight: CGFloat { UIScreen.main.bounds.height * 0.45 }
    private var expandedHeight: CGFloat { UIScreen.main.bounds.height * 0.85 }
    
    private var progress: Double {
        Double(viewModel.totalCountries) / Double(totalCountries)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let maxHeight = geometry.size.height
            let minY = maxHeight - expandedHeight
            let midY = maxHeight - middleHeight
            let collapsedY = maxHeight - collapsedHeight
            
            mainContent(geometry: geometry, minY: minY, midY: midY, collapsedY: collapsedY)
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private func mainContent(geometry: GeometryProxy, minY: CGFloat, midY: CGFloat, collapsedY: CGFloat) -> some View {
        ZStack(alignment: .topTrailing) {
            AddButton(showingAddSheet: $showingAddSheet, impactMed: impactMed)
            sheetContent(geometry: geometry, collapsedY: collapsedY)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .offset(y: max(minY, min(collapsedY, (currentHeight == 0 ? collapsedY : currentHeight) + dragOffset)))
        .gesture(createDragGesture(geometry: geometry))
        .onAppear { setupInitialState(geometry: geometry) }
        .ignoresSafeArea(edges: .bottom)
    }
    
    @ViewBuilder
    private func sheetContent(geometry: GeometryProxy, collapsedY: CGFloat) -> some View {
        VStack(spacing: 0) {
            SheetHeaderView(
                impactLight: impactLight,
                onCloseButtonTap: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        currentHeight = collapsedY
                    }
                }
            )
            
            ScrollView(showsIndicators: false) {
                sheetScrollContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: expandedHeight, alignment: .top)
        .background(sheetBackground)
    }
    
    private var sheetScrollContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("My Passport")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                ProgressCircleView(
                    progress: progress,
                    totalCountries: viewModel.totalCountries
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    StatView(
                        title: "Total Cities",
                        value: "\(viewModel.totalVisitedCities)",
                        icon: "building.2.fill"
                    )
                    
                    if let lastVisit = viewModel.lastVisit {
                        StatView(
                            title: "Last Visit",
                            value: lastVisit.formatted(date: .abbreviated, time: .omitted),
                            icon: "calendar"
                        )
                    }
                    
                    if let mostVisited = viewModel.mostVisitedCountry {
                        StatView(
                            title: "Most Visited",
                            value: "\(mostVisited.name) (\(viewModel.citiesPerCountry[mostVisited.code] ?? 0))",
                            icon: "star.fill"
                        )
                    }
                }
            }
            .padding(.horizontal)
            
            if viewModel.visitedCountries.isEmpty {
                EmptyStateView()
            } else {
                CountryListView()
                    .environmentObject(viewModel)
            }
        }
    }
    
    private var sheetBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground).opacity(0.8))
        }
    }
    
    // MARK: - Gesture Handling
    private func createDragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                handleDragGesture(value: value, geometry: geometry)
            }
    }
    
    private func handleDragGesture(value: DragGesture.Value, geometry: GeometryProxy) {
        let maxHeight = geometry.size.height
        let minY = maxHeight - expandedHeight
        let midY = maxHeight - middleHeight
        let collapsedY = maxHeight - collapsedHeight
        
        let newY = (currentHeight == 0 ? collapsedY : currentHeight) + value.translation.height
        let positions = [collapsedY, midY, minY]
        let closest = positions.min(by: { abs($0 - newY) < abs($1 - newY) }) ?? collapsedY
        
        impactLight.impactOccurred()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            currentHeight = closest
        }
    }
    
    private func setupInitialState(geometry: GeometryProxy) {
        let maxHeight = geometry.size.height
        let collapsedY = maxHeight - collapsedHeight
        currentHeight = collapsedY
        
        impactMed.prepare()
        impactLight.prepare()
    }
}

private struct StatView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }
}
