import SwiftUI
import MapKit

/// Represents the possible vertical positions of the bottom sheet
enum SheetPosition {
    case collapsed
    case middle
    case expanded
}

/// A customizable bottom sheet view that supports drag interactions and snapping
/// Similar to the sheet UI in Apple Maps
struct BottomSheetView<Content: View>: View {
    // MARK: - Properties
    
    /// Binding to control/observe the sheet's position state
    @Binding var position: SheetPosition
    
    /// Maximum height the sheet can expand to
    let maxHeight: CGFloat
    
    /// The content view to display inside the sheet
    let content: Content
    
    /// Tracks the current height of the sheet
    @State private var currentHeight: CGFloat = 0
    
    /// Tracks the current drag offset while gesture is active
    @GestureState private var dragOffset: CGFloat = 0
    
    /// Stores the previous drag value for velocity calculations
    @State private var previousDragValue: DragGesture.Value?
    
    /// Exposes the current offset for external views to respond to
    @Binding var currentOffset: CGFloat
    
    // Haptic feedback generators for tactile response
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - Constants
    
    /// Height of the sheet when collapsed
    private var collapsedHeight: CGFloat { 70 }
    
    /// Height of the sheet in middle position (60% of max)
    private var middleHeight: CGFloat { maxHeight * 0.6 }
    
    /// Maximum expanded height
    private var expandedHeight: CGFloat { maxHeight }
    
    /// Distance threshold for snapping to positions
    private let snapThreshold: CGFloat = 50
    
    /// Velocity threshold for gesture-based position changes
    private let velocityThreshold: CGFloat = 300
    
    // MARK: - Initialization
    
    /// Creates a new bottom sheet view
    /// - Parameters:
    ///   - position: Binding to control the sheet position
    ///   - maxHeight: Maximum height the sheet can expand to
    ///   - currentOffset: Binding to observe the sheet's current offset
    ///   - content: The content view builder
    init(position: Binding<SheetPosition>, maxHeight: CGFloat, currentOffset: Binding<CGFloat> = .constant(0), @ViewBuilder content: () -> Content) {
        self._position = position
        self.maxHeight = maxHeight
        self._currentOffset = currentOffset
        self.content = content()
    }
    
    // MARK: - Body
    
    var body: some View {
        // GeometryReader allows us to work with the parent view's dimensions
        GeometryReader { geometry in
            let maxScreenHeight = geometry.size.height
            let minY = maxScreenHeight - expandedHeight
            let midY = maxScreenHeight - middleHeight
            let collapsedY = maxScreenHeight - collapsedHeight
            
            mainContent(geometry: geometry, minY: minY, midY: midY, collapsedY: collapsedY)
        }
    }
    
    // MARK: - View Components
    
    /// Builds the main content view with proper positioning and gesture handling
    @ViewBuilder
    private func mainContent(geometry: GeometryProxy, minY: CGFloat, midY: CGFloat, collapsedY: CGFloat) -> some View {
        // Calculate the current offset, constrained between min and max values
        let offset = max(minY, min(collapsedY, (currentHeight == 0 ? collapsedY : currentHeight) + dragOffset))
        
        VStack(spacing: 0) {
            // Sheet header with drag handle and close button
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
        // Spring animation for smooth movement
        .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: currentHeight)
        .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: dragOffset)
    }
    
    /// Creates the sheet's background with a frosted glass effect
    private var sheetBackground: some View {
        ZStack {
            // Blur layer for frosted effect
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
            // Overlay layer for proper contrast
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground).opacity(0.3))
        }
    }
    
    // MARK: - Gesture Handling
    
    /// Creates the drag gesture that handles sheet movement
    private func createDragGesture(geometry: GeometryProxy) -> some Gesture {
        let maxScreenHeight = geometry.size.height
        let minY = maxScreenHeight - expandedHeight
        let midY = maxScreenHeight - middleHeight
        let collapsedY = maxScreenHeight - collapsedHeight
        
        return DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .updating($dragOffset) { value, state, _ in
                // Only allow dragging down if we're at the top of the scroll content
                if value.translation.height > 0 {
                    state = value.translation.height
                } else {
                    // Allow dragging up always
                    state = value.translation.height
                }
            }
            .onChanged { value in
                previousDragValue = value
            }
            .onEnded { value in
                handleDragGesture(value: value, geometry: geometry)
            }
    }
    
    /// Handles the end of a drag gesture and determines the final position
    private func handleDragGesture(value: DragGesture.Value, geometry: GeometryProxy) {
        let maxScreenHeight = geometry.size.height
        let minY = maxScreenHeight - expandedHeight
        let midY = maxScreenHeight - middleHeight
        let collapsedY = maxScreenHeight - collapsedHeight
        
        let currentY = (currentHeight == 0 ? collapsedY : currentHeight)
        let targetY = currentY + value.translation.height
        
        // Calculate velocity for momentum-based position changes
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
        
        // Provide haptic feedback for position change
        impactLight.impactOccurred()
        
        // Animate to new position
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
            currentHeight = newHeight
            position = newPosition
        }
    }
    
    /// Sets up the initial state of the sheet
    private func setupInitialState(geometry: GeometryProxy) {
        let maxScreenHeight = geometry.size.height
        let collapsedY = maxScreenHeight - collapsedHeight
        currentHeight = collapsedY
        
        // Prepare haptic feedback generators
        impactMed.prepare()
        impactLight.prepare()
    }
    
    /// Updates the sheet height when position changes externally
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