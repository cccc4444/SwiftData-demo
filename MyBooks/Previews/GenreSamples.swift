//
//  GenreSamples.swift
//  MyBooks
//
//  Created by Danylo Kushlianskyi on 10.01.2024.
//

import Foundation

extension Genre {
    static var sampleGenres: [Genre] {
        [
            .init(name: "Fiction", color: "00FF00"),
            .init(name: "Non Fiction", color: "0000FF"),
            .init(name: "Romance", color: "FF0000"),
            .init(name: "Thriller", color: "000000"),
        ]
    }
}
