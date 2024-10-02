//
//  ContentView.swift
//  RSS-Feed-Reader
//
//  Created by Moritz Tucher on 01.10.24.
//

import SwiftUI
import WebKit

/// The main view displaying the list of RSS items.
struct ContentView: View {
    @State private var rssItems: [RSSItem] = []
    
    var body: some View {
        NavigationView {
            List(rssItems) { item in
                NavigationLink(destination: DetailView(item: item)) {
                    HStack {
                        if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                     .scaledToFit()
                                     .frame(width: 50, height: 50)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        VStack(alignment: .leading) {
                            Text(item.title)
                            Text(item.pubDate, formatter: dateFormatter) // Format pubDate
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .onAppear {
                fetchRSSFeed()
            }
            .navigationTitle("Apple Developer News")
        }
    }
    
    /// A date formatter for displaying publication dates.
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy"
        return formatter
    }
    
    /// Fetches the RSS feed from the specified URL.
    func fetchRSSFeed() {
        guard let url = URL(string: "https://developer.apple.com/news/rss/news.rss") else {
            print("Invalid URL")
            return
        }
        
        print("Fetching RSS feed from \(url)")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            print("Received \(data.count) bytes of data")
            
            let parser = RSSParser()
            if let rssItems = parser.parseRSS(data: data) {
                DispatchQueue.main.async {
                    self.rssItems = rssItems
                    print("Updated rssItems with \(rssItems.count) items")
                }
            } else {
                print("Failed to parse RSS data")
            }
        }
        
        task.resume()
    }
}

#Preview {
    ContentView()
}
