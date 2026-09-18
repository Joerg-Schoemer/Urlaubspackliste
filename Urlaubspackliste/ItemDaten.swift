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
        // Allgemein (für jede Reise)
        ("Ausweis", "Dokumente", [], [], [], false),
        ("Krankenkassenkarte", "Dokumente", [], [], [], false),
        ("Impfpässe", "Dokumente", [], [], [], false),
        ("Vollmacht", "Dokumente", [], [], [], false),
        ("Hosen", "Kleidung", [], [], [], false),
        ("Kurze Hosen", "Kleidung", [], ["Sommer"], [], false),
        ("T-Shirts", "Kleidung", [], [], [], false),
        ("Pullis", "Kleidung", [], [], [], false),
        ("Jacke", "Kleidung", [], [], [], false),
        ("Regenjacke", "Kleidung", [], ["Herbst", "Frühling"], [], false),
        ("Sonnenhut", "Kleidung", [], ["Sommer"], [], false),
        ("Unterwäsche", "Kleidung", [], [], [], false),
        ("Socken", "Kleidung", [], [], [], false),
        ("Schuhe", "Kleidung", [], [], [], false),
        ("Schlafanzug", "Kleidung", [], [], [], false),
        ("Kosmetik", "Hygiene", [], [], [], false),
        ("Badeanzug/Badehose", "Kleidung", ["Strand"], [], [], false),
        ("Badelatschen", "Kleidung", ["Strand"], [], [], false),
        ("Strandponchos", "Kleidung", ["Strand"], [], [], false),
        ("Taucherbrille", "Sonstiges", ["Strand"], [], [], false),
        ("Schlafsack", "Sonstiges", [], [], ["Camping"], false),
        ("Kopfkissen", "Sonstiges", [], [], [], false),
        ("Bettdecken", "Sonstiges", [], [], [], false),
        ("Bettwäsche", "Sonstiges", [], [], [], false),
        ("Bettücher 1,4m", "Sonstiges", [], [], [], false),
        ("Kopfhörer", "Technik", [], [], [], false),
        ("Sonnenbrille", "Sonstiges", [], [], [], false),
        ("Bücher", "Sonstiges", [], [], [], false),
        ("Musik", "Sonstiges", [], [], [], false),
        ("Sportkleidung", "Kleidung", [], [], [], false),
        ("iPad", "Technik", [], [], [], false),
        ("Trinkflasche", "Sonstiges", [], [], [], false),

        // Apotheke
        ("Salzwassernasenspray", "Apotheke", [], [], [], false),
        ("Abschwellendes Nasenspray", "Apotheke", [], [], [], false),
        ("Kamistad", "Apotheke", [], [], [], true),
        ("Fenistil (Anti-Juck)", "Apotheke", [], [], [], true),
        ("Pflaster", "Apotheke", [], [], [], true),
        ("Desinfektionsmittel", "Apotheke", [], [], [], true),
        ("Schmerzmittel", "Apotheke", [], [], [], true),
        ("Wundsalbe", "Apotheke", [], [], [], true),
        ("Brand- & Wundgel", "Apotheke", [], [], [], true),
        ("Durchfallmittel", "Apotheke", [], [], [], true),
        ("Kamillosan", "Apotheke", [], [], [], true),

        // Auto
        ("Scheibenwaschzeug Sommer", "Auto", [], ["Sommer"], [], true),
        ("Fahrzeugschein", "Dokumente", [], [], [], true),
        ("Führerscheine", "Dokumente", [], [], [], true),
        ("Dachträger", "Auto", [], [], [], true),
        ("Schlüssel Spanngurte", "Auto", [], [], [], true),
        ("Reiseproviant", "Lebensmittel", [], [], [], true),

        // Bootfahren
        ("Schwimmwesten", "Sonstiges", ["Bootfahren"], [], [], false),
        ("Kopfbedeckung", "Kleidung", ["Bootfahren"], [], [], false),
        ("Cap-Catcher", "Sonstiges", ["Bootfahren"], [], [], false),
        ("Neoprenschläppchen", "Kleidung", ["Bootfahren"], [], [], false),
        ("SUP", "Sonstiges", ["Bootfahren"], [], [], true),
        ("SUP Finne", "Sonstiges", ["Bootfahren"], [], [], true),
        ("SUP Leash", "Sonstiges", ["Bootfahren"], [], [], true),
        ("Paddel", "Sonstiges", ["Bootfahren"], [], [], true),
        ("2,5mm Imbusschlüssel", "Sonstiges", ["Bootfahren"], [], [], true),
        ("Schraubendreher", "Sonstiges", ["Bootfahren"], [], [], true),
        ("Wasserdichte Handyhülle", "Technik", ["Bootfahren"], [], [], true),
        ("Schlüsselanhänger Schwimmer", "Sonstiges", ["Bootfahren"], [], [], true),

        // Camping
        ("Zelt", "Sonstiges", [], [], ["Camping"], true),
        ("Luftmatratzen", "Sonstiges", [], [], ["Camping"], true),
        ("Luftpumpe", "Sonstiges", [], [], ["Camping"], true),

        // Haushalt
        ("Sonnencreme", "Hygiene", [], [], [], true),
        ("Apres Sun", "Hygiene", [], [], [], true),
        ("Anti Brumm", "Hygiene", [], ["Sommer"], [], true),
        ("Nähzeug", "Sonstiges", [], [], [], true),
        ("Handtücher", "Sonstiges", [], [], [], true),
        ("Waschlappen", "Hygiene", [], [], [], true),
        ("Wäschebeutel", "Sonstiges", [], [], [], true),
        ("Maglite/Stirnlampe", "Technik", [], [], [], true),
        ("Batterien", "Technik", [], [], [], true),
        ("Taschenmesser", "Sonstiges", [], [], [], true),
        ("Ladegeräte", "Technik", [], [], [], true),
        ("Mehrfachstecker", "Technik", [], [], [], true),
        ("Powerbanks", "Technik", [], [], [], true),
        ("Kartenspiele", "Sonstiges", [], [], [], true),
        ("Kuscheltiere", "Sonstiges", [], [], [], true),
        ("Rei in der Tube", "Hygiene", [], [], [], true),
        ("Taschentücher", "Hygiene", [], [], [], true),
        ("Papier und Stifte", "Sonstiges", [], [], [], true),

        // Lebensmittel
        ("Gewürze (Salz, Pfeffer)", "Lebensmittel", [], [], ["Ferienwohnung"], true),
        ("Kaffee", "Lebensmittel", [], [], [], true),
        ("Kaffeefilter", "Lebensmittel", [], [], [], true),
        ("Back-Kakao", "Lebensmittel", [], [], [], true),
        ("Erythrit", "Lebensmittel", [], [], [], true),
        ("Limo Zero", "Lebensmittel", [], [], [], true),
        ("Müsliriegel", "Lebensmittel", [], [], [], true),

        // Ski
        ("Skischuhe", "Kleidung", ["Skiurlaub"], ["Winter"], [], false),
        ("Helme", "Sonstiges", ["Skiurlaub"], ["Winter"], [], false),
        ("Skibrillen", "Sonstiges", ["Skiurlaub"], ["Winter"], [], false),
        ("Skihandschuhe", "Kleidung", ["Skiurlaub"], ["Winter"], [], false),
        ("Seidenhandschuhe", "Kleidung", ["Skiurlaub"], ["Winter"], [], false),
        ("Schlauchschal", "Kleidung", ["Skiurlaub"], ["Winter"], [], false),
        ("Sturmhaube", "Kleidung", ["Skiurlaub"], ["Winter"], [], false),
        ("Skijacke", "Kleidung", ["Skiurlaub"], ["Winter"], [], false),
        ("Skisocken", "Kleidung", ["Skiurlaub"], ["Winter"], [], false),
        ("Schneehose", "Kleidung", ["Skiurlaub"], ["Winter"], [], false),
        ("Funktionsshirts", "Kleidung", ["Skiurlaub"], ["Winter"], [], false),
        ("Lange Unterhosen/Wollhosen", "Kleidung", ["Skiurlaub"], ["Winter"], [], false),
        ("Kleiner Rucksack", "Sonstiges", ["Skiurlaub"], ["Winter"], [], false),
        ("Skischlösser", "Sonstiges", ["Skiurlaub"], ["Winter"], [], false),
        ("Protektoren", "Sonstiges", ["Skiurlaub"], ["Winter"], [], false),
        ("Beheizte Handschuhe", "Kleidung", ["Skiurlaub"], ["Winter"], [], false),
        ("Lippenschutz", "Hygiene", ["Skiurlaub"], ["Winter"], [], true),
        ("Bauchtasche", "Sonstiges", ["Skiurlaub"], ["Winter"], [], true),
        ("Poporutsche", "Sonstiges", ["Skiurlaub"], ["Winter"], [], true),

        // Wandern
        ("Wanderschuhe", "Kleidung", ["Wandern"], [], [], false),
        ("Wandersocken", "Kleidung", ["Wandern"], [], [], false),
        ("Wanderhose", "Kleidung", ["Wandern"], [], [], false),
        ("Funktionsunterwäsche", "Kleidung", ["Wandern"], [], [], false),
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

