//
//  SharingManager.swift
//  Urlaubspackliste
//
//  Created by Jörg Schömer on 06.09.26.
//


import Foundation
import CloudKit
import SwiftData

@MainActor
final class SharingManager {
    static let shared = SharingManager()
    private let container = CKContainer(identifier: "iCloud.Packliste")
    
    private init() {}
    
    /// Erstellt (oder holt) einen CKShare für die übergebene Packliste.
    ///
    /// Nur der Besitzer kann teilen: die Zone liegt in seiner privaten Datenbank. Ein
    /// Mitreisender würde hier eine Zone im eigenen Namen ansprechen, die es nicht gibt.
    func fetchOrCreateShare(for liste: PackingList) async throws -> (share: CKShare, container: CKContainer) {
        guard liste.istBesitzer else {
            throw SharingFehler.nurBesitzerKannTeilen
        }

        let zoneID = CKRecordZone.ID(zoneName: liste.zoneName, ownerName: CKCurrentUserDefaultName)
        
        try await zoneSicherstellen(zoneID: zoneID)
        
        // Falls schon geteilt: bestehenden Share zurückgeben
        if let vorhandenerName = liste.shareRecordName {
            let shareID = CKRecord.ID(recordName: vorhandenerName, zoneID: zoneID)
            if let bestehenderShare = try? await container.privateCloudDatabase.record(for: shareID) as? CKShare {
                return (bestehenderShare, container)
            }
        }
        
        // Neuen Root-Record + Share erstellen
        let recordID = CKRecord.ID(recordName: "List-\(liste.id.uuidString)", zoneID: zoneID)
        let listRecord = CKRecord(recordType: "PackingListRecord", recordID: recordID)
        listRecord["titel"] = liste.titel as CKRecordValue
        listRecord["aktivitaet"] = liste.aktivitaet as CKRecordValue
        listRecord["unterkunftsart"] = liste.unterkunftsart as CKRecordValue
        listRecord["jahreszeit"] = liste.jahreszeit as CKRecordValue
        
        let share = CKShare(rootRecord: listRecord)
        share[CKShare.SystemFieldKey.title] = liste.titel as CKRecordValue
        share.publicPermission = .none
        
        try await recordsSpeichern([listRecord, share])
        
        liste.istGeteilt = true
        liste.shareRecordName = share.recordID.recordName
        liste.ownerName = zoneID.ownerName
        
        try await pushAllItems(for: liste)
        
        return (share, container)
    }
    
    private func zoneSicherstellen(zoneID: CKRecordZone.ID) async throws {
        let zone = CKRecordZone(zoneID: zoneID)
        do {
            _ = try await container.privateCloudDatabase.save(zone)
            print("Zone erfolgreich erstellt oder bereits vorhanden: \(zoneID)")
        } catch {
            print("Fehler beim Erstellen der Zone: \(error)")
        }
    }
    
    private func recordsSpeichern(_ records: [CKRecord]) async throws {
        var einzelFehler: Error?
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            operation.isAtomic = true
            operation.savePolicy = .allKeys
            
            operation.perRecordSaveBlock = { recordID, result in
                if case .failure(let error) = result {
                    print("❌ Fehler bei \(recordID.recordName): \(error)")
                    einzelFehler = error
                }
            }
            
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            container.privateCloudDatabase.add(operation)
        }
        
        if let einzelFehler {
            throw einzelFehler
        }
    }
}

extension SharingManager {

