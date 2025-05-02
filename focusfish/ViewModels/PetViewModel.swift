import Foundation
import Combine
import SwiftUI

@MainActor
class PetViewModel: ObservableObject {
    // Data structure for each pet type
    struct PetData: Codable {
        var name: String
        var level: Int
        var experience: Int
        var fedFish: [Fish]
        
        init(name: String, level: Int = 1, experience: Int = 0, fedFish: [Fish] = []) {
            self.name = name
            self.level = level
            self.experience = experience
            self.fedFish = fedFish
        }
    }
    
    // Local storage for each pet type
    @Published private var petsData: [PetType: PetData] = [
        .cat: PetData(name: "Cat"),
        .dog: PetData(name: "Dog")
    ]
    
    @Published var selectedPetType: PetType?
    
    // Fish tracking - shared across all pets
    @Published private var collectedFish: [Fish] = [] // Player's collected fish
    
    init() {
        // Load saved pet type
        if let petTypeString = UserDefaults.standard.string(forKey: "selected_pet_type"),
           let petType = PetType(rawValue: petTypeString) {
            self.selectedPetType = petType
        }
        
        // Load all pet data
        loadPetsData()
        
        // Load fish collection data
        loadFishData()
    }
    
    // Get current selected pet data
    private var currentPet: PetData? {
        guard let petType = selectedPetType else { return nil }
        return petsData[petType]
    }
    
    // Method to modify current pet data
    private func updateCurrentPet(_ update: (inout PetData) -> Void) {
        guard let petType = selectedPetType else { return }
        var petData = petsData[petType] ?? PetData(name: petType == .cat ? "Cat" : "Dog")
        update(&petData)
        petsData[petType] = petData
        saveData()
    }
    
    // Add experience to current pet
    func addExperience(_ amount: Int) async {
        updateCurrentPet { petData in
            petData.experience += amount
            // Simple leveling mechanism: level up every 100 experience points
            petData.level = (petData.experience / 100) + 1
        }
    }
    
    // Update pet name
    func updatePetName() {
        guard let petType = selectedPetType else { return }
        updateCurrentPet { petData in
            petData.name = petType == .cat ? "Cat" : "Dog"
        }
    }
    
    private func saveData() {
        // Save selected pet type
        if let petType = selectedPetType {
            UserDefaults.standard.set(petType.rawValue, forKey: "selected_pet_type")
        }
        
        // Save all pet data
        for (petType, petData) in petsData {
            if let encodedData = try? JSONEncoder().encode(petData) {
                UserDefaults.standard.set(encodedData, forKey: "pet_data_\(petType.rawValue)")
            }
        }
        
        // Save fish collection data
        if let encodedCollectedFish = try? JSONEncoder().encode(collectedFish) {
            UserDefaults.standard.set(encodedCollectedFish, forKey: "collected_fish")
        }
    }
    
    private func loadPetsData() {
        // Load data for each pet type
        for petType in PetType.allCases {
            if let savedData = UserDefaults.standard.data(forKey: "pet_data_\(petType.rawValue)"),
               let decodedData = try? JSONDecoder().decode(PetData.self, from: savedData) {
                petsData[petType] = decodedData
            }
        }
    }
    
    private func loadFishData() {
        if let savedData = UserDefaults.standard.data(forKey: "collected_fish"),
           let decodedFish = try? JSONDecoder().decode([Fish].self, from: savedData) {
            self.collectedFish = decodedFish
        }
    }
    
    // MARK: - Computed Properties
    
    // Current pet level
    public var petLevel: Int {
        return currentPet?.level ?? 1
    }
    
    // Current pet experience for current level
    public var currentExp: Int {
        return (currentPet?.experience ?? 0) % 100
    }
    
    // Experience needed to level up
    public var expToNextLevel: Int { 100 }
    
    // MARK: - Public Methods
    
    // Add fish to collection
    public func addFishToCollection(_ fish: Fish) {
        collectedFish.append(fish)
        saveData()
    }
    
    // Feed fish to pet
    public func feedFish(_ fish: Fish) {
        guard selectedPetType != nil else { return }
        
        // Find if player's collection has this fish
        if let index = findFishInCollection(fish) {
            // Remove this fish from collection
            let removedFish = collectedFish.remove(at: index)
            
            // Add experience and record feeding
            Task {
                await addExperience(fish.rarity.experienceValue)
                
                // Add to current pet's feeding record
                updateCurrentPet { petData in
                    petData.fedFish.append(removedFish)
                }
            }
        } else {
            // Direct feeding from FishCaughtView - no reduction in collection, as this is new fish
            Task {
                await addExperience(fish.rarity.experienceValue)
                
                // Add to current pet's feeding record
                updateCurrentPet { petData in
                    petData.fedFish.append(fish)
                }
            }
        }
    }
    
    // Find fish in collection
    private func findFishInCollection(_ fish: Fish) -> Int? {
        return collectedFish.firstIndex(where: { $0.icon == fish.icon && $0.rarity == fish.rarity })
    }
    
    // Get count of specific rarity fish fed to current pet
    public func getFedFishCount(rarity: FishRarity) -> Int {
        return currentPet?.fedFish.filter { $0.rarity == rarity }.count ?? 0
    }
    
    // Get count of specific rarity fish in collection
    public func getCollectedFishCount(rarity: FishRarity) -> Int {
        return collectedFish.filter { $0.rarity == rarity }.count
    }
    
    // Get total count of fish fed to current pet
    public func getTotalFedFish() -> Int {
        return currentPet?.fedFish.count ?? 0
    }
    
    // Get total count of fish in collection
    public func getTotalCollectedFish() -> Int {
        return collectedFish.count
    }
    
    // Get count of collection by fish icon name
    public func getFishCountByIconName(iconName: String) -> Int {
        return collectedFish.filter { $0.icon == iconName }.count
    }
    
    // Get current pet status description
    public func getStatusDescription() -> String {
        guard let petType = selectedPetType else {
            return "No pet selected."
        }
        
        let type = petType == .cat ? "Cat" : "Dog"
        let level = petLevel
        
        if level <= 3 {
            return "Your \(type) is still young and needs more fish!"
        } else if level <= 7 {
            return "Your \(type) is growing stronger thanks to those delicious fish!"
        } else {
            return "Your \(type) is doing great and enjoys the variety of fish you provide!"
        }
    }
} 