//
//  ContentView.swift
//  Urlaubspackliste
//
//  Created by Jörg Schömer on 06.09.26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PackingList.erstelltAm, order: .reverse) private var packingLists: [PackingList]
    @StateObject private var shareKoordinator = ShareAnnahmeKoordinator.shared
    
    @State private var zeigeNeueListe = false
    @State private var zeigeItemVerwaltung = false
    @State private var teilenAufgehobenHinweis = false
    
    var body: some View {
        NavigationStack {
            Group {
                if packingLists.isEmpty {
                    ContentUnavailableView(
                        "Noch keine Packliste",
                        systemImage: "checklist",
                        description: Text("Erstelle deine erste Packliste für die nächste Reise.")
                    )
                } else {
                    List {
                        ForEach(packingLists) { liste in
                            NavigationLink(value: liste) {
                                VStack(alignment: .leading) {
                                    Text(liste.titel)
                                        .font(.headline)
                                    Text("\(liste.aktivitaet) · \(liste.jahreszeit)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: listeLoeschen)
                    }
                }
            }
            .navigationTitle("Meine Packlisten")
            .navigationDestination(for: PackingList.self) { liste in
                PackingListeDetailView(liste: liste)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        zeigeItemVerwaltung = true
                    } label: {
                        Label("Artikel verwalten", systemImage: "list.bullet.clipboard")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        zeigeNeueListe = true
                    } label: {
                        Label("Neue Packliste", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $zeigeNeueListe) {
                NeuePackListeView()
            }
            .sheet(isPresented: $zeigeItemVerwaltung) {
                ItemVerwaltungView()
            }
            .alert("Teilen aufgehoben", isPresented: $teilenAufgehobenHinweis) {
                Button("OK") {}
            } message: {
                Text("Das Teilen wurde aufgehoben, die Liste ist jetzt wieder bearbeitbar. Zum endgültigen Löschen erneut nach links wischen.")
            }
            .onAppear {
                ItemDaten.seedFallsLeer(context: modelContext)
            }
            .onChange(of: shareKoordinator.annahmeZaehler) { _, _ in
                guard let metadata = shareKoordinator.letzteMetadata else {
                    print("Keine Metadata vorhanden beim onChange")
                    return
                }
                print("onChange ausgelöst, starte geteilteListeUebernehmen")
                Task {
                    do {
                        try await SharingManager.shared.geteilteListeUebernehmen(metadata: metadata, context: modelContext)
                        print("geteilteListeUebernehmen erfolgreich abgeschlossen")
                    } catch {
                        print("Fehler in geteilteListeUebernehmen: \(error)")
                    }
                }
            }
        }
    }
    
    private func listeLoeschen(at offsets: IndexSet) {
        let zuLoeschen = offsets.map { packingLists[$0] }

        for liste in zuLoeschen {
            if liste.istGeteilt && liste.istBesitzer {
                // Erst Teilen aufheben, damit die Liste wieder bearbeitbar wird.
                // Endgültig gelöscht wird sie erst bei einem erneuten Löschversuch (dann istGeteilt == false).
                Task {
                    await SharingManager.shared.teilenAufheben(for: liste)
                    try? modelContext.save()
                }
                teilenAufgehobenHinweis = true
                continue
            }

            if liste.istGeteilt {
                let zoneName = liste.zoneName
                let ownerName = liste.ownerName
                let istBesitzer = liste.istBesitzer
                Task {
                    await SharingManager.shared.zoneLoeschen(zoneName: zoneName, ownerName: ownerName, istBesitzer: istBesitzer)
                }
            }
            modelContext.delete(liste)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PackingList.self, inMemory: true)
}