    /// Lädt alle Items und Personen einer Liste als verknüpfte Kind-Records hoch.
    func pushAllItems(for liste: PackingList) async throws {
        let zoneID = CKRecordZone.ID(zoneName: liste.zoneName, ownerName: CKCurrentUserDefaultName)
        let listRecordID = CKRecord.ID(recordName: "List-\(liste.id.uuidString)", zoneID: zoneID)
        let parentRef = CKRecord.Reference(recordID: listRecordID, action: .none)
        
        var records: [CKRecord] = []
        
        for item in liste.items ?? [] {
            let recordID = CKRecord.ID(recordName: "Item-\(item.id.uuidString)", zoneID: zoneID)
            let record = CKRecord(recordType: "PackingItemRecord", recordID: recordID)
            record["name"] = item.name as CKRecordValue
            record["kategorie"] = item.kategorie as CKRecordValue
            record["istGruppenartikel"] = item.istGruppenartikel as CKRecordValue
            record["gruppeAbgehakt"] = item.gruppeAbgehakt as CKRecordValue
            record["listRef"] = parentRef as CKRecordValue

            let gepacktVonIDs = (item.gepacktVon ?? []).map { $0.id.uuidString }
            if !gepacktVonIDs.isEmpty {
                record["gepacktVonIDs"] = gepacktVonIDs as CKRecordValue
            }
            record.parent = parentRef
            records.append(record)
        }
        
        for person in liste.personen ?? [] {
            let recordID = CKRecord.ID(recordName: "Person-\(person.id.uuidString)", zoneID: zoneID)
            let record = CKRecord(recordType: "PersonRecord", recordID: recordID)
            record["name"] = person.name as CKRecordValue
            record["teilnehmerID"] = person.teilnehmerID as CKRecordValue
            record["teilnehmerUserRecordName"] = person.teilnehmerUserRecordName as CKRecordValue
            record["teilnehmerKennung"] = person.teilnehmerKennung as CKRecordValue
            record["listRef"] = parentRef as CKRecordValue
            record.parent = parentRef
            records.append(record)
        }
        
        print("Anzahl Items in der Liste: \((liste.items ?? []).count)")
        print("Anzahl Personen in der Liste: \((liste.personen ?? []).count)")
        print("Zu speichernde Records: \(records.count)")
        
        guard !records.isEmpty else {
            print("Keine Records zum Hochladen vorhanden - Abbruch.")
            return
        }

        do {
            try await recordsSpeichern(records)
            print("Items und Personen erfolgreich hochgeladen.")
        } catch {
            print("Fehler beim Hochladen von Items/Personen: \(error)")
            throw error
        }
    }
}

extension SharingManager {

    func pruefeHochgeladeneRecords(for liste: PackingList) async {
        let zoneID = CKRecordZone.ID(zoneName: liste.zoneName, ownerName: CKCurrentUserDefaultName)
        
        guard let erstesItem = (liste.items ?? []).first else {
            print("Keine lokalen Items zum Prüfen vorhanden.")
            return
        }
        let recordID = CKRecord.ID(recordName: "Item-\(erstesItem.id.uuidString)", zoneID: zoneID)
        
        do {
            let record = try await container.privateCloudDatabase.record(for: recordID)
            print("Record gefunden: \(record.recordType), Felder: \(record.allKeys())")
        } catch {
            print("Record NICHT gefunden: \(error)")
        }
    }
}

extension SharingManager {

    func zoneLoeschen(zoneName: String, ownerName: String?, istBesitzer: Bool) async {
        guard !zoneName.isEmpty else { return }

        // Als Mitglied liegt die Zone beim Besitzer - ohne dessen Namen lässt sich in der
        // shared DB nichts ansprechen. Dann bleibt nur, die Zone stehen zu lassen.
        if !istBesitzer, ownerName?.isEmpty ?? true {
            print("Zone \(zoneName) nicht löschbar: ownerName fehlt")
            return
        }

        let zoneID = CKRecordZone.ID(zoneName: zoneName, ownerName: ownerName ?? CKCurrentUserDefaultName)
        let datenbank = istBesitzer ? container.privateCloudDatabase : container.sharedCloudDatabase

        do {
            _ = try await datenbank.deleteRecordZone(withID: zoneID)
            print("Zone erfolgreich gelöscht: \(zoneID)")
        } catch {
            print("Fehler beim Löschen der Zone (evtl. bereits gelöscht): \(error)")
        }
    }

    /// Hebt das Teilen einer eigenen Liste auf: löscht die CloudKit-Zone (inkl. Share) vollständig,
    /// die lokale Liste bleibt erhalten und ist danach wieder bearbeitbar.
    func teilenAufheben(for liste: PackingList) async {
        await zoneLoeschen(zoneName: liste.zoneName, ownerName: liste.ownerName, istBesitzer: true)
        liste.istGeteilt = false
        liste.shareRecordName = nil
        liste.ownerName = nil
    }

