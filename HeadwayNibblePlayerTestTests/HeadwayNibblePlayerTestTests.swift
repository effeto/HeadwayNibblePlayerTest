
@testable import HeadwayNibblePlayerTest
import XCTest
import ComposableArchitecture
import Combine
import AVFoundation

@MainActor
class AudioPlayerManagerTests: XCTestCase {

    var audioPlayerManager: AudioPlayerManager!
    var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        audioPlayerManager = AudioPlayerManager()
    }

    override func tearDownWithError() throws {
        audioPlayerManager = nil
        cancellables.removeAll()
    }

    func testPlay() {
        XCTAssertFalse(audioPlayerManager.isPlaying)
        audioPlayerManager.play()
        XCTAssertTrue(audioPlayerManager.isPlaying)
    }

    func testPause() {
        audioPlayerManager.play()
        XCTAssertTrue(audioPlayerManager.isPlaying)
        audioPlayerManager.pause()
        XCTAssertFalse(audioPlayerManager.isPlaying)
    }

    func testGetCurrentTime() {
        let expectation = XCTestExpectation(description: "Retrieve current time")

        let currentTimeSubscriber = audioPlayerManager.currentTime
            .sink { currentTime in
                XCTAssertGreaterThanOrEqual(currentTime, 0.0)
                expectation.fulfill()
            }

        guard let url = Bundle.main.url(forResource: "audioName1", withExtension: "mp3") else {
            XCTFail("No audio found")
            return
        }
        let playerItem = AVPlayerItem(url: url)
        audioPlayerManager.player.replaceCurrentItem(with: playerItem)
        audioPlayerManager.play()

        wait(for: [expectation], timeout: 10.0)

        currentTimeSubscriber.cancel()
    }
    
    func testSkipForwardTenSeconds() {
        guard let url = Bundle.main.url(forResource: "audioName1", withExtension: "mp3") else {
            XCTFail("No audio found")
            return
        }
        let playerItem = AVPlayerItem(url: url)
        audioPlayerManager.player.replaceCurrentItem(with: playerItem)
        audioPlayerManager.play()
        
        let initialTime = audioPlayerManager.player.currentTime().seconds
        audioPlayerManager.skipForwardTenSeconds()
        let updatedTime = audioPlayerManager.player.currentTime().seconds

        XCTAssertEqual(updatedTime, initialTime + 10, accuracy: 0.1)
    }

    func testSkipBackwardFiveSeconds() {
        guard let url = Bundle.main.url(forResource: "audioName1", withExtension: "mp3") else {
            XCTFail("No audio found")
            return
        }
        let playerItem = AVPlayerItem(url: url)
        audioPlayerManager.player.replaceCurrentItem(with: playerItem)
        audioPlayerManager.play()
        
        let initialTime = audioPlayerManager.player.currentTime().seconds
        audioPlayerManager.skipBackwardFiveSeconds()
        let updatedTime = audioPlayerManager.player.currentTime().seconds

        XCTAssertEqual(updatedTime, initialTime - 5, accuracy: 0.1)
    }

    func testSeekTo() async {
        guard let url = Bundle.main.url(forResource: "audioName1", withExtension: "mp3") else {
            XCTFail("No audio found")
            return
        }
        let playerItem = AVPlayerItem(url: url)
        audioPlayerManager.player.replaceCurrentItem(with: playerItem)
        audioPlayerManager.play()
        
        let targetTime: TimeInterval = 20
        let expectation = XCTestExpectation(description: "Seek to \(targetTime)")
        let initialTime = audioPlayerManager.player.currentTime().seconds
        let expectedTime = initialTime + targetTime

        let currentTimeSubscriber = audioPlayerManager.currentTime
            .sink { currentTime in
                if currentTime >= targetTime {
                    expectation.fulfill()
                }
            }

        audioPlayerManager.play()
        await audioPlayerManager.seek(to: targetTime)
        
        XCTAssertTrue(audioPlayerManager.isPlaying)
        currentTimeSubscriber.cancel()
    }
    
    func testNextSpeed() {
        let initialSpeedIndex = audioPlayerManager.currentSpeedIndex
        audioPlayerManager.nextSpeed()
        let updatedSpeedIndex = audioPlayerManager.currentSpeedIndex

        XCTAssertEqual(updatedSpeedIndex, (initialSpeedIndex + 1) % audioPlayerManager.speeds.count)
    }

    func testLoadAudioLocal() async {
        guard let url =  URL(string: "audioName1") else {
            XCTFail("No audio found")
            return
        }
  
        do {
            try await audioPlayerManager.loadAudioLocal(url: url)
            XCTAssertTrue(audioPlayerManager.isPlaying)
        } catch {
            XCTFail("Failed to load audio: \(error.localizedDescription)")
        }
    }
    
    func testLoadAudioWeb() async {
        guard let url =  URL(string: "https://media.djlunatique.com/2021/03/I-am-Batman-Sound-Effect.mp3") else {
            XCTFail("No audio found")
            return
        }
  
        do {
            try await audioPlayerManager.loadAudio(url: url)
            XCTAssertTrue(audioPlayerManager.isPlaying)
        } catch {
            XCTFail("Failed to load audio: \(error.localizedDescription)")
        }
    }
}


