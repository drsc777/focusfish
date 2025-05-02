import SwiftUI

struct PixelButton: View {
    let text: String
    let action: () -> Void
    var width: CGFloat?
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.custom("Menlo", size: 16))
                .frame(width: width)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
        }
        .disabled(isDisabled)
    }
}

struct PixelButtonStyle: ButtonStyle {
    var backgroundColor: Color = .black
    var textColor: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(textColor)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(backgroundColor == .gray ? Color.clear : Color.black, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct PixelButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PixelButton(text: "Normal Button", action: {})
                .buttonStyle(PixelButtonStyle())
            
            PixelButton(text: "Gray Button", action: {})
                .buttonStyle(PixelButtonStyle(backgroundColor: .gray))
            
            PixelButton(text: "Fixed Width", action: {}, width: 200)
                .buttonStyle(PixelButtonStyle())
            
            PixelButton(text: "Disabled", action: {}, isDisabled: true)
                .buttonStyle(PixelButtonStyle())
        }
        .padding()
    }
} 
