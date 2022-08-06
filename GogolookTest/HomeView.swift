//
//  HomeView.swift
//  GogolookTest
//
//  Created by yoie on 2022/8/3.
//

import SwiftUI
import Kingfisher
import WebKit

enum ContentTab: String {
    case anime
    case manga
}

struct HomeView: View {

    @EnvironmentObject var viewModel: HomeViewModel
    
    @State var animeSelectionsType = AnimeType.none

    @State var animeSelectionsIndex = (type: 0, filter: 0)
    @State var mangaSelectionsIndex = (type: 0, filter: 0)
    @State var offset: CGPoint = .zero
    @State var contentOffser = CGFloat()

    var body: some View {
        VStack {
            TabbedView()
            pickerGroup
            Divider()
                .frame(height: 3)
            content
            
            Spacer()
        }

        .sheet(item: $viewModel.webUrl){ str in
            WebView(urlStr: str)
        }
        .environmentObject(viewModel)
    }
    
    @ViewBuilder
    var content: some View {
        switch viewModel.selectedTab {
            case .manga: mangaListView.onAppear{viewModel.getMangaList()}
            case .anime: animeListView.onAppear{viewModel.getAnimeList()}
        }
    }
    
    @ViewBuilder
    var pickerGroup: some View {
        switch viewModel.selectedTab {
            case .manga: mangaPicker
            case .anime: animePicker
        }
    }
        
    var mangaPicker: some View {
        HStack {
            VStack {
                HStack {
                    Spacer()

                    Text("Types: ")
                    
                    Spacer()
                    
                    Picker(selection: $mangaSelectionsIndex.type) {
                        ForEach(0 ..< MangaType.allCases.count) { index in
                            Text(MangaType.allCases[index].rawValue)
                        }
                    } label: {
                        Text("Type")
                    }
                    .frame(width: 30)
                    
                    Spacer()

                }
                
                HStack {
                    Spacer()

                    Text("Filters: ")
                    
                    Spacer()
                    
                    Picker(selection: $mangaSelectionsIndex.filter) {
                        ForEach(0 ..< MangaFilter.allCases.count) { index in
                            Text(MangaFilter.allCases[index].rawValue)
                        }
                    } label: {
                        Text("Filter")
                    }
                    .frame(width: 30)
                    
                    Spacer()

                }
                
            }
            mangaPickerSendBtn

            Spacer()

        }
    }
    
    var animePicker: some View {
        HStack {
            VStack {
                HStack {
                    Spacer()

                    Text("Types: ")
                    
                    Spacer()
                    
                    Picker(selection: $animeSelectionsIndex.type) {
                        ForEach(0 ..< AnimeType.allCases.count) { index in
                            Text(AnimeType.allCases[index].rawValue)
                        }
                    } label: {
                        Text("Type")
                    }
                    .frame(width: 30)
                    
                    Spacer()

                }
                
                HStack {
                    Spacer()

                    Text("Filters: ")
                    
                    Spacer()
                    
                    Picker(selection: $animeSelectionsIndex.filter) {
                        ForEach(0 ..< AnimeFilter.allCases.count) { index in
                            Text(AnimeFilter.allCases[index].rawValue)
                        }
                    } label: {
                        Text("Filter")
                    }
                    .frame(width: 30)
                    
                    Spacer()

                }
                
            }
            animePickerSendBtn

            Spacer()

        }
    }

    
    var mangaPickerSendBtn: some View {
        Button {
            viewModel.mangaQuerys.type = MangaType.allCases[mangaSelectionsIndex.type]
            viewModel.mangaQuerys.filter = MangaFilter.allCases[mangaSelectionsIndex.filter]
            viewModel.getMangaList(newQuery: true)
        }label: {
            Text("Send")
                .padding(2)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder().foregroundColor(Color.blue)
        )
    }
    
    var animePickerSendBtn: some View {
        Button {
            viewModel.animeQuerys.type = AnimeType.allCases[animeSelectionsIndex.type]
            viewModel.animeQuerys.filter = AnimeFilter.allCases[animeSelectionsIndex.filter]
            viewModel.getAnimeList(newQuery: true)
        }label: {
            Text("Send")
                .padding(2)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder().foregroundColor(Color.blue)
        )
    }
    
