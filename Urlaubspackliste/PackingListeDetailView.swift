//
//  PackingListeDetailView.swift
//  Urlaubspackliste
//
//  Created by Jörg Schömer on 06.09.26.
//


import SwiftUI
import SwiftData
import Combine

struct PackingListeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var liste: PackingList
    @State private var meinePerson: Person?
    @State private var zeigePersonAuswahl = false
    @State private var sharePaket: SharePaket?
    @State private var teilenLaeuft = false
    @State private var fehlerText: String?
    @State private var zeigeBearbeiten = false
    @State private var zeigeZuordnung = false
    @State private var syncPausiert = false
    @State private var zeigeFreigabeBeendet = false
    
    private var listeSchluessel: String {
        "meinePerson_\(liste.titel)_\(liste.erstelltAm.timeIntervalSince1970)"
    }
    
    private var sortiertePersonen: [Person] {
        (liste.personen ?? []).sorted { $0.name < $1.name }
    }
    
    /// Nur der Besitzer arbeitet mehrere Packlisten ab - Mitreisende bleiben
    /// auf der Person, die ihrer Apple-ID zugeordnet wurde.
    private var kannPersonWechseln: Bool {
        liste.istBesitzer && sortiertePersonen.count > 1
    }
    
    /// Beschriftung der gerade bearbeiteten Person.
    ///
    /// Wechselt der Besitzer zwischen den Mitreisenden, wäre "Du" irreführend -
    /// dann zeigt die Markierung nur noch, wessen Liste gerade offen ist.
    private var aktivMarkierung: String {
        kannPersonWechseln ? "Aktiv" : "Du"
    }
    
    /// Auswahl der Person, deren Liste gerade abgearbeitet wird.
    private var aktivePersonID: Binding<UUID> {
        Binding(
            get: { meinePerson?.id ?? sortiertePersonen.first?.id ?? UUID() },
            set: { neueID in
                guard let person = sortiertePersonen.first(where: { $0.id == neueID }) else { return }
                meinePerson = person
                UserDefaults.standard.set(person.name, forKey: listeSchluessel)
            }
        )
    }
    
    /// Sortierung: Kategorie, darin das Gewicht, zuletzt der Name.
    ///
    /// Das Gewicht hält ähnliche Artikel innerhalb einer Kategorie beieinander.
    private var sortierteItems: [PackingItem] {
        (liste.items ?? []).sorted {
            if $0.kategorie != $1.kategorie { return $0.kategorie < $1.kategorie }
            if $0.gewicht != $1.gewicht { return $0.gewicht < $1.gewicht }
            return $0.name < $1.name
        }
    }

    private var gruppierteKategorien: [String] {
        Array(Set(sortierteItems.map { $0.kategorie })).sorted()
    }
    
    /// Artikel, die jede Person für sich packt.
    private var persoenlicheItems: [PackingItem] {
        (liste.items ?? []).filter { !$0.istGruppenartikel }
    }

    /// Artikel, die nur einmal für alle gepackt werden.
    private var gemeinsameItems: [PackingItem] {
        (liste.items ?? []).filter { $0.istGruppenartikel }
    }

    private var fortschritt: Double {
        guard let meinePerson else { return 0 }
        return fortschritt(fuer: meinePerson)
    }

    /// Fortschritt einer Person - ohne die gemeinsamen Artikel.
    ///
    /// Gemeinsame Artikel hakt einer für alle ab. Zählten sie mit, stiege der
    /// Balken aller Mitreisenden, obwohl sie selbst nichts gepackt haben.
    private func fortschritt(fuer person: Person) -> Double {
        let items = persoenlicheItems
        guard !items.isEmpty else { return 0 }
        let erledigt = items.filter { $0.istAbgehakt(von: person) }.count
        return Double(erledigt) / Double(items.count)
    }

    private var gemeinsamErledigt: Int {
        gemeinsameItems.filter { $0.gruppeAbgehakt }.count
    }

    private var gemeinsamerFortschritt: Double {
        guard !gemeinsameItems.isEmpty else { return 0 }
        return Double(gemeinsamErledigt) / Double(gemeinsameItems.count)
    }
    
    var body: some View {
        List {
            if let meinePerson {
                ForEach(gruppierteKategorien, id: \.self) { kategorie in
                    // Artikel ohne Kategorie bekommen eine eigene Überschrift,
                    // sonst stünde ihre Section titellos in der Liste.
                    Section(kategorie.isEmpty ? "Ohne Kategorie" : kategorie) {
                        ForEach(sortierteItems.filter { $0.kategorie == kategorie }) { item in
                            ItemZeile(item: item, person: meinePerson, liste: liste)
                        }
                    }
                }
            }
            
            if !gemeinsameItems.isEmpty {
                Section {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(gemeinsamErledigt) von \(gemeinsameItems.count) gepackt")
                        Spacer()
                        ProgressView(value: gemeinsamerFortschritt)
                            .frame(width: 80)
                    }
                } header: {
                    Text("Gemeinsames")
                } footer: {
                    Text("Diese Artikel packt einer für alle. Sie zählen nicht in den Fortschritt der Mitreisenden.")
                }
            }

            if !sortiertePersonen.isEmpty {
                Section {
                    ForEach(sortiertePersonen) { person in
                        Button {
                            aktivePersonID.wrappedValue = person.id
                        } label: {
                            MitreisenderZeile(
                                person: person,
                                istAktiv: person.id == meinePerson?.id,
                                markierung: aktivMarkierung,
                                fortschritt: fortschritt(fuer: person)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!kannPersonWechseln)
                        .accessibilityAddTraits(person.id == meinePerson?.id ? .isSelected : [])
                    }
                } header: {
                    Text("Mitreisende")
                } footer: {
                    if kannPersonWechseln {
                        Text("Tippe auf einen Mitreisenden, um dessen Liste abzuarbeiten.")
                    }
                }
            }
        }
        .navigationTitle(liste.titel)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 4) {
                    Text(liste.titel)
                        .font(.headline)
                    // Beim Wechseln zwischen Mitreisenden muss erkennbar bleiben,
                    // wessen Fortschritt der Balken zeigt.
                    if kannPersonWechseln, let meinePerson {
                        Text(meinePerson.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: fortschritt)
                        .frame(width: 160)
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    zeigeBearbeiten = true
                } label: {
                    Label("Bearbeiten", systemImage: "pencil")
                }
                .disabled(liste.istGeteilt)
            }
            if kannPersonWechseln {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Mitreisender", selection: aktivePersonID) {
                            ForEach(sortiertePersonen) { person in
                                Text(person.name).tag(person.id)
                            }
                        }
                    } label: {
                        Label("Mitreisender wechseln", systemImage: "person.crop.circle")
                    }
                }
            }
            // Teilen und Zuordnen kann nur der Besitzer: die CloudKit-Zone gehört ihm.
            if liste.istBesitzer {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        teilen()
                    } label: {
                        if teilenLaeuft {
                            ProgressView()
                        } else {
                            Label("Teilen", systemImage: "person.badge.plus")
                        }
                    }
                    .disabled(teilenLaeuft)
                }
            }
            if liste.istGeteilt && liste.istBesitzer {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        zeigeZuordnung = true
                    } label: {
                        Label("Zuordnung", systemImage: "person.2.badge.gearshape")
                    }
                }
            }
        }
        .task { await personLaden() }
        .sheet(isPresented: $zeigePersonAuswahl) {
            PersonAuswahlView(personen: liste.personen ?? []) { ausgewaehlt in
                meinePerson = ausgewaehlt
                UserDefaults.standard.set(ausgewaehlt.name, forKey: listeSchluessel)
                zeigePersonAuswahl = false
            }
        }
        .sheet(item: $sharePaket, onDismiss: {
            // Direkt nach dem Einladen die Zuordnung zu den Mitreisenden anbieten.
            if liste.istGeteilt && liste.istBesitzer {
                zeigeZuordnung = true
            }
        }) { paket in
            CloudSharingView(share: paket.share, container: paket.container)
        }
        .sheet(isPresented: $zeigeZuordnung) {
            TeilnehmerZuordnungView(liste: liste)
        }
        .sheet(isPresented: $zeigeBearbeiten) {
            PackingListeBearbeitenView(liste: liste)
        }
        .alert("Fehler beim Teilen", isPresented: .constant(fehlerText != nil)) {
            Button("OK") { fehlerText = nil }
        } message: {
            Text(fehlerText ?? "")
        }
        .alert("Teilen beendet", isPresented: $zeigeFreigabeBeendet) {
            Button("OK") { listeEntfernen() }
        } message: {
            Text("\(liste.titel) wird nicht mehr mit dir geteilt. Die Liste wird von diesem Gerät entfernt.")
        }
        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
            guard liste.istGeteilt, syncPausiert == false else { return }
            print("🔄 Polling für Liste: \(liste.titel), istBesitzer: \(liste.istBesitzer)")
            Task {
                do {
                    try await SharingManager.shared.listeAktualisieren(liste)
                    try await SharingManager.shared.personZuordnungenAktualisieren(liste)
                    // Falls der Besitzer die Zuordnung erst nachträglich gesetzt hat.
                    if meinePerson == nil, let zugeordnet = await SharingManager.shared.eigenePerson(in: liste) {
                        meinePerson = zugeordnet
                        zeigePersonAuswahl = false
                        UserDefaults.standard.set(zugeordnet.name, forKey: listeSchluessel)
                    }
                    print("✅ listeAktualisieren erfolgreich durchlaufen")
                } catch let fehler as SharingFehler {
                    // Ein fehlender Zonen-Besitzer heilt nicht von selbst - nicht weiter pollen.
                    print("❌ \(fehler.localizedDescription)")
                    syncPausiert = true
                    fehlerText = fehler.localizedDescription
                } catch {
                    print("❌ Fehler bei listeAktualisieren: \(error)")
                    await freigabePruefen()
                }
            }
        }
    }
    
    private func teilen() {
        teilenLaeuft = true
        Task {
            do {
                let (share, container) = try await SharingManager.shared.fetchOrCreateShare(for: liste)
                sharePaket = SharePaket(share: share, container: container)
                await SharingManager.shared.pruefeHochgeladeneRecords(for: liste)
            } catch {
                fehlerText = error.localizedDescription
            }
            teilenLaeuft = false
        }
    }
    
    /// Stellt fest, ob der Besitzer das Teilen beendet hat, und kündigt das Entfernen an.
    ///
    /// Die Prüfung läuft nur bei Mitreisenden: der Besitzer hebt das Teilen selbst auf und
    /// behält seine Liste dabei.
    private func freigabePruefen() async {
        guard liste.istGeteilt, !liste.istBesitzer, !zeigeFreigabeBeendet else { return }
        guard await SharingManager.shared.teilenVomBesitzerBeendet(fuer: liste) else { return }

        // Nicht weiter pollen - sonst schlägt jede Abfrage in die nun fehlende Zone.
        syncPausiert = true
        zeigeFreigabeBeendet = true
    }

    /// Entfernt die nicht mehr geteilte Liste von diesem Gerät und kehrt zur Übersicht zurück.
    private func listeEntfernen() {
        UserDefaults.standard.removeObject(forKey: listeSchluessel)
        modelContext.delete(liste)
        try? modelContext.save()
        dismiss()
    }

    private func personLaden() async {
        // Bei geteilten Listen zählt die Zuordnung der Apple-ID zum Mitreisenden.
        if liste.istGeteilt {
            await freigabePruefen()
            if zeigeFreigabeBeendet { return }
            try? await SharingManager.shared.personZuordnungenAktualisieren(liste)
            if let zugeordnet = await SharingManager.shared.eigenePerson(in: liste) {
                meinePerson = zugeordnet
                UserDefaults.standard.set(zugeordnet.name, forKey: listeSchluessel)
                return
            }
        }

        if let gespeicherterName = UserDefaults.standard.string(forKey: listeSchluessel),
           let gefunden = (liste.personen ?? []).first(where: { $0.name == gespeicherterName }) {
            meinePerson = gefunden
        } else if meinePerson == nil {
            zeigePersonAuswahl = true
        }
    }
}

