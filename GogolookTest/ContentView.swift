//
//  ContentView.swift
//  GogolookTest
//
//  Created by yoie on 2022/8/3.
//

import SwiftUI
import Foundation



struct ContentView: View {
    @StateObject var homeViewModel = HomeViewModel()
    var body: some View {
        TabView {
            HomeView().tabItem {
                Label("Home", systemImage: "list.dash")
            }
            FavoriteView().tabItem {
                Label("Favorite", systemImage: "heart")
            }
        }
        .environmentObject(homeViewModel)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