    /// Sucht unter den übergebenen Listen die heraus, deren Freigabe der Besitzer beendet hat.
    ///
    /// Beim Aufheben löscht der Besitzer die ganze Zone; damit verschwindet sie aus unserer
    /// shared DB. allRecordZones liefert genau die Zonen, die andere mit uns teilen - fehlt
    /// unsere darin, ist die Freigabe weg (Teilen beendet oder wir wurden entfernt).
    ///
    /// Bewusst nicht über Fehlercodes einzelner Abfragen: hier wird ein Netzausfall zu einem
    /// leeren Ergebnis, sodass eine Störung niemals lokale Daten vernichtet.
    func beendeteFreigaben(unter listen: [PackingList]) async -> [PackingList] {
        let kandidaten = listen.filter { $0.istGeteilt && !$0.istBesitzer }
        guard !kandidaten.isEmpty else { return [] }

        let zonen: [CKRecordZone]
        do {
            zonen = try await container.sharedCloudDatabase.allRecordZones()
        } catch {
            print("Zonen-Prüfung fehlgeschlagen, Listen bleiben erhalten: \(error)")
            return []
        }

        let geteilteZonen = Set(zonen.map { $0.zoneID })
        return kandidaten.filter { liste in
            guard let zoneID = try? zoneID(fuer: liste) else { return false }
            guard !geteilteZonen.contains(zoneID) else { return false }
            print("Zone \(zoneID.zoneName) nicht mehr geteilt - Besitzer hat das Teilen beendet")
            return true
        }
    }

    /// Prüft aus Sicht eines Mitreisenden, ob der Besitzer das Teilen dieser Liste beendet hat.
    func teilenVomBesitzerBeendet(fuer liste: PackingList) async -> Bool {
        !(await beendeteFreigaben(unter: [liste])).isEmpty
    }
}

extension SharingManager {
    
    /// Baut aus einer angenommenen Einladung eine lokale PackingList auf.
    func geteilteListeUebernehmen(metadata: CKShare.Metadata, context: ModelContext) async throws {
        let sharedContainer = CKContainer(identifier: metadata.containerIdentifier)
        let datenbank = sharedContainer.sharedCloudDatabase
        
        guard let rootID = metadata.hierarchicalRootRecordID else {
            print("Kein hierarchicalRootRecordID vorhanden - kann Liste nicht laden")
            return
        }
        
        let listRecord = try await datenbank.record(for: rootID)
        
        let itemQuery = CKQuery(
            recordType: "PackingItemRecord",
            predicate: NSPredicate(format: "listRef == %@", CKRecord.Reference(recordID: rootID, action: .none))
        )
        let (itemErgebnisse, _) = try await datenbank.records(matching: itemQuery, inZoneWith: rootID.zoneID)
        
        let personQuery = CKQuery(
            recordType: "PersonRecord",
            predicate: NSPredicate(format: "listRef == %@", CKRecord.Reference(recordID: rootID, action: .none))
        )
        let (personErgebnisse, _) = try await datenbank.records(matching: personQuery, inZoneWith: rootID.zoneID)
        
        let listenUUID = UUID(uuidString: String(rootID.recordName.dropFirst("List-".count))) ?? UUID()
        
        let neueListe = PackingList(
            titel: listRecord["titel"] as? String ?? "Geteilte Liste",
            aktivitaet: listRecord["aktivitaet"] as? String ?? "",
            unterkunftsart: listRecord["unterkunftsart"] as? String ?? "",
            jahreszeit: listRecord["jahreszeit"] as? String ?? ""
        )
        neueListe.id = listenUUID
        neueListe.istGeteilt = true
        neueListe.istBesitzer = false
        neueListe.zoneName = rootID.zoneID.zoneName
        neueListe.ownerName = rootID.zoneID.ownerName
        neueListe.shareRecordName = metadata.share.recordID.recordName
        
        print("Neue Liste übernommen - istBesitzer: \(neueListe.istBesitzer)")
        
        var personenNachID: [UUID: Person] = [:]
        var personen: [Person] = []
        
        for (_, ergebnis) in personErgebnisse {
            guard let record = try? ergebnis.get() else { continue }
            let uuid = UUID(uuidString: String(record.recordID.recordName.dropFirst("Person-".count))) ?? UUID()
            let person = Person(
                name: record["name"] as? String ?? ""
            )
            person.id = uuid
            person.teilnehmerID = record["teilnehmerID"] as? String ?? ""
            person.teilnehmerUserRecordName = record["teilnehmerUserRecordName"] as? String ?? ""
            person.teilnehmerKennung = record["teilnehmerKennung"] as? String ?? ""
            personenNachID[uuid] = person
            personen.append(person)
        }
        neueListe.personen = personen
        
        var items: [PackingItem] = []
        for (_, ergebnis) in itemErgebnisse {
            guard let record = try? ergebnis.get() else { continue }
            let uuid = UUID(uuidString: String(record.recordID.recordName.dropFirst("Item-".count))) ?? UUID()
            
            let item = PackingItem(
                name: record["name"] as? String ?? "",
                kategorie: record["kategorie"] as? String ?? "",
                istGruppenartikel: record["istGruppenartikel"] as? Bool ?? false
            )
            item.id = uuid   // <- die fehlende Zeile
            item.gruppeAbgehakt = record["gruppeAbgehakt"] as? Bool ?? false
            
            let gepacktVonIDs = (record["gepacktVonIDs"] as? [String] ?? []).compactMap { UUID(uuidString: $0) }
            item.gepacktVon = gepacktVonIDs.compactMap { personenNachID[$0] }
            
            items.append(item)
        }
        neueListe.items = items
        
        context.insert(neueListe)
        try context.save()
    }
}

