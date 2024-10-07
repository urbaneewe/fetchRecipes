//
//  RecipesView.swift
//
//
//  Created by Mihajlo Saric on 6.10.24..
//

import SwiftUI

public struct RecipesView: View {
    @StateObject private var store: RecipesViewStore

    public init(store: @autoclosure @escaping () -> RecipesViewStore) {
        _store = StateObject(wrappedValue: store())
    }

    public var body: some View {
        switch store.viewState {
        case .loading:
            Text("Loading indicator")
        case .failedToLoad(let error):
            Text("Error view")
        case .loaded(let recipes):
            Text("Actual UI")
        }
    }
}

