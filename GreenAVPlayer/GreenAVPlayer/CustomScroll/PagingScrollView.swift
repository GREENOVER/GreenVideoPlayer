//
//  PagingScrollView.swift
//  GreenAVPlayer
//
//  Created by GREEN on 7/17/24.
//

import SwiftUI

// MARK: - 수직 스크롤 뷰
public struct PagingScrollView<Content: View>: UIViewRepresentable {
  var content: () -> Content
  
  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  public func makeUIView(context: Context) -> UIScrollView {
    let scrollView = UIScrollView()
    scrollView.isPagingEnabled = true
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.delegate = context.coordinator
    
    let hostingController = context.coordinator.hostingController
    hostingController.rootView = content()
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    hostingController.view.backgroundColor = .clear
    
    scrollView.addSubview(hostingController.view)
    
    NSLayoutConstraint.activate([
      hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      // 수직 스크롤을 위함
      hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
    ])
    
    return scrollView
  }
  
  public func updateUIView(_ uiView: UIScrollView, context: Context) {
    if let hostingView = uiView.subviews.first {
      hostingView.setNeedsLayout()
      hostingView.layoutIfNeeded()
    }
  }
  
  public class Coordinator: NSObject, UIScrollViewDelegate {
    var parent: PagingScrollView
    var hostingController = UIHostingController<Content?>(rootView: nil)
    
    init(_ parent: PagingScrollView) {
      self.parent = parent
    }
  }
}
