//
//  RecipeModel.swift
//
//
//  Created by Mihajlo Saric on 6.10.24..
//

import Foundation

public struct RecipeResponse: Codable {
    public let recipes: [Recipe]
}

public struct Recipe: Codable, Identifiable {
    public let id: UUID
    public let cuisine: String
    public let name: String
    public let photoUrlLarge: URL
    public let photoUrlSmall: URL
    public let sourceUrl: URL?
    public let youtubeUrl: URL?

    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case cuisine
        case name
        case photoUrlLarge = "photo_url_large"
        case photoUrlSmall = "photo_url_small"
        case sourceUrl = "source_url"
        case youtubeUrl = "youtube_url"
    }
}

extension Recipe {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        cuisine = try container.decode(String.self, forKey: .cuisine)
        name = try container.decode(String.self, forKey: .name)
        photoUrlLarge = try container.decode(URL.self, forKey: .photoUrlLarge)
        photoUrlSmall = try container.decode(URL.self, forKey: .photoUrlSmall)
        sourceUrl = try? container.decodeIfPresent(URL.self, forKey: .sourceUrl)
        youtubeUrl = try? container.decodeIfPresent(URL.self, forKey: .youtubeUrl)
    }
}
