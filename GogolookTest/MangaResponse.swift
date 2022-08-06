//
//  MangaResponse.swift
//  GogolookTest
//
//  Created by yoie on 2022/8/3.
//
import SwiftUI

struct MangaResponse: Codable {
    let data: [MangaData]
    let pagination: Pagination

}

struct Manga: Identifiable, Hashable, Codable {
    var id = UUID()
    let url: String
    let images: ImageType
    let title: String
    let rank: Int
    let published: PublishedDetail
    var isFavorite: Bool = false
    
    init(manga: MangaData) {
        images = manga.images
        title = manga.title
        rank = manga.rank
        published = manga.published
        url = manga.url
    }
    
    static func == (lhs: Manga, rhs: Manga) -> Bool {
          return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
       hasher.combine(id)
    }
}

struct MangaData: Codable {
    let url: String
    let images: ImageType
    let title: String
    let rank: Int
    let published: PublishedDetail
    
}

struct PublishedDetail: Codable {
    let from: String
    let to: String?
    init() {
        from = ""
        to =  ""
    }
}

extension Manga {
    init() {
        url = ""
        images = ImageType.init()
        title = ""
        rank = 0
        published = PublishedDetail.init()
        isFavorite = false
    }
}

