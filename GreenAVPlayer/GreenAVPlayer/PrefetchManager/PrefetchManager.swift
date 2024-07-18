//
//  PrefetchManager.swift
//  GreenAVPlayer
//
//  Created by GREEN on 7/18/24.
//

import AVKit
import Combine

public class PrefetchManager: ObservableObject {
  private var prefetchedPlayers: [String: AVPlayer] = [:]
  private let prefetchCount = 2
  
  func updatePrefetchIndex(currentIndex: Int, urls: [String]) {
    let startIndex = max(0, currentIndex - 1)
    let endIndex = min(urls.count - 1, currentIndex + prefetchCount)
    
    for index in startIndex...endIndex {
      let url = urls[index]
      if prefetchedPlayers[url] == nil {
        prefetchPlayer(for: url)
      }
    }
    
    prefetchedPlayers = prefetchedPlayers.filter { (key, _) in
      urls[startIndex...endIndex].contains(key)
    }
  }
  
  private func prefetchPlayer(for urlString: String) {
    guard let url = URL(string: urlString) else { return }
    let asset = AVURLAsset(url: url)
    let playerItem = AVPlayerItem(asset: asset)
    let player = AVPlayer(playerItem: playerItem)
    prefetchedPlayers[urlString] = player
  }
  
  func getPlayer(for urlString: String) -> AVPlayer? {
    return prefetchedPlayers[urlString]
  }
}
