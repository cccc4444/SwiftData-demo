//
//  ContentView.swift
//  MyBooks
//
//  Created by Danylo Kushlianskyi on 08.01.2024.
//

import SwiftUI
import SwiftData

enum SortOrder: String, Identifiable, CaseIterable {
    case status, title, author
    
    var id: Self {
        self
    }
}

struct BookListView: View {
    @State private var sortOrder: SortOrder = .status
    @State private var filter = ""
    
    var body: some View {
        NavigationStack {
            Picker("", selection: $sortOrder) {
                ForEach(SortOrder.allCases) { type in
                    Text("Sort by \(type.rawValue)").tag(type)
                }
            }
            .pickerStyle(.menu).buttonStyle(.bordered)
            BookList(sortOrder: sortOrder, filterString: filter)
                .searchable(text: $filter, prompt: Text("Filter on title or author"))
        }
    }
}

#Preview {
    let preview = Preview(Book.self)
    let genres = Genre.sampleGenres
    preview.addExamples(Book.sampleBooks)
    preview.addExamples(Genre.sampl)
    return BookListView()
        .modelContainer(preview.container)
}
