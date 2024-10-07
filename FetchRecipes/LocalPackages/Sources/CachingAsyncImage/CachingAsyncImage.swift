//
//  CachingAsyncImage.swift
//
//
//  Created by Mihajlo Saric on 7.10.24..
//

import SwiftUI

/// The current phase of the asynchronous image loading operation.
///
/// A custom implementation that exactly mirrors iOS 15's [AsyncImagePhase](https://developer.apple.com/documentation/swiftui/asyncimagephase) public API.
public enum AsyncImagePhase {
  case empty
  case success(Image)
  case failure(Error)

  public var image: Image? {
    switch self {
    case .success(let image):
      return image
    case .empty, .failure:
      return nil
    }
  }

  public var error: Error? {
    switch self {
    case .failure(let error):
      return error
    case .empty, .success:
      return nil
    }
  }
}

/// A view that asynchronously loads and displays an image.
///
/// - Attention: A custom implementation that mirrors iOS 15's [AsyncImage](https://developer.apple.com/documentation/swiftui/asyncimage) public API. It also adds additional caching/pre-loading behavior.
///
/// This view uses a custom `asyncImageSession`
/// <doc://com.apple.documentation/documentation/Foundation/URLSession>
/// instance to load an image from the specified URL, and then display it.
/// For example, you can display an icon that's stored on a server:
///
///     CachingAsyncImage(url: URL(string: "https://example.com/icon.png"))
///         .frame(width: 200, height: 200)
///
/// Until the image loads, the view displays a standard placeholder that
/// fills the available space. After the load completes successfully, the view
/// updates to display the image. In the example above, the icon is smaller
/// than the frame, and so appears smaller than the placeholder.
///
///
/// You can specify a custom placeholder using
/// ``init(url:scale:content:placeholder:)``. With this initializer, you can
/// also use the `content` parameter to manipulate the loaded image.
/// For example, you can add a modifier to make the loaded image resizable:
///
///     CachingAsyncImage(url: URL(string: "https://example.com/icon.png")) { image in
///         image.resizable()
///     } placeholder: {
///         ProgressView()
///     }
///     .frame(width: 50, height: 50)
///
/// For this example, SwiftUI shows a ``ProgressView`` first, and then the
/// image scaled to fit in the specified frame:
///
/// > Important: You can't apply image-specific modifiers, like
/// ``Image/resizable(capInsets:resizingMode:)``, directly to an `CachingAsyncImage`.
/// Instead, apply them to the ``Image`` instance that your `content`
/// closure gets when defining the view's appearance.
///
/// To gain more control over the loading process, use the
/// ``init(url:scale:transaction:content:)`` initializer, which takes a
/// `content` closure that receives an ``AsyncImagePhase`` to indicate
/// the state of the loading operation. Return a view that's appropriate
/// for the current phase:
///
///     CachingAsyncImage(url: URL(string: "https://example.com/icon.png")) { phase in
///         if let image = phase.image {
///             image // Displays the loaded image.
///         } else if phase.error != nil {
///             Color.red // Indicates an error.
///         } else {
///             Color.blue // Acts as a placeholder.
///         }
///     }
///
public struct CachingAsyncImage<Content: View>: View {
  @StateObject private var imageLoader = ImageLoader(components: NetworkStatusChanged())
  fileprivate let url: URL?
  fileprivate let scale: CGFloat
  fileprivate let content: (AsyncImagePhase) -> Content

  public init(
    url: URL?, scale: CGFloat = 1, transaction: Transaction = Transaction(),
    @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
  ) {
    self.url = url
    self.scale = scale
    self.content = content
  }

  public init<ImageView: View, Placeholder: View>(
    url: URL?, scale: CGFloat = 1, content: @escaping (Image) -> ImageView,
    placeholder: @escaping () -> Placeholder
  ) where Content == _ConditionalContent<ImageView, Placeholder> {
    self.init(url: url, scale: scale) { phase in
      switch phase {
      case .success(let image):
        content(image)
      case .empty, .failure:
        placeholder()
      }
    }
  }

  public init(url: URL?, scale: CGFloat = 1) where Content == Image {
    self.init(url: url, scale: scale) { phase in
      phase.image ?? Image("")
    }
  }

  private func loadImage(at url: URL?) {
    guard let url else { return }
    imageLoader.loadImage(at: url, scale: scale)
  }

  public var body: some View {
    content(imageLoader.phase)
      .onChange(of: url) { _, newUrl in
        imageLoader.phase = .empty
        loadImage(at: newUrl)
      }
      .onAppear {
        loadImage(at: url)
      }
      .onDisappear {
        imageLoader.cancelLoad()
      }
  }
}

extension CachingAsyncImage {
  public init(
    _ urlString: String?, scale: CGFloat = 1, transaction: Transaction = Transaction(),
    @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
  ) {
    self.init(
      url: urlString.flatMap { URL(string: $0) }, scale: scale, transaction: transaction,
      content: content)
  }

  public init<ImageView: View, Placeholder: View>(
    _ urlString: String?, scale: CGFloat = 1, content: @escaping (Image) -> ImageView,
    placeholder: @escaping () -> Placeholder
  ) where Content == _ConditionalContent<ImageView, Placeholder> {
    self.init(
      url: urlString.flatMap { URL(string: $0) }, scale: scale, content: content,
      placeholder: placeholder)
  }

  public init(_ urlString: String?, scale: CGFloat = 1) where Content == Image {
    self.init(url: urlString.flatMap { URL(string: $0) }, scale: scale)
  }

  public func resizable() -> some View where Content == Image {
    let currentContent = content
    return CachingAsyncImage(url: url, scale: scale) { phase in
      currentContent(phase).resizable()
    }
  }
}

extension URLSession {
  public static var cacheKeyConverter: (URL) -> URL? = { _ in nil }

  /// A session used within our custom `CachingAsyncImage`.
  /// Has a larger cache than `URLSession.shared`, which has a small cache not suitable for images.
  public static let asyncImage: URLSession = {
    let cachesURL =
      (try? FileManager.default.url(
        for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false))
      ?? FileManager.default.temporaryDirectory
    let diskCacheURL = cachesURL.appendingPathComponent(
      "\(Bundle.main.bundleIdentifier ?? #file).ImageCache")
    let cache = KeyConvertingURLCache(
      memoryCapacity: 10_000_000, diskCapacity: 1_000_000_000, directory: diskCacheURL)
    cache.cacheKeyConverter = cacheKeyConverter

    var configuration = URLSessionConfiguration.default
    configuration.urlCache = cache
    return URLSession(configuration: configuration)
  }()
}

struct CachingAsyncImage_Previews: PreviewProvider {
  static var previews: some View {
    CachingAsyncImage(
      url: URL(string: "https://houseparty-koala.s3.amazonaws.com/posters/updated/video2.jpg")
    ) { phase in
      if let image = phase.image {
        image  // Displays the loaded image.
      } else if phase.error != nil {
        Color.red  // Indicates an error.
      } else {
        Color.blue  // Acts as a placeholder.
      }
    }
    .frame(width: 50, height: 50)
  }
}

