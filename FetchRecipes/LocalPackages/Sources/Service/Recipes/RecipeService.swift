//
//  RecipeService.swift
//
//
//  Created by Mihajlo Saric on 6.10.24..
//

import Foundation
import ServiceConfiguration

// MARK: - Errors

enum RecipeServiceError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse
    case serverError(statusCode: Int)
}

// MARK: - RecipeService Protocol

public protocol RecipeService {
    func fetchRecipes() async throws -> [Recipe]
}

// MARK: - RecipeService Implementation

final public class RecipeServiceImpl: RecipeService {
    private let config: ServiceConfiguration

    public init(config: ServiceConfiguration) {
        self.config = config
    }

    public func fetchRecipes() async throws -> [Recipe] {
        let endpoint = config.baseURL.appendingPathComponent("recipes")

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
            return try await config.session.data(from: url)
        } catch {
            throw RecipeServiceError.networkError(error)
        }
    }
}
