//
//  HTMLTextView.swift
//  RSS-Feed-Reader
//
//  Created by Moritz Tucher on 01.10.24.
//


import SwiftUI
import UIKit

struct HTMLTextView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        if let data = htmlContent.data(using: .utf8) {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
                textView.attributedText = attributedString
            } else {
                textView.text = htmlContent // fallback to plain text if HTML parsing fails
            }
        }
    }
}
