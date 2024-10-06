//
//  RecipeModel.swift
//
//
//  Created by Mihajlo Saric on 6.10.24..
//

import Foundation


struct Recipe: Codable, Identifiable {
    let id: UUID
    let cuisine: String
    let name: String
    let photoUrlLarge: URL
    let photoUrlSmall: URL
    let sourceUrl: URL?
    let youtubeUrl: URL?

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
    init(from decoder: Decoder) throws {
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
