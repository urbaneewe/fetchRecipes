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
                ProgressView()
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            case .failedToLoad(_):
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.red)

                    Text("An error has occured!")

                    Button {
                        Task { await store.send(.refresh) }
                    } label: {
                        Text("Refresh")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .foregroundStyle(.white)
                }
            case .loaded(let recipes):
                ZStack(alignment: .bottom) {
                    VStack {
                        if recipes.isEmpty {
                            Text("No Recipes at this time!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, 30)
                        } else {
                            Text("Recipes!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, 10)
                        }

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
                .refreshable {
                    await store.send(.refresh)
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
