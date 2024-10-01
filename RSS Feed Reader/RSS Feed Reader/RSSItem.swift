//
//  RSSItem.swift
//  RSS Feed Reader
//
//  Created by Moritz Tucher on 01.10.24.
//

import Foundation

struct RSSItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

class RSSParser: NSObject, XMLParserDelegate {
    private var rssItems: [RSSItem] = []
    private var currentElement = ""
    private var currentTitle = ""
    private var currentDescription = ""
    
    func parseRSS(data: Data) -> [RSSItem]? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return rssItems
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            currentTitle = ""
            currentDescription = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "title" {
            currentTitle += string
        } else if currentElement == "description" {
            currentDescription += string
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let rssItem = RSSItem(title: currentTitle, description: currentDescription)
            rssItems.append(rssItem)
        }
    }
}
