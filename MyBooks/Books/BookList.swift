//
//  BookList.swift
//  MyBooks
//
//  Created by Danylo Kushlianskyi on 10.01.2024.
//

import SwiftUI
import SwiftData

struct BookList: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Book.status) private var books: [Book]
    @State var showNewBookView: Bool = false
    
    init(sortOrder: SortOrder, filterString: String) {
        let sortDescriptors: [SortDescriptor<Book>] = switch sortOrder {
        case .status:
            [SortDescriptor(\Book.status), .init(\Book.title)]
        case .title:
            [.init(\Book.title)]
        case .author:
            [.init(\Book.authro)]
        }
        
        let predicate = #Predicate<Book> { book in
            book.title.localizedStandardContains(filterString) ||
            book.authro.localizedStandardContains(filterString) ||
            filterString.isEmpty
        }
        _books = Query(filter: predicate, sort: sortDescriptors)
    }
    
    var body: some View {
        Group {
            if books.isEmpty {
                ContentUnavailableView("Enter your first book", systemImage: "book.fill")
            }
            List {
                ForEach(books) { book in
                    NavigationLink {
                        EditBookView(book: book)
                    } label: {
                        HStack(spacing: 10) {
                            book.icon
                            VStack(alignment: .leading, spacing: 5) {
                                Text(book.title)
                                    .font(.title2)
                                Text(book.authro)
                                    .foregroundStyle(.secondary)
                                if let rating = book.rating {
                                    HStack {
                                        ForEach(1..<rating, id: \.self) { _ in
                                            Image(systemName: "star.fill")
                                                .imageScale(.small)
                                                .foregroundStyle(.yellow )
                                        }
                                    }
                                }
                               
                                if let genres = book.genres {
                                    ViewThatFits {
                                        GenreStackView(genres: genres)
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            GenreStackView(genres: genres)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        let book = books[index]
                        context.delete(book)
                    }
                }
            }
            .listStyle(.plain )
            .padding()
            .navigationTitle("My books")
            .toolbar {
                Button(action: {
                    showNewBookView = true
                }, label: {
                    Image(systemName: "plus.circle")
                        .imageScale(.large)
                })
            }
            .sheet(isPresented: $showNewBookView, content: {
                NewBookView()
                    .presentationDetents([.medium, .large])
            })
            
        }
    }
}

#Preview {
    let preview = Preview(Book.self)
    preview.addExamples(Book.sampleBooks)
    return BookList(sortOrder: .status, filterString: "")
        .modelContainer(preview.container)
}
