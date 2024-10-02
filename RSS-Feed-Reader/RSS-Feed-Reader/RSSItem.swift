//
//  RSSItem.swift
//  RSS-Feed-Reader
//
//  Created by Moritz Tucher on 01.10.24.
//

import Foundation

struct RSSItem: Identifiable {
    let id = UUID()
    let title: String
    let imageUrl: String? // Added image URL
    let description: String // This will now contain raw HTML
    let link: String
    let pubDate: Date
}

class RSSParser: NSObject, XMLParserDelegate {
    private var rssItems: [RSSItem] = []
    private var currentElement = ""
    private var currentTitle: String?
    private var currentDescription: String?
    private var currentLink: String?
    private var currentPubDate: Date?
    private var currentImageUrl: String? // New property for image URL
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz" // Updated to match the RSS feed format
        formatter.locale = Locale(identifier: "en_US") // Ensure the locale is set correctly
        return formatter
    }
    
    func parseRSS(data: Data) -> [RSSItem]? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        print("Starting to parse RSS data")
        if parser.parse() {
            print("Parsing completed. Found \(rssItems.count) items.")
            return rssItems
        } else {
            print("Failed to parse RSS")
            if let error = parser.parserError {
                print("Parser error: \(error.localizedDescription)")
            }
            return nil
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        print("Started element: \(elementName)")
        if elementName == "item" {
            currentTitle = nil
            currentDescription = nil
            currentLink = nil
            currentPubDate = nil
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !data.isEmpty {
            switch currentElement {
            case "title": currentTitle = (currentTitle ?? "") + data
            case "description":
                if currentElement == "description" {
                    currentDescription = (currentDescription ?? "") + string
                    currentImageUrl = extractImageUrl(from: currentDescription ?? "") // Extract image URL here
                }
            case "link": currentLink = (currentLink ?? "") + data
            case "pubDate":
                if let pubDate = dateFormatter.date(from: data) {
                    currentPubDate = pubDate
                }
            default: break
            }
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            if let title = currentTitle,
               let description = currentDescription,
               let link = currentLink,
               let pubDate = currentPubDate,
               let imageUrl = currentImageUrl { // Ensure image URL is available
                let item = RSSItem(title: title, imageUrl: imageUrl, description: description, link: link, pubDate: pubDate)
                rssItems.append(item)
                print("Added item: \(title)")
            } else {
                print("Failed to create item. Missing data: title=\(currentTitle != nil), description=\(currentDescription != nil), link=\(currentLink != nil), pubDate=\(currentPubDate != nil)")
            }
        }
        currentElement = ""
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if currentElement == "description" {
            if let cdataString = String(data: CDATABlock, encoding: .utf8) {
                currentDescription = (currentDescription ?? "") + cdataString
            }
        }
    }
    
    private func extractImageUrl(from description: String) -> String? {
        let pattern = "<img[^>]+src=\"([^\"]+)\""
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let nsString = description as NSString
        let results = regex?.matches(in: description, options: [], range: NSRange(location: 0, length: nsString.length))
        
        if let match = results?.first, let range = Range(match.range(at: 1), in: description) {
            return String(description[range])
        }
        return nil
    }
}

