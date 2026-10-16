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
    static let alle: [(
        name: String,
        kategorie: String,
        aktivitaeten: [String],
        jahreszeiten: [String],
        unterkunftsarten: [String],
        istGruppenartikel: Bool,
        gewicht: Int
    )] = [
        // Apotheke
        ("Brand- & Wundgel", "Apotheke", [], [], [], true, 10),
        ("Desinfektionsmittel", "Apotheke", [], [], [], true, 10),
        ("Pflaster", "Apotheke", [], [], [], true, 10),
        ("Rettungsdecke", "Apotheke", [], [], [], true, 10),
        ("Verband", "Apotheke", [], [], [], true, 10),
        ("Wundsalbe", "Apotheke", [], [], [], true, 10),
        ("Durchfallmittel", "Apotheke", [], [], [], true, 20),
        ("L-Thyroxin", "Apotheke", [], [], [], true, 20),
        ("Reisetabletten/Kaugummis", "Apotheke", [], [], [], true, 20),
        ("Schmerzmittel", "Apotheke", [], [], [], true, 20),
        ("Trinkwasserentkeimung", "Apotheke", [], [], ["Camping"], true, 20),
        ("Vitamin-D", "Apotheke", [], [], [], true, 20),
        ("Abschwellendes Nasenspray", "Apotheke", [], [], [], false, 30),
        ("Erkältungsbalsam", "Apotheke", [], [], [], true, 30),
        ("Fieberthermometer", "Apotheke", [], [], [], true, 30),
        ("Inhalator", "Apotheke", [], [], [], true, 30),
        ("Salzwassernasenspray", "Apotheke", [], [], [], false, 30),
        ("Fenistil (Anti-Juck)", "Apotheke", [], [], [], true, 40),
        ("Handcreme", "Apotheke", [], [], [], true, 40),
        ("Kamillosan", "Apotheke", [], [], [], true, 40),
        ("Kamistad", "Apotheke", [], [], [], true, 40),
        ("Kotzbeutel", "Apotheke", [], [], [], true, 40),
        ("Zahnspange", "Apotheke", [], [], [], false, 40),
        // Auto
        ("Handfeger für Schnee", "Auto", [], ["Winter"], [], true, 10),
        ("Scheibenwaschzeug Sommer", "Auto", [], ["Sommer", "Herbst", "Frühling"], [], true, 10),
        ("Scheibenwaschzeug Winter", "Auto", [], ["Winter"], [], true, 10),
        ("Dachbox", "Auto", ["Skifahren"], [], [], true, 20),
        ("Dachträger", "Auto", ["Skifahren"], [], [], true, 20),
        ("Fahrradträger", "Auto", ["Fahrradfahren"], [], [], true, 20),
        ("Schlüssel Dachbox", "Auto", ["Skifahren"], [], [], true, 20),
        ("Schlüssel Dachträger", "Auto", ["Fahrradfahren", "Skifahren"], [], [], true, 20),
        ("Schlüssel Fahrradträger", "Auto", ["Fahrradfahren"], [], [], true, 20),
        ("Schlüssel Spanngurte", "Auto", ["Bootfahren"], [], [], true, 20),
        ("Auffahrkeile", "Auto", [], [], ["Camping"], true, 30),
        ("Kindersitz", "Auto", [], [], [], true, 30),
        ("Schneeketten", "Auto", [], ["Winter"], [], true, 30),
        ("Vignette", "Auto", [], [], [], true, 30),
        // Diabetes
        ("Blutzuckermessgerät", "Diabetes", ["Diabetes"], [], [], true, 10),
        ("DIA-Powerbank", "Diabetes", ["Diabetes"], [], [], true, 10),
        ("Diabetes-Handy", "Diabetes", ["Diabetes"], [], [], true, 10),
        ("Diabetes-Watch", "Diabetes", ["Diabetes"], [], [], true, 10),
        ("Ersatz-PDM", "Diabetes", ["Diabetes"], [], [], true, 10),
        ("Ersatzpods Omnipod", "Diabetes", ["Diabetes"], [], [], true, 10),
        ("Ersatzsensoren Dexcom", "Diabetes", ["Diabetes"], [], [], true, 10),
        ("PEN", "Diabetes", ["Diabetes"], [], [], true, 10),
        ("Ladekabel Handy", "Diabetes", ["Diabetes"], [], [], true, 20),
        ("Ladekabel PDM", "Diabetes", ["Diabetes"], [], [], true, 20),
        ("Ladekabel Watch", "Diabetes", ["Diabetes"], [], [], true, 20),
        ("Alkoholtücher", "Diabetes", ["Diabetes"], [], [], true, 30),
        ("baqsimi", "Diabetes", ["Diabetes"], [], [], true, 30),
        ("Fixomull Pflaster", "Diabetes", ["Diabetes"], [], [], true, 30),
        ("Insulin", "Diabetes", ["Diabetes"], [], [], true, 30),
        ("Kühltaschen für Insulin", "Diabetes", ["Diabetes"], [], [], true, 30),
        ("Lanzetten", "Diabetes", ["Diabetes"], [], [], true, 30),
        ("Nadeldose", "Diabetes", ["Diabetes"], [], [], true, 30),
        ("Stechhilfe", "Diabetes", ["Diabetes"], [], [], true, 30),
        ("Teststreifen Blutzucker", "Diabetes", ["Diabetes"], [], [], true, 30),
        ("Teststreifen Ketone", "Diabetes", ["Diabetes"], [], [], true, 30),
        ("APP-Salbe", "Diabetes", ["Diabetes"], [], [], true, 40),
        ("Bauchgürtel", "Diabetes", ["Diabetes"], [], [], true, 40),
        ("Bauchtasche", "Diabetes", ["Diabetes"], [], [], true, 40),
        ("edding", "Diabetes", ["Diabetes"], [], [], true, 40),
        ("Pflasterlöser", "Diabetes", ["Diabetes"], [], [], true, 40),
        ("Star-Wars-Tasche", "Diabetes", ["Diabetes"], [], [], true, 40),
        ("Tagebuch", "Diabetes", ["Diabetes"], [], [], true, 40),
        ("lange KH", "Diabetes", ["Diabetes"], [], [], true, 50),
        ("Traubenzucker", "Diabetes", ["Diabetes"], [], [], true, 50),
        // Dokumente
        ("Ausweis", "Dokumente", [], [], [], false, 10),
        ("Vollmacht", "Dokumente", [], [], [], false, 10),
        ("Impfpass", "Dokumente", [], [], [], false, 20),
        ("Krankenkassenkarte", "Dokumente", [], [], [], false, 20),
        ("Bootsführerscheine", "Dokumente", ["Bootfahren"], [], [], true, 30),
        ("Fahrzeugschein", "Dokumente", [], [], [], true, 30),
        ("Führerschein", "Dokumente", [], [], [], false, 30),
        ("Versicherungsnachweis", "Dokumente", [], [], [], true, 30),
        // Hygiene
        ("Handwaschmittel", "Hygiene", [], [], ["Ferienwohnung"], true, 10),
        ("Kosmetik", "Hygiene", [], [], [], false, 10),
        ("Seife", "Hygiene", [], [], ["Ferienwohnung"], true, 10),
        ("Waschlappen", "Hygiene", [], [], ["Ferienwohnung"], true, 10),
        ("Apres Sun", "Hygiene", [], [], [], true, 20),
        ("Handtücher", "Hygiene", [], [], ["Ferienwohnung", "Camping"], true, 20),
        ("Lippenschutz", "Hygiene", ["Skifahren"], ["Winter"], [], true, 20),
        ("Sonnencreme", "Hygiene", [], [], [], true, 20),
        ("Anti Brumm", "Hygiene", [], ["Sommer"], [], true, 30),
        ("Klopapier", "Hygiene", [], [], ["Ferienwohnung"], true, 40),
        ("Küchenrolle", "Hygiene", [], [], ["Ferienwohnung"], true, 40),
        ("Servietten", "Hygiene", [], [], ["Ferienwohnung"], true, 40),
        ("Taschentücher", "Hygiene", [], [], [], true, 40),
        ("WC-Chemie", "Hygiene", [], [], ["Camping"], true, 40),
        ("Gallseife", "Hygiene", [], [], ["Ferienwohnung"], true, 50),
        ("Geschirrtücher", "Hygiene", [], [], ["Ferienwohnung"], true, 50),
        ("Putzlappen", "Hygiene", [], [], ["Ferienwohnung"], true, 50),
        ("Spüli", "Hygiene", [], [], ["Camping", "Ferienwohnung"], true, 50),
        ("Spüllappen", "Hygiene", [], [], ["Ferienwohnung"], true, 50),
        ("Spülmaschinentabs", "Hygiene", [], [], ["Ferienwohnung"], true, 50),
        ("Waschmittel", "Hygiene", [], [], ["Ferienwohnung"], true, 50),
        ("Wollshampoo", "Hygiene", [], [], ["Ferienwohnung"], true, 50),
        // Kleidung
        ("Funktionsshirts", "Kleidung", ["Skifahren"], ["Winter"], [], false, 10),
        ("Pullis", "Kleidung", [], [], [], false, 10),
        ("T-Shirts", "Kleidung", [], [], [], false, 10),
        ("Gürtel", "Kleidung", [], [], [], false, 20),
        ("Hosen", "Kleidung", [], [], [], false, 20),
        ("Kurze Hosen", "Kleidung", [], ["Sommer"], [], false, 20),
        ("Schneehose", "Kleidung", ["Skifahren"], ["Winter"], [], false, 20),
        ("Segelhose", "Kleidung", ["Bootfahren"], [], [], false, 20),
        ("Wanderhose", "Kleidung", ["Wandern"], [], [], false, 20),
        ("Jacke", "Kleidung", [], [], [], false, 30),
        ("Regenhose", "Kleidung", [], ["Herbst", "Frühling"], [], false, 30),
        ("Regenjacke", "Kleidung", [], ["Herbst", "Frühling"], [], false, 30),
        ("Segeljacke", "Kleidung", ["Bootfahren"], [], [], false, 30),
        ("Skijacke", "Kleidung", ["Skifahren"], ["Winter"], [], false, 30),
        ("Softshell", "Kleidung", ["Wandern"], [], [], false, 30),
        ("Funktionsunterwäsche", "Kleidung", ["Wandern"], [], [], false, 40),
        ("Lange Unterhosen", "Kleidung", ["Skifahren"], ["Winter"], [], false, 40),
        ("Skisocken", "Kleidung", ["Skifahren"], ["Winter"], [], false, 40),
        ("Socken", "Kleidung", [], [], [], false, 40),
        ("Unterwäsche", "Kleidung", [], [], [], false, 40),
        ("Wandersocken", "Kleidung", ["Wandern"], [], [], false, 40),
        ("Badelatschen", "Kleidung", ["Schwimmen"], [], [], false, 50),
        ("Gummistiefel", "Kleidung", ["Bootfahren"], [], [], false, 50),
        ("Neoprenschläppchen", "Kleidung", ["Bootfahren"], [], [], false, 50),
        ("Pantoffeln", "Kleidung", [], [], [], false, 50),
        ("Schuhe", "Kleidung", [], [], [], false, 50),
        ("Skischuhe", "Kleidung", ["Skifahren"], ["Winter"], [], false, 50),
        ("Turnschuhe", "Kleidung", ["Bootfahren"], [], [], false, 50),
        ("Wanderschuhe", "Kleidung", ["Wandern"], [], [], false, 50),
        ("Beheizte Handschuhe", "Kleidung", ["Skifahren"], ["Winter"], [], false, 60),
        ("Handschuhe", "Kleidung", [], [], [], false, 60),
        ("Kopfbedeckung", "Kleidung", ["Bootfahren"], [], [], false, 60),
        ("Mütze", "Kleidung", [], [], [], false, 60),
        ("Schlauchschal", "Kleidung", ["Skifahren"], ["Winter"], [], false, 60),
        ("Segelhandschuhe", "Kleidung", ["Bootfahren"], [], [], false, 60),
        ("Seidenhandschuhe", "Kleidung", ["Skifahren"], ["Winter"], [], false, 60),
        ("Skihandschuhe", "Kleidung", ["Skifahren"], ["Winter"], [], false, 60),
        ("Sonnenhut", "Kleidung", [], ["Sommer"], [], false, 60),
        ("Sporthandschuhe", "Kleidung", ["Wandern"], [], [], false, 60),
        ("Sturmhaube", "Kleidung", ["Skifahren"], ["Winter"], [], false, 60),
        ("Schlafanzug", "Kleidung", [], [], [], false, 70),
        ("Badeanzug/-hose", "Kleidung", ["Schwimmen"], [], [], false, 80),
        ("Bademantel", "Kleidung", ["Schwimmen"], [], [], false, 80),
        ("Badetücher", "Kleidung", ["Schwimmen"], [], [], true, 80),
        ("Neoprenanzug", "Kleidung", ["Bootfahren"], [], [], false, 80),
        ("Strandponcho", "Kleidung", ["Schwimmen"], [], [], false, 80),
        ("Sportkleidung", "Kleidung", [], [], [], false, 90),
        // Lebensmittel
        ("Kaffee", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 10),
        ("Kaffeefilter", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 10),
        ("Kaffeefilterhalter", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 10),
        ("Tee", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 10),

        ("Alufolie", "Lebensmittel", [], [], ["Ferienwohnung"], true, 20),
        ("Back-Kakao", "Lebensmittel", [], [], [], true, 20),
        ("Backpapier", "Lebensmittel", [], [], ["Ferienwohnung"], true, 20),
        ("Besteck", "Lebensmittel", [], [], ["Camping"], true, 20),
        ("Brotbox", "Lebensmittel", [], [], ["Ferienwohnung"], true, 20),
        ("Brotmesser", "Lebensmittel", [], [], ["Ferienwohnung"], true, 20),
        ("Dosenöffner", "Lebensmittel", [], [], ["Camping"], true, 20),
        ("Erythrit", "Lebensmittel", [], [], [], true, 20),
        ("Kochlöffel", "Lebensmittel", [], [], ["Camping"], true, 20),
        ("Pfannenwender", "Lebensmittel", [], [], ["Camping"], true, 20),
        ("Salatschüssel", "Lebensmittel", [], [], ["Camping"], true, 20),
        ("scharfes Messer", "Lebensmittel", [], [], ["Ferienwohnung"], true, 20),
        ("Schneidebrett", "Lebensmittel", [], [], ["Camping"], true, 20),
        ("Schürze", "Lebensmittel", [], [], ["Ferienwohnung"], true, 20),
        ("Soßenkelle", "Lebensmittel", [], [], ["Camping"], true, 20),
        ("Sparschäler", "Lebensmittel", [], [], ["Ferienwohnung"], true, 20),
        ("Spülschüssel", "Lebensmittel", [], [], ["Camping"], true, 20),
        ("Tassen und Gläser", "Lebensmittel", [], [], ["Camping"], true, 20),
        ("Teller und Schüsseln", "Lebensmittel", [], [], ["Camping"], true, 20),
        ("Thermoskanne", "Lebensmittel", [], [], ["Camping"], true, 20),
        ("Töpfe", "Lebensmittel", [], [], ["Camping"], true, 20),
        ("Topflappen", "Lebensmittel", [], [], ["Ferienwohnung"], true, 20),

        ("Aufschnitt", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Brot", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Butter", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Essig", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Gemüsebrühe", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Gewürze (Salz, Pfeffer)", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Käse", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Käsereibe", "Lebensmittel", [], [], ["Ferienwohnung"], true, 30),
        ("Knabberzeug", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Knoblauch", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Marmelade", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Mehl", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Möhren", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Müsli", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Müsliriegel", "Lebensmittel", [], [], [], true, 30),
        ("Nudeln", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Nutella", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Parmesan", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Passierte Tomaten", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Pestos", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Risottoreis", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Rote Linsen", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Öl", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Senf", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Zucker", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),
        ("Zwiebeln", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 30),

        ("Bier", "Lebensmittel", [], [], ["Ferienwohnung", "Camping"], true, 40),
        ("Limo Zero", "Lebensmittel", [], [], [], true, 40),
        ("Wasser", "Lebensmittel", [], [], [], true, 40),

        ("Inhalt Kühlschrank", "Lebensmittel", [], [], [], true, 50),
        ("Reiseproviant", "Lebensmittel", [], [], [], true, 50),
        ("Süßes/Nervennahrung", "Lebensmittel", [], [], [], true, 50),
        // Sonstiges
        ("Schlafsack", "Sonstiges", [], [], ["Camping"], false, 10),
        ("Kleines Handtuch", "Sonstiges", [], [], ["Ferienwohnung"], true, 20),
        ("Picknickdecke", "Sonstiges", [], [], ["Ferienwohnung", "Camping"], true, 20),
        ("Wäschebeutel", "Sonstiges", [], [], ["Ferienwohnung"], true, 20),
        ("Abwasserschlauch", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Flaschenadapter", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Fußmatte", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Gasflaschen", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Gefrierbeutel", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Gefrierbeutelclips", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Grill", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Insektenkerzen", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Klappstühle", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Klapptisch", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Kleiderbügel", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Luftmatratzen", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Luftpumpe", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Mülleimer", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Müllsäcke", "Sonstiges", [], [], ["Ferienwohnung"], true, 30),
        ("Ski", "Sonstiges", ["Skifahren"], ["Winter"], [], true, 30),
        ("Skistöcke", "Sonstiges", ["Skifahren"], ["Winter"], [], true, 30),
        ("Sonnensegel", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Wäscheklammern", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Wäscheleine", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Wasserschlauch/Kanister", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Zelt", "Sonstiges", [], [], ["Camping"], true, 30),
        ("Cap-Catcher", "Sonstiges", ["Bootfahren"], [], [], false, 40),
        ("Kniebandagen", "Sonstiges", ["Wandern"], [], [], true, 40),
        ("Paddel", "Sonstiges", ["Bootfahren"], [], [], true, 40),
        ("Rettungswesten", "Sonstiges", ["Bootfahren"], [], [], true, 40),
        ("Schlüsselanhänger Schwimmer", "Sonstiges", ["Bootfahren"], [], [], true, 40),
        ("Schwimmtiere", "Sonstiges", ["Schwimmen"], [], ["Ferienwohnung", "Camping"], true, 40),
        ("Schwimmweste", "Sonstiges", ["Bootfahren"], [], [], false, 40),
        ("SUP", "Sonstiges", ["Bootfahren"], [], [], true, 40),
        ("SUP Finne", "Sonstiges", ["Bootfahren"], [], [], true, 40),
        ("SUP Leash", "Sonstiges", ["Bootfahren"], [], [], true, 40),
        ("Taucherbrille", "Sonstiges", ["Schwimmen"], [], [], false, 40),
        ("Abspannleine", "Sonstiges", [], [], ["Camping"], true, 50),
        ("Aufnehmer", "Sonstiges", [], [], ["Ferienwohnung"], true, 50),
        ("Besen", "Sonstiges", [], [], ["Camping"], true, 50),
        ("Draht und Zange", "Sonstiges", [], [], ["Camping"], true, 50),
        ("Fäustel", "Sonstiges", [], [], ["Camping"], true, 50),
        ("Grillanzünder", "Sonstiges", [], [], ["Ferienwohnung"], true, 50),
        ("Handfeger", "Sonstiges", [], [], ["Camping"], true, 50),
        ("Heringe", "Sonstiges", [], [], ["Camping"], true, 50),
        ("Imbusschlüssel 2,5mm", "Sonstiges", ["Bootfahren"], [], [], true, 50),
        ("Kabelbinder", "Sonstiges", [], [], ["Camping"], true, 50),
        ("Klebeband", "Sonstiges", [], [], ["Camping"], true, 50),
        ("Kompass", "Sonstiges", ["Wandern"], [], [], true, 50),
        ("Nähzeug", "Sonstiges", [], [], ["Ferienwohnung"], true, 50),
        ("Schere", "Sonstiges", [], [], ["Camping"], true, 50),
        ("Schraubendreher", "Sonstiges", ["Bootfahren"], [], [], true, 50),
        ("Stabfeuerzeug", "Sonstiges", [], [], ["Ferienwohnung", "Camping"], true, 50),
        ("Taschenmesser", "Sonstiges", [], [], ["Ferienwohnung"], true, 50),
        ("Zeitungspapier", "Sonstiges", [], [], ["Ferienwohnung"], true, 50),
        ("Poporutsche", "Sonstiges", ["Skifahren"], ["Winter"], [], true, 60),
        ("Protektoren", "Sonstiges", ["Skifahren"], ["Winter"], [], false, 60),
        ("Skibrillen", "Sonstiges", ["Skifahren"], ["Winter"], [], false, 60),
        ("Skihelme", "Sonstiges", ["Skifahren"], ["Winter"], [], false, 60),
        ("Skischlösser", "Sonstiges", ["Skifahren"], ["Winter"], [], false, 60),
        ("Wanderstöcke", "Sonstiges", ["Wandern"], [], [], true, 60),
        ("Fahrrad", "Sonstiges", ["Fahrradfahren"], [], [], false, 70),
        ("Fahrradhelm", "Sonstiges", ["Fahrradfahren"], [], [], false, 70),
        ("Bauchtasche", "Sonstiges", ["Skifahren"], ["Winter"], [], true, 80),
        ("Jutetaschen/Rucksack", "Sonstiges", [], [], ["Ferienwohnung"], true, 80),
        ("Kleiner Rucksack", "Sonstiges", ["Skifahren"], ["Winter"], [], false, 80),
        ("Rucksack", "Sonstiges", [], [], ["Camping"], true, 80),
        ("Bücher", "Sonstiges", [], [], [], false, 90),
        ("Campingführer", "Sonstiges", [], [], ["Camping"], true, 90),
        ("Drachen", "Sonstiges", [], ["Herbst"], [], true, 90),
        ("Kartenspiele", "Sonstiges", [], [], [], true, 90),
        ("Kuscheltiere", "Sonstiges", [], [], [], true, 90),
        ("Musik", "Sonstiges", [], [], [], false, 90),
        ("Papier und Stifte", "Sonstiges", [], [], ["Ferienwohnung"], true, 90),
        ("Schulsachen", "Sonstiges", [], [], ["Ferienwohnung"], true, 90),
        ("Ohropax", "Sonstiges", [], [], ["Ferienwohnung"], true, 100),
        ("Sonnenbrille", "Sonstiges", [], [], [], false, 100),
        ("Trinkblasen", "Sonstiges", ["Wandern"], [], [], true, 100),
        ("Trinkflasche", "Sonstiges", [], [], [], false, 100),
        // Technik
        ("Batterien", "Technik", [], [], ["Ferienwohnung", "Camping"], true, 10),
        ("Ladegeräte", "Technik", [], [], [], true, 10),
        ("Langes Kabel", "Technik", [], [], ["Camping"], true, 10),
        ("Mehrfachstecker", "Technik", [], [], ["Ferienwohnung", "Camping"], true, 10),
        ("Powerbanks", "Technik", [], [], [], true, 10),
        ("Strom Adapter", "Technik", [], [], ["Camping"], true, 10),
        ("Campinglampe", "Technik", [], [], ["Camping"], true, 20),
        ("Föhn", "Technik", [], [], ["Ferienwohnung"], true, 20),
        ("Maglite/Stirnlampe", "Technik", [], [], ["Ferienwohnung", "Camping"], true, 20),
        ("iPad", "Technik", [], [], [], false, 30),
        ("Kopfhörer", "Technik", [], [], [], false, 30),
        ("Wasserdichte Handyhülle", "Technik", ["Bootfahren"], [], [], true, 40),
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

