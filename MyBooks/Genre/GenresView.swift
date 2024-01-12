//
//  GenresView.swift
//  MyBooks
//
//  Created by Danylo Kushlianskyi on 10.01.2024.
//

import SwiftUI
import SwiftData

struct GenresView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    var book: Book
    @Query(sort: (\Genre.name)) var genres: [Genre]
    @State private var newGenre: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                if genres.isEmpty {
                    ContentUnavailableView(label: {
                        Image(systemName: "bookmark.fill")
                    }, description: {
                        Text("You need to create some genres first")
                    }, actions: {
                        Button(action: {
                            newGenre.toggle()
                        }) {
                            Text("Create genre")
                        }.buttonStyle(.borderedProminent)
                    })
                } else {
                    List {
                        ForEach(genres) { genre in
                            HStack {
                                if let bookgenres = book.genres {
                                    if bookgenres.isEmpty {
                                        Button {
                                            addRemove(genre)
                                        } label: {
                                            Image(systemName: "circle")
                                        }
                                        .foregroundStyle(genre.hexColor)

                                    } else {
                                        Button {
                                            addRemove(genre)
                                        } label: {
                                            Image(systemName: bookgenres.contains(genre) ? "circle.fill" : "circle")
                                        }
                                        .foregroundStyle(genre.hexColor)
                                    }
                                }
                                Text(genre.name)
                            }
                        }
                        .onDelete(perform: { indexSet in
                            indexSet.forEach { index in
                                if let bookGenres = book.genres,
                                   bookGenres.contains(genres[index]),
                                   let bookGenreIndex = bookGenres.firstIndex(where: { $0.id == genres[index].id }) {
                                    book.genres?.remove(at: bookGenreIndex)
                                }
                                modelContext.delete(genres[index])
                            }
                        })
                        LabeledContent {
                            Button(action: {
                                newGenre.toggle()
                            }, label: {
                                Image(systemName: "plus.circle.fill")
                                    .imageScale(.large)
                            })
                        } label: {
                            Text("Create new genre")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(book.title)
            .sheet(isPresented: $newGenre, content: {
                NewGenreView()
            })
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            })
        }
    }
    
    func addRemove(_ genre: Genre) {
        if let bookGenres = book.genres {
            if bookGenres.isEmpty {
                book.genres?.append(genre)
            } else {
                if bookGenres.contains(genre), let index = bookGenres.firstIndex(where: { $0.id == genre.id }) {
                    book.genres?.remove(at: index)
                } else {
                    book.genres?.append(genre)
                }
            }
        }
    }
}

#Preview {
    let preview = Preview(Book.self)
    let books = Book.sampleBooks
    let genres = Genre.sampleGenres
    preview.addExamples(genres)
    preview.addExamples(books)
    books[1].genres?.append(genres[1])
    return GenresView(book: books[1])
        .modelContainer(preview.container)
}
