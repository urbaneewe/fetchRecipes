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

    public init(store: @escaping @autoclosure () -> RecipesViewStore) {
        _store = StateObject(wrappedValue: store())
    }

    public var body: some View {
        Group {
            switch store.viewState {
            case .loading:
                Text("Loading indicator")
            case .failedToLoad(let error):
                Text("Error view")
            case .loaded(let recipes):
                ZStack {
                    VStack {
                        Text("Recipes!")
                            .font(.system(size: 20))

                        ScrollView {
                            LazyVStack {
                                ForEach(recipes, id: \.id) { recipe in
                                    VStack {

                                        AsyncImage(url: URL(string: recipe.photoUrlLarge)) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                                    .padding(.horizontal, 16)
                                            case .failure(_):
                                                ProgressView()
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        .frame(width: UIScreen.main.bounds.width, height: 516)

                                        HStack {
                                            Spacer()
                                            Text(recipe.cuisine)
                                                .padding(12)
                                                .font(.title)
                                                .fontWeight(.bold)
                                            Spacer()
                                        }
                                        .background(.ultraThinMaterial)
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
                    .background(.red)
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

