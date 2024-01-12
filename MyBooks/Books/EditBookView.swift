//
//  EditBookView.swift
//  MyBooks
//
//  Created by Danylo Kushlianskyi on 08.01.2024.
//

import SwiftUI
import PhotosUI

struct EditBookView: View {
    let book: Book
    @Environment(\.dismiss) private var dismiss
    @State private var status: Status
    @State private var rating: Int?
    @State private var title = ""
    @State private var author = ""
    @State private var synopsis = ""
    @State private var dateAdded = Date.distantPast
    @State private var dateStarted = Date.distantPast
    @State private var dateCompleted = Date.distantPast
    @State private var recommendedBy: String = ""
    @State private var showGenres: Bool = false
    @State private var selectedBookCover: PhotosPickerItem?
    @State private var selectedBookCoverData: Data?
    
    init(book: Book) {
        self.book = book
        _status = State(initialValue: Status(rawValue: book.status)!)
    }
    
    var body: some View {
        HStack {
            Text("Status")
            Picker("Status", selection: $status) {
                ForEach(Status.allCases) {
                    Text($0.descr).tag($0)
                }
            }
            .buttonStyle(.bordered)
        }
        VStack(alignment: .leading) {
            GroupBox {
                LabeledContent {
                    switch status {
                    case .onShelf:
                        DatePicker("", selection: $dateAdded,  displayedComponents: .date)
                    case .inProgress, .completed:
                        DatePicker("", selection: $dateAdded, in: ...dateStarted, displayedComponents: .date)
                    }
                } label: {
                    Text("Date added:")
                }
                if status == .inProgress || status == .completed {
                    LabeledContent {
                        DatePicker("", selection: $dateStarted, in: dateAdded..., displayedComponents: .date)
                    } label: {
                        Text("Date started:")
                    }
                }
                if status == .completed  {
                    LabeledContent {
                        DatePicker("", selection: $dateCompleted, in: dateStarted...,  displayedComponents: .date)
                    } label: {
                        Text("Date completed:")
                    }
                }
            }
            .foregroundStyle(.secondary)
            .onChange(of: status) { oldValue, newValue in
                if newValue == .onShelf {
                    dateStarted = Date.distantPast
                    dateCompleted = Date.distantPast
                } else if newValue == .inProgress && oldValue == .completed {
                    dateCompleted = Date.distantPast
                } else if newValue == .inProgress && oldValue == .onShelf {
                    dateStarted = Date.now
                } else if newValue == .completed && oldValue == .onShelf {
                    dateCompleted = Date.now
                    dateStarted = dateAdded
                } else {
                    dateCompleted = Date.now
                }
                
            }
            
            Divider()
            
            HStack {
                PhotosPicker(
                    selection: $selectedBookCover,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Group {
                            if let selectedBookCoverData,
                               let uiImage = UIImage(data: selectedBookCoverData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .tint(.primary)
                            }
                        }
                        .frame(width: 75)
                        .overlay(alignment: .bottomTrailing) {
                            if selectedBookCoverData != nil {
                                Button {
                                    selectedBookCoverData = nil
                                    selectedBookCover = nil
                                } label: {
                                    Image(systemName: "x.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                VStack {
                    LabeledContent {
                        RatingsView(maxRating: 5, currentRating: $rating)
                    } label: {
                        Text("Rating")
                    }
                    
                    LabeledContent {
                        TextField("", text: $title)
                    } label: {
                        Text("Title").foregroundStyle(.secondary)
                    }
                    
                    LabeledContent {
                        TextField("", text: $author)
                    } label: {
                        Text("Author").foregroundStyle(.secondary)
                    }
                }
            }
            
            LabeledContent {
                TextField("", text: $recommendedBy)
            } label: {
                Text("Recommended by").foregroundStyle(.secondary)
            }
            
            Divider()
            
            Text("Summary").foregroundStyle(.secondary)
            TextEditor(text: $synopsis)
                .padding(5)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(uiColor: .tertiarySystemFill), lineWidth: 2))
            if let genres = book.genres {
                ViewThatFits {
                    GenreStackView(genres: genres)
                    ScrollView(.horizontal, showsIndicators: false) {
                        GenreStackView(genres: genres)
                    }
                }
            }
            HStack {
                Button {
                    showGenres.toggle()
                } label: {
                    Label("Genres", systemImage: "bookmark.fill")
                }.buttonStyle(.bordered)
                    .sheet(isPresented: $showGenres) {
                        GenresView(book: book)
                    }
                
                NavigationLink {
                    QuotesListView(book: book)
                } label: {
                    let count = book.quotes?.count ?? .zero
                    Label("\(count) Quotes", systemImage: "quote.opening")
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .textFieldStyle(.roundedBorder)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if changed {
                ToolbarItem {
                    Button("Update") {
                        book.status = status.rawValue
                        book.rating = rating
                        book.title = title
                        book.authro = author
                        book.synopsis = synopsis
                        book.dateAdded = dateAdded
                        book.dateStarted = dateStarted
                        book.dateCompleted = dateCompleted
                        book.recommendedBy = recommendedBy
                        book.bookCover = selectedBookCoverData
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .onAppear() {
            rating = book.rating
            title = book.title
            author = book.authro
            synopsis = book.synopsis
            dateAdded = book.dateAdded
            dateStarted = book.dateStarted
            dateCompleted = book.dateCompleted
            recommendedBy = book.recommendedBy
            selectedBookCoverData = book.bookCover
        }
        .task(id: selectedBookCover) {
            if let data = try? await selectedBookCover?.loadTransferable(type: Data.self) {
                selectedBookCoverData = data
            }
        }
    }
    
    var changed: Bool {
        status != Status(rawValue: book.status)!
        || rating != book.rating
        || title != book.title
        || author != book.authro
        || synopsis != book.synopsis
        || dateAdded != book.dateAdded
        || dateStarted != book.dateStarted
        || dateCompleted != book.dateCompleted
        || recommendedBy != book.recommendedBy
        || selectedBookCoverData != book.bookCover
    }
}

#Preview {
    let preview = Preview(Book.self)
    return NavigationStack {
        EditBookView(book: Book.sampleBooks[5])
            .modelContainer(preview.container)
    }
}
