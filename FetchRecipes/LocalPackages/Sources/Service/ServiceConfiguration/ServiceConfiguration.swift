//
//  ServiceConfiguration.swift
//
//
//  Created by Mihajlo Saric on 7.10.24..
//

import Foundation

public protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

public struct ServiceConfiguration {
    public let baseURL: URL
    public let session: URLSessionProtocol

    public init(baseURL: URL, session: URLSessionProtocol = URLSession.shared) {
        self.baseURL = baseURL
        self.session = session
    }
}
