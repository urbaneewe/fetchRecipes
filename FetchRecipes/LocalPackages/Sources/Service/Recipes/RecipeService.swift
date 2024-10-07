//
//  RecipeService.swift
//
//
//  Created by Mihajlo Saric on 6.10.24..
//

import Foundation

// MARK: - Errors

enum RecipeServiceError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse
    case serverError(statusCode: Int)
}

// MARK: - RecipeService Protocol

protocol RecipeServiceProtocol {
    func fetchRecipes() async throws -> [Recipe]
}

// MARK: - RecipeService Implementation

final class RecipeService: RecipeServiceProtocol {
    private let session: URLSession
    private let baseURL: URL

    init(session: URLSession = .shared, baseURL: URL) {
        self.session = session
        self.baseURL = baseURL
    }

    func fetchRecipes() async throws -> [Recipe] {
        let endpoint = baseURL.appendingPathComponent("recipes")

        let (data, response) = try await performRequest(for: endpoint)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RecipeServiceError.invalidResponse
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw RecipeServiceError.serverError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            let recipeResponse = try decoder.decode(RecipeResponse.self, from: data)
            return recipeResponse.recipes
        } catch {
            throw RecipeServiceError.decodingError(error)
        }
    }

    private func performRequest(for url: URL) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(from: url)
        } catch {
            throw RecipeServiceError.networkError(error)
        }
    }
}
