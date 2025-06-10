//
//  ContentView.swift
//  Stamps
//
//  Created by mac on 6/11/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = CountriesViewModel()
    @State private var showingAddSheet = false
    @State private var showingBottomSheet = true
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
                
                if showingBottomSheet {
                    BottomSheetView(viewModel: viewModel)
                        .transition(.move(edge: .bottom))
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCountryView(viewModel: viewModel)
        }
    }
}

struct BottomSheetView: View {
    @ObservedObject var viewModel: CountriesViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Your Travel Stats")
                    .font(.title2)
                    .bold()
                
                HStack(spacing: 30) {
                    StatView(title: "Countries", value: "\(viewModel.totalCountries)")
                    if let lastVisit = viewModel.lastVisit {
                        StatView(title: "Last Visit", value: lastVisit.formatted(date: .abbreviated, time: .omitted))
                    }
                    if let region = viewModel.mostVisitedRegion {
                        StatView(title: "Top Region", value: region)
                    }
                }
                
                if !viewModel.visitedCountries.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.visitedCountries) { country in
                                CountryCard(country: country)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
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

struct CountryCard: View {
    let country: Country
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(country.name)
                .font(.headline)
            Text(country.visitDate.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

#Preview {
    ContentView()
}
