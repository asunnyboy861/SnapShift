import SwiftUI

struct MetricBadge: View {
    let label: String
    let date: Date
    let weight: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(date, style: .date)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
            if let w = weight, w > 0 {
                Text("\(w, specifier: "%.1f") lbs")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(6)
        .background(Color.black.opacity(0.6))
        .cornerRadius(8)
    }
}
