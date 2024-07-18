//
//  PagingScrollView.swift
//  GreenAVPlayer
//
//  Created by GREEN on 7/17/24.
//

import SwiftUI

// MARK: - 수직 스크롤 뷰
public struct PagingScrollView<Content: View>: UIViewRepresentable {
  private var count: Int
  private var content: () -> Content
  
  public init(
    count: Int,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.count = count
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
    scrollView.bounces = false
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
      hostingController.view.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * CGFloat(count))
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
