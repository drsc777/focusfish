import SwiftUI

struct PixelFishView: View {
    let rarity: FishRarity
    let size: CGFloat
    let iconName: String
    
    var body: some View {
        Image(iconName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(rarityColor, lineWidth: 2)
            )
    }
    
    private var rarityColor: Color {
        switch rarity {
        case .common:
            return .gray
        case .rare:
            return .blue
        case .epic:
            return .purple
        }
    }
}

struct PixelFishView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ForEach(FishRarity.allCases) { rarity in
                PixelFishView(
                    rarity: rarity,
                    size: 60,
                    iconName: "bubbly"
                )
            }
        }
        .padding()
    }
} 