import Foundation
import SwiftUI

// MARK: - Pet Model
public struct Pet: Codable {
    public var type: PetType?
    public var level: Int
    public var experience: Int
    public var fedFish: [FishRarity: Int]
    
    public init(type: PetType? = nil, level: Int = 1, experience: Int = 0, fedFish: [FishRarity: Int] = [:]) {
        self.type = type
        self.level = level
        self.experience = experience
        self.fedFish = fedFish
    }
    
    // MARK: - Experience Management
    private mutating func addExperience(_ amount: Int) {
        experience += amount
        checkLevelUp()
    }
    
    private mutating func checkLevelUp() {
        while experience >= 100 {
            level += 1
            experience -= 100
        }
    }
    
    // MARK: - Pet Actions
    public mutating func setPetType(_ type: PetType) {
        self.type = type
        save()
    }
    
    public mutating func feedFish(_ fish: Fish) {
        fedFish[fish.rarity, default: 0] += 1
        addExperience(fish.rarity.experienceValue)
        save()
    }
    
    // MARK: - Pet Status
    public var levelProgress: Double {
        Double(experience) / 100.0
    }
    
    public var statusDescription: String {
        guard let type = type else {
            return "Choose a pet to start your journey"
        }
        
        let mood = level > 5 ? "happy" : "content"
        return "Your \(type.displayName) is \(mood) and at level \(level)"
    }
}

// MARK: - Pet Storage
public extension Pet {
    static func load() -> Pet {
        if let data = UserDefaults.standard.data(forKey: "pet"),
           let pet = try? JSONDecoder().decode(Pet.self, from: data) {
            return pet
        }
        return Pet()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "pet")
        }
    }
} 