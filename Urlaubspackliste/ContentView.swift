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
        
    @State private var zeigeNeueListe = false
    @State private var zeigeItemVerwaltung = false

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
            .onAppear {
                ItemDaten.seedFallsLeer(context: modelContext)
            }
        }
    }

    private func listeLoeschen(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(packingLists[index])
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PackingList.self, inMemory: true)
}
