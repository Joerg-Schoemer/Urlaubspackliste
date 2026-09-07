//
//  NeuePackListeView.swift
//  Urlaubspackliste
//
//  Created by Jörg Schömer on 06.09.26.
//


import SwiftUI
import SwiftData
import CloudKit

struct NeuePackListeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var vorlagen: [ItemTemplate]
    
    private var aktivitaeten: [String] {
        Array(Set(vorlagen.flatMap { $0.aktivitaeten })).sorted()
    }
    private var unterkunftsarten: [String] {
        Array(Set(vorlagen.flatMap { $0.unterkunftsarten })).sorted()
    }
    private var jahreszeiten: [String] {
        Array(Set(vorlagen.flatMap { $0.jahreszeiten })).sorted()
    }
    
    @State private var titel = ""
    @State private var ausgewaehlteAktivitaet = ""
    @State private var ausgewaehlteUnterkunft = ""
    @State private var ausgewaehlteJahreszeit = ""
    @State private var personen: [Person] = [Person(name: "")]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Titel") {
                    TextField("z. B. Toskana 2026", text: $titel)
                }
                
                Section("Aktivität") {
                    Picker("Aktivität", selection: $ausgewaehlteAktivitaet) {
                        ForEach(aktivitaeten, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.inline)
                }
                
                Section("Unterkunftsart") {
                    Picker("Unterkunftsart", selection: $ausgewaehlteUnterkunft) {
                        ForEach(unterkunftsarten, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.inline)
                }
                
                Section("Jahreszeit") {
                    Picker("Jahreszeit", selection: $ausgewaehlteJahreszeit) {
                        ForEach(jahreszeiten, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.inline)
                }
                
                Section("Personen") {
                    ForEach(personen) { person in
                        PersonZeile(person: person)
                    }
                    .onDelete { offsets in
                        personen.remove(atOffsets: offsets)
                    }
                    
                    Button {
                        personen.append(Person(name: ""))
                    } label: {
                        Label("Person hinzufügen", systemImage: "person.badge.plus")
                    }
                }
            }
            .navigationTitle("Neue Packliste")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Erstellen") { listeErstellen() }
                        .disabled(titel.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if ausgewaehlteAktivitaet.isEmpty { ausgewaehlteAktivitaet = aktivitaeten.first ?? "" }
                if ausgewaehlteUnterkunft.isEmpty { ausgewaehlteUnterkunft = unterkunftsarten.first ?? "" }
                if ausgewaehlteJahreszeit.isEmpty { ausgewaehlteJahreszeit = jahreszeiten.first ?? "" }
            }
        }
    }
    
    private func listeErstellen() {
        let neueListe = PackingList(
            titel: titel,
            aktivitaet: ausgewaehlteAktivitaet,
            unterkunftsart: ausgewaehlteUnterkunft,
            jahreszeit: ausgewaehlteJahreszeit
        )
        neueListe.personen = personen
        
        let passendeItems = ItemDaten.alle.filter { vorlage in
            let aktivitaetPasst = vorlage.aktivitaeten.isEmpty || vorlage.aktivitaeten.contains(ausgewaehlteAktivitaet)
            let jahreszeitPasst = vorlage.jahreszeiten.isEmpty || vorlage.jahreszeiten.contains(ausgewaehlteJahreszeit)
            let unterkunftPasst = vorlage.unterkunftsarten.isEmpty || vorlage.unterkunftsarten.contains(ausgewaehlteUnterkunft)
            return aktivitaetPasst && jahreszeitPasst && unterkunftPasst
        }
        
        neueListe.items = passendeItems.map { vorlage in
            PackingItem(name: vorlage.name, kategorie: vorlage.kategorie, istGruppenartikel: vorlage.istGruppenartikel)
        }
        
        modelContext.insert(neueListe)
        dismiss()
    }
}

private struct PersonZeile: View {
    @Bindable var person: Person
    
    var body: some View {
        HStack {
            TextField("Name eingeben", text: $person.name)
            Spacer()
            Toggle(isOn: $person.istKind) {
                Text("Kind")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .labelsHidden()
        }
    }
}

#Preview {
    NeuePackListeView()
        .modelContainer(for: PackingList.self, inMemory: true)
}
