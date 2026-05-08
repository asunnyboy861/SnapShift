import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        TabView(selection: $currentPage) {
            onboardingPage(
                icon: "camera.viewfinder",
                title: "Track Your Progress",
                subtitle: "Take photos from the same angle every time with ghost overlay alignment"
            )
            .tag(0)

            onboardingPage(
                icon: "slider.horizontal.3",
                title: "Compare Side by Side",
                subtitle: "Slider, side-by-side, and overlay modes to see your transformation"
            )
            .tag(1)

            onboardingPage(
                icon: "heart.text.square",
                title: "Health Data Integration",
                subtitle: "Sync weight and body fat from HealthKit for complete tracking"
            )
            .tag(2)

            onboardingPage(
                icon: "film",
                title: "Create Timelapses",
                subtitle: "Turn your progress photos into a timelapse video to share"
            )
            .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }

    private func onboardingPage(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(Color.teal)

            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                if currentPage < 3 {
                    withAnimation { currentPage += 1 }
                } else {
                    hasCompletedOnboarding = true
                }
            } label: {
                Text(currentPage < 3 ? "Next" : "Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.teal)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}
