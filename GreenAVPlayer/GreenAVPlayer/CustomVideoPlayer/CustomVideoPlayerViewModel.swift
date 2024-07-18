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
  @Published var isLoading: Bool = false
  @Published var error: Error?
  
  let player: AVPlayer
  private var playerItemStatusObserver: NSKeyValueObservation?
  
  init(prefetchedPlayer: AVPlayer?) {
    if let prefetchedPlayer = prefetchedPlayer {
      self.player = prefetchedPlayer
    } else {
      self.player = AVPlayer()
    }
    setAudioSessionCategory(to: .playback)
    setupBackgroundPlayback()
  }
  
  private func setAudioSessionCategory(to value: AVAudioSession.Category) {
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(value, mode: .default, options: [.defaultToSpeaker, .mixWithOthers])
      try audioSession.setActive(true)
    } catch {
      print("Setting category to AVAudioSessionCategoryPlayback failed.")
    }
  }
  
  private func setupBackgroundPlayback() {
    do {
      try AVAudioSession.sharedInstance().setCategory(
        .playback,
        mode: .default,
        options: [.mixWithOthers, .defaultToSpeaker]
      )
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("Failed to set audio session category.")
    }
  }
  
  func loadMedia(url: URL) {
    guard player.currentItem == nil else { return }
    
    isLoading = true
    error = nil
    
    let asset = AVURLAsset(url: url)
    let playerItem = AVPlayerItem(asset: asset)
    
    player.replaceCurrentItem(with: playerItem)
    observePlayerItemStatus(playerItem: playerItem)
  }
  
  private func observePlayerItemStatus(playerItem: AVPlayerItem) {
    playerItemStatusObserver = playerItem.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
      guard let self = self else { return }
      if item.status == .readyToPlay {
        self.isLoading = false
        if self.player.timeControlStatus != .playing {
          self.player.play()
        }
      } else if item.status == .failed {
        self.isLoading = false
        if let error = item.error {
          self.error = error
          print("Failed to load video: \(error.localizedDescription)")
        } else {
          print("Failed to load video: Unknown error")
        }
      }
    }
  }
  
  func play() {
    if player.currentItem?.status == .readyToPlay {
      player.play()
    }
  }
  
  func pause() {
    player.pause()
  }
  
  func resetAndPlay() {
    player.seek(to: .zero)
    play()
  }
}
