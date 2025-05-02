import SwiftUI

struct FishingSceneView: View {
    var progress: Double
    
    @State private var cloudOffset1: CGFloat = 0
    @State private var cloudOffset2: CGFloat = 100
    @State private var cloudOffset3: CGFloat = -100
    @State private var bobberOffset: CGFloat = 0
    @State private var showBubble = false
    @State private var bubbleOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                // Clouds - lowered position to avoid obscuring text above
                cloud(width: 60, height: 30)
                    .fill(Color.black.opacity(0.1))
                    .position(x: (cloudOffset1 + geometry.size.width).truncatingRemainder(dividingBy: geometry.size.width),
                              y: geometry.size.height * 0.4)
                
                cloud(width: 80, height: 40)
                    .fill(Color.black.opacity(0.1))
                    .position(x: (cloudOffset2 + geometry.size.width).truncatingRemainder(dividingBy: geometry.size.width),
                              y: geometry.size.height * 0.3)
                
                cloud(width: 70, height: 35)
                    .fill(Color.black.opacity(0.1))
                    .position(x: (cloudOffset3 + geometry.size.width).truncatingRemainder(dividingBy: geometry.size.width),
                              y: geometry.size.height * 0.35)
                
                // Water line
                Rectangle()
                    .fill(Color.black)
                    .frame(width: geometry.size.width, height: 2)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.6)
                
                // Underwater area
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.8)
                
                // Fishing rod
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width * 0.1, y: geometry.size.height * 0.2))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.4, y: geometry.size.height * 0.1))
                }
                .stroke(Color.black, lineWidth: 3)
                
                // Fishing line
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width * 0.4, y: geometry.size.height * 0.1))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.4, y: geometry.size.height * 0.6 + bobberOffset))
                }
                .stroke(Color.black, lineWidth: 1)
                
                // Bobber
                Circle()
                    .fill(Color.black)
                    .frame(width: 10, height: 10)
                    .position(x: geometry.size.width * 0.4, y: geometry.size.height * 0.6 + bobberOffset)
                
                // Bubble
                if showBubble {
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.7 - bubbleOffset)
                }
                
                // Bottom decorations
                ForEach(0..<5) { i in
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 5, height: 15)
                        .position(x: CGFloat(i) * geometry.size.width / 4 + geometry.size.width / 8, 
                                  y: geometry.size.height * 0.98)
                }
            }
            .onAppear {
                // Cloud animations
                withAnimation(Animation.linear(duration: 60).repeatForever(autoreverses: false)) {
                    cloudOffset1 = geometry.size.width
                }
                withAnimation(Animation.linear(duration: 80).repeatForever(autoreverses: false)) {
                    cloudOffset2 = geometry.size.width
                }
                withAnimation(Animation.linear(duration: 100).repeatForever(autoreverses: false)) {
                    cloudOffset3 = geometry.size.width
                }
                
                // Bubble animations
                Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                    showBubble = true
                    bubbleOffset = 0
                    withAnimation(Animation.easeOut(duration: 2)) {
                        bubbleOffset = 50
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showBubble = false
                    }
                }
            }
            .onChange(of: progress) { newValue in
                withAnimation {
                    bobberOffset = CGFloat(newValue) * 15
                }
            }
        }
    }
    
    private func cloud(width: CGFloat, height: CGFloat) -> some Shape {
        CloudShape()
            .scale(x: width / 100, y: height / 50, anchor: .center)
    }
}

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Draw basic cloud shape
        path.addEllipse(in: CGRect(x: rect.width * 0.25, y: rect.height * 0.4, 
                                     width: rect.width * 0.3, height: rect.height * 0.5))
        path.addEllipse(in: CGRect(x: rect.width * 0.45, y: rect.height * 0.3, 
                                     width: rect.width * 0.4, height: rect.height * 0.7))
        path.addEllipse(in: CGRect(x: rect.width * 0.05, y: rect.height * 0.3, 
                                     width: rect.width * 0.35, height: rect.height * 0.6))
        
        return path
    }
}

struct FishingSceneView_Previews: PreviewProvider {
    static var previews: some View {
        FishingSceneView(progress: 0.5)
            .frame(height: 200)
            .padding()
    }
}
 