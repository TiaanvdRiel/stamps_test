import SwiftUI
import MapKit

internal struct BottomSheetView: View {
    @ObservedObject var viewModel: CountriesViewModel
    @Binding var showingAddSheet: Bool
    @State private var currentHeight: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0
    @State private var previousDragValue: DragGesture.Value?
    
    // Haptic feedback generators
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - Constants
    private let totalCountries = 195
    private var collapsedHeight: CGFloat { 120 }
    private var middleHeight: CGFloat { UIScreen.main.bounds.height * 0.45 }
    private var expandedHeight: CGFloat { UIScreen.main.bounds.height * 0.85 }
    private let snapThreshold: CGFloat = 50
    private let velocityThreshold: CGFloat = 300
    
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
        .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: currentHeight)
        .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: dragOffset)
    }
    
    @ViewBuilder
    private func sheetContent(geometry: GeometryProxy, collapsedY: CGFloat) -> some View {
        VStack(spacing: 0) {
            SheetHeaderView(
                impactLight: impactLight,
                onCloseButtonTap: {
                    withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                        currentHeight = collapsedY
                    }
                }
            )
            
            PassportView()
                .environmentObject(viewModel)
        }
        .background(sheetBackground)
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
        let maxHeight = geometry.size.height
        let minY = maxHeight - expandedHeight
        let midY = maxHeight - middleHeight
        let collapsedY = maxHeight - collapsedHeight
        
        return DragGesture(minimumDistance: 10)
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onChanged { value in
                previousDragValue = value
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
        
        let currentY = (currentHeight == 0 ? collapsedY : currentHeight)
        let targetY = currentY + value.translation.height
        
        // Calculate velocity
        let timeDiff = value.time.timeIntervalSince(previousDragValue?.time ?? value.time)
        let heightDiff = value.location.y - (previousDragValue?.location.y ?? value.location.y)
        let velocity = timeDiff > 0 ? heightDiff / CGFloat(timeDiff) : 0
        
        // Determine target position based on velocity and position
        var newHeight: CGFloat
        
        if abs(velocity) > velocityThreshold {
            // Fast drag - move to next position in drag direction
            if velocity > 0 {
                // Dragging down
                if currentY < midY {
                    newHeight = midY
                } else {
                    newHeight = collapsedY
                }
            } else {
                // Dragging up
                if currentY > midY {
                    newHeight = midY
                } else {
                    newHeight = minY
                }
            }
        } else {
            // Slow drag - snap to nearest position
            let positions = [minY, midY, collapsedY]
            newHeight = positions.min(by: { abs($0 - targetY) < abs($1 - targetY) }) ?? collapsedY
        }
        
        impactLight.impactOccurred()
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
            currentHeight = newHeight
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
