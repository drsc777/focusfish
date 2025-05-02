import SwiftUI

struct PetStatusView: View {
    @ObservedObject var petViewModel: PetViewModel
    @State private var showPetSelection = false
    @State private var showFeedFishView = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    petDisplayView
                    fishCollectionView
                }
                .padding()
                .frame(minWidth: geometry.size.width)
                .frame(minHeight: geometry.size.height)
            }
        }
        .sheet(isPresented: $showPetSelection) {
            PetSelectionView(petViewModel: petViewModel, isPresented: $showPetSelection)
        }
        .sheet(isPresented: $showFeedFishView) {
            FeedFishView(petViewModel: petViewModel, isPresented: $showFeedFishView)
        }
    }
    
    // Pet display view with horizontal layout
    private var petDisplayView: some View {
        Group {
            if let petType = petViewModel.selectedPetType {
                // Horizontal layout with pet image on left and stats on right
                HStack(alignment: .top, spacing: 20) {
                    // Left side - Pet image
                    Image(petType == .cat ? "cat" : "dog")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding()
                    
                    // Right side - Pet stats and feed button
                    VStack(alignment: .leading, spacing: 12) {
                        // Pet level info and switch button
                        HStack {
                            Text("Level \(petViewModel.petLevel)")
                                .font(.custom("Menlo", size: 20))
                                .bold()
                            
                            Spacer()
                            
                            // 添加切换宠物类型按钮
                            Button(action: {
                                // 切换猫/狗
                                petViewModel.selectedPetType = petType == .cat ? .dog : .cat
                                // 更新宠物名称
                                petViewModel.updatePetName()
                            }) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            }
                        }
                        
                        // Experience progress bar
                        VStack(alignment: .leading, spacing: 5) {
                            ProgressBarView(
                                progress: Double(petViewModel.currentExp) / Double(petViewModel.expToNextLevel),
                                height: 8
                            )
                            .frame(maxWidth: .infinity)
                            
                            Text("\(petViewModel.currentExp)/\(petViewModel.expToNextLevel) EXP")
                                .font(.custom("Menlo", size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        if petViewModel.getTotalFedFish() > 0 {
                            HStack(spacing: 15) {
                                ForEach(FishRarity.allCases) { rarity in
                                    statLabel(
                                        title: rarity.rawValue.capitalized,
                                        value: "\(petViewModel.getFedFishCount(rarity: rarity))"
                                    )
                                }
                            }
                            .padding(.top, 5)
                        }
                        
                        // Simplified Feed button
                        PixelButton(
                            text: "Feed",
                            action: { showFeedFishView = true }
                        )
                        .buttonStyle(PixelButtonStyle(backgroundColor: .black, textColor: .white))
                        .padding(.top, 10)
                    }
                    .padding(.vertical)
                }
            } else {
                // No pet selected yet - show selection button
                Button(action: {
                    showPetSelection = true
                }) {
                    ZStack {
                        Rectangle()
                            .stroke(Color.black, lineWidth: 2)
                            .frame(height: 150)
                        
                        VStack {
                            Image(systemName: "plus")
                                .font(.system(size: 40))
                                .foregroundColor(.black)
                            
                            Text("Choose a Pet")
                                .font(.custom("Menlo", size: 16))
                                .foregroundColor(.black)
                                .padding(.top, 10)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 2)
        )
    }
    
    private func statLabel(title: String, value: String) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.custom("Menlo", size: 10))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.custom("Menlo", size: 14))
                .bold()
        }
    }
    
    // Fish collection view
    private var fishCollectionView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Fish Collection")
                .font(.custom("Menlo", size: 20))
                .bold()
            
            // Fish grid by rarity
            ForEach(FishRarity.allCases) { rarity in
                fishRaritySection(rarity: rarity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 2)
        )
    }
    
    private func fishRaritySection(rarity: FishRarity) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(rarity.displayName)
                    .font(.custom("Menlo", size: 16))
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.top, 5)
            
            // Fish icons for this rarity
            HStack(spacing: 15) {
                ForEach(0..<Fish.fishIcons[rarity.iconArrayIndex].count, id: \.self) { index in
                    let iconName = Fish.fishIcons[rarity.iconArrayIndex][index]
                    let count = petViewModel.getFishCountByIconName(iconName: iconName)
                    
                    fishItemView(iconName: iconName, count: count)
                }
            }
            .padding(.horizontal, 5)
        }
    }
    
    // Single fish item view
    private func fishItemView(iconName: String, count: Int) -> some View {
        VStack(spacing: 8) {
            // Fish icon
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            Text(iconName.capitalized)
                .font(.custom("Menlo", size: 12))
                .foregroundColor(.gray)
            
            // Fish count
            Text("× \(count)")
                .font(.custom("Menlo", size: 12))
                .foregroundColor(.black)
                .fontWeight(.bold)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}

struct FeedFishView: View {
    @ObservedObject var petViewModel: PetViewModel
    @Binding var isPresented: Bool
    @State private var selectedRarity: FishRarity = .common
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Feed Your Pet")
                .font(.custom("Menlo", size: 24))
                .bold()
            
            // Fish rarity selector
            Picker("Fish Rarity", selection: $selectedRarity) {
                ForEach(FishRarity.allCases) { rarity in
                    Text(rarity.displayName).tag(rarity)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Fish icons for selected rarity
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<Fish.fishIcons[selectedRarity.iconArrayIndex].count, id: \.self) { index in
                        let iconName = Fish.fishIcons[selectedRarity.iconArrayIndex][index]
                        let count = petViewModel.getFishCountByIconName(iconName: iconName)
                        let hasEnoughFish = count > 0
                        
                        Button(action: {
                            // Create a fish and feed it to the pet
                            if hasEnoughFish {
                                let fish = Fish(rarity: selectedRarity, focusMinutes: 0)
                                fish.icon = iconName
                                petViewModel.feedFish(fish)
                                isPresented = false
                            }
                        }) {
                            VStack(spacing: 8) {
                                Image(iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .opacity(hasEnoughFish ? 1.0 : 0.5)
                                
                                Text(iconName.capitalized)
                                    .font(.custom("Menlo", size: 12))
                                
                                Text("+\(selectedRarity.experienceValue) EXP")
                                    .font(.custom("Menlo", size: 10))
                                    .foregroundColor(.gray)
                                
                                // Show current count
                                Text("Collected: \(count)")
                                    .font(.custom("Menlo", size: 10))
                                    .foregroundColor(hasEnoughFish ? .black : .red)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(hasEnoughFish ? Color.black : Color.gray, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(!hasEnoughFish)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            
            PixelButton(
                text: "Cancel",
                action: { isPresented = false }
            )
            .buttonStyle(PixelButtonStyle(backgroundColor: .gray, textColor: .white))
        }
        .padding()
        .background(Color.white)
    }
}

struct PetSelectionView: View {
    @ObservedObject var petViewModel: PetViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Choose Your Pet")
                .font(.custom("Menlo", size: 24))
                .bold()
            
            HStack(spacing: 40) {
                petButton(type: .cat)
                petButton(type: .dog)
            }
            
            PixelButton(
                text: "Close",
                action: { isPresented = false }
            )
            .buttonStyle(PixelButtonStyle(backgroundColor: .gray, textColor: .white))
        }
        .padding()
        .background(Color.white)
    }
    
    private func petButton(type: PetType) -> some View {
        Button(action: {
            petViewModel.selectedPetType = type
            isPresented = false
        }) {
            VStack(spacing: 10) {
                Image(type == .cat ? "cat" : "dog")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                Text(type == .cat ? "Cat" : "Dog")
                    .font(.custom("Menlo", size: 16))
                    .foregroundColor(.black)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black, lineWidth: 2)
            )
        }
    }
}

struct PetStatusView_Previews: PreviewProvider {
    static var previews: some View {
        PetStatusView(petViewModel: PetViewModel())
    }
} 