enum SharingFehler: LocalizedError {
    case ownerNameFehlt(titel: String)
    case nurBesitzerKannTeilen

    var errorDescription: String? {
        switch self {
        case .ownerNameFehlt(let titel):
            return "Für die geteilte Liste \"\(titel)\" fehlt der Zonen-Besitzer. "
                + "Die Liste muss über den Einladungslink neu geöffnet werden."
        case .nurBesitzerKannTeilen:
            return "Diese Liste kann nur von der Person geteilt werden, die sie erstellt hat."
        }
    }
}

extension SharingManager {
    func datenbank(fuer liste: PackingList) -> CKDatabase {
        liste.istBesitzer ? container.privateCloudDatabase : container.sharedCloudDatabase
    }

    /// Baut die Zone-ID einer Liste auf.
    ///
    /// Für Mitglieder liegt die Zone beim Besitzer, nicht bei uns. Fehlt der ownerName,
    /// darf hier kein Ersatz eingesetzt werden: CKCurrentUserDefaultName zeigt dann auf
    /// eine Zone im eigenen Namen, die es in der shared DB nicht gibt - CloudKit quittiert
    /// das mit "Only shared zones can be accessed in the shared DB".
    func zoneID(fuer liste: PackingList) throws -> CKRecordZone.ID {
        if liste.istBesitzer {
            return CKRecordZone.ID(zoneName: liste.zoneName, ownerName: CKCurrentUserDefaultName)
        }
        guard let ownerName = liste.ownerName, !ownerName.isEmpty else {
            throw SharingFehler.ownerNameFehlt(titel: liste.titel)
        }
        return CKRecordZone.ID(zoneName: liste.zoneName, ownerName: ownerName)
    }
}

extension SharingManager {
    func itemAktualisieren(_ item: PackingItem, in liste: PackingList) async throws {
        guard liste.istGeteilt else { return }
        let zoneID = try zoneID(fuer: liste)
        let recordID = CKRecord.ID(recordName: "Item-\(item.id.uuidString)", zoneID: zoneID)
        let datenbank = datenbank(fuer: liste)
        
        let record = try await datenbank.record(for: recordID)
        record["gruppeAbgehakt"] = item.gruppeAbgehakt as CKRecordValue
        
        let gepacktVonIDs = (item.gepacktVon ?? []).map { $0.id.uuidString }
        if gepacktVonIDs.isEmpty {
            record["gepacktVonIDs"] = nil
        } else {
            record["gepacktVonIDs"] = gepacktVonIDs as CKRecordValue
        }
        
        _ = try await datenbank.save(record)
    }
}

