import SwiftUI

struct PixelProgressBar: View {
    var progress: Double // 0.0 - 1.0
    var width: CGFloat = 300
    var height: CGFloat = 20
    var cornerSize: CGFloat = 4
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background
            Rectangle()
                .fill(Color.white)
                .frame(width: width, height: height)
                .overlay(
                    Rectangle()
                        .stroke(Color.black, lineWidth: 2)
                )
            
            // Progress
            Rectangle()
                .fill(Color.black)
                .frame(width: max(0, width * CGFloat(min(progress, 1.0)) - 4), height: height - 4)
                .padding(2)
            
            // Pixel corner effect
            VStack {
                HStack {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: cornerSize, height: cornerSize)
                    Spacer()
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: cornerSize, height: cornerSize)
                }
                .frame(width: width - 4)
                
                Spacer()
                
                HStack {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: cornerSize, height: cornerSize)
                    Spacer()
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: cornerSize, height: cornerSize)
                }
                .frame(width: width - 4)
            }
            .frame(width: width, height: height)
        }
    }
}

struct PixelProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PixelProgressBar(progress: 0.25)
            PixelProgressBar(progress: 0.5)
            PixelProgressBar(progress: 0.75)
            PixelProgressBar(progress: 1.0)
        }
        .padding()
    }
} 