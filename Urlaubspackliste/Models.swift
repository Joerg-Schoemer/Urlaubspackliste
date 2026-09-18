import Foundation
import SwiftData

// MARK: - Person, die mitreist
@Model
final class Person {
    var id: UUID = UUID()
    var name: String = ""
    var packingList: PackingList?

    // Zuordnung zu einem Teilnehmer des CloudKit-Shares (Apple-ID);
    // leerer String bedeutet "keine Zuordnung".
    //
    // Die participantID ist die einzige Kennung, die Besitzer und Eingeladener
    // gleich sehen: sie steht im Share-Record selbst. userRecordName dagegen ist
    // blickwinkelabhängig und kennung liefert CloudKit für die eigene Apple-ID nicht.
    var teilnehmerID: String = ""               // participantID im CKShare
    var teilnehmerUserRecordName: String = ""   // CloudKit-Benutzerkennung des Teilnehmers
    var teilnehmerKennung: String = ""          // E-Mail oder Telefonnummer der Apple-ID

    // Items, die diese Person bereits gepackt hat
    var gepackteItems: [PackingItem]? = []

    /// Eine Zuordnung kann allein über die Apple-ID-Kennung bestehen, solange CloudKit
    /// die Benutzerkennung noch nicht liefert (Einladung noch nicht angenommen).
    var istZugeordnet: Bool {
        !teilnehmerID.isEmpty || !teilnehmerUserRecordName.isEmpty || !teilnehmerKennung.isEmpty
    }

    init(name: String = "") {
        self.name = name
    }
}

// MARK: - Eine konkrete Packliste für eine Reise
@Model
final class PackingList {
    var id: UUID = UUID()
    var titel: String = ""
    var aktivitaet: String = ""
    var unterkunftsart: String = ""
    var jahreszeit: String = ""
    var erstelltAm: Date = Date()
    
    // Neu: Sharing-Metadaten
    var istGeteilt: Bool = false
    var istBesitzer: Bool = true
    var zoneName: String = ""          // Name der eigenen CKRecordZone für diese Liste
    var ownerName: String?             // CloudKit-Zonen-Besitzer (nur für Mitglieder relevant)
    var shareRecordName: String?       // Verweis auf den CKShare-Record
        
    
    @Relationship(deleteRule: .cascade, inverse: \PackingItem.packingList)
    var items: [PackingItem]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Person.packingList)
    var personen: [Person]? = []
    
    init(titel: String = "", aktivitaet: String = "", unterkunftsart: String = "", jahreszeit: String = "") {
        self.titel = titel
        self.aktivitaet = aktivitaet
        self.unterkunftsart = unterkunftsart
        self.jahreszeit = jahreszeit
        self.erstelltAm = Date()
        self.zoneName = "Liste-\(UUID().uuidString)"
    }
}

// MARK: - Ein einzelnes Item auf der Packliste
@Model
final class PackingItem {
    var id: UUID = UUID()
    var name: String = ""
    var kategorie: String = ""
    var istGruppenartikel: Bool = false
    var gruppeAbgehakt: Bool = false   // nur relevant, wenn istGruppenartikel == true
    var packingList: PackingList?
    
    @Relationship(inverse: \Person.gepackteItems)
    var gepacktVon: [Person]? = []
    
    init(name: String = "", kategorie: String = "", istGruppenartikel: Bool = false) {
        self.name = name
        self.kategorie = kategorie
        self.istGruppenartikel = istGruppenartikel
    }
    
    func istAbgehakt(von person: Person) -> Bool {
        istGruppenartikel ? gruppeAbgehakt : (gepacktVon ?? []).contains(person)
    }
    
    func toggleAbgehakt(fuer person: Person) {
        if istGruppenartikel {
            gruppeAbgehakt.toggle()
        } else {
            var liste = gepacktVon ?? []
            if let index = liste.firstIndex(of: person) {
                liste.remove(at: index)
            } else {
                liste.append(person)
            }
            gepacktVon = liste
        }
    }
}

// MARK: - Vorlage: mögliche Items mit Tags, aus denen gefiltert wird
@Model
final class ItemTemplate {
    var name: String = ""
    var kategorie: String = ""
    var istGruppenartikel: Bool = false
    var aktivitaeten: [String] = []
    var jahreszeiten: [String] = []
    var unterkunftsarten: [String] = []
    
    init(name: String = "", kategorie: String = "", istGruppenartikel: Bool = false, aktivitaeten: [String] = [], jahreszeiten: [String] = [], unterkunftsarten: [String] = []) {
        self.name = name
        self.kategorie = kategorie
        self.istGruppenartikel = istGruppenartikel
        self.aktivitaeten = aktivitaeten
        self.jahreszeiten = jahreszeiten
        self.unterkunftsarten = unterkunftsarten
    }
}
