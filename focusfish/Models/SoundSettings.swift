import Foundation
import AVFoundation
import Combine

enum WhiteNoiseType: String, Codable, CaseIterable, Identifiable {
    case none = "none"
    case fireplace = "fireplace"
    case stream = "stream"
    case rain = "rain"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .none:
            return "None"
        case .fireplace:
            return "Fireplace"
        case .stream:
            return "Stream"
        case .rain:
            return "Rain"
        }
    }
    
    var soundFileName: String? {
        switch self {
        case .none:
            return nil
        case .stream:
            return "stream.m4a"
        case .fireplace:
            return "fireplace.mp3"
        case .rain:
            return "rain.mp3"
        }
    }
}

enum SoundType {
    case tick
    case complete
    case whiteNoise(WhiteNoiseType)
}

@MainActor
class SoundSettings: ObservableObject {
    @Published var tickSound: String
    @Published var completeSound: String
    @Published var whiteNoiseType: WhiteNoiseType {
        didSet {
            Task {
                if whiteNoiseType == .none {
                    await stopSound()
                } else if isSoundEnabled {
                    await playSound()
                }
            }
        }
    }
    @Published var volume: Double {
        didSet {
            Task {
                await saveSettings()
                await updateVolume()
            }
        }
    }
    @Published var isSoundEnabled: Bool {
        didSet {
            Task {
                await saveSettings()
                await updateSound()
            }
        }
    }
    