    var mangaListView: some View {
        List {
            ForEach(Array(viewModel.mangaList.enumerated()), id: \.element.id) { index, item in
                MangaRowItem(manga: $viewModel.mangaList[index])
                    .onAppear {
                        if index == viewModel.mangaList.count-1 {
                            viewModel.getMangaList(loadMore: true)
                        }
                    }
                    .onTapGesture {
                        viewModel.webUrl = viewModel.mangaList[index].url
                    }
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .onEnded { value in
                                viewModel.mangaList[index].isFavorite.toggle()
                                if viewModel.mangaList[index].isFavorite {
                                    viewModel.favoriteList.append(FavoritItem(manga: viewModel.mangaList[index]))
                                } else {
                                    viewModel.removeFaviteItem(item: FavoritItem(manga: viewModel.mangaList[index]), fromHome: true)
                                }
                            }
                        )
            }
        }


    }
    @ViewBuilder
    var animeListView: some View {
        List {
            ForEach(Array(viewModel.animeList.enumerated()), id: \.element.id) { index, item in
                AnimeRowItem(anime: $viewModel.animeList[index])
                    .onAppear {
                        if index == viewModel.animeList.count-1 {
                            viewModel.getAnimeList(loadMore: true)
                        }
                    }
                    .onTapGesture {
                        viewModel.webUrl = viewModel.animeList[index].url
                    }
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .onEnded { value in
                                viewModel.animeList[index].isFavorite.toggle()
                                if viewModel.animeList[index].isFavorite {
                                    viewModel.favoriteList.append(FavoritItem(anime: viewModel.animeList[index]))
                                } else {
                                    viewModel.removeFaviteItem(item: FavoritItem(anime: viewModel.animeList[index]), fromHome: true)
                                }
                            }
                        )
            }
        }
    }
    
        
    }
    
struct TabbedView: View {
    @EnvironmentObject var viewModel : HomeViewModel
    var types = [ContentTab.anime, ContentTab.manga]

    var body: some View {
        VStack {
            Picker("Content", selection: $viewModel.selectedTab) {
                ForEach(types, id: \.self){ type in
                    Text(type.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
        }
    }
    
}
    
struct MangaRowItem: View {
    @Binding var manga: Manga
    var body: some View {
        HStack {

            KFImage(URL(string: manga.images.jpg.largeImageUrl))
                .resizable()
                .scaledToFit()
                .frame(width: 100)

            Divider()
            VStack(alignment: .leading) {
                Text(manga.title)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(3)
                
                Spacer()

                Text("Rank:\(manga.rank)")
                    .font(.system(size: 10, weight: .regular))

                
                Spacer()
                
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(manga.isFavorite ? Color.red: Color.gray)
                }

            }
            .frame(width: UIScreen.main.bounds.width/4, height: 100, alignment: .leading)
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("Start:")
                    .font(.system(size: 12, weight: .semibold))
                Text(manga.published.from.components(separatedBy: "T")[0])
                    .font(.system(size: 10, weight: .regular))
                    .lineLimit(1)
                Spacer()

                Text("End:")
                    .font(.system(size: 12, weight: .semibold))
                Text(manga.published.to?.components(separatedBy: "T")[0] ?? "~")
                    .font(.system(size: 10, weight: .regular))
                    .lineLimit(1)
                Spacer()

            }
            .frame(height: 100, alignment: .leading)
        }
    }
}
    
struct AnimeRowItem: View {
    @Binding var anime: Anime
    var body: some View {
        HStack {

            KFImage(URL(string: anime.images.jpg.largeImageUrl))
                .resizable()
                .scaledToFit()
                .frame(width: 100)

            Divider()
            VStack(alignment: .leading) {
                Text(anime.title)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(3)
                
                Spacer()

                Text("Rank:\(anime.rank)")
                    .font(.system(size: 10, weight: .regular))

                
                Spacer()
                
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(anime.isFavorite ? Color.red: Color.gray)
                }

            }
            .frame(width: UIScreen.main.bounds.width/4, height: 100, alignment: .leading)
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("Start:")
                    .font(.system(size: 12, weight: .semibold))
                Text(anime.aired.from.components(separatedBy: "T")[0])
                    .font(.system(size: 10, weight: .regular))
                    .lineLimit(1)
                Spacer()

                Text("End:")
                    .font(.system(size: 12, weight: .semibold))
                Text(anime.aired.to?.components(separatedBy: "T")[0] ?? "~")
                    .font(.system(size: 10, weight: .regular))
                    .lineLimit(1)
                Spacer()

            }
            .frame(height: 100, alignment: .leading)
            
        }

    }
}

struct WebView: UIViewRepresentable {
    var urlStr: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: urlStr) {
            let request = URLRequest(url:url)
            webView.load(request)
        } else {
            print("URL Error")
        }
    }
}

extension String: Identifiable {
    public var id: String {
        return self
    }
}
