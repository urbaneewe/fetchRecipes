//
//  RecipesView.swift
//
//
//  Created by Mihajlo Saric on 6.10.24..
//

import SwiftUI
import RecipesService

public struct RecipesView: View {
    @StateObject private var store: RecipesViewStore

    public init(recipeService: RecipeService) {
        _store = StateObject(wrappedValue: RecipesViewStore(viewState: .loading, recipeService: recipeService))
    }

    public var body: some View {
        Group {
            switch store.viewState {
            case .loading:
                Text("Loading indicator")
            case .failedToLoad(let error):
                Text("Error view")
            case .loaded(let recipes):
                List {
                    ForEach(recipes) { recipe in
                        Text(recipe.cuisine)
                    }
                }
            }
        }
        .onAppear {
            Task {
                await store.send(.loadRecipes)
            }
        }
    }
}

