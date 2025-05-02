import SwiftUI

struct SoundSettingsView: View {
    @ObservedObject var soundSettings: SoundSettings
    @State private var selectedNoise: WhiteNoiseType
    
    init(soundSettings: SoundSettings) {
        self.soundSettings = soundSettings
        self._selectedNoise = State(initialValue: soundSettings.whiteNoiseType)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sound Settings")
                .font(.custom("Menlo", size: 18))
                .bold()
            
            // Sound enable/disable toggle
            Toggle(isOn: $soundSettings.isSoundEnabled) {
                Text("Enable Sound")
                    .font(.custom("Menlo", size: 14))
            }
            .toggleStyle(SwitchToggleStyle(tint: .black))
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Select White Noise Type")
                    .font(.custom("Menlo", size: 14))
                
                VStack(spacing: 10) {
                    ForEach(WhiteNoiseType.allCases) { noiseType in
                        Button(action: {
                            selectedNoise = noiseType
                            soundSettings.whiteNoiseType = noiseType
                            if soundSettings.isSoundEnabled {
                                Task {
                                    await soundSettings.playSound()
                                }
                            }
                        }) {
                            HStack {
                                Text(noiseType.displayName)
                                    .font(.custom("Menlo", size: 14))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                if selectedNoise == noiseType {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.black)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black, lineWidth: 1)
                                    .background(selectedNoise == noiseType ? Color.gray.opacity(0.2) : Color.white)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            if selectedNoise != .none {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Volume")
                        .font(.custom("Menlo", size: 14))
                    
                    HStack {
                        Text("Low")
                            .font(.custom("Menlo", size: 12))
                        
                        Slider(value: $soundSettings.volume, in: 0...1)
                            .accentColor(.black)
                        
                        Text("High")
                            .font(.custom("Menlo", size: 12))
                    }
                }
                
                Button(action: {
                    Task {
                        await soundSettings.playSound()
                    }
                }) {
                    Text("Test Sound")
                        .font(.custom("Menlo", size: 14))
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Show sound file location information for debugging
                if selectedNoise == .stream {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Sound File Info:")
                            .font(.custom("Menlo", size: 12))
                            .foregroundColor(.gray)
                        
                        let fileInfo = getSoundFileInfo(for: "stream", extension: "m4a")
                        Text(fileInfo)
                            .font(.custom("Menlo", size: 10))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 10)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 2)
                .background(Color.white)
        )
        .padding()
    }
    
    private func getSoundFileInfo(for name: String, extension ext: String) -> String {
        var info = ""
        
        // Check main bundle
        if let bundleURL = Bundle.main.url(forResource: name, withExtension: ext) {
            info += "Bundle: Found at \(bundleURL.path)\n"
        } else {
            info += "Bundle: Not found\n"
        }
        
        // Check Resources directory
        let resourcesPath = Bundle.main.bundlePath + "/Resources/\(name).\(ext)"
        if FileManager.default.fileExists(atPath: resourcesPath) {
            info += "Resources: Found at \(resourcesPath)\n"
        } else {
            info += "Resources: Not found\n"
        }
        
        // Check documents directory
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let docsPath = documentsURL.appendingPathComponent("\(name).\(ext)").path
            if FileManager.default.fileExists(atPath: docsPath) {
                info += "Documents: Found at \(docsPath)\n"
            } else {
                info += "Documents: Not found\n"
            }
        } else {
            info += "Documents: Directory not accessible\n"
        }
        
        return info
    }
}

struct SoundSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SoundSettingsView(soundSettings: SoundSettings())
    }
} 