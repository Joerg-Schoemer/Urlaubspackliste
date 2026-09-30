//
//  ItemDaten.swift
//  Urlaubspackliste
//
//  Created by Jörg Schömer on 06.09.26.
//


import Foundation
import SwiftData

struct ItemDaten {
    /// Das Gewicht sortiert innerhalb der Kategorie und hält Verwandtes beieinander.
    ///
    /// Vergeben in 10er-Schritten, damit sich später etwas dazwischenschieben lässt.
    /// Die Gruppen gelten je Kategorie für sich - eine 20 in "Kleidung" hat mit
    /// einer 20 in "Apotheke" nichts zu tun.
    ///
    /// Kleidung:     10 Oberteile · 20 Hosen · 30 Jacken · 40 Unterwäsche und Socken ·
    ///               50 Schuhe · 60 Kopf, Hände, Hals · 70 Schlafen · 80 Baden · 90 Sport
    /// Sonstiges:    10 Bettzeug · 20 Wäsche · 30 Camping · 40 Wassersport ·
    ///               50 Werkzeug · 60 Ski · 70 Fahrrad · 80 Taschen ·
    ///               90 Unterhaltung · 100 Persönliches
    /// Apotheke:     10 Wundversorgung · 20 Medikamente · 30 Erkältung · 40 Haut und Mund
    /// Technik:      10 Strom · 20 Licht · 30 Geräte · 40 Zubehör
    /// Hygiene:      10 Körperpflege · 20 Sonnenschutz · 30 Insekten · 40 Papier · 50 Waschen
    /// Dokumente:    10 Person · 20 Gesundheit · 30 Fahrzeug
    /// Lebensmittel: 10 Kaffee · 20 Backen und Süßen · 30 Würzen · 40 Getränke · 50 Unterwegs
    /// Auto:         10 Fahrzeug · 20 Dachlast · 30 Zurren
    static let alle: [(name: String, kategorie: String, aktivitaeten: [String], jahreszeiten: [String], unterkunftsarten: [String], istGruppenartikel: Bool, gewicht: Int)] = [
        // Allgemein (für jede Reise)
        ("Ausweis", "Dokumente", [], [], [], false, 10),
        ("Krankenkassenkarte", "Dokumente", [], [], [], false, 20),
        ("Impfpässe", "Dokumente", [], [], [], false, 20),
        ("Vollmacht", "Dokumente", [], [], [], false, 10),
        ("Hosen", "Kleidung", [], [], [], false, 20),
        ("Kurze Hosen", "Kleidung", [], ["Sommer"], [], false, 20),
        ("T-Shirts", "Kleidung", [], [], [], false, 10),
        ("Pullis", "Kleidung", [], [], [], false, 10),
        ("Jacke", "Kleidung", [], [], [], false, 30),
        ("Regenjacke", "Kleidung", [], ["Herbst", "Frühling"], [], false, 30),
        ("Sonnenhut", "Kleidung", [], ["Sommer"], [], false, 60),
        ("Unterwäsche", "Kleidung", [], [], [], false, 40),
        ("Socken", "Kleidung", [], [], [], false, 40),
        ("Schuhe", "Kleidung", [], [], [], false, 50),
        ("Schlafanzug", "Kleidung", [], [], [], false, 70),
        ("Kosmetik", "Hygiene", [], [], [], false, 10),
        ("Badeanzug/Badehose", "Kleidung", ["Strand"], [], [], false, 80),
        ("Badelatschen", "Kleidung", ["Strand"], [], [], false, 50),
        ("Strandponchos", "Kleidung", ["Strand"], [], [], false, 80),
        ("Taucherbrille", "Sonstiges", ["Strand"], [], [], false, 40),
        ("Schlafsack", "Sonstiges", [], [], ["Camping"], false, 10),
        ("Kopfkissen", "Sonstiges", [], [], [], false, 10),
        ("Bettdecken", "Sonstiges", [], [], [], false, 10),
        ("Bettwäsche", "Sonstiges", [], [], [], false, 10),
        ("Kopfhörer", "Technik", [], [], [], false, 30),
        ("Sonnenbrille", "Sonstiges", [], [], [], false, 100),
        ("Bücher", "Sonstiges", [], [], [], false, 90),
        ("Musik", "Sonstiges", [], [], [], false, 90),
        ("Sportkleidung", "Kleidung", [], [], [], false, 90),
        ("iPad", "Technik", [], [], [], false, 30),
        ("Trinkflasche", "Sonstiges", [], [], [], false, 100),

        // Apotheke
        ("Salzwassernasenspray", "Apotheke", [], [], [], false, 30),
        ("Abschwellendes Nasenspray", "Apotheke", [], [], [], false, 30),
        ("Kamistad", "Apotheke", [], [], [], true, 40),
        ("Fenistil (Anti-Juck)", "Apotheke", [], [], [], true, 40),
        ("Pflaster", "Apotheke", [], [], [], true, 10),
        ("Desinfektionsmittel", "Apotheke", [], [], [], true, 10),
        ("Schmerzmittel", "Apotheke", [], [], [], true, 20),
        ("Wundsalbe", "Apotheke", [], [], [], true, 10),
        ("Brand- & Wundgel", "Apotheke", [], [], [], true, 10),
        ("Durchfallmittel", "Apotheke", [], [], [], true, 20),
        ("Kamillosan", "Apotheke", [], [], [], true, 40),

        // Auto
        ("Scheibenwaschzeug Sommer", "Auto", [], ["Sommer"], [], true, 10),
        ("Fahrzeugschein", "Dokumente", [], [], [], true, 30),
        ("Führerscheine", "Dokumente", [], [], [], true, 30),
        ("Reiseproviant", "Lebensmittel", [], [], [], true, 50),

        // Bootfahren
        ("Schwimmwesten", "Sonstiges", ["Bootfahren"], [], [], false, 40),
        ("Kopfbedeckung", "Kleidung", ["Bootfahren"], [], [], false, 60),
        ("Cap-Catcher", "Sonstiges", ["Bootfahren"], [], [], false, 40),
        ("Neoprenschläppchen", "Kleidung", ["Bootfahren"], [], [], false, 50),
        ("SUP", "Sonstiges", ["Bootfahren"], [], [], true, 40),
        ("SUP Finne", "Sonstiges", ["Bootfahren"], [], [], true, 40),
        ("SUP Leash", "Sonstiges", ["Bootfahren"], [], [], true, 40),
        ("Paddel", "Sonstiges", ["Bootfahren"], [], [], true, 40),
        ("2,5mm Imbusschlüssel", "Sonstiges", ["Bootfahren"], [], [], true, 50),
        ("Schraubendreher", "Sonstiges", ["Bootfahren"], [], [], true, 50),
        ("Wasserdichte Handyhülle", "Technik", ["Bootfahren"], [], [], true, 40),
        ("Schlüsselanhänger Schwimmer", "Sonstiges", ["Bootfahren"], [], [], true, 40),
        ("Schlüssel Spanngurte", "Auto", ["Bootfahren"], [], [], true, 30),

        // Camping
        ("Zelt", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Luftmatratzen", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Luftpumpe", "Sonstiges", [], [], ["Camping"], true, 30),

        // Haushalt
        ("Sonnencreme", "Hygiene", [], [], [], true, 20),
        ("Apres Sun", "Hygiene", [], [], [], true, 20),
        ("Anti Brumm", "Hygiene", [], ["Sommer"], [], true, 30),
        ("Nähzeug", "Sonstiges", [], [], [], true, 50),
        ("Handtücher", "Sonstiges", [], [], [], true, 20),
        ("Waschlappen", "Hygiene", [], [], [], true, 10),
        ("Wäschebeutel", "Sonstiges", [], [], [], true, 20),
        ("Maglite/Stirnlampe", "Technik", [], [], [], true, 20),
        ("Batterien", "Technik", [], [], [], true, 10),
        ("Taschenmesser", "Sonstiges", [], [], [], true, 50),
        ("Ladegeräte", "Technik", [], [], [], true, 10),
        ("Mehrfachstecker", "Technik", [], [], [], true, 10),
        ("Powerbanks", "Technik", [], [], [], true, 10),
        ("Kartenspiele", "Sonstiges", [], [], [], true, 90),
        ("Kuscheltiere", "Sonstiges", [], [], [], true, 90),
        ("Rei in der Tube", "Hygiene", [], [], [], true, 50),
        ("Taschentücher", "Hygiene", [], [], [], true, 40),
        ("Papier und Stifte", "Sonstiges", [], [], [], true, 90),

        // Lebensmittel
        ("Gewürze (Salz, Pfeffer)", "Lebensmittel", [], [], ["Ferienwohnung"], true, 30),
        ("Kaffee", "Lebensmittel", [], [], [], true, 10),
        ("Kaffeefilter", "Lebensmittel", [], [], [], true, 10),
        ("Back-Kakao", "Lebensmittel", [], [], [], true, 20),
        ("Erythrit", "Lebensmittel", [], [], [], true, 20),
        ("Limo Zero", "Lebensmittel", [], [], [], true, 40),
        ("Müsliriegel", "Lebensmittel", [], [], [], true, 50),

        // Ski
        ("Skischuhe", "Kleidung", ["Skifahren"], ["Winter"], [], false, 50),
        ("Helme", "Sonstiges", ["Skifahren"], ["Winter"], [], false, 60),
        ("Skibrillen", "Sonstiges", ["Skifahren"], ["Winter"], [], false, 60),
        ("Skihandschuhe", "Kleidung", ["Skifahren"], ["Winter"], [], false, 60),
        ("Seidenhandschuhe", "Kleidung", ["Skifahren"], ["Winter"], [], false, 60),
        ("Schlauchschal", "Kleidung", ["Skifahren"], ["Winter"], [], false, 60),
        ("Sturmhaube", "Kleidung", ["Skifahren"], ["Winter"], [], false, 60),
        ("Skijacke", "Kleidung", ["Skifahren"], ["Winter"], [], false, 30),
        ("Skisocken", "Kleidung", ["Skifahren"], ["Winter"], [], false, 40),
        ("Schneehose", "Kleidung", ["Skifahren"], ["Winter"], [], false, 20),
        ("Funktionsshirts", "Kleidung", ["Skifahren"], ["Winter"], [], false, 10),
        ("Lange Unterhosen/Wollhosen", "Kleidung", ["Skifahren"], ["Winter"], [], false, 40),
        ("Kleiner Rucksack", "Sonstiges", ["Skifahren"], ["Winter"], [], false, 80),
        ("Skischlösser", "Sonstiges", ["Skifahren"], ["Winter"], [], false, 60),
        ("Protektoren", "Sonstiges", ["Skifahren"], ["Winter"], [], false, 60),
        ("Beheizte Handschuhe", "Kleidung", ["Skifahren"], ["Winter"], [], false, 60),
        ("Lippenschutz", "Hygiene", ["Skifahren"], ["Winter"], [], true, 20),
        ("Bauchtasche", "Sonstiges", ["Skifahren"], ["Winter"], [], true, 80),
        ("Poporutsche", "Sonstiges", ["Skifahren"], ["Winter"], [], true, 60),
        ("Dachträger", "Auto", ["Skifahren"], [], [], true, 20),
        ("Dachbox", "Auto", ["Skifahren"], [], [], true, 20),

        // Wandern
        ("Wanderschuhe", "Kleidung", ["Wandern"], [], [], false, 50),
        ("Wandersocken", "Kleidung", ["Wandern"], [], [], false, 40),
        ("Wanderhose", "Kleidung", ["Wandern"], [], [], false, 20),
        ("Funktionsunterwäsche", "Kleidung", ["Wandern"], [], [], false, 40),

        // Fahrradfahren
        ("Fahrrad", "Sonstiges", ["Fahrradfahren"], [], [], false, 70),
        ("Fahrradhelm", "Sonstiges", ["Fahrradfahren"], [], [], false, 70),
        ("Fahrradträger", "Auto", ["Fahrradfahren"], [], [], true, 20),

    ]
    
