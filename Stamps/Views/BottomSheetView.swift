import SwiftUI
import MapKit

enum SheetPosition {
    case collapsed
    case middle
    case expanded
}

struct BottomSheetView<Content: View>: View {
    @Binding var position: SheetPosition
    let maxHeight: CGFloat
    let content: Content
    
    @State private var currentHeight: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0
    @State private var previousDragValue: DragGesture.Value?
    
    // Expose current offset for external views
    @Binding var currentOffset: CGFloat
    
    // Haptic feedback generators
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - Constants
    private var collapsedHeight: CGFloat { 70 }
    private var middleHeight: CGFloat { maxHeight * 0.6 }
    private var expandedHeight: CGFloat { maxHeight }
    private let snapThreshold: CGFloat = 50
    private let velocityThreshold: CGFloat = 300
    
    init(position: Binding<SheetPosition>, maxHeight: CGFloat, currentOffset: Binding<CGFloat> = .constant(0), @ViewBuilder content: () -> Content) {
        self._position = position
        self.maxHeight = maxHeight
        self._currentOffset = currentOffset
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            let maxScreenHeight = geometry.size.height
            let minY = maxScreenHeight - expandedHeight
            let midY = maxScreenHeight - middleHeight
            let collapsedY = maxScreenHeight - collapsedHeight
            
            mainContent(geometry: geometry, minY: minY, midY: midY, collapsedY: collapsedY)
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private func mainContent(geometry: GeometryProxy, minY: CGFloat, midY: CGFloat, collapsedY: CGFloat) -> some View {
        let offset = max(minY, min(collapsedY, (currentHeight == 0 ? collapsedY : currentHeight) + dragOffset))
        
        VStack(spacing: 0) {
            SheetHeaderView(
                impactLight: impactLight,
                onCloseButtonTap: {
                    withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                        position = .collapsed
                        currentHeight = collapsedY
                    }
                },
                showCloseButton: position != .collapsed
            )
            
            content
        }
        .background(sheetBackground)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .offset(y: offset)
        .onChange(of: offset) { newOffset in
            currentOffset = newOffset
        }
        .gesture(createDragGesture(geometry: geometry))
        .onAppear { setupInitialState(geometry: geometry) }
        .onChange(of: position) { newPosition in
            updateHeight(for: newPosition, geometry: geometry)
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: currentHeight)
        .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: dragOffset)
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
        let maxScreenHeight = geometry.size.height
        let minY = maxScreenHeight - expandedHeight
        let midY = maxScreenHeight - middleHeight
        let collapsedY = maxScreenHeight - collapsedHeight
        
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
        let maxScreenHeight = geometry.size.height
        let minY = maxScreenHeight - expandedHeight
        let midY = maxScreenHeight - middleHeight
        let collapsedY = maxScreenHeight - collapsedHeight
        
        let currentY = (currentHeight == 0 ? collapsedY : currentHeight)
        let targetY = currentY + value.translation.height
        
        // Calculate velocity
        let timeDiff = value.time.timeIntervalSince(previousDragValue?.time ?? value.time)
        let heightDiff = value.location.y - (previousDragValue?.location.y ?? value.location.y)
        let velocity = timeDiff > 0 ? heightDiff / CGFloat(timeDiff) : 0
        
        // Determine target position based on velocity and position
        var newHeight: CGFloat
        var newPosition: SheetPosition
        
        if abs(velocity) > velocityThreshold {
            // Fast drag - move to next position in drag direction
            if velocity > 0 {
                // Dragging down
                if currentY < midY {
                    newHeight = midY
                    newPosition = .middle
                } else {
                    newHeight = collapsedY
                    newPosition = .collapsed
                }
            } else {
                // Dragging up
                if currentY > midY {
                    newHeight = midY
                    newPosition = .middle
                } else {
                    newHeight = minY
                    newPosition = .expanded
                }
            }
        } else {
            // Slow drag - snap to nearest position
            let positions = [(minY, SheetPosition.expanded), (midY, .middle), (collapsedY, .collapsed)]
            let (height, pos) = positions.min(by: { abs($0.0 - targetY) < abs($1.0 - targetY) }) ?? (collapsedY, .collapsed)
            newHeight = height
            newPosition = pos
        }
        
        impactLight.impactOccurred()
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
            currentHeight = newHeight
            position = newPosition
        }
    }
    
    private func setupInitialState(geometry: GeometryProxy) {
        let maxScreenHeight = geometry.size.height
        let collapsedY = maxScreenHeight - collapsedHeight
        currentHeight = collapsedY
        
        impactMed.prepare()
        impactLight.prepare()
    }
    
    private func updateHeight(for position: SheetPosition, geometry: GeometryProxy) {
        let maxScreenHeight = geometry.size.height
        let minY = maxScreenHeight - expandedHeight
        let midY = maxScreenHeight - middleHeight
        let collapsedY = maxScreenHeight - collapsedHeight
        
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
            switch position {
            case .collapsed:
                currentHeight = collapsedY
            case .middle:
                currentHeight = midY
            case .expanded:
                currentHeight = minY
            }
        }
    }
} 