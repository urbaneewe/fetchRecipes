//
//  RecipeView.swift
//  
//
//  Created by Mihajlo Saric on 7.10.24..
//

import SwiftUI
import CachingAsyncImage

struct RecipeView: View {
    let imageUrl: String

    var body: some View {
        VStack {
            CachingAsyncImage(url: URL(string: imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .foregroundStyle(.white)
                case .success(let image):
                    image
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 16)
                case .failure(_):
                    ProgressView()
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: 516)
        }
    }
}

#Preview {
    RecipeView(imageUrl: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg")
}
