//
//  NetworkStatusChanged.swift
//
//
//  Created by Mihajlo Saric on 7.10.24..
//

import Foundation

/// This class is used to expand the functionality of ImageLoader
/// It keep the image url and scale and listens for the network changes.
/// When network is not available, the downlkoad request will fail.
/// When neetwork is back again, this class checks current status of the last download.
/// If the status was failed, it will retry the download.
class NetworkStatusChanged: ImageLoaderComponent {
  private weak var imageLoader: ImageLoader?
  private var cancellable: Any?
  private var context: (url: URL, scale: CGFloat)?

  init(notificationCenter: NotificationCenter = .default) {
    cancellable = notificationCenter.addObserver(
      forName: .networkStatusMonitorStatusChanged,
      object: nil,
      queue: .main
    ) { [weak self] notification in
      guard
        let self,
        let imageLoader = self.imageLoader,
        let isConnected = notification.userInfo?["isConnected"] as? Bool,
        isConnected
      else {
        return
      }
      guard case .failure(_) = imageLoader.phase else {
        return
      }

      self.retry()
    }
  }

  func set(imageLoader: ImageLoader) {
    self.imageLoader = imageLoader
  }

  func loadStarted(url: URL, scale: CGFloat) {
    context = (url, scale)
  }

  func retry() {
    guard let imageLoader, let (url, scale) = context else { return }
    imageLoader.loadImage(at: url, scale: scale)
  }
}