    @MainActor
    static func seedFallsLeer(context: ModelContext) {
        let bestehende = (try? context.fetch(FetchDescriptor<ItemTemplate>())) ?? []
        
        // Ist schon etwas da, wird nichts ergänzt - sonst kämen gelöschte Vorlagen zurück.
        // Stattdessen werden Kopien aus früheren Doppel-Seeds aufgeräumt.
        guard bestehende.isEmpty else {
            duplikateEntfernen(bestehende, context: context)
            return
        }
        
        for vorlage in alle {
            let template = ItemTemplate(
                name: vorlage.name,
                kategorie: vorlage.kategorie,
                istGruppenartikel: vorlage.istGruppenartikel,
                aktivitaeten: vorlage.aktivitaeten,
                jahreszeiten: vorlage.jahreszeiten,
                unterkunftsarten: vorlage.unterkunftsarten,
                gewicht: vorlage.gewicht
            )
            context.insert(template)
        }
        
        // Sofort sichern: onAppear kann erneut feuern, und ein ungesicherter
        // Kontext lieferte oben wieder ein leeres Ergebnis - der Katalog
        // würde ein zweites Mal angelegt.
        try? context.save()
    }
    
    /// Entfernt exakte Kopien einer Vorlage und behält jeweils die erste.
    ///
    /// Verglichen wird der vollständige Inhalt, nicht nur der Name. Zwei
    /// gleichnamige Vorlagen mit unterschiedlichen Merkmalen bleiben damit
    /// erhalten - die hat jemand bewusst angelegt oder bearbeitet.
    @MainActor
    private static func duplikateEntfernen(_ vorlagen: [ItemTemplate], context: ModelContext) {
        var gesehen = Set<String>()
        var entferntEtwas = false
        
        for vorlage in vorlagen {
            let merkmale = [
                vorlage.name,
                vorlage.kategorie,
                String(vorlage.istGruppenartikel),
                vorlage.aktivitaeten.sorted().joined(separator: ","),
                vorlage.jahreszeiten.sorted().joined(separator: ","),
                vorlage.unterkunftsarten.sorted().joined(separator: ",")
            ].joined(separator: "|")
            
            if gesehen.insert(merkmale).inserted == false {
                context.delete(vorlage)
                entferntEtwas = true
            }
        }
        
        if entferntEtwas {
            try? context.save()
        }
    }
}

