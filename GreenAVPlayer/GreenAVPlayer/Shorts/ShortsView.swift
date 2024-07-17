//
//  ShortsView.swift
//  GreenAVPlayer
//
//  Created by GREEN on 7/17/24.
//

import SwiftUI
import AVKit

public struct ShortsView: View {
  @StateObject var viewModel: ShortsViewModel
  @StateObject private var customVideoPlayerViewModel = CustomVideoPlayerViewModel()
  @Binding var isPlaying: Bool
  
  public var body: some View {
    GeometryReader { geometry in
      let frame = geometry.frame(in: .global)
      let screenHeight = UIScreen.main.bounds.height
      let midY = frame.midY
      
      Color.clear
        .onAppear {
          customVideoPlayerViewModel.media = Media(url: viewModel.contentURL)
          customVideoPlayerViewModel.play()
        }
        .onChange(of: midY) { newValue in
          isPlaying = (midY > 0 && midY < screenHeight)
          if isPlaying {
            customVideoPlayerViewModel.play()
          } else {
            customVideoPlayerViewModel.pause()
          }
        }
        .onDisappear {
          customVideoPlayerViewModel.pause()
        }
        .overlay(
          CustomVideoPlayer(viewModel: customVideoPlayerViewModel)
        )
        .overlay(
          VStack {
            HStack {
              Spacer()
              
              Button(
                action: {
                  UIApplication.shared.open(URL(string: "https://www.lifeplus.co.kr")!)
                },
                label: {
                  Text("이동")
                }
              )
                .padding(.trailing, 20)
            }
            .padding(.top, 20)
            
            Spacer()
          }
        )
        .overlay(
          RetryView(
            title: "This video file could not be played",
            remainingRetries: viewModel.remainingRetries,
            perform: {
              Task {
                let canRetryPlay = await viewModel.retryPlayVideo()
                if canRetryPlay {
                  customVideoPlayerViewModel.play()
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
