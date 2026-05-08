import Foundation

enum PhotoAngle: String, Codable, CaseIterable {
    case front
    case back
    case side
    case custom

    var displayName: String {
        switch self {
        case .front: return "Front"
        case .back: return "Back"
        case .side: return "Side"
        case .custom: return "Custom"
        }
    }

    var iconName: String {
        switch self {
        case .front: return "person.fill"
        case .back: return "person.fill.turn.down"
        case .side: return "person.fill.turn.right"
        case .custom: return "person.fill.badge.plus"
        }
    }
}
