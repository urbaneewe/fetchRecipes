//
//  RecipesViewStore.swift
//
//
//  Created by Mihajlo Saric on 6.10.24..
//

import Foundation
import ViewStore
import RecipesService

public final class RecipesViewStore: ViewStore {
    public enum ViewState {
        case loading
        case failedToLoad(Error)
        case loaded(_ recipes: [Recipe])
    }

    public enum Action {
        case refresh
        case loadRecipes
    }

    @Published public private(set) var viewState: ViewState = .loading
    private let recipeService: RecipeService

    @MainActor public init(viewState: ViewState, recipeService: RecipeService) {
        self.viewState = .loading
        self.recipeService = recipeService
    }

    public func send(_ action: Action) async {
        switch action {
        case .refresh:
            await fetchRecipes(showLoading: false)
        case .loadRecipes:
            await fetchRecipes(showLoading: true)
        }
    }

    @MainActor
        private func fetchRecipes(showLoading: Bool) async {
            if showLoading {
                viewState = .loading
            }

            do {
                let recipes = try await recipeService.fetchRecipes()
                viewState = .loaded(recipes)
            } catch {
                viewState = .failedToLoad(error)
                // Here we can implement a logger to log the error.
                print("Error fetching recipes: \(error)")
            }
        }
}
