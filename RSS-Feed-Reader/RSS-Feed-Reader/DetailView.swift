//
//  DetailView.swift
//  RSS-Feed-Reader
//
//  Created by Moritz Tucher on 02.10.24.
//

import SwiftUI

/// A view that displays the details of a selected RSS item.
struct DetailView: View {
    let item: RSSItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.title)
                    .padding()
                
                if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                             .scaledToFit()
                             .frame(maxWidth: .infinity)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                Text(item.description)
                    .padding()
            }
        }
    }
}
