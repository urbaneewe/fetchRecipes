//
//  RecipesViewStoreTests.swift
//  
//
//  Created by Mihajlo Saric on 8.10.24..
//

import XCTest
@testable import RecipesUI
@testable import RecipesService

class RecipesViewStoreTests: XCTestCase {
    var sut: RecipesViewStore!
    var mockRecipeService: MockRecipeService!

    @MainActor override func setUp() {
        super.setUp()
        mockRecipeService = MockRecipeService()
        sut = RecipesViewStore(viewState: .loading, recipeService: mockRecipeService)
    }

    override func tearDown() {
        sut = nil
        mockRecipeService = nil
        super.tearDown()
    }

    func testLoadRecipes_Success() async {
        // Given
        let expectedRecipes = [Recipe.mock(), Recipe.mock()]
        mockRecipeService.mockRecipes = expectedRecipes

        // When
        await sut.send(.loadRecipes)

        // Then
        if case .loaded(let recipes) = sut.viewState {
            XCTAssertEqual(recipes, expectedRecipes)
        } else {
            XCTFail("Expected .loaded state, got \(sut.viewState)")
        }
    }

    func testLoadRecipes_Empty() async {
        // Given
        mockRecipeService.mockRecipes = []

        // When
        await sut.send(.loadRecipes)

        // Then
        if case .loaded(let recipes) = sut.viewState {
            XCTAssertTrue(recipes.isEmpty)
        } else {
            XCTFail("Expected .loaded state with empty array, got \(sut.viewState)")
        }
    }

    func testLoadRecipes_Error() async {
        // Given
        mockRecipeService.mockError = NSError(domain: "TestError", code: 0, userInfo: nil)

        // When
        await sut.send(.loadRecipes)

        // Then
        if case .failedToLoad(let error) = sut.viewState {
            XCTAssertNotNil(error)
        } else {
            XCTFail("Expected .failedToLoad state, got \(sut.viewState)")
        }
    }

    func testRefresh() async {
        // Given
        let expectedRecipes = [Recipe.mock()]
        mockRecipeService.mockRecipes = expectedRecipes

        // When
        await sut.send(.refresh)

        // Then
        if case .loaded(let recipes) = sut.viewState {
            XCTAssertEqual(recipes, expectedRecipes)
        } else {
            XCTFail("Expected .loaded state, got \(sut.viewState)")
        }
    }
}

class MockRecipeService: RecipeService {
    var mockRecipes: [Recipe] = []
    var mockError: Error?

    func fetchRecipes() async throws -> [Recipe] {
        if let mockError = mockError {
            throw mockError
        }
        return mockRecipes
    }
}

extension Recipe {
    static func mock() -> Recipe {
        Recipe(id: UUID(),
               cuisine: "Italian",
               name: "Spaghetti Carbonara",
               photoUrlLarge: "https://example.com/large.jpg",
               photoUrlSmall: "https://example.com/small.jpg",
               sourceUrl: "https://example.com/recipe",
               youtubeUrl: "https://youtube.com/watch?v=123"
        )
    }
}