extension SharingManager {
    func listeAktualisieren(_ liste: PackingList) async throws {
        guard liste.istGeteilt else { return }
        print("istBesitzer: \(liste.istBesitzer), ownerName: \(liste.ownerName ?? "nil"), zoneName: \(liste.zoneName)")
        
        let zoneID = try zoneID(fuer: liste)
        let datenbank = datenbank(fuer: liste)
        let listRecordID = CKRecord.ID(recordName: "List-\(liste.id.uuidString)", zoneID: zoneID)
        let parentRef = CKRecord.Reference(recordID: listRecordID, action: .none)
        
        let itemQuery = CKQuery(recordType: "PackingItemRecord", predicate: NSPredicate(format: "listRef == %@", parentRef))
        let (itemErgebnisse, _) = try await datenbank.records(matching: itemQuery, inZoneWith: zoneID)
        
        var itemsNachID: [UUID: PackingItem] = [:]
        for item in liste.items ?? [] {
            itemsNachID[item.id] = item
        }
        var personenNachID: [UUID: Person] = [:]
        for person in liste.personen ?? [] {
            personenNachID[person.id] = person
        }
        
        for (recordID, ergebnis) in itemErgebnisse {
            guard let record = try? ergebnis.get() else { continue }
            guard let uuid = UUID(uuidString: String(recordID.recordName.dropFirst("Item-".count))) else { continue }
            guard let lokalesItem = itemsNachID[uuid] else { continue }
            
            lokalesItem.gruppeAbgehakt = record["gruppeAbgehakt"] as? Bool ?? false
            let gepacktVonIDs = (record["gepacktVonIDs"] as? [String] ?? []).compactMap { UUID(uuidString: $0) }
            lokalesItem.gepacktVon = gepacktVonIDs.compactMap { personenNachID[$0] }
        }

        print("Gefundene Item-Records: \(itemErgebnisse.count)")
    }
}

// MARK: - Zuordnung Apple-ID zu Mitreisenden

/// Ein Teilnehmer des Shares, aufbereitet für die Zuordnung zu einer Person.
struct ShareTeilnehmer: Identifiable, Hashable {
    let id: String                 // participantID - für alle Beteiligten identisch
    let userRecordName: String     // CloudKit-Benutzerkennung, "" solange noch unbekannt
    let kennung: String            // E-Mail oder Telefonnummer der Apple-ID, "" wenn unbekannt
    let anzeigeName: String
    let istBesitzer: Bool
    let istAkzeptiert: Bool
}

extension SharingManager {

    /// Vereinheitlicht Kennungen (E-Mail/Telefon) für den Vergleich.
    fileprivate static func normalisiert(_ wert: String) -> String {
        wert.trimmingCharacters(in: .whitespaces).lowercased()
    }

    /// Lädt den CKShare der Liste aus der passenden Datenbank.
    func share(fuer liste: PackingList) async throws -> CKShare? {
        guard liste.istGeteilt, let shareRecordName = liste.shareRecordName else { return nil }

        let zoneID = try zoneID(fuer: liste)
        let shareID = CKRecord.ID(recordName: shareRecordName, zoneID: zoneID)

        return try await datenbank(fuer: liste).record(for: shareID) as? CKShare
    }

