//
//  TeilnehmerZuordnungView.swift
//  Urlaubspackliste
//
//  Created by Jörg Schömer on 18.09.26.
//


import SwiftUI
import SwiftData
import CloudKit

/// Ordnet die eingeladenen Apple-IDs den Mitreisenden der Liste zu.
struct TeilnehmerZuordnungView: View {
    @Bindable var liste: PackingList
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var teilnehmer: [ShareTeilnehmer] = []
    @State private var laedt = true
    @State private var speichertGerade = false
    @State private var fehlerText: String?

    /// Aktuelle Zuordnung Teilnehmer-ID -> Person-ID. Wird als eigener State geführt, weil
    /// Änderungen an den Feldern der Person-Objekte die View nicht neu zeichnen würden.
    @State private var zuordnung: [String: UUID] = [:]

    private var personen: [Person] {
        (liste.personen ?? []).sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationStack {
            Group {
                if laedt {
                    ProgressView("Teilnehmer werden geladen …")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if teilnehmer.isEmpty {
                    ContentUnavailableView(
                        "Noch keine Teilnehmer",
                        systemImage: "person.badge.plus",
                        description: Text("Lade zuerst jemanden über „Teilen“ ein. Danach kannst du die Apple-IDs den Mitreisenden zuordnen.")
                    )
                } else {
                    List {
                        Section {
                            ForEach(teilnehmer) { eintrag in
                                TeilnehmerZeile(
                                    teilnehmer: eintrag,
                                    personen: personen,
                                    zugeordnetePerson: person(fuer: eintrag),
                                    onAuswahl: { person in
                                        zuordnen(eintrag, zu: person)
                                    }
                                )
                            }
                        } footer: {
                            Text("Jede Apple-ID kann genau einem Mitreisenden zugeordnet werden. Beim Öffnen der Liste wird der passende Mitreisende dann automatisch ausgewählt.")
                        }

                        let zugeordnetePersonIDs = Set(zuordnung.values)
                        let nichtZugeordnet = personen.filter { !zugeordnetePersonIDs.contains($0.id) }
                        if !nichtZugeordnet.isEmpty {
                            Section("Noch ohne Apple-ID") {
                                ForEach(nichtZugeordnet) { person in
                                    Text(person.name)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Zuordnung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") { dismiss() }
                        .disabled(speichertGerade)
                }
            }
            .overlay {
                if speichertGerade {
                    ProgressView()
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .alert("Fehler", isPresented: .constant(fehlerText != nil)) {
                Button("OK") { fehlerText = nil }
            } message: {
                Text(fehlerText ?? "")
            }
            .task { await teilnehmerLaden() }
        }
    }

    private func person(fuer eintrag: ShareTeilnehmer) -> Person? {
        guard let personID = zuordnung[eintrag.id] else { return nil }
        return personen.first { $0.id == personID }
    }

    /// Ermittelt aus den gespeicherten Feldern der Personen, welcher Teilnehmer zu wem gehört.
    private func zuordnungAufbauen() {
        var neu: [String: UUID] = [:]

        for eintrag in teilnehmer {
            let treffer = personen.first { person in
                if !person.teilnehmerID.isEmpty, person.teilnehmerID == eintrag.id {
                    return true
                }
                if !eintrag.userRecordName.isEmpty,
                   person.teilnehmerUserRecordName == eintrag.userRecordName {
                    return true
                }
                if !eintrag.kennung.isEmpty,
                   normalisiert(person.teilnehmerKennung) == normalisiert(eintrag.kennung) {
                    return true
                }
                return false
            }
            guard let treffer else { continue }
            neu[eintrag.id] = treffer.id

            // Nach der Annahme liefert CloudKit zusätzliche Angaben - nachtragen, damit die
            // Zuordnung auch dann noch trägt, wenn die E-Mail nicht mehr mitgeliefert wird.
            var geaendert = false
            if treffer.teilnehmerID != eintrag.id {
                treffer.teilnehmerID = eintrag.id
                geaendert = true
            }
            if !eintrag.userRecordName.isEmpty,
               treffer.teilnehmerUserRecordName != eintrag.userRecordName {
                treffer.teilnehmerUserRecordName = eintrag.userRecordName
                geaendert = true
            }
            if geaendert {
                let nachzutragen = treffer
                Task {
                    try? await SharingManager.shared.personZuordnungSpeichern(nachzutragen, in: liste)
                }
            }
        }

        zuordnung = neu
    }

    private func normalisiert(_ wert: String) -> String {
        wert.trimmingCharacters(in: .whitespaces).lowercased()
    }

    private func teilnehmerLaden() async {
        laedt = true
        do {
            try await SharingManager.shared.personZuordnungenAktualisieren(liste)
            teilnehmer = try await SharingManager.shared.teilnehmer(fuer: liste)
            zuordnungAufbauen()
        } catch {
            fehlerText = error.localizedDescription
        }
        laedt = false
    }

    private func zuordnen(_ eintrag: ShareTeilnehmer, zu neuePerson: Person?) {
        // Bisherige Zuordnung dieser Apple-ID lösen, damit sie eindeutig bleibt.
        let vorherZugeordnet = person(fuer: eintrag)
        let bisherige = [vorherZugeordnet].compactMap { $0 }.filter { $0.id != neuePerson?.id }

        for alte in bisherige {
            alte.teilnehmerID = ""
            alte.teilnehmerUserRecordName = ""
            alte.teilnehmerKennung = ""
        }

        if let neuePerson {
            // Die Person darf nicht gleichzeitig an einer anderen Apple-ID hängen.
            for (teilnehmerID, personID) in zuordnung where personID == neuePerson.id {
                zuordnung[teilnehmerID] = nil
            }
            neuePerson.teilnehmerID = eintrag.id
            neuePerson.teilnehmerUserRecordName = eintrag.userRecordName
            neuePerson.teilnehmerKennung = eintrag.kennung
            zuordnung[eintrag.id] = neuePerson.id
        } else {
            zuordnung[eintrag.id] = nil
        }

        speichertGerade = true
        let zuSpeichern = bisherige + [neuePerson].compactMap { $0 }

        Task {
            do {
                for person in zuSpeichern {
                    try await SharingManager.shared.personZuordnungSpeichern(person, in: liste)
                }
                try modelContext.save()
            } catch {
                fehlerText = error.localizedDescription
            }
            speichertGerade = false
        }
    }
}

private struct TeilnehmerZeile: View {
    let teilnehmer: ShareTeilnehmer
    let personen: [Person]
    let zugeordnetePerson: Person?
    let onAuswahl: (Person?) -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(teilnehmer.anzeigeName)
                    if teilnehmer.istBesitzer {
                        Text("Besitzer")
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(.blue))
                    } else if !teilnehmer.istAkzeptiert {
                        Text("Eingeladen")
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(.orange))
                    }
                }
                if !teilnehmer.kennung.isEmpty, teilnehmer.kennung != teilnehmer.anzeigeName {
                    Text(teilnehmer.kennung)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Menu {
                Button("Keine Zuordnung") { onAuswahl(nil) }
                Divider()
                ForEach(personen) { person in
                    Button {
                        onAuswahl(person)
                    } label: {
                        if person.id == zugeordnetePerson?.id {
                            Label(person.name, systemImage: "checkmark")
                        } else {
                            Text(person.name)
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(zugeordnetePerson?.name ?? "Zuordnen")
                        .foregroundStyle(zugeordnetePerson == nil ? Color.accentColor : .primary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
