//
//  MockURLSession.swift
//
//
//  Created by Mihajlo Saric on 8.10.24..
//

import ServiceConfiguration
import XCTest

class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let mockError = mockError {
            throw mockError
        }
        return (mockData ?? Data(), mockResponse ?? URLResponse())
    }
}
