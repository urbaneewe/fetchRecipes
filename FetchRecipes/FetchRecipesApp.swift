//
//  FetchRecipesApp.swift
//  FetchRecipes
//
//  Created by Mihajlo Saric on 6.10.24..
//

import SwiftUI
import RecipesService
import ServiceConfiguration

@main
struct FetchRecipesApp: App {
    let config = ServiceConfiguration(baseURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net")!)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppEnvironment(config: config))
        }
    }
}

class AppEnvironment: ObservableObject {
    let recipeService: RecipeService

    init(config: ServiceConfiguration) {
        self.recipeService = RecipeServiceImpl(config: config)
    }
}
