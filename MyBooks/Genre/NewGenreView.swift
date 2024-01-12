//
//  NewGenreView.swift
//  MyBooks
//
//  Created by Danylo Kushlianskyi on 11.01.2024.
//

import SwiftUI
import SwiftData

struct NewGenreView: View {
    @State private var name = ""
    @State private var color = Color.red
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("name", text: $name)
                ColorPicker("Set genre color:", selection: $color)
                Button(action: {
                    let newGenre = Genre(name: name, color: color.toHexString()!)
                    modelContext.insert(newGenre)
                    dismiss()
                }, label: {
                    Text("Create")
                })
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .disabled(name.isEmpty)
            }
            .padding()
            .navigationTitle("New Genre")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NewGenreView()
}
