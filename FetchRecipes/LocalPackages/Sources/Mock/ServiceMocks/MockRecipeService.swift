//
//  MockRecipeService.swift
//  
//
//  Created by Mihajlo Saric on 8.10.24..
//

import RecipesService

public class MockRecipeService: RecipeService {
    public var result: Result<[Recipe], Error>

    public init(result: Result<[Recipe], Error>) {
        self.result = result
    }

    public func fetchRecipes() async throws -> [Recipe] {
        switch result {
        case .success(let recipes):
            return recipes
        case .failure(let error):
            throw error
        }
    }
}
