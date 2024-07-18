//
//  ContentView.swift
//  GreenAVPlayer
//
//  Created by GREEN on 2023/03/23.
//

import SwiftUI
import AVKit

// MARK: - 오직 SwiftUI (트라이브에 올려서 페이징 확인 필요) - 1안
//struct ContentView: View {
//  let videoURLs: [String] = [
//    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
//    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
//    "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
//    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
//  ]
//  
//  @State private var currentVisibleIndex: Int = 0
//  
//  var body: some View {
//    ScrollView(showsIndicators: false) {
//      LazyVStack(spacing: 0) {
//        ForEach(videoURLs.indices, id: \.self) { index in
//          VStack(spacing: 0) {
//            // 영상 해당 사이즈에 맞게 노출을 위한 스페이서
//            Spacer()
//              .frame(minHeight: 0)
//            
//            ShortsView(
//              viewModel: ShortsViewModel(contentURL: videoURLs[index]),
//              isPlaying: Binding<Bool>(
//                get: { self.currentVisibleIndex == index },
//                set: { newValue in
//                  if newValue {
//                    self.currentVisibleIndex = index
//                  }
//                }
//              )
//            )
//            
//            // 영상 해당 사이즈에 맞게 노출을 위한 스페이서
//            Spacer()
//              .frame(minHeight: 0)
//          }
//          .frame(height: UIScreen.main.bounds.height)
//        }
//      }
//    }
//    .ignoresSafeArea()
//    .onAppear {
//      UIScrollView.appearance().isPagingEnabled = true
//    }
//    .onDisappear {
//      UIScrollView.appearance().isPagingEnabled = false
//    }
//  }
//}


// MARK: - UIKit으로 래핑함 (정상 동작 확인) - 2안
struct ContentView: View {
  let videoURLs: [String] = [
    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
    "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
  ]
  
  @State private var currentVisibleIndex: Int = 0
  
  var body: some View {
    PagingScrollView(count: videoURLs.count) {
      LazyVStack(spacing: 0) {
        ForEach(videoURLs.indices, id: \.self) { index in
          GeometryReader { geometry in
            if isViewVisible(geometry: geometry) {
              VStack(spacing: 0) {
                Spacer()
                  .frame(minHeight: 0)
                
                ShortsView(
                  viewModel: ShortsViewModel(contentURL: videoURLs[index]),
                  isPlaying: Binding<Bool>(
                    get: { self.currentVisibleIndex == index },
                    set: { newValue in
                      if newValue {
                        self.currentVisibleIndex = index
                      }
                    }
                  )
                )
                
                Spacer()
                  .frame(minHeight: 0)
              }
              .frame(height: UIScreen.main.bounds.height)
            } else {
              Color.clear.frame(height: UIScreen.main.bounds.height)
            }
          }
          .frame(height: UIScreen.main.bounds.height)
        }
      }
      .ignoresSafeArea()
    }
    .ignoresSafeArea()
  }
  
  private func isViewVisible(geometry: GeometryProxy) -> Bool {
    let frame = geometry.frame(in: .global)
    return frame.intersects(UIScreen.main.bounds)
  }
}


// MARK: - 가로 스크롤 (썸네일 클릭하여 하나의 영상으로 접근)
//struct ContentView: View {
//  let videoURLs: [String] = [
//    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
//    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
//    "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
//    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
//  ]
//  let thumbnails: [Color] = [
//    .blue,
//    .orange,
//    .yellow,
//    .green
//  ]
//  
//  @State private var selectedVideoIndex: Int?
//  @State private var isShowingShortsView = false
//  
//  var body: some View {
//    ScrollView(.horizontal) {
//      HStack(spacing: 10) {
//        ForEach(thumbnails.indices, id: \.self) { index in
//          Button(action: {
//            self.selectedVideoIndex = index
//            self.isShowingShortsView = true
//          }) {
//            Rectangle()
//              .foregroundColor(thumbnails[index])
//          }
//          .frame(width: 100, height: 200)
//          .sheet(
//            isPresented: $isShowingShortsView,
//            onDismiss: {
//              self.selectedVideoIndex = nil
//            },
//            content: {
//              if let index = self.selectedVideoIndex {
//                VStack(spacing: 0) {
//                  Spacer()
//                    .frame(minHeight: 0)
//                  
//                  ShortsView(
//                    viewModel: ShortsViewModel(contentURL: videoURLs[index]),
//                    isPlaying: .constant(true)
//                  )
//                  
//                  Spacer()
//                    .frame(minHeight: 0)
//                }
//              }
//            }
//          )
//        }
//      }
//    }
//  }
//}


// MARK: - 프리패칭
