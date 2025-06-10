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
            
            ZStack(alignment: .topTrailing) {
                AddButton(showingAddSheet: $showingAddSheet, impactMed: impactMed)
                
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
                        VStack(alignment: .leading, spacing: 20) {
                            Text("My Passport")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ProgressCircleView(
                                progress: progress,
                                totalCountries: viewModel.totalCountries
                            )
                            
                            if viewModel.visitedCountries.isEmpty {
                                EmptyStateView()
                            } else {
                                CountryListView(viewModel: viewModel)
                            }
                        }
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: expandedHeight, alignment: .top)
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
            .offset(y: max(minY, min(collapsedY, (currentHeight == 0 ? collapsedY : currentHeight) + dragOffset)))
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        handleDragGesture(value: value, geometry: geometry)
                    }
            )
            .onAppear {
                setupInitialState(geometry: geometry)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    // MARK: - Helper Methods
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
