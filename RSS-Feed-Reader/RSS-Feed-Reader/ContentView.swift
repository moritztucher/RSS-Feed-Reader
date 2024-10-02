//
//  ContentView.swift
//  RSS-Feed-Reader
//
//  Created by Moritz Tucher on 01.10.24.
//

import SwiftUI
import WebKit

//import Alamofire

struct ContentView: View {
    @State private var rssItems: [RSSItem] = []
    
    var body: some View {
        NavigationView {
            List(rssItems) { item in
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.headline)
                    Text(item.pubDate, formatter: dateFormatter) // Format pubDate
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .onAppear {
                fetchRSSFeed()
            }
            .navigationTitle("Apple Developer News")
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy"
        return formatter
    }
    
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
   
    // Function to read the RSSFeed with Alamofire
//    func fetchRSSFeed_alamofire() {
//        let rssURL = "https://developer.apple.com/news/rss/news.rss"
//        
//        AF.request(rssURL).responseData { response in
//            switch response.result {
//            case .success(let data):
//                let parser = RSSParser()
//                if let rssItems = parser.parseRSS(data: data) {
//                    self.rssItems = rssItems
//                }
//            case .failure(let error):
//                print("Error fetching RSS feed: \(error)")
//            }
//        }
//    }
    
}

struct HTMLText: UIViewRepresentable {
    let html: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(html, baseURL: nil)
    }
}

#Preview {
    ContentView()
}
