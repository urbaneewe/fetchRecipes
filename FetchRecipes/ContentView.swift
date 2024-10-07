//
//  ContentView.swift
//  FetchRecipes
//
//  Created by Mihajlo Saric on 6.10.24..
//

import SwiftUI
import RecipesUI
import RecipesService
import ServiceConfiguration

struct ContentView: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment

    var body: some View {
        RecipesView(store: {
            RecipesViewStore(
                viewState: .loading,
                recipeService: appEnvironment.recipeService
            )
        }())
    }
}

#Preview {
    ContentView()
}
