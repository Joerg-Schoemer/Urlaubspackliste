//
//  PackingListeBearbeitenView.swift
//  Urlaubspackliste
//
//  Created by Jörg Schömer on 18.09.26.
//


import SwiftUI
import SwiftData

struct PackingListeBearbeitenView: View {
    @Bindable var liste: PackingList
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var vorlagen: [ItemTemplate]
    @State private var neuesItem: PackingItem?

    private var aktivitaeten: [String] {
        Array(Set(vorlagen.flatMap { $0.aktivitaeten } + [liste.aktivitaet])).filter { !$0.isEmpty }.sorted()
    }
    private var unterkunftsarten: [String] {
        Array(Set(vorlagen.flatMap { $0.unterkunftsarten } + [liste.unterkunftsart])).filter { !$0.isEmpty }.sorted()
    }
    private var jahreszeiten: [String] {
        Array(Set(vorlagen.flatMap { $0.jahreszeiten } + [liste.jahreszeit])).sorted()
    }

    private var kategorien: [String] {
        Array(Set((liste.items ?? []).map { $0.kategorie })).sorted()
    }

    private func items(fuer kategorie: String) -> [PackingItem] {
        (liste.items ?? []).filter { $0.kategorie == kategorie }.sorted { $0.name < $1.name }
    }

    private var mindestensEinePersonAngegeben: Bool {
        (liste.personen ?? []).contains { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Titel") {
                    TextField("Titel", text: $liste.titel)
                }

                Section("Aktivität") {
                    Picker("Aktivität", selection: $liste.aktivitaet) {
                        Text("Keine Auswahl").tag("")
                        ForEach(aktivitaeten, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.inline)
                }

                Section("Unterkunftsart") {
                    Picker("Unterkunftsart", selection: $liste.unterkunftsart) {
                        Text("Keine Auswahl").tag("")
                        ForEach(unterkunftsarten, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.inline)
                }

                Section("Jahreszeit") {
                    Picker("Jahreszeit", selection: $liste.jahreszeit) {
                        ForEach(jahreszeiten, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.inline)
                }

                Section("Personen") {
                    ForEach(liste.personen ?? []) { person in
                        PersonZeile(person: person)
                    }
                    .onDelete { offsets in
                        let betroffene = offsets.map { (liste.personen ?? [])[$0] }
                        for person in betroffene { modelContext.delete(person) }
                    }

                    Button {
                        let neu = Person(name: "")
                        modelContext.insert(neu)
                        liste.personen = (liste.personen ?? []) + [neu]
                    } label: {
                        Label("Person hinzufügen", systemImage: "person.badge.plus")
                    }
                }

                ForEach(kategorien, id: \.self) { kategorie in
                    Section(kategorie.isEmpty ? "Ohne Kategorie" : kategorie) {
                        ForEach(items(fuer: kategorie)) { item in
                            HStack {
                                Text(item.name)
                                if item.istGruppenartikel {
                                    Spacer()
                                    Image(systemName: "person.2.fill")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete { offsets in
                            let itemsDerKategorie = items(fuer: kategorie)
                            for item in offsets.map({ itemsDerKategorie[$0] }) {
                                modelContext.delete(item)
                            }
                        }
                    }
                }

                Section {
                    Button {
                        let neu = PackingItem(name: "", kategorie: "")
                        modelContext.insert(neu)
                        liste.items = (liste.items ?? []) + [neu]
                        neuesItem = neu
                    } label: {
                        Label("Artikel hinzufügen", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Packliste bearbeiten")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(liste.titel.trimmingCharacters(in: .whitespaces).isEmpty || !mindestensEinePersonAngegeben)
                }
            }
            .sheet(item: $neuesItem) { item in
                PackingItemBearbeitenView(item: item)
            }
        }
    }
}

private struct PackingItemBearbeitenView: View {
    @Bindable var item: PackingItem
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Artikel") {
                    TextField("Name", text: $item.name)
                    TextField("Kategorie", text: $item.kategorie)
                    Toggle("Gruppenartikel (nur einmal für alle)", isOn: $item.istGruppenartikel)
                }
            }
            .navigationTitle(item.name.isEmpty ? "Neuer Artikel" : item.name)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(item.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onDisappear {
                if item.name.trimmingCharacters(in: .whitespaces).isEmpty {
                    modelContext.delete(item)
                }
            }
        }
    }
}

#Preview {
    PackingListeBearbeitenView(liste: PackingList(titel: "Test", aktivitaet: "Strand", unterkunftsart: "Hotel", jahreszeit: "Sommer"))
        .modelContainer(for: PackingList.self, inMemory: true)
}
