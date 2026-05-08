import SwiftUI

struct DifferenceBadge: View {
    let change: Double
    let unit: String
    let isPositiveGood: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: change <= 0 ? "arrow.down" : "arrow.up")
            Text("\(abs(change), specifier: "%.1f") \(unit)")
        }
        .font(.caption)
        .fontWeight(.bold)
        .foregroundColor((change <= 0) == isPositiveGood ? .green : .red)
        .padding(6)
        .background(Color.black.opacity(0.6))
        .cornerRadius(8)
    }
}
