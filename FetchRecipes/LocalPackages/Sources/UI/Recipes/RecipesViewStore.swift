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
      case refresh(isPullToRefresh: Bool)
    }

    @Published public private(set) var viewState: ViewState
    private let recipeService: RecipeService

    @MainActor public init(viewState: ViewState, recipeService: RecipeService) {
        self.viewState = .loading
        self.recipeService = recipeService
    }

    public func send(_ action: Action) async {
      do {
        switch action {
        case .refresh(let isPullToRefresh):
            if !isPullToRefresh {
                viewState = .loading
            }
            do {
                let recipes = try await recipeService.fetchRecipes()
                viewState = .loaded(recipes)
            } catch {
                viewState = .failedToLoad(error)
            }
        }
      } catch {
          print("Here we can implement a logger to log the error.")
      }
    }

}
