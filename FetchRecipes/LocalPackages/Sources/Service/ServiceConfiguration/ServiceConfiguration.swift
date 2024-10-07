//
//  ServiceConfiguration.swift
//
//
//  Created by Mihajlo Saric on 7.10.24..
//

import Foundation

public struct ServiceConfiguration {
    public let baseURL: URL
    public let session: URLSession

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
}
