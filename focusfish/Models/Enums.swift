import Foundation

// MARK: - Common Enums
/// Pet type enumeration
public enum PetType: String, Codable, CaseIterable {
    case cat
    case dog
    
    public var displayName: String {
        return self.rawValue.capitalized
    }
    
    public var imageName: String {
        return self.rawValue
    }
}

/// Fish rarity enumeration
public enum FishRarity: String, Codable, CaseIterable, Identifiable {
    case common = "common"
    case rare = "rare"
    case epic = "epic"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .common:
            return "Common Fish"
        case .rare:
            return "Rare Fish"
        case .epic:
            return "Epic Fish"
        }
    }
    
    public var iconArrayIndex: Int {
        switch self {
        case .common:
            return 0  // Common
        case .rare:
            return 1  // Rare
        case .epic:
            return 2  // Epic
        }
    }
    
    public var experienceValue: Int {
        switch self {
        case .common:
            return 5
        case .rare:
            return 20
        case .epic:
            return 30
        }
    }
    
    public static func getRandomFish(focusMinutes: Int) -> FishRarity {
        // The longer the focus time, the higher chance to get rare fish
        let random = Double.random(in: 0...1)
        let bonusChance = min(Double(focusMinutes) / 100.0, 0.5) // Maximum 50% bonus
        
        switch random - bonusChance {
        case ..<0.6:
            return .common
        case ..<0.9:
            return .rare
        default:
            return .epic
        }
    }
} 