    init() {
        self.tickSound = "tick"
        self.completeSound = "complete"
        
        // Load from UserDefaults
        let defaults = UserDefaults.standard
        
        // Get saved noise type if it exists
        if let savedTypeString = defaults.string(forKey: "whiteNoiseType"),
           let savedType = WhiteNoiseType(rawValue: savedTypeString) {
            self.whiteNoiseType = savedType
        } else {
            self.whiteNoiseType = .none
        }
        
        // Get saved volume
        let savedVolume = defaults.double(forKey: "volume")
        self.volume = savedVolume > 0 ? savedVolume : 0.5
        
        // Get saved sound enabled state
        self.isSoundEnabled = defaults.bool(forKey: "isSoundEnabled")
        
        // Start playing if enabled
        if isSoundEnabled && whiteNoiseType != .none {
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                await playSound()
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func updateSound() async {
        if isSoundEnabled && whiteNoiseType != .none {
            await playSound()
        } else {
            await stopSound()
        }
    }
    
    func playSound() async {
        if isSoundEnabled && whiteNoiseType != .none {
            if let _ = whiteNoiseType.soundFileName {
                await SoundManager.shared.playSound(type: .whiteNoise(whiteNoiseType))
                print("Starting to play white noise: \(whiteNoiseType.displayName)")
            }
        }
    }
    
    func stopSound() async {
        await SoundManager.shared.stopSound()
        print("Stopping white noise playback")
    }
    
    private func updateVolume() async {
        await SoundManager.shared.updateVolume(Float(volume))
    }
    
    private func saveSettings() async {
        UserDefaults.standard.set(tickSound, forKey: "tickSound")
        UserDefaults.standard.set(completeSound, forKey: "completeSound")
        UserDefaults.standard.set(whiteNoiseType.rawValue, forKey: "whiteNoiseType")
        UserDefaults.standard.set(volume, forKey: "volume")
        UserDefaults.standard.set(isSoundEnabled, forKey: "isSoundEnabled")
    }
}

@MainActor
class SoundManager {
    static let shared = SoundManager()
    
    private var player: AVAudioPlayer?
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        #if os(iOS) || os(tvOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
        #else
        // No need to set up AVAudioSession on macOS
        print("Running on macOS, skipping AVAudioSession setup")
        #endif
    }
    
    func playSound(type: SoundType) async {
        // Stop any currently playing sound first
        await stopSound()
        
        switch type {
        case .tick:
            // Play tick sound
            print("Playing timer tick sound")
            
        case .complete:
            // Play complete sound
            print("Playing completion sound")
            
        case .whiteNoise(let noiseType):
            guard let fileName = noiseType.soundFileName else { return }
            
            print("Attempting to play \(noiseType.displayName) sound file: \(fileName)")
            
            // Try to find the sound file in various locations
            var soundURL: URL? = nil
            let fileNameWithoutExt = (fileName as NSString).deletingPathExtension
            let fileExt = (fileName as NSString).pathExtension
            
            // 1. Try Bundle main first (most reliable)
            if let bundleURL = Bundle.main.url(forResource: fileNameWithoutExt, withExtension: fileExt) {
                soundURL = bundleURL
                print("Found audio in main bundle: \(bundleURL.path)")
            }
            
            // 2. Check various resource paths including the Resources directory
            if soundURL == nil {
                // Check project Resources directory
                let paths = [
                    // Add current project path with Resources folder
                    "./Resources/\(fileName)",
                    // Relative paths from project
                    "Resources/\(fileName)",
                    "../Resources/\(fileName)",
                    // Absolute paths for testing
                    "/Users/abby/Developer/focusfish/focusfish/Resources/\(fileName)",
                    "/Users/abby/Developer/focusfish/Resources/\(fileName)",
                    // Bundle paths
                    Bundle.main.bundlePath + "/Contents/Resources/\(fileName)",
                    Bundle.main.bundlePath + "/Resources/\(fileName)"
                ]
                
                for path in paths {
                    if FileManager.default.fileExists(atPath: path) {
                        soundURL = URL(fileURLWithPath: path)
                        print("Found audio file at: \(path)")
                        break
                    }
                }
            }
            
            // 3. Try to locate in app's document directory as last resort
            if soundURL == nil, 
               let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsURL.appendingPathComponent(fileName)
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    soundURL = fileURL
                    print("Found audio in documents directory: \(fileURL.path)")
                }
            }
            
            // 4. Debug: If still can't find, list Resources directory contents
            if soundURL == nil {
                if let resourcesPath = Bundle.main.resourcePath {
                    print("Listing resources directory contents:")
                    do {
                        let resourceContents = try FileManager.default.contentsOfDirectory(atPath: resourcesPath)
                        for item in resourceContents {
                            print("  - \(item)")
                        }
                    } catch {
                        print("Error listing resources: \(error)")
                    }
                }
                
                // Also check current directory
                do {
                    print("Listing current directory contents:")
                    let currentPath = FileManager.default.currentDirectoryPath
                    print("Current path: \(currentPath)")
                    let contents = try FileManager.default.contentsOfDirectory(atPath: currentPath)
                    for item in contents {
                        print("  - \(item)")
                    }
                    
                    // Check Resources directory specifically
                    if FileManager.default.fileExists(atPath: "Resources") {
                        print("Listing Resources directory contents:")
                        let resourcesContents = try FileManager.default.contentsOfDirectory(atPath: "Resources")
                        for item in resourcesContents {
                            print("  - \(item)")
                        }
                    }
                } catch {
                    print("Error listing directory: \(error)")
                }
            }
            
            // If found, try to play it
            if let url = soundURL {
                do {
                    player = try AVAudioPlayer(contentsOf: url)
                    player?.numberOfLoops = -1 // Loop indefinitely
                    player?.volume = Float(UserDefaults.standard.double(forKey: "volume"))
                    player?.prepareToPlay()
                    
                    // Make sure we have a valid audio file loaded
                    if player?.duration ?? 0 > 0 {
                        let success = player?.play() ?? false
                        print("Audio player started: \(success) for \(noiseType.displayName)")
                    } else {
                        print("Audio file invalid or empty")
                    }
                } catch {
                    print("Failed to play white noise: \(error.localizedDescription)")
                }
            } else {
                print("Could not find sound file: \(fileName). Searched in bundle and other locations.")
            }
        }
    }
    
    func updateVolume(_ volume: Float) async {
        player?.volume = volume
    }
    
    func stopSound() async {
        player?.stop()
        player = nil
    }
} 