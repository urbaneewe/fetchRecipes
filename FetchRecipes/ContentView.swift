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
import BackgroundColorManager

struct ContentView: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @State private var colorManager = BackgroundColorManager()

    var body: some View {
        RecipesView(store: {
            RecipesViewStore(
                viewState: .loading,
                recipeService: appEnvironment.recipeService
            )
        }(), colorManager: colorManager)
    }
}

#Preview {
    ContentView()
}
