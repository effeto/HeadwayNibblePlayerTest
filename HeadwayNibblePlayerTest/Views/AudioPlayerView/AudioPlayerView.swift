//
//  AudioPlayerView.swift
//  HeadwayNibbleTest
//
//  Created by Демьян on 26.03.2024.
//

import SwiftUI
import ComposableArchitecture

struct AudioPlayerView:  View {
    @Bindable var store: StoreOf<AudioPlayerFeature>
    


    var body: some View {
        VStack(content: {
            self.bookCoverView
            self.keyPointView
            self.sectionTitle
            self.progressView
            self.toolbar
            Spacer()
            self.modeToggle
        })
        .onAppear(perform: {
            store.send(.onAppear)
        })
        .onChange(of: store.currentTime, { oldValue, newValue in
            if Int(newValue) == Int(store.duration) {
                self.store.send(.goForwardButtonTapped)
            }
        })
    }
    
    
    private var bookCoverView: some View {
        VStack(alignment: .center, content: {
            if !Helpers.isProduction {
                Image(store.state.book.bookCover ?? "bookCoverMock")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 250, height: 350)
                    .clipped()
            } else {
                if let url = URL(string: store.state.book.bookCover ?? "") {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 250, height: 350)
                            .clipped()
                    } placeholder: {
                        Color.gray
                            .frame(width: 250, height: 350)
                    }
                }
            }
        })
        .padding(.top, 10)
    }
    
    private var keyPointView: some View {
        Text("KEY POINT \(store.currentSection?.sectionNumber ?? 0) OF \(store.state.book.sectionCount ?? 0)")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.gray)
            .padding(.top, 25)
    }
    
    private var sectionTitle: some View {
        Text("\(store.currentSection?.sectionTitle ?? "")")
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(.black)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .padding(.top, 5)
            .padding(.horizontal, 20)
    }
    
    private var progressView: some View {
        VStack {
            Slider(value: $store.currentTimeLineTime.sending(\.updateTimeLineCurrentTime) , in: 0...store.state.duration) {
            } minimumValueLabel: {
                progressViewLabel(store.state.currentTimeLocalized)
                    .frame(width: 40)
            } maximumValueLabel: {
                progressViewLabel(store.state.durationLocalized)
                    .frame(width: 40)
            } onEditingChanged: { editing in
                store.send(.timeLineValueChanged(editing))
            }
            
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Button {
                store.send(.speedButtonTapped)
            } label: {
                Text("Speed \(store.currentSpeed)")
                    .padding(10)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(.primary)
            .background(.gray.secondary.opacity(0.3))
            .clipShape(.rect(cornerRadius: 6))
            .padding(.top, 5)
        }
    }
    
    private func progressViewLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundStyle(.gray)
    }
    
    private var toolbar: some View {
        HStack(spacing: 25) {
            Button {
                store.send(.previousButtonTapped)
            } label: {
                Image(systemName: "backward.end.fill")
            }
            .font(.system(size: 28))
            .disabled(store.isFirstSection)
            
            
            Button {
                store.send(.goBackwardButtonTapped)
            } label: {
                Image(systemName: "gobackward.5")
            }
            .font(.system(size: 32))
            
            Button {
                store.send(.pauseButtonTapped)
            } label: {
                Image(systemName: store.isPaused ? "play.fill" : "pause.fill")
            }
            .font(.system(size: 40))
            .frame(width: 30, height: 30)
                
            
            Button {
                store.send(.goForwardButtonTapped)
            } label: {
                Image(systemName: "goforward.10")
            }
            .font(.system(size: 32))//
            
            Button {
                store.send(.nextButtonTapped)
            } label: {
                Image(systemName: "forward.end.fill")
            }
            .font(.system(size: 28))
            .disabled(store.isLastSection)
            
        }
        .buttonStyle(.plain)
        .padding(.top, 20)
    }
    
    private var modeToggle: some View {
        Toggle(isOn: $store.isSoundMode.sending(\.updateIsSoundOn)) {
            EmptyView()
        }
        .toggleStyle(ListeningModeToggleStyle())
        .padding(.bottom, 20)
    }
}
