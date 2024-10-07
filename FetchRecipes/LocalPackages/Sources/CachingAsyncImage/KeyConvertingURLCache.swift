//
//  KeyConvertingURLCache.swift
//
//
//  Created by Mihajlo Saric on 7.10.24..
//

import Foundation

/// A `URLCache` that runs the specified converter closure when storing and retrieving `CachedURLResponse` objects.
final class KeyConvertingURLCache: URLCache {

  /// The converter that will run on each cache read/write.
  /// - Note: This cannot be passed on init due to a runtime error with `URLCache`'s init.
  var cacheKeyConverter: (URL) -> URL? = { _ in nil }

  override func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
    let requestToRetrieve = request.convertUrlToCacheKey(cacheKeyConverter)
    return super.cachedResponse(for: requestToRetrieve)
  }

  override func getCachedResponse(
    for dataTask: URLSessionDataTask, completionHandler: @escaping (CachedURLResponse?) -> Void
  ) {
    guard let request = dataTask.originalRequest else {
      return super.getCachedResponse(for: dataTask, completionHandler: completionHandler)
    }

    completionHandler(cachedResponse(for: request))
  }

  override func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
    let requestToCache = request.convertUrlToCacheKey(cacheKeyConverter)
    super.storeCachedResponse(cachedResponse, for: requestToCache)
  }

  override func storeCachedResponse(
    _ cachedResponse: CachedURLResponse, for dataTask: URLSessionDataTask
  ) {
    guard let request = dataTask.originalRequest else {
      return super.storeCachedResponse(cachedResponse, for: dataTask)
    }

    storeCachedResponse(cachedResponse, for: request)
  }

  override func removeCachedResponse(for request: URLRequest) {
    let requestToRemove = request.convertUrlToCacheKey(cacheKeyConverter)
    super.removeCachedResponse(for: requestToRemove)
  }

  override func removeCachedResponse(for dataTask: URLSessionDataTask) {
    guard let request = dataTask.originalRequest else {
      return super.removeCachedResponse(for: dataTask)
    }

    removeCachedResponse(for: request)
  }
}

extension URLRequest {
  fileprivate func convertUrlToCacheKey(_ converter: (URL) -> URL?) -> URLRequest {
    guard let url else {
      return self
    }
    guard let convertedUrl = converter(url) else {
      return self
    }

    var newRequest = self
    newRequest.url = convertedUrl
    return newRequest
  }
}

