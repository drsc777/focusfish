import Foundation
// Removed duplicate FishRarity definition, using the one from Enums.swift
// Using FishRarity from Enums.swift

public final class Fish: Identifiable, Codable, Hashable {
    public var id: UUID
    public var rarity: FishRarity
    public var catchDate: Date
    public var focusMinutes: Int
    public var icon: String
    
    // Fish icons organized by rarity
    public static let fishIcons: [[String]] = [
        // Common fish
        ["bubbly", "minno", "swoop"],
        // Rare fish
        ["stripes", "speck", "glint"],
        // Epic fish
        ["shadowfin", "blazetail", "moonshark"]
    ]
    
    public init(rarity: FishRarity, focusMinutes: Int) {
        self.id = UUID()
        self.rarity = rarity
        self.catchDate = Date()
        self.focusMinutes = focusMinutes
        
        // Select a random fish icon based on rarity
        let iconIndex = rarity.iconArrayIndex
        let availableIcons = Fish.fishIcons[iconIndex]
        self.icon = availableIcons[Int.random(in: 0..<availableIcons.count)]
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id
        case rarity
        case catchDate
        case focusMinutes
        case icon
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        rarity = try container.decode(FishRarity.self, forKey: .rarity)
        catchDate = try container.decode(Date.self, forKey: .catchDate)
        focusMinutes = try container.decode(Int.self, forKey: .focusMinutes)
        icon = try container.decode(String.self, forKey: .icon)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(rarity, forKey: .rarity)
        try container.encode(catchDate, forKey: .catchDate)
        try container.encode(focusMinutes, forKey: .focusMinutes)
        try container.encode(icon, forKey: .icon)
    }
    
    public static func catchNewFish(focusMinutes: Int) -> Fish {
        let rarity = FishRarity.getRandomFish(focusMinutes: focusMinutes)
        return Fish(rarity: rarity, focusMinutes: focusMinutes)
    }
    
    // MARK: - Hashable
    public static func == (lhs: Fish, rhs: Fish) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
} 