/// Eine Zeile in der Mitreisenden-Übersicht mit Fortschritt und Aktiv-Markierung.
private struct MitreisenderZeile: View {
    let person: Person
    let istAktiv: Bool
    let markierung: String
    let fortschritt: Double
    
    var body: some View {
        HStack {
            Text(person.name)
                .foregroundStyle(.primary)
            if istAktiv {
                Text(markierung)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(.blue))
            }
            if person.istZugeordnet {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ProgressView(value: fortschritt)
                .frame(width: 80)
        }
        .contentShape(.rect)
    }
}

private struct ItemZeile: View {
    @Bindable var item: PackingItem

    let person: Person
    let liste: PackingList
    
    private var abgehakt: Bool { item.istAbgehakt(von: person) }
    
    var body: some View {
        Button {
            item.toggleAbgehakt(fuer: person)
            Task {
                do {
                    try await SharingManager.shared.itemAktualisieren(item, in: liste)
                    print("✅ Item hochgeladen: \(item.name)")
                } catch {
                    print("❌ Fehler beim Hochladen von \(item.name): \(error)")
                }
            }
        } label: {
            HStack {
                Image(systemName: abgehakt ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(abgehakt ? .green : .secondary)
                Text(item.name)
                    .foregroundStyle(abgehakt ? .secondary : .primary)
                Spacer()
                if item.istGruppenartikel {
                    Image(systemName: "person.2.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    if let anzahl = item.gepacktVon?.count, anzahl > 0 {
                        Text("\(anzahl)")
                            .font(.caption2)
                            .padding(4)
                            .background(Circle().fill(.green.opacity(0.2)))
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PackingListeDetailView(liste: PackingList(titel: "Test", aktivitaeten: ["Strand", "Wandern"], unterkunftsart: "Hotel", jahreszeit: "Sommer"))
    }
}
