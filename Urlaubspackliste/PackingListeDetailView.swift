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
    @Bindable var liste: PackingList
    @State private var meinePerson: Person?
    @State private var zeigePersonAuswahl = false
    @State private var sharePaket: SharePaket?
    @State private var teilenLaeuft = false
    @State private var fehlerText: String?
    @State private var zeigeBearbeiten = false
    
    private var listeSchluessel: String {
        "meinePerson_\(liste.titel)_\(liste.erstelltAm.timeIntervalSince1970)"
    }
    
    private var sortierteItems: [PackingItem] {
        (liste.items ?? []).sorted {
            $0.kategorie == $1.kategorie ? $0.name < $1.name : $0.kategorie < $1.kategorie
        }
    }

    private var gruppierteKategorien: [String] {
        Array(Set(sortierteItems.map { $0.kategorie })).sorted()
    }
    
    private var fortschritt: Double {
        guard let meinePerson else { return 0 }
        return fortschritt(fuer: meinePerson)
    }

    private func fortschritt(fuer person: Person) -> Double {
        let items = liste.items ?? []
        guard !items.isEmpty else { return 0 }
        let erledigt = items.filter { $0.istAbgehakt(von: person) }.count
        return Double(erledigt) / Double(items.count)
    }
    
    var body: some View {
        List {
            if let meinePerson {
                ForEach(gruppierteKategorien, id: \.self) { kategorie in
                    Section(kategorie) {
                        ForEach(sortierteItems.filter { $0.kategorie == kategorie }) { item in
                            ItemZeile(item: item, person: meinePerson, liste: liste)
                        }
                    }
                }
            }
            
            if !(liste.personen ?? []).isEmpty {
                Section("Mitreisende") {
                    ForEach(liste.personen ?? []) { person in
                        HStack {
                            Text(person.name)
                            if person.id == meinePerson?.id {
                                Text("Du")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(.blue))
                            }
                            Spacer()
                            ProgressView(value: fortschritt(fuer: person))
                                .frame(width: 80)
                        }
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
        .onAppear { personLaden() }
        .sheet(isPresented: $zeigePersonAuswahl) {
            PersonAuswahlView(personen: liste.personen ?? []) { ausgewaehlt in
                meinePerson = ausgewaehlt
                UserDefaults.standard.set(ausgewaehlt.name, forKey: listeSchluessel)
                zeigePersonAuswahl = false
            }
        }
        .sheet(item: $sharePaket) { paket in
            CloudSharingView(share: paket.share, container: paket.container)
        }
        .sheet(isPresented: $zeigeBearbeiten) {
            PackingListeBearbeitenView(liste: liste)
        }
        .alert("Fehler beim Teilen", isPresented: .constant(fehlerText != nil)) {
            Button("OK") { fehlerText = nil }
        } message: {
            Text(fehlerText ?? "")
        }
        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
            guard liste.istGeteilt else { return }
            print("🔄 Polling für Liste: \(liste.titel), istBesitzer: \(liste.istBesitzer)")
            Task {
                do {
                    try await SharingManager.shared.listeAktualisieren(liste)
                    print("✅ listeAktualisieren erfolgreich durchlaufen")
                } catch {
                    print("❌ Fehler bei listeAktualisieren: \(error)")
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
    
    private func personLaden() {
        if let gespeicherterName = UserDefaults.standard.string(forKey: listeSchluessel),
           let gefunden = (liste.personen ?? []).first(where: { $0.name == gespeicherterName }) {
            meinePerson = gefunden
        } else if meinePerson == nil {
            zeigePersonAuswahl = true
        }
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
                    .strikethrough(abgehakt)
                    .foregroundStyle(abgehakt ? .secondary : .primary)
                if item.istGruppenartikel {
                    Image(systemName: "person.2.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if !item.istGruppenartikel, let anzahl = item.gepacktVon?.count, anzahl > 0 {
                    Text("\(anzahl)")
                        .font(.caption2)
                        .padding(6)
                        .background(Circle().fill(.green.opacity(0.2)))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PackingListeDetailView(liste: PackingList(titel: "Test", aktivitaet: "Strand", unterkunftsart: "Hotel", jahreszeit: "Sommer"))
    }
}
