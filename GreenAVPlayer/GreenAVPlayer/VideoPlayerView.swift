//
//  ContentView.swift
//  GreenAVPlayer
//
//  Created by GREEN on 2023/03/23.
//

import SwiftUI
import AVKit

struct ContentView: View {
  let videoURLs: [String] = [
    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
    "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
  ]
  
  @State private var currentVisibleIndex: Int = 0
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        ForEach(videoURLs.indices, id: \.self) { index in
          VideoPlayerView(viewModel: VideoPlayerViewModel(contentURL: videoURLs[index]), isPlaying: Binding<Bool>(
            get: { self.currentVisibleIndex == index },
            set: { newValue in
              if newValue {
                self.currentVisibleIndex = index
              }
            })
          )
          .frame(height: UIScreen.main.bounds.height)
        }
      }
    }
    .ignoresSafeArea()
    .onAppear {
      UIScrollView.appearance().isPagingEnabled = true
    }
    .onChange(of: currentVisibleIndex) { newValue in
      print("Current visible index: \(newValue)")
    }
  }
}

public struct VideoPlayerView: View {
  @StateObject var viewModel: VideoPlayerViewModel
  @StateObject private var greenVideoPlayerViewModel = GreenVideoPlayerViewModel()
  @Binding var isPlaying: Bool
  
  public var body: some View {
    GeometryReader { geometry in
      let frame = geometry.frame(in: .global)
      let screenHeight = UIScreen.main.bounds.height
      let midY = frame.midY
      
      Color.clear
        .onAppear {
          greenVideoPlayerViewModel.media = Media(url: viewModel.contentURL)
          greenVideoPlayerViewModel.play()
        }
        .onChange(of: midY) { newValue in
          isPlaying = (midY > 0 && midY < screenHeight)
          if isPlaying {
            greenVideoPlayerViewModel.play()
          } else {
            greenVideoPlayerViewModel.pause()
          }
        }
        .onDisappear {
          greenVideoPlayerViewModel.pause()
        }
        .overlay(
          GreenVideoPlayer(viewModel: greenVideoPlayerViewModel)
        )
        .overlay(
          Button(action: { print(123123) }, label: { Text("gg")})
        )
        .overlay(
          RetryView(
            title: "This video file could not be played",
            remainingRetries: viewModel.remainingRetries,
            perform: {
              Task {
                let canRetryPlay = await viewModel.retryPlayVideo()
                if canRetryPlay {
                  greenVideoPlayerViewModel.play()
                }
              }
            }
          )
          .opacity(viewModel.canPlay ? 0 : 1)
        )
    }
  }
}

// MARK: - 재시도 뷰
private struct RetryView: View {
  var title: String
  var remainingRetries: Int
  var perform: () -> Void
  
  public init(
    title: String,
    remainingRetries: Int,
    perform: @escaping () -> Void
  ) {
    self.title = title
    self.remainingRetries = remainingRetries
    self.perform = perform
  }
  
  public var body: some View {
    VStack(alignment: .center, spacing: 10) {
      Spacer()
      
      Text(title)
        .foregroundColor(.white)
      
      Button(
        action: remainingRetries != 0 ? perform : {},
        label: {
          Text(
            remainingRetries != 0
            ? "Please try again"
            : "Please try again later"
          )
        }
      )
      .padding(.horizontal, 20)
      .padding(.vertical, 10)
      .foregroundColor(.white)
      .background(remainingRetries != 0 ? Color.blue : Color.red)
      .cornerRadius(10)
      .disabled(remainingRetries == 0)
      .padding(.bottom, 300)
    }
  }
}

// 스크롤 도중 영상 정지 되지 않게
// 컨트롤러 바 크기 수정 + 비디오 뷰 크기 수정 확인
// Lazy / isPage onAppear / onDisappear
