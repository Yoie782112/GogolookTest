//
//  Anime.swift
//  GogolookTest
//
//  Created by yoie on 2022/8/3.
//
import SwiftUI

struct AnimeResponse: Codable{
    let data: [AnimeData]
    let pagination: Pagination
}

struct Anime: Identifiable, Hashable, Codable {
    var id = UUID()
    let url: String
    let images: ImageType
    let title: String
    let rank: Int
    let aired: AiredDetail
    var isFavorite: Bool = false
    
    init(anime: AnimeData) {
        images = anime.images
        title = anime.title
        rank = anime.rank
        aired = anime.aired
        url = anime.url
    }
    
    static func == (lhs: Anime, rhs: Anime) -> Bool {
          return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
       hasher.combine(id)
    }
}

struct AnimeData: Codable {
    let url: String
    let images: ImageType
    let title: String
    let rank: Int
    let aired: AiredDetail
}

struct ImageType: Codable {
    let jpg: ImageContent
    let webp: ImageContent
    init() {
        jpg = ImageContent.init()
        webp = ImageContent.init()
    }
}

struct ImageContent: Codable {
    let imageUrl: String
    let smallImageUrl: String
    let largeImageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
        case smallImageUrl = "small_image_url"
        case largeImageUrl = "large_image_url"
    }
    
    init() {
        imageUrl = ""
        smallImageUrl = ""
        largeImageUrl = ""
    }
}

struct AiredDetail: Codable {
    let from: String
    let to: String?
    init() {
        from = ""
        to =  ""
    }
}

struct Pagination: Codable {
    var lastVisiblePage: Int
    var hasNextPage: Bool
    var currentPage: Int
    
    enum CodingKeys: String, CodingKey {
        case lastVisiblePage = "last_visible_page"
        case hasNextPage = "has_next_page"
        case currentPage = "current_page"
    }
}

extension Anime {
    init() {
        url = ""
        images = ImageType.init()
        title = ""
        rank = 0
        aired = AiredDetail.init()
        isFavorite = false
    }
}

extension Pagination {
    init() {
        lastVisiblePage = 0
        hasNextPage = true
        currentPage = 1
    }
}


