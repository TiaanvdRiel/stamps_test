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
    }
}

// MARK: - Sheet Header Component
internal struct SheetHeaderView: View {
    let impactLight: UIImpactFeedbackGenerator
    let onCloseButtonTap: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
            Spacer()
            Button(action: {
                impactLight.impactOccurred()
                onCloseButtonTap()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            }
            .padding(.trailing)
        }
        .padding(.top, 10)
        .padding(.bottom, 5)
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

// MARK: - Country List Component
internal struct CountryListView: View {
    let viewModel: CountriesViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.visitedCountries) { country in
                CountryRow(country: country)
                    .contentShape(Rectangle())
                    .onTapGesture {}
                if country.id != viewModel.visitedCountries.last?.id {
                    Divider()
                        .padding(.horizontal)
                }
            }
        }
        .padding(.vertical, 8)
    }
} 