
import Foundation
import ComposableArchitecture

@Reducer
struct AudioPlayerFeature {
    // MARK: - Variables
    private let audioPlayerManager = AudioPlayerManager()
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        
        static func == (lhs: AudioPlayerFeature.State, rhs: AudioPlayerFeature.State) -> Bool {
            return true
        }
        
        init(book: BookModel) {
            self.book = book
        }
        
        var bookURL: URL?
        var book: BookModel
        var currentSection: BookSectionModel?
        var currentSectionIndex = 0
        
        var duration: TimeInterval = 0
        var durationLocalized: String {
            duration.asString()
        }
        
        var currentTime: TimeInterval = 0
        var currentTimeLocalized: String {
            currentTime.asString()
        }
        
        var isTimeLineEditing = false
        var currentTimeLineTime: TimeInterval = 0
        
        var currentSpeed = ""
        
        var isPaused = false
        var isSoundMode = true
        
        var isFirstSection: Bool {
            currentSection?.sectionNumber == 1
        }
        
        var isLastSection: Bool {
            book.sectionCount == (currentSection?.sectionNumber ?? 0)
        }
        
    }
    
    // MARK: - Actions Enum
    enum Action {
        case onAppear
        case startAudio(url: URL)
        case updateCurrentSection(BookSectionModel)
        
        case applyAudioDuration(TimeInterval)
        case updateCurrentTime(TimeInterval)
        case updateTimeLineCurrentTime(TimeInterval)
        case timeLineValueChanged(Bool)
        case timeLineFinishedEditing
        case timeLineStartedEditing
        case seekingFinished
        case updateIsSoundOn(Bool)
        
        
        case pauseButtonTapped
        case speedButtonTapped
        case previousButtonTapped
        case nextButtonTapped
        case goBackwardButtonTapped
        case goForwardButtonTapped
    }
    
    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if let bookSections = state.book.bookSections, bookSections.count > 0 {
                    state.currentSection = bookSections.first
                    state.currentSectionIndex = state.currentSection?.sectionNumber ?? 1
                    state.currentSpeed = audioPlayerManager.currentSpeedLocalized
                    return .concatenate(
                        .send(.startAudio(url: URL(string: state.currentSection?.sectionURL ?? "")!)),
                        .publisher ({
                            audioPlayerManager
                                .currentTime
                                .map { .updateCurrentTime($0) }
                        })
                    )
                } else {
                    return .none
                }
                
            case let .startAudio(url: url):
                state.bookURL = url
                audioPlayerManager.currentSpeedIndex = 1
                state.currentSpeed = audioPlayerManager.currentSpeedLocalized
                if state.isPaused {
                    state.isPaused = false
                }
                return .run { [url = state.bookURL] send in
                    guard let url = url else { return }
                    if !Helpers.isProduction {
                        try await self.audioPlayerManager.loadAudioLocal(url: url)
                    } else {
                        try await self.audioPlayerManager.loadAudio(url: url)
                    }
                    let time = try await audioPlayerManager.getDuration()
                    await send(.applyAudioDuration(time))
                } catch: { error, send in
                    print(error.localizedDescription)
                }
                
            case let .applyAudioDuration(value):
                state.duration = value
                return .none
                
            case let .updateTimeLineCurrentTime(value):
                state.currentTimeLineTime = value
                return .none
                
            case let .updateCurrentTime(value):
                
                if value == state.duration {
                    return .run { send in
                        await send(.nextButtonTapped)
                    }
                }
                
                state.currentTime = value
                
                if !state.isTimeLineEditing {
                    return .send(.updateTimeLineCurrentTime(value))
                } else {
                    return .none
                }
                
            case .timeLineFinishedEditing:
                return .run { [currentTime = state.currentTimeLineTime] send in
                    await audioPlayerManager.seek(to: currentTime)
                    await send(.seekingFinished)
                }
            case .seekingFinished:
                state.isTimeLineEditing = false
                return .none
                
            case .timeLineStartedEditing:
                state.isTimeLineEditing = true
                return .none
                
            case .pauseButtonTapped:
                if state.isPaused  {
                    audioPlayerManager.play()
                } else {
                    audioPlayerManager.pause()
                }
                state.isPaused.toggle()
                return .none
                
            case .previousButtonTapped:
                guard !state.isFirstSection else { return .none }
                
                state.currentSectionIndex -= 1
                guard let newSection = state.book.bookSections?[state.currentSectionIndex - 1] else {return .none }
                guard let url = URL(string: newSection.sectionURL ?? "") else { return .none }
                return .run { send in
                    await send(.startAudio(url: url))
                    await send(.updateCurrentSection(newSection))
                    await send(.updateTimeLineCurrentTime(0))
                }
                
            case .nextButtonTapped:
                guard !state.isLastSection else { return .none }
                
                state.currentSectionIndex += 1
                guard let newSection = state.book.bookSections?[state.currentSectionIndex - 1] else {return .none }
                guard let url = URL(string: newSection.sectionURL ?? "") else { return .none }
                return .run { send in
                    await send(.startAudio(url: url))
                    await send(.updateCurrentSection(newSection))
                    await send(.updateTimeLineCurrentTime(0))
                }
                
            case .goForwardButtonTapped:
                return .run { [currentTime = state.currentTime] send in
                    audioPlayerManager.skipForwardTenSeconds()
                    await send(.updateTimeLineCurrentTime(currentTime))
                } catch: { error, send in
                    print(error)
                }
                
            case .goBackwardButtonTapped:
                return .run { [currentTime = state.currentTime] send  in
                    audioPlayerManager.skipBackwardFiveSeconds()
                    await send(.updateTimeLineCurrentTime(currentTime))
                } catch: { error, send in
                    print(error)
                }
                
            case let .updateCurrentSection(section):
                state.currentSection = section
                return .none
                
            case let .timeLineValueChanged(value):
                if !value {
                    return .send(.timeLineFinishedEditing)
                } else {
                    return .send(.timeLineStartedEditing)
                }
                
            case .speedButtonTapped:
                audioPlayerManager.nextSpeed()
                state.currentSpeed = audioPlayerManager.currentSpeedLocalized
                return .none
                
            case let .updateIsSoundOn(update):
                state.isSoundMode = update
                return .none
            }
            
        }
    }
}
