//
//  ItemVerwaltungView.swift
//  Urlaubspackliste
//
//  Created by Jörg Schömer on 06.09.26.
//


import SwiftUI
import SwiftData

struct ItemVerwaltungView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ItemTemplate.name) private var vorlagen: [ItemTemplate]
    
    @State private var neueVorlage: ItemTemplate?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(vorlagen) { vorlage in
                    Button {
                        neueVorlage = vorlage
                    } label: {
                        VStack(alignment: .leading) {
                            Text(vorlage.name)
                                .foregroundStyle(.primary)
                            Text(tagsText(vorlage))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    for index in offsets { modelContext.delete(vorlagen[index]) }
                }
            }
            .navigationTitle("Artikel-Vorlagen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fertig") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let neu = ItemTemplate()
                        modelContext.insert(neu)
                        neueVorlage = neu
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $neueVorlage) { vorlage in
                ItemVorlageBearbeitenView(vorlage: vorlage)
            }
        }
    }
    
    private func tagsText(_ vorlage: ItemTemplate) -> String {
        let teile = (vorlage.aktivitaeten + vorlage.jahreszeiten + vorlage.unterkunftsarten)
        return teile.isEmpty ? "Für alle Reisen" : teile.joined(separator: ", ")
    }
}

private struct ItemVorlageBearbeitenView: View {
    @Bindable var vorlage: ItemTemplate
    @Environment(\.dismiss) private var dismiss
    
    @State private var aktivitaetenText = ""
    @State private var jahreszeitenText = ""
    @State private var unterkunftsartenText = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Artikel") {
                    TextField("Name", text: $vorlage.name)
                    TextField("Kategorie", text: $vorlage.kategorie)
                    Toggle("Gruppenartikel (nur einmal für alle)", isOn: $vorlage.istGruppenartikel)
                }
                
                Section {
                    TextField("z. B. Strand, Wandern", text: $aktivitaetenText)
                } header: {
                    Text("Aktivitäten")
                } footer: {
                    Text("Kommagetrennt. Leer lassen = für jede Aktivität relevant.")
                }
                
                Section {
                    TextField("z. B. Sommer, Winter", text: $jahreszeitenText)
                } header: {
                    Text("Jahreszeiten")
                } footer: {
                    Text("Kommagetrennt. Leer lassen = für jede Jahreszeit relevant.")
                }
                
                Section {
                    TextField("z. B. Camping, Hotel", text: $unterkunftsartenText)
                } header: {
                    Text("Unterkunftsarten")
                } footer: {
                    Text("Kommagetrennt. Leer lassen = für jede Unterkunftsart relevant.")
                }
            }
            .navigationTitle(vorlage.name.isEmpty ? "Neuer Artikel" : vorlage.name)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        vorlage.aktivitaeten = tagsAusText(aktivitaetenText)
                        vorlage.jahreszeiten = tagsAusText(jahreszeitenText)
                        vorlage.unterkunftsarten = tagsAusText(unterkunftsartenText)
                        dismiss()
                    }
                }
            }
            .onAppear {
                aktivitaetenText = vorlage.aktivitaeten.joined(separator: ", ")
                jahreszeitenText = vorlage.jahreszeiten.joined(separator: ", ")
                unterkunftsartenText = vorlage.unterkunftsarten.joined(separator: ", ")
            }
        }
    }
    
    private func tagsAusText(_ text: String) -> [String] {
        text.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}