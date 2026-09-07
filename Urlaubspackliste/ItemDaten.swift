//
//  ItemDaten.swift
//  Urlaubspackliste
//
//  Created by Jörg Schömer on 06.09.26.
//


import Foundation
import SwiftData

struct ItemDaten {
    static let alle: [(name: String, kategorie: String, aktivitaeten: [String], jahreszeiten: [String], unterkunftsarten: [String], istGruppenartikel: Bool)] = [
        ("Ausweis/Reisepass", "Dokumente", [], [], [], false),
        ("Zahnbürste", "Hygiene", [], [], [], false),
        ("Ladekabel", "Technik", [], [], [], false),
        ("Unterwäsche", "Kleidung", [], [], [], false),
        ("Erste-Hilfe-Set", "Sonstiges", [], [], [], true),
        
        ("Badehose/Bikini", "Kleidung", ["Strand"], [], [], false),
        ("Sonnencreme", "Hygiene", ["Strand"], ["Sommer"], [], true),
        ("Strandtuch", "Sonstiges", ["Strand"], [], [], false),
        ("Flip-Flops", "Kleidung", ["Strand"], [], [], false),
        
        ("Wanderschuhe", "Kleidung", ["Wandern"], [], [], false),
        ("Regenjacke", "Kleidung", ["Wandern"], ["Herbst", "Frühling"], [], false),
        ("Wanderrucksack", "Sonstiges", ["Wandern"], [], [], false),
        ("Trinkflasche", "Sonstiges", ["Wandern"], [], [], false),
        ("Wanderkarte/GPS-Gerät", "Sonstiges", ["Wandern"], [], [], true),
        
        ("Skijacke", "Kleidung", ["Skiurlaub"], ["Winter"], [], false),
        ("Skihandschuhe", "Kleidung", ["Skiurlaub"], ["Winter"], [], false),
        ("Skibrille", "Sonstiges", ["Skiurlaub"], ["Winter"], [], false),
        
        ("Bequeme Schuhe", "Kleidung", ["Städtetrip"], [], [], false),
        ("Stadtplan/Offline-Karten", "Sonstiges", ["Städtetrip"], [], [], true),
        
        ("Laptop", "Technik", ["Geschäftsreise"], [], [], false),
        ("Business-Kleidung", "Kleidung", ["Geschäftsreise"], [], [], false),
        
        ("Zelt", "Sonstiges", [], [], ["Camping"], true),
        ("Schlafsack", "Sonstiges", [], [], ["Camping"], false),
        ("Taschenlampe", "Technik", [], [], ["Camping"], true),
        ("Kocher/Campingkocher", "Sonstiges", [], [], ["Camping"], true),
        
        ("Warme Mütze", "Kleidung", [], ["Winter"], [], false),
        ("Handschuhe", "Kleidung", [], ["Winter"], [], false),
        
        ("Sonnenbrille", "Sonstiges", [], ["Sommer"], [], false),
        ("Kurze Hosen", "Kleidung", [], ["Sommer"], [], false),
    ]
    
    @MainActor
    static func seedFallsLeer(context: ModelContext) {
        let bestehende = try? context.fetch(FetchDescriptor<ItemTemplate>())
        guard (bestehende ?? []).isEmpty else { return }
        
        for vorlage in alle {
            let template = ItemTemplate(
                name: vorlage.name,
                kategorie: vorlage.kategorie,
                istGruppenartikel: vorlage.istGruppenartikel,
                aktivitaeten: vorlage.aktivitaeten,
                jahreszeiten: vorlage.jahreszeiten,
                unterkunftsarten: vorlage.unterkunftsarten
            )
            context.insert(template)
        }
    }
}

