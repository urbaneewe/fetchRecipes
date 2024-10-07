//
//  ImageLoader.swift
//  
//
//  Created by Mihajlo Saric on 7.10.24..
//

import Combine
import Foundation
import SwiftUI

protocol ImageLoaderComponent {
  func loadStarted(url: URL, scale: CGFloat)
  func set(imageLoader: ImageLoader)
}

final class ImageLoader: ObservableObject {
  enum Error: Swift.Error {
    case urlSessionError(Swift.Error)
    case incorrectStatusCode(Int?)
    case incorrectDataType
  }

  enum ImageLoadingStatus {
    case success(uiImage: UIImage, data: Data, response: URLResponse)
    case failure(Error)
  }

  @Published var phase: AsyncImagePhase = .empty

  private let urlSession: URLSession

  private var loadingURL: URL?
  private var loadingImageCancellable: AnyCancellable?
  private let components: [ImageLoaderComponent]

  init(urlSession: URLSession = .asyncImage, components: ImageLoaderComponent...) {
    self.urlSession = urlSession
    self.components = components

    components.forEach { $0.set(imageLoader: self) }
  }

  func loadImage(at url: URL, scale: CGFloat) {
    components.forEach { $0.loadStarted(url: url, scale: scale) }

    let request = URLRequest(url: url)

    if let imageData = urlSession.configuration.urlCache?.cachedResponse(for: request)?.data,
      let image = UIImage(data: imageData, scale: scale)
    {
      phase = .success(Image(uiImage: image))
      return
    }

    guard url != loadingURL else { return }

    loadingImageCancellable = urlSession.dataTaskPublisher(for: url)
      .map { data, response in
        if !url.isFileURL {
          guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
            (200...299).contains(statusCode)
          else {
            return ImageLoadingStatus.failure(
              Error.incorrectStatusCode((response as? HTTPURLResponse)?.statusCode))
          }
        }

        guard let image = UIImage(data: data, scale: scale) else {
          return ImageLoadingStatus.failure(Error.incorrectDataType)
        }

        return ImageLoadingStatus.success(uiImage: image, data: data, response: response)
      }
      .catch { error in
        return Just(ImageLoadingStatus.failure(.urlSessionError(error)))
      }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] status in
        if self?.loadingURL == url {
          self?.loadingURL = nil
        }

        switch status {
        case .success(let uiImage, let data, let response):
          self?.urlSession.configuration.urlCache?.storeCachedResponse(
            CachedURLResponse(response: response, data: data), for: request)
          self?.phase = .success(Image(uiImage: uiImage))
        case .failure(let error):
          self?.phase = .failure(error)
        }
      }

    loadingURL = url
  }

  func cancelLoad() {
    loadingImageCancellable?.cancel()
    loadingImageCancellable = nil
  }
}
