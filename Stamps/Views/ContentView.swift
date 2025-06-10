import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = CountriesViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        ZStack {
            MapView()
                .environmentObject(viewModel)
                .ignoresSafeArea()
            
            BottomSheetView(viewModel: viewModel, showingAddSheet: $showingAddSheet)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCountryView()
                .environmentObject(viewModel)
        }
    }
}

struct BottomSheetView: View {
    @ObservedObject var viewModel: CountriesViewModel
    @Binding var showingAddSheet: Bool
    @State private var currentHeight: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    // Haptic feedback generators
    private let impactMed = UIImpactFeedbackGenerator(style: .medium)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    // Constants
    private let totalCountries = 195 // Standard count of sovereign states
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
                // Add Button
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
                
                // Bottom Sheet
                VStack(spacing: 0) {
                    // Handle and Close Button Row
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 40, height: 5)
                        Spacer()
                        Button(action: {
                            impactLight.impactOccurred()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                currentHeight = collapsedY
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 5)
                    
                    // Content
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("My Passport")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            // Progress Circle
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
                                        Text("\(viewModel.totalCountries)")
                                            .font(.system(size: 32, weight: .bold))
                                        Text("of \(totalCountries)")
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
                            
                            if viewModel.visitedCountries.isEmpty {
                                Spacer()
                                Text("No destinations added")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 40)
                                Spacer()
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(viewModel.visitedCountries) { country in
                                        CountryRow(country: country)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                impactLight.impactOccurred()
                                            }
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
            )
            .onAppear {
                // Start collapsed
                let maxHeight = geometry.size.height
                let collapsedY = maxHeight - collapsedHeight
                currentHeight = collapsedY
                
                // Prepare haptic engines
                impactMed.prepare()
                impactLight.prepare()
            }
            .ignoresSafeArea(edges: .bottom)
        }
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
