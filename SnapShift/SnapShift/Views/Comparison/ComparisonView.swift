import SwiftUI

struct ComparisonView: View {
    let beforePhoto: ProgressPhoto
    let afterPhoto: ProgressPhoto
    @StateObject private var viewModel = ComparisonViewModel()
    @State private var sliderPosition: CGFloat = 0.5
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                modePicker

                TabView(selection: $viewModel.comparisonMode) {
                    sliderComparison
                        .tag(ComparisonViewModel.ComparisonMode.slider)

                    sideBySideComparison
                        .tag(ComparisonViewModel.ComparisonMode.sideBySide)

                    overlayComparison
                        .tag(ComparisonViewModel.ComparisonMode.overlay)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                metricsBar
            }
            .navigationTitle("Compare")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                viewModel.beforePhoto = beforePhoto
                viewModel.afterPhoto = afterPhoto
            }
        }
    }

    private var modePicker: some View {
        Picker("Mode", selection: $viewModel.comparisonMode) {
            ForEach(ComparisonViewModel.ComparisonMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var sliderComparison: some View {
        GeometryReader { geo in
            ZStack {
                if let afterImg = viewModel.afterImage {
                    Image(uiImage: afterImg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }

                if let beforeImg = viewModel.beforeImage {
                    Image(uiImage: beforeImg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width * sliderPosition, height: geo.size.height)
                        .clipped()
                }

                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2)
                    .position(x: geo.size.width * sliderPosition, y: geo.size.height / 2)

                Circle()
                    .fill(Color.white)
                    .frame(width: 32, height: 32)
                    .shadow(radius: 4)
                    .overlay {
                        HStack(spacing: 2) {
                            Image(systemName: "chevron.left")
                                .font(.caption2)
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                        }
                    }
                    .position(x: geo.size.width * sliderPosition, y: geo.size.height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                sliderPosition = min(max(value.location.x / geo.size.width, 0.05), 0.95)
                            }
                    )
            }
        }
    }

    private var sideBySideComparison: some View {
        HStack(spacing: 2) {
            if let beforeImg = viewModel.beforeImage {
                Image(uiImage: beforeImg)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped()
            }

            if let afterImg = viewModel.afterImage {
                Image(uiImage: afterImg)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
        }
    }

    private var overlayComparison: some View {
        ZStack {
            if let afterImg = viewModel.afterImage {
                Image(uiImage: afterImg)
                    .resizable()
                    .scaledToFill()
            }
            if let beforeImg = viewModel.beforeImage {
                Image(uiImage: beforeImg)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.5)
            }
        }
        .clipped()
    }

    private var metricsBar: some View {
        HStack(spacing: 16) {
            if let weightDiff = viewModel.weightDifference {
                DifferenceBadge(change: weightDiff, unit: "lbs", isPositiveGood: true)
            }
            if let bfDiff = viewModel.bodyFatDifference {
                DifferenceBadge(change: bfDiff, unit: "% BF", isPositiveGood: true)
            }
            if let days = viewModel.daysBetween {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text("\(days) days")
                }
                .font(.caption)
                .fontWeight(.bold)
                .padding(6)
                .background(Color.black.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
    }
}