    /// Wandelt einen CKShare-Teilnehmer in die Anzeigeform um.
    ///
    /// Als id dient die participantID: sie steht im Share-Record und ist daher für
    /// Besitzer und Eingeladenen dieselbe. userRecordID und lookupInfo sind das nicht -
    /// die userRecordID unterscheidet sich je nach Blickwinkel, und für die eigene
    /// Apple-ID liefert CloudKit weder Namen noch lookupInfo.
    fileprivate func aufbereiten(_ teilnehmer: CKShare.Participant) -> ShareTeilnehmer? {
        let teilnehmerID = teilnehmer.participantID
        guard !teilnehmerID.isEmpty else { return nil }

        let userRecordName = teilnehmer.userIdentity.userRecordID?.recordName ?? ""
        let kennung = teilnehmer.userIdentity.lookupInfo?.emailAddress
            ?? teilnehmer.userIdentity.lookupInfo?.phoneNumber
            ?? ""

        let name = teilnehmer.userIdentity.nameComponents.map {
            PersonNameComponentsFormatter.localizedString(from: $0, style: .default)
        } ?? ""

        let istBesitzer = teilnehmer.role == .owner
        let ersatzName = istBesitzer ? "Du (Ersteller)" : "Unbekannte Apple-ID"

        return ShareTeilnehmer(
            id: teilnehmerID,
            userRecordName: userRecordName,
            kennung: kennung,
            anzeigeName: name.isEmpty ? (kennung.isEmpty ? ersatzName : kennung) : name,
            istBesitzer: istBesitzer,
            istAkzeptiert: teilnehmer.acceptanceStatus == .accepted
        )
    }

    /// Liest die aktuellen Teilnehmer eines Shares (inkl. noch ausstehender Einladungen).
    /// Der Besitzer steht immer zuerst, danach wird nach Anzeigename sortiert.
    func teilnehmer(fuer liste: PackingList) async throws -> [ShareTeilnehmer] {
        guard let share = try await share(fuer: liste) else { return [] }

        // isEqual auf CKShare.Participant prüft Personen-Identität (participantID,
        // userRecordID oder lookupInfo) - damit fällt derselbe Mensch nicht in zwei Zeilen.
        var rohe: [CKShare.Participant] = []
        for teilnehmer in share.participants where !rohe.contains(teilnehmer) {
            rohe.append(teilnehmer)
        }

        let eintraege = rohe.compactMap { aufbereiten($0) }

        return eintraege.sorted { links, rechts in
            links.istBesitzer == rechts.istBesitzer
                ? links.anzeigeName.localizedCaseInsensitiveCompare(rechts.anzeigeName) == .orderedAscending
                : links.istBesitzer
        }
    }

    /// Der Teilnehmer-Eintrag der aktuell angemeldeten Apple-ID in diesem Share.
    func eigenerTeilnehmer(in liste: PackingList) async -> ShareTeilnehmer? {
        guard let share = try? await share(fuer: liste),
              let teilnehmer = share.currentUserParticipant else { return nil }
        return aufbereiten(teilnehmer)
    }

    /// Speichert die Zuordnung eines Share-Teilnehmers zu einer Person in CloudKit.
    func personZuordnungSpeichern(_ person: Person, in liste: PackingList) async throws {
        guard liste.istGeteilt else { return }

        let zoneID = try zoneID(fuer: liste)
        let recordID = CKRecord.ID(recordName: "Person-\(person.id.uuidString)", zoneID: zoneID)
        let datenbank = datenbank(fuer: liste)

        let record = try await datenbank.record(for: recordID)
        record["teilnehmerID"] = person.teilnehmerID as CKRecordValue
        record["teilnehmerUserRecordName"] = person.teilnehmerUserRecordName as CKRecordValue
        record["teilnehmerKennung"] = person.teilnehmerKennung as CKRecordValue

        _ = try await datenbank.save(record)
    }

