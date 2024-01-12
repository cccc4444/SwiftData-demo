//
//  ContentView.swift
//  MyBooks
//
//  Created by Danylo Kushlianskyi on 08.01.2024.
//

import SwiftUI
import SwiftData

enum SortOrder: LocalizedStringResource, Identifiable, CaseIterable {
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

#Preview("English") {
    let preview = Preview(Book.self)
    preview.addExamples(Book.sampleBooks)
    preview.addExamples(Genre.sampleGenres)
    return BookListView()
        .modelContainer(preview.container)
}

#Preview("Ukrainian") {
    let preview = Preview(Book.self)
    preview.addExamples(Book.sampleBooks)
    preview.addExamples(Genre.sampleGenres)
    return BookListView()
        .modelContainer(preview.container)
        .environment(\.locale, Locale(identifier: "uk"))
}

