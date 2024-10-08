//
//  RecipeServiceTests.swift
//  
//
//  Created by Mihajlo Saric on 8.10.24..
//

import XCTest
@testable import RecipesService
@testable import ServiceConfiguration

class RecipeServiceTests: XCTestCase {
    var sut: RecipeServiceImpl!
    var mockURLSession: MockURLSession!

    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        let config = ServiceConfiguration(baseURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net")!, session: mockURLSession)
        sut = RecipeServiceImpl(config: config)
    }

    override func tearDown() {
        sut = nil
        mockURLSession = nil
        super.tearDown()
    }

    func testFetchRecipes_Success() async throws {
        // Given
        let jsonData = """
        {
            "recipes": [
                {
                    "uuid": "123e4567-e89b-12d3-a456-426614174000",
                    "name": "Spaghetti Carbonara",
                    "cuisine": "Italian",
                    "photo_url_large": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
                    "photo_url_small": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
                    "source_url": "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
                    "youtube_url": "https://www.youtube.com/watch?v=6R8ffRRJcrg"
                }
            ]
        }
        """.data(using: .utf8)!

        mockURLSession.mockData = jsonData
        mockURLSession.mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        // When
        let recipes = try await sut.fetchRecipes()

        // Then
        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes[0].name, "Spaghetti Carbonara")
        XCTAssertEqual(recipes[0].cuisine, "Italian")
    }

    func testFetchRecipes_EmptyResponse() async throws {
        // Given
        let jsonData = """
        {
            "recipes": []
        }
        """.data(using: .utf8)!

        mockURLSession.mockData = jsonData
        mockURLSession.mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        // When
        let recipes = try await sut.fetchRecipes()

        // Then
        XCTAssertTrue(recipes.isEmpty)
    }

    func testFetchRecipes_MalformedResponse() async {
        // Given
        let jsonData = """
        {
            "recipes": [
                {
                    "invalid_field": "This will cause a decoding error"
                }
            ]
        }
        """.data(using: .utf8)!

        mockURLSession.mockData = jsonData
        mockURLSession.mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        // When/Then
        do {
            _ = try await sut.fetchRecipes()
            XCTFail("Expected decoding error")
        } catch {
            XCTAssertTrue(error is RecipeServiceError)
            if case RecipeServiceError.decodingError = error {
                // Expected error
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }
}
