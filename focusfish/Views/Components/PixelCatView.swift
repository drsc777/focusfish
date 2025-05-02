import SwiftUI

struct PixelCatView: View {
    var level: Int
    var size: CGFloat = 100
    
    var body: some View {
        ZStack {
            catShape
                .frame(width: size, height: size)
        }
    }
    
    private var catShape: some View {
        ZStack {
            // Basic cat shape
            VStack(spacing: 0) {
                // Head and ears
                ZStack {
                    // Basic head shape
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: size * 0.7, height: size * 0.5)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black, lineWidth: size * 0.04)
                        )
                    
                    // Left ear
                    Path { path in
                        path.move(to: CGPoint(x: -size * 0.3, y: -size * 0.25))
                        path.addLine(to: CGPoint(x: -size * 0.15, y: -size * 0.25))
                        path.addLine(to: CGPoint(x: -size * 0.15, y: -size * 0.1))
                        path.closeSubpath()
                    }
                    .fill(Color.white)
                    .overlay(
                        Path { path in
                            path.move(to: CGPoint(x: -size * 0.3, y: -size * 0.25))
                            path.addLine(to: CGPoint(x: -size * 0.15, y: -size * 0.25))
                            path.addLine(to: CGPoint(x: -size * 0.15, y: -size * 0.1))
                            path.closeSubpath()
                        }
                        .stroke(Color.black, lineWidth: size * 0.04)
                    )
                    
                    // Right ear
                    Path { path in
                        path.move(to: CGPoint(x: size * 0.15, y: -size * 0.25))
                        path.addLine(to: CGPoint(x: size * 0.3, y: -size * 0.25))
                        path.addLine(to: CGPoint(x: size * 0.15, y: -size * 0.1))
                        path.closeSubpath()
                    }
                    .fill(Color.white)
                    .overlay(
                        Path { path in
                            path.move(to: CGPoint(x: size * 0.15, y: -size * 0.25))
                            path.addLine(to: CGPoint(x: size * 0.3, y: -size * 0.25))
                            path.addLine(to: CGPoint(x: size * 0.15, y: -size * 0.1))
                            path.closeSubpath()
                        }
                        .stroke(Color.black, lineWidth: size * 0.04)
                    )
                    
                    // Eyes
                    HStack(spacing: size * 0.25) {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: size * 0.08, height: size * 0.08)
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: size * 0.08, height: size * 0.08)
                    }
                    .offset(y: -size * 0.05)
                }
                
                // Body
                HStack(spacing: 0) {
                    // Main body
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: size * 0.5, height: size * 0.4)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black, lineWidth: size * 0.04)
                        )
                    
                    // Tail
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: size * 0.1))
                        path.addLine(to: CGPoint(x: size * 0.25, y: -size * 0.1))
                        path.addLine(to: CGPoint(x: size * 0.25, y: size * 0.2))
                        path.closeSubpath()
                    }
                    .fill(Color.white)
                    .overlay(
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: size * 0.1))
                            path.addLine(to: CGPoint(x: size * 0.25, y: -size * 0.1))
                            path.addLine(to: CGPoint(x: size * 0.25, y: size * 0.2))
                            path.closeSubpath()
                        }
                        .stroke(Color.black, lineWidth: size * 0.04)
                    )
                }
                
                // Legs
                HStack(spacing: size * 0.1) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: size * 0.1, height: size * 0.15)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black, lineWidth: size * 0.04)
                        )
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: size * 0.1, height: size * 0.15)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black, lineWidth: size * 0.04)
                        )
                }
            }
            
            // Add decorations based on level
            if level >= 5 {
                // Level 5: add small crown
                Path { path in
                    path.move(to: CGPoint(x: -size * 0.1, y: -size * 0.35))
                    path.addLine(to: CGPoint(x: 0, y: -size * 0.45))
                    path.addLine(to: CGPoint(x: size * 0.1, y: -size * 0.35))
                    path.closeSubpath()
                }
                .fill(Color.black)
            }
        }
    }
}

struct PixelCatView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            PixelCatView(level: 1)
            PixelCatView(level: 5)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 