//
//  FavoriteView.swift
//  GogolookTest
//
//  Created by yoie on 2022/8/4.
//

import SwiftUI
import Kingfisher

struct FavoriteView: View {

    @EnvironmentObject var viewModel: HomeViewModel
    var body: some View {
        List {
            ForEach(viewModel.favoriteList) { item in
                HStack {
                    KFImage(URL(string: item.getImage()))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 150)
                    Divider()
                    Text(item.getTitle())
                }
            }.onDelete(perform: delete)
        }
       
    }
    
    func delete(at offsets: IndexSet) {
        if let i = offsets.first {
            viewModel.removeFaviteItem(item: viewModel.favoriteList[i])
            viewModel.favoriteList.remove(atOffsets: offsets)
        }
    }
}
