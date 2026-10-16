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
    @Query private var vorlagen: [ItemTemplate]
    
    @State private var neueVorlage: ItemTemplate?
    @State private var zeigeAllesLoeschenBestaetigung = false

    /// Sortierung wie in der Packliste: Kategorie, darin das Gewicht, zuletzt der Name.
    /// Das Gewicht hält ähnliche Artikel innerhalb einer Kategorie beieinander.
    private var sortierteVorlagen: [ItemTemplate] {
        vorlagen.sorted {
            if $0.kategorie != $1.kategorie { return $0.kategorie < $1.kategorie }
            if $0.gewicht != $1.gewicht { return $0.gewicht < $1.gewicht }
            return $0.name < $1.name
        }
    }

    /// Kategorien alphabetisch sortiert - wie die Kategorie-Sections in der Packliste.
    private var gruppierteKategorien: [String] {
        Array(Set(vorlagen.map { $0.kategorie })).sorted()
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(gruppierteKategorien, id: \.self) { kategorie in
                    let vorlagenDerKategorie = sortierteVorlagen.filter { $0.kategorie == kategorie }
                    Section {
                        ForEach(vorlagenDerKategorie) { vorlage in
                            // buttonStyle(.plain): sonst färbt SwiftUI das gesamte Label
                            // mit der Akzentfarbe ein und die Zeile wirkt wie ein Link.
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
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { offsets in
                            for index in offsets { modelContext.delete(vorlagenDerKategorie[index]) }
                        }
                    } header: {
                        Text(kategorie.isEmpty ? "Ohne Kategorie" : kategorie)
                    }
                }
            }
            .navigationTitle("Artikel-Vorlagen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .destructive) {
                        zeigeAllesLoeschenBestaetigung = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(vorlagen.isEmpty)
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
            .confirmationDialog(
                "Alle Artikel-Vorlagen löschen?",
                isPresented: $zeigeAllesLoeschenBestaetigung,
                titleVisibility: .visible
            ) {
                Button("Alle löschen", role: .destructive) {
                    alleLoeschen()
                }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Dies kann nicht rückgängig gemacht werden.")
            }
            .sheet(item: $neueVorlage) { vorlage in
                ItemVorlageBearbeitenView(vorlage: vorlage)
            }
        }
    }

    private func alleLoeschen() {
        for vorlage in vorlagen { modelContext.delete(vorlage) }
        try? modelContext.save()
    }

    private func tagsText(_ vorlage: ItemTemplate) -> String {
        let teile = (vorlage.aktivitaeten + vorlage.jahreszeiten + vorlage.unterkunftsarten)
        return teile.isEmpty ? "Für alle Reisen" : teile.joined(separator: ", ")
    }
}

private struct ItemVorlageBearbeitenView: View {
    @Bindable var vorlage: ItemTemplate
    @Environment(\.modelContext) private var modelContext
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
                    Stepper(value: $vorlage.gewicht, in: -99...99) {
                        HStack {
                            Text("Gewicht")
                            Spacer()
                            Text("\(vorlage.gewicht)")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                } footer: {
                    Text("Sortierung innerhalb der Kategorie: kleineres Gewicht steht weiter oben. Gleiches Gewicht hält ähnliche Artikel beieinander.")
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
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        vorlage.aktivitaeten = tagsAusText(aktivitaetenText)
                        vorlage.jahreszeiten = tagsAusText(jahreszeitenText)
                        vorlage.unterkunftsarten = tagsAusText(unterkunftsartenText)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(vorlage.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                aktivitaetenText = vorlage.aktivitaeten.joined(separator: ", ")
                jahreszeitenText = vorlage.jahreszeiten.joined(separator: ", ")
                unterkunftsartenText = vorlage.unterkunftsarten.joined(separator: ", ")
            }
            .onDisappear {
                abbrechen()
            }
        }
    }

    private func abbrechen() {
        if vorlage.name.trimmingCharacters(in: .whitespaces).isEmpty {
            modelContext.delete(vorlage)
        }
    }
    
    private func tagsAusText(_ text: String) -> [String] {
        text.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
