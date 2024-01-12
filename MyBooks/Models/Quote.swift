//
//  Quote.swift
//  MyBooks
//
//  Created by Danylo Kushlianskyi on 10.01.2024.
//

import Foundation
import SwiftData

@Model
class Quote {
    @Attribute(originalName: "date")
    var creationDate: Date = Date.now
    var text: String
    var pageNumber: String?
    
    init(text: String, pageNumber: String? = nil) {
        self.text = text
        self.pageNumber = pageNumber
    }
    
    var book: Book?
}
