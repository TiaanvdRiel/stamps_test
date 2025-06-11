import SwiftUI

// MARK: - Add Button Component
internal struct AddButton: View {
    @Binding var showingAddSheet: Bool
    let impactMed: UIImpactFeedbackGenerator
    
    var body: some View {
        Button(action: {
            impactMed.impactOccurred()
            showingAddSheet = true
        }) {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.accentColor)
                .clipShape(Circle())
                .shadow(radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Sheet Header Component
internal struct SheetHeaderView: View {
    let impactLight: UIImpactFeedbackGenerator
    let onCloseButtonTap: () -> Void
    let showCloseButton: Bool
    
    var body: some View {
        ZStack {
            // Center pull handle
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .offset(y: -5)
            
            // Right-aligned close button
            if showCloseButton {
                HStack {
                    Spacer()
                    Button(action: {
                        impactLight.impactOccurred()
                        onCloseButtonTap()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 25))
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 10)
                }
            }
        }
        .frame(height: 30)
        .padding(.vertical, 6)
    }
}

// MARK: - Progress Circle Component
internal struct ProgressCircleView: View {
    let progress: Double
    let totalCountries: Int
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 12)
                    .opacity(0.3)
                    .foregroundColor(.blue)
                
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.easeInOut(duration: 1.0), value: progress)
                
                VStack {
                    Text("\(totalCountries)")
                        .font(.system(size: 32, weight: .bold))
                    Text("of 195")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 120, height: 120)
            .padding(.vertical)
            
            Text("Countries Visited")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Empty State Component
internal struct EmptyStateView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("No destinations added")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 40)
            Spacer()
        }
    }
} 