    /// Aktualisiert die lokal gespeicherten Zuordnungen anhand der Records in CloudKit.
    ///
    /// Die Records werden gezielt über ihre RecordID geholt statt per CKQuery: Queries sind in
    /// CloudKit nur eventually consistent und lieferten direkt nach dem Speichern noch den alten
    /// Stand - die gerade gesetzte Zuordnung wurde dadurch lokal wieder geleert.
    func personZuordnungenAktualisieren(_ liste: PackingList) async throws {
        guard liste.istGeteilt else { return }

        let personen = liste.personen ?? []
        guard !personen.isEmpty else { return }

        let zoneID = try zoneID(fuer: liste)
        let datenbank = datenbank(fuer: liste)

        var personenNachRecordName: [String: Person] = [:]
        var recordIDs: [CKRecord.ID] = []
        for person in personen {
            let recordName = "Person-\(person.id.uuidString)"
            personenNachRecordName[recordName] = person
            recordIDs.append(CKRecord.ID(recordName: recordName, zoneID: zoneID))
        }

        let ergebnisse = try await datenbank.records(for: recordIDs)

        for (recordID, ergebnis) in ergebnisse {
            guard let record = try? ergebnis.get() else { continue }
            guard let lokalePerson = personenNachRecordName[recordID.recordName] else { continue }

            lokalePerson.teilnehmerID = record["teilnehmerID"] as? String ?? ""
            lokalePerson.teilnehmerUserRecordName = record["teilnehmerUserRecordName"] as? String ?? ""
            lokalePerson.teilnehmerKennung = record["teilnehmerKennung"] as? String ?? ""
        }
    }

    /// Ermittelt die eigene CloudKit-Benutzerkennung.
    func eigeneBenutzerkennung() async throws -> String {
        try await container.userRecordID().recordName
    }

    /// Sucht die Person, die der aktuell angemeldeten Apple-ID zugeordnet ist.
    ///
    /// Maßgeblich ist die participantID: nur sie sehen Besitzer und Eingeladener gleich.
    /// Die beiden anderen Kennungen dienen als Rückfalloption für Zuordnungen, die noch
    /// aus einer Version ohne participantID stammen.
    func eigenePerson(in liste: PackingList) async -> Person? {
        let personen = liste.personen ?? []
        guard !personen.isEmpty else { return nil }

        let eigenerTeilnehmer = await eigenerTeilnehmer(in: liste)

        // 1. Der verlässliche Weg: participantID aus dem Share-Record.
        if let eigeneID = eigenerTeilnehmer?.id, !eigeneID.isEmpty,
           let treffer = personen.first(where: { $0.teilnehmerID == eigeneID }) {
            return treffer
        }

        // 2. Altbestand: Zuordnung über die Benutzerkennung.
        var kandidaten: [String] = []
        if let kennung = eigenerTeilnehmer?.userRecordName, !kennung.isEmpty {
            kandidaten.append(kennung)
        }
        if let eigene = try? await eigeneBenutzerkennung(), !eigene.isEmpty {
            kandidaten.append(eigene)
        }
        for kandidat in kandidaten {
            if let treffer = personen.first(where: { $0.teilnehmerUserRecordName == kandidat }) {
                await participantIDNachtragen(treffer, eigenerTeilnehmer, in: liste)
                return treffer
            }
        }

        // 3. Altbestand: Zuordnung über E-Mail/Telefon der eigenen Apple-ID.
        if let eigeneKennung = eigenerTeilnehmer?.kennung, !eigeneKennung.isEmpty {
            let gesucht = Self.normalisiert(eigeneKennung)
            if let treffer = personen.first(where: { Self.normalisiert($0.teilnehmerKennung) == gesucht }) {
                await participantIDNachtragen(treffer, eigenerTeilnehmer, in: liste)
                return treffer
            }
        }

        print("⚠️ Keine eigene Person gefunden. Eigene participantID: \(eigenerTeilnehmer?.id ?? "-")")
        for person in personen {
            print("   \(person.name): teilnehmerID=\(person.teilnehmerID), kennung=\(person.teilnehmerKennung)")
        }
        return nil
    }

    /// Trägt die participantID an einer über den Altbestand gefundenen Person nach - und
    /// speichert sie, damit personZuordnungenAktualisieren sie beim nächsten Mal nicht
    /// wieder mit dem leeren Serverwert überschreibt.
    private func participantIDNachtragen(
        _ person: Person,
        _ teilnehmer: ShareTeilnehmer?,
        in liste: PackingList
    ) async {
        guard let teilnehmer, !teilnehmer.id.isEmpty, person.teilnehmerID != teilnehmer.id else { return }
        person.teilnehmerID = teilnehmer.id
        try? await personZuordnungSpeichern(person, in: liste)
    }
}

