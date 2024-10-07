//
//  RecipesView.swift
//
//
//  Created by Mihajlo Saric on 6.10.24..
//

import SwiftUI
import RecipesService
import BackgroundColorManager

public struct RecipesView: View {
    @StateObject private var store: RecipesViewStore
    private var colorManager: BackgroundColorManager

    public init(store: @escaping @autoclosure () -> RecipesViewStore, colorManager: BackgroundColorManager) {
        _store = StateObject(wrappedValue: store())
        self.colorManager = colorManager
    }

    public var body: some View {
        Group {
            switch store.viewState {
            case .loading:
                Text("Loading indicator")
            case .failedToLoad(let error):
                Text("Error view")
            case .loaded(let recipes):
                ZStack(alignment: .bottom) {
                    VStack {
                        Text("Recipes!")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        ScrollView {
                            LazyVStack {
                                ForEach(recipes, id: \.id) { recipe in
                                    VStack {
                                        GeometryReader { geometry in
                                            RecipeView(imageUrl: recipe.photoUrlLarge)
                                            .onAppear {
                                                colorManager.updateBackgroundColor(
                                                    for: recipe.photoUrlLarge,
                                                    geometry: geometry)
                                            }
                                            .onChange(of: geometry.frame(in: .global).midY) {
                                                colorManager.updateBackgroundColor(
                                                    for: recipe.photoUrlLarge,
                                                    geometry: geometry)
                                            }
                                        }
                                        .frame(height: 516)

                                        HStack {
                                            Spacer()
                                            Text(recipe.cuisine)
                                                .padding(12)
                                                .font(.title)
                                                .fontWeight(.bold)
                                            Spacer()
                                        }
                                        .background(colorManager.backgroundColor)
                                        .clipShape(Capsule())
                                        .padding(.horizontal, 12)

                                        HStack {
                                            Spacer()
                                            Text(recipe.name)
                                                .padding(12)
                                            Spacer()
                                        }
                                        .background(.ultraThinMaterial)
                                        .clipShape(Capsule())
                                        .padding(.horizontal, 12)
                                        .padding(.bottom, 60)
                                    }
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                colorManager.backgroundColor,
                                .black
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
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

