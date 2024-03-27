
import AVFoundation
import AVKit
import Combine
import MediaPlayer

final class AudioPlayerManager {
    
    // MARK: - Variables
    var player: AVPlayer
    let currentTimeSubject = PassthroughSubject<Float64, Never>()
    var speeds = AVPlaybackSpeed.systemDefaultSpeeds
    var currentSpeedIndex: Int
    var isPlaying = false
    
    var currentTime: AnyPublisher<Float64, Never> {
        currentTimeSubject.eraseToAnyPublisher()
    }
    
    var currentSpeedLocalized: String {
        speeds[currentSpeedIndex].localizedNumericName
    }
    
    // MARK: - Init
    init() {
        self.player = AVPlayer()
        currentSpeedIndex = speeds.firstIndex {
            $0.rate == 1
        } ?? 0
        
        addTimeObserver()
        setupRemoteTransportControls()
        setupNowPlaying()
    }

    // MARK: - Functions
    func getDuration() async throws -> Float64 {
        guard let item = player.currentItem else {
            return .zero
        }
        let duration = try await item.asset.load(.duration)
        let seconds = CMTimeGetSeconds(duration)
        return seconds
    }
    
    func play() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            print(error.localizedDescription)
        }
        self.isPlaying = true
        player.play()
    }
    
    func pause() {
        self.isPlaying = false
        player.pause()
    }
    
  
    func skipForwardTenSeconds() {
        guard let currentTime = player.currentItem?.currentTime() else { return }
        let tenSecondsForward = CMTimeAdd(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
        player.seek(to: tenSecondsForward)
    }
    
    
    func skipBackwardFiveSeconds() {
        guard let currentTime = player.currentItem?.currentTime() else { return }
        let fiveSecondsBackward = CMTimeSubtract(currentTime, CMTime(seconds: 5, preferredTimescale: 1))
        player.seek(to: fiveSecondsBackward)
    }
    
    
    func seek(to timeInterval: TimeInterval) async {
        let targetTime = CMTimeMake(value: Int64(timeInterval), timescale: 1)
        player.currentTime()
        await player.seek(to: targetTime)
    }
        
    func nextSpeed() {
        let nextIndex = currentSpeedIndex + 1
        if nextIndex == speeds.count {
            currentSpeedIndex = 0
        } else {
            currentSpeedIndex = nextIndex
        }
        player.rate = speeds[currentSpeedIndex].rate
    }
    
    func loadAudioLocal(url: URL) async throws {
        guard let url = Bundle.main.url(forResource: url.absoluteString, withExtension: "mp3") else {
            throw AudioPlayerError.invalidURL
        }
        
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        player.replaceCurrentItem(with: playerItem)
        
        self.play()
    }
    

    func loadAudio(url: URL) async throws {        
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        player.replaceCurrentItem(with: playerItem)
        
        self.play()
    }
    
    private func addTimeObserver() {
        let interval = CMTimeMakeWithSeconds(1, preferredTimescale: 1)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                self?.currentTimeSubject.send(CMTimeGetSeconds(time))
        }
    }
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [unowned self] event in
            if !self.isPlaying {
                self.play()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.isPlaying {
                self.pause()
                return .success
            }
            return .commandFailed
        }
    }

    func setupNowPlaying() {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Just For Test"
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}



enum AudioPlayerError: Error {
    case invalidCurrentTime
    case invalidURL
    case error
}
