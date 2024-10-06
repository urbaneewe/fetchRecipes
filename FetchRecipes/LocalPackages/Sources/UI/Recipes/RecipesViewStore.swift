//
//  RecipesViewStore.swift
//
//
//  Created by Mihajlo Saric on 6.10.24..
//

import Foundation
import ViewStore

public final class RecipesViewStore: ViewStore {
    public enum ViewState: Equatable {
        case loading
        case failedToLoad
        case loaded
    }

    public enum Action {
      case refresh(isPullToRefresh: Bool)
    }

    @Published public private(set) var viewState: ViewState

    public init(viewState: ViewState) {
        self.viewState = viewState
    }

    public func send(_ action: Action) async {
      do {
        switch action {
        case .refresh(let isPullToRefresh):
            print("Refresh")
        }
      } catch {
          print("Log the error")
      }
    }

}
