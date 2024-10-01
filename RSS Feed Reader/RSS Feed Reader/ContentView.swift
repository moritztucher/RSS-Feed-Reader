//
//  ContentView.swift
//  RSS Feed Reader
//
//  Created by Moritz Tucher on 01.10.24.
//

import SwiftUI
import Alamofire

struct ContentView: View {
    @State private var rssItems: [RSSItem] = []

    var body: some View {
        NavigationView {
            List(rssItems) { item in
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.headline)
                    Text(item.description)
                        .font(.subheadline)
                }
            }
            .onAppear {
                fetchRSSFeed()
            }
            .navigationTitle("Apple Developer News")
        }
    }

    func fetchRSSFeed() {
        let rssURL = "https://developer.apple.com/news/rss/news.rss"
        
        AF.request(rssURL).responseData { response in
            switch response.result {
            case .success(let data):
                let parser = RSSParser()
                if let rssItems = parser.parseRSS(data: data) {
                    self.rssItems = rssItems
                }
            case .failure(let error):
                print("Error fetching RSS feed: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
