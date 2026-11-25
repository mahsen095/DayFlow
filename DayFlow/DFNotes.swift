import SwiftUI

struct DFNotes: View {

    @ObservedObject var store: DFStore
    @State private var title = ""
    @State private var content = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {

            TextField("Give your note a title", text: $title)
                .font(.system(size: 14, weight: .semibold))
                .padding(15)
                .background(DF.bg)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            TextEditor(text: $content)
                .font(.system(size: 14))
                .scrollContentBackground(.hidden)
                .frame(height: 120)
                .padding(10)
                .background(DF.bg)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            DFPrimaryButton(title: "Save Note", icon: "square.and.arrow.down") {
                let clean = content.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !clean.isEmpty || !title.isEmpty else { return }

                store.addNote(
                    title.trimmingCharacters(in: .whitespaces).isEmpty ? "Untitled Note" : title,
                    content
                )
                title = ""
                content = ""
            }

            DFSection(title: "Your saved notes")

            if store.notes.isEmpty {
                Text("Your thoughts will live here.")
                    .font(.system(size: 12))
                    .foregroundStyle(DF.muted)
                    .padding(.vertical, 20)
            }

            ForEach(store.notes) { note in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(note.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(DF.ink)

                        Spacer()

                        Button(role: .destructive) {
                            store.notes.removeAll { $0.id == note.id }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(DF.coral)
                        }
                    }

                    Text(note.body)
                        .font(.system(size: 12))
                        .foregroundStyle(DF.muted)

                    Text(note.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 10))
                        .foregroundStyle(DF.purple)
                }
                .padding(15)
                .background(DF.bg)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(17)
        .background(DF.paper)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}
