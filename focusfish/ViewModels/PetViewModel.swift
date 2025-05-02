import Foundation
import Combine
import SwiftUI

@MainActor
class PetViewModel: ObservableObject {
    // 每个宠物类型的数据结构
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
    
    // Fish tracking - 鱼类收集是共享的
    @Published private var collectedFish: [Fish] = [] // 玩家收集的鱼
    
    init() {
        // 加载已保存的宠物类型
        if let petTypeString = UserDefaults.standard.string(forKey: "selected_pet_type"),
           let petType = PetType(rawValue: petTypeString) {
            self.selectedPetType = petType
        }
        
        // 加载所有宠物数据
        loadPetsData()
        
        // 加载鱼类收集数据
        loadFishData()
    }
    
    // 获取当前选中宠物的数据
    private var currentPet: PetData? {
        guard let petType = selectedPetType else { return nil }
        return petsData[petType]
    }
    
    // 修改当前宠物数据的方法
    private func updateCurrentPet(_ update: (inout PetData) -> Void) {
        guard let petType = selectedPetType else { return }
        var petData = petsData[petType] ?? PetData(name: petType == .cat ? "Cat" : "Dog")
        update(&petData)
        petsData[petType] = petData
        saveData()
    }
    
    // 为当前宠物添加经验值
    func addExperience(_ amount: Int) async {
        updateCurrentPet { petData in
            petData.experience += amount
            // 简单的升级机制：每100点经验升一级
            petData.level = (petData.experience / 100) + 1
        }
    }
    
    // 更新宠物名称
    func updatePetName() {
        guard let petType = selectedPetType else { return }
        updateCurrentPet { petData in
            petData.name = petType == .cat ? "Cat" : "Dog"
        }
    }
    
    private func saveData() {
        // 保存选中的宠物类型
        if let petType = selectedPetType {
            UserDefaults.standard.set(petType.rawValue, forKey: "selected_pet_type")
        }
        
        // 保存所有宠物数据
        for (petType, petData) in petsData {
            if let encodedData = try? JSONEncoder().encode(petData) {
                UserDefaults.standard.set(encodedData, forKey: "pet_data_\(petType.rawValue)")
            }
        }
        
        // 保存鱼类收集数据
        if let encodedCollectedFish = try? JSONEncoder().encode(collectedFish) {
            UserDefaults.standard.set(encodedCollectedFish, forKey: "collected_fish")
        }
    }
    
    private func loadPetsData() {
        // 加载每种宠物的数据
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
    
    // 当前宠物的等级
    public var petLevel: Int {
        return currentPet?.level ?? 1
    }
    
    // 当前宠物的当前等级的经验值
    public var currentExp: Int {
        return (currentPet?.experience ?? 0) % 100
    }
    
    // 升级所需经验值
    public var expToNextLevel: Int { 100 }
    
    // MARK: - Public Methods
    
    // 添加鱼到收集
    public func addFishToCollection(_ fish: Fish) {
        collectedFish.append(fish)
        saveData()
    }
    
    // 喂鱼给宠物
    public func feedFish(_ fish: Fish) {
        guard selectedPetType != nil else { return }
        
        // 查找玩家收集中是否有这种鱼
        if let index = findFishInCollection(fish) {
            // 从收集中移除这条鱼
            let removedFish = collectedFish.remove(at: index)
            
            // 添加经验值并记录喂食
            Task {
                await addExperience(fish.rarity.experienceValue)
                
                // 添加到当前宠物的喂食记录
                updateCurrentPet { petData in
                    petData.fedFish.append(removedFish)
                }
            }
        } else {
            // 直接从FishCaughtView喂鱼的情况 - 不减少收集数量，因为这是新钓到的鱼
            Task {
                await addExperience(fish.rarity.experienceValue)
                
                // 添加到当前宠物的喂食记录
                updateCurrentPet { petData in
                    petData.fedFish.append(fish)
                }
            }
        }
    }
    
    // 查找鱼在收集中的索引
    private func findFishInCollection(_ fish: Fish) -> Int? {
        return collectedFish.firstIndex(where: { $0.icon == fish.icon && $0.rarity == fish.rarity })
    }
    
    // 获取当前宠物喂食的特定稀有度鱼的数量
    public func getFedFishCount(rarity: FishRarity) -> Int {
        return currentPet?.fedFish.filter { $0.rarity == rarity }.count ?? 0
    }
    
    // 获取特定稀有度收集的鱼的数量
    public func getCollectedFishCount(rarity: FishRarity) -> Int {
        return collectedFish.filter { $0.rarity == rarity }.count
    }
    
    // 获取当前宠物喂食的总鱼数
    public func getTotalFedFish() -> Int {
        return currentPet?.fedFish.count ?? 0
    }
    
    // 获取收集的总鱼数
    public func getTotalCollectedFish() -> Int {
        return collectedFish.count
    }
    
    // 按鱼的图标名称获取收集数量
    public func getFishCountByIconName(iconName: String) -> Int {
        return collectedFish.filter { $0.icon == iconName }.count
    }
    
    // 获取当前宠物的状态描述
    public func getStatusDescription() -> String {
        guard let petType = selectedPetType else {
            return "没有选择宠物。"
        }
        
        let type = petType == .cat ? "猫" : "狗"
        let level = petLevel
        
        if level <= 3 {
            return "你的\(type)还很年轻，需要更多鱼！"
        } else if level <= 7 {
            return "你的\(type)因为那些美味的鱼而变得强壮！"
        } else {
            return "你的\(type)过得很好，喜欢你提供的各种鱼！"
        }
    }
} 