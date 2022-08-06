//
//  HomeViewModel.swift
//  GogolookTest
//
//  Created by yoie on 2022/8/3.
//

import SwiftUI

enum MangaType: String, CaseIterable, Identifiable {
    case none
    case manga
    case novel
    case lightnovel
    case oneshot
    case doujin
    case manhwa
    case manhua
    
    var id: String { return self.rawValue }

}

enum MangaFilter: String, CaseIterable, Identifiable {
    case none
    case publishing
    case upcoming
    case bypopularity
    case favorite
    
    var id: String { return self.rawValue }
}

struct MangaQuerys {
    var filter: MangaFilter = .none
    var type: MangaType = .none
}

enum AnimeType: String, CaseIterable, Identifiable  {
    case none
    case tv
    case movie
    case ova
    case special
    case ona
    case music
    
    var id: String { return self.rawValue }
}

enum AnimeFilter: String, CaseIterable, Identifiable  {
    case none
    case airing
    case upcoming
    case bypopularity
    case favorite
    
    var id: String { return self.rawValue }
}

struct AnimeQuerys {
    var filter: AnimeFilter = .none
    var type: AnimeType = .none
}

protocol FavoriteProtocol {
    func getImage() -> String
    func getTitle() -> String

}

struct FavoritItem: FavoriteProtocol, Codable, Identifiable {
    func getImage() -> String {
        if anime != nil {
            return anime?.images.jpg.largeImageUrl ?? ""
        } else {
            return manga?.images.jpg.largeImageUrl ?? ""
        }
    }
    
    func getTitle() -> String {
        if anime != nil {
            return anime?.title ?? ""
        } else {
            return manga?.title ?? ""
        }
    }
    var id = UUID()
    var anime: Anime?
    var manga: Manga?
    
}

class HomeViewModel: ObservableObject {
    var paginations = (anime: Pagination.init(), manga: Pagination.init())
    @Published var mangaQuerys = MangaQuerys()
    @Published var animeQuerys = AnimeQuerys()

    @Published var webUrl: String?
    @Published var animeList: [Anime] = []
    @Published var mangaList: [Manga] = []
    @Published var favoriteList: [FavoritItem] = [] {
        didSet {
            setFavoriteList()
        }
    }
    @Published var selectedTab: ContentTab = .manga

    init(){
        getFavoriteList()
    }
    
    func checkIfLikedForManga(list: inout [Manga]) {
        for index in 0 ... list.count-1 {
            for favor in favoriteList {
                if favor.getTitle() == list[index].title {
                    list[index].isFavorite = true
                }
            }
        }
    }
    
    func checkIfLikedForAnime(list: inout [Anime]) {
        for index in 0 ... list.count-1 {
            for favor in favoriteList {
                if favor.getTitle() == list[index].title {
                    list[index].isFavorite = true
                }
            }
        }
    }
    
    func getFavoriteList() {
        if let data = UserDefaults.standard.data(forKey: "favors") {
            do {
                let decoder = JSONDecoder()
                let favors = try decoder.decode([FavoritItem].self, from: data)
                self.favoriteList = favors
            } catch {
                print("Unable to Decode Notes (\(error))")
            }
        }
    }
    
    func setFavoriteList() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self.favoriteList)
            UserDefaults.standard.set(data, forKey: "favors")

        } catch {
            print("Unable to Encode Array of favors (\(error))")
        }
    }
    
    func getAnimeList(loadMore: Bool = false, newQuery: Bool = false){
        var queryItems = [URLQueryItem(name: "type", value: animeQuerys.type.rawValue),
                          URLQueryItem(name: "filter", value: animeQuerys.filter.rawValue)]
        if loadMore && paginations.anime.hasNextPage {
            queryItems.append(URLQueryItem(name: "page", value: String(paginations.anime.currentPage + 1)))
        }
        var urlComps = URLComponents(string: "https://api.jikan.moe/v4/top/anime")!
        urlComps.queryItems = queryItems
        let url = urlComps.url!
        URLSession.shared.dataTask(with: url) { data, response, error in
            let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    if let data = data {
                        do {
                            let str = String(decoding: data, as: UTF8.self)
                            let response = try decoder.decode(AnimeResponse.self, from: data)
                            var itemList = [Anime]()
                            for item in response.data {
                                itemList.append(Anime.init(anime: item))
                            }
                            self.checkIfLikedForAnime(list: &itemList)
                            self.paginations.anime = response.pagination
                            DispatchQueue.main.async {
                                if newQuery {
                                    self.animeList = itemList
                                } else {
                                    self.animeList.append(contentsOf: itemList)
                                }
                            }
                        } catch {
                            print(error)
                        }
                    } else {
                        print("error")
            }
        }.resume()
    }
    
    func getMangaList(loadMore: Bool = false, newQuery: Bool = false){
        var queryItems = [URLQueryItem(name: "type", value: mangaQuerys.type.rawValue),
                          URLQueryItem(name: "filter", value: mangaQuerys.filter.rawValue)]
        var urlComps = URLComponents(string: "https://api.jikan.moe/v4/top/manga")!
        if loadMore && paginations.manga.hasNextPage {
            queryItems.append(URLQueryItem(name: "page", value: String(paginations.manga.currentPage + 1)))
        }
        urlComps.queryItems = queryItems
        let url = urlComps.url!
        URLSession.shared.dataTask(with: url) { data, response, error in
            let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    if let data = data {
                        do {
                            let response = try decoder.decode(MangaResponse.self, from: data)
                            var itemList = [Manga]()
                            for item in response.data {
                                itemList.append(Manga.init(manga: item))
                            }
                            self.checkIfLikedForManga(list: &itemList)
                            self.paginations.manga = response.pagination
                            DispatchQueue.main.async {
                                if newQuery {
                                    self.mangaList = itemList
                                } else {
                                    self.mangaList.append(contentsOf: itemList)
                                }
                            }
                        } catch {
                            print(error)
                        }
                    } else {
                        print("error")
            }
        }.resume()
    }
    
    func removeFaviteItem(item: FavoritItem, fromHome: Bool = false) {
        if mangaList.count == 0 {
            return
        }
        for index in 0 ... mangaList.count-1 {
            if item.getTitle() == mangaList[index].title {
                mangaList[index].isFavorite = false
            }
        }
        if animeList.count == 0 {
            return
        }
        for index in 0 ... animeList.count-1 {
            if item.getTitle() == animeList[index].title {
                animeList[index].isFavorite = false
            }
        }
        
        if fromHome {
            for index in 0 ... favoriteList.count-1 {
                if item.getTitle() == favoriteList[index].getTitle(){
                    favoriteList.remove(at: index)
                    return
                }
            }
        }
    }
    
    
}
