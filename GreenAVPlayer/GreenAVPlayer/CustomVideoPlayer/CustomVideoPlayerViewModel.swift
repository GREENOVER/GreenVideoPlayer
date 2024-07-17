//
//  CustomVideoPlayerViewModel.swift
//  CustomVideoPlayer
//
//  Created by GREEN on 2023/03/23.
//

import AVKit
import Combine

final public class CustomVideoPlayerViewModel: ObservableObject {
  @Published var pipStatus: PipStatus = .unowned
  @Published var media: Media?
  
  let player = AVPlayer()
  private var cancellable: AnyCancellable?
  private var playerItemStatusObserver: NSKeyValueObservation?
  
  public init() {
    setAudioSessionCategory(to: .playback)
    cancellable = $media
      .compactMap({ $0 })
      .compactMap({ URL(string: $0.url) })
      .sink(receiveValue: { [weak self] url in
        guard let self = self else { return }
        self.loadPlayerItem(url: url)
      })
  }
  
  private func setAudioSessionCategory(to value: AVAudioSession.Category) {
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(value)
    } catch {
      print("Setting category to AVAudioSessionCategoryPlayback failed.")
    }
  }
  
  private func loadPlayerItem(url: URL) {
    DispatchQueue.global().async {
      let asset = AVURLAsset(url: url)
      let playerItem = AVPlayerItem(asset: asset)
      DispatchQueue.main.async {
        self.player.replaceCurrentItem(with: playerItem)
        self.observePlayerItemStatus(playerItem: playerItem)
      }
    }
  }
  
  private func observePlayerItemStatus(playerItem: AVPlayerItem) {
    playerItemStatusObserver = playerItem.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
      guard let self = self else { return }
      if item.status == .readyToPlay {
        self.player.play()
      } else if item.status == .failed {
        print("Failed to load video: \(String(describing: item.error))")
      }
    }
  }
  
  // 영상 재생
  func play() {
    if player.currentItem?.status == .readyToPlay {
      player.play()
    }
  }
  
  // 영상 정지
  func pause() {
    player.pause()
    player.seek(to: .zero)
  }
}
