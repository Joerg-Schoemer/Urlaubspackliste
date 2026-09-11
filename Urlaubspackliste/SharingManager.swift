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
    func fetchOrCreateShare(for liste: PackingList) async throws -> (share: CKShare, container: CKContainer) {
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
            record["istKind"] = person.istKind as CKRecordValue
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
        let zoneID = CKRecordZone.ID(zoneName: zoneName, ownerName: ownerName ?? CKCurrentUserDefaultName)
        let datenbank = istBesitzer ? container.privateCloudDatabase : container.sharedCloudDatabase
        
        do {
            _ = try await datenbank.deleteRecordZone(withID: zoneID)
            print("Zone erfolgreich gelöscht: \(zoneID)")
        } catch {
            print("Fehler beim Löschen der Zone (evtl. bereits gelöscht): \(error)")
        }
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
                name: record["name"] as? String ?? "",
                istKind: record["istKind"] as? Bool ?? false
            )
            person.id = uuid
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

extension SharingManager {
    func datenbank(fuer liste: PackingList) -> CKDatabase {
        liste.istBesitzer ? container.privateCloudDatabase : container.sharedCloudDatabase
    }
}

extension SharingManager {
    func itemAktualisieren(_ item: PackingItem, in liste: PackingList) async throws {
        guard liste.istGeteilt else { return }
        let zoneID = CKRecordZone.ID(zoneName: liste.zoneName, ownerName: liste.ownerName ?? CKCurrentUserDefaultName)
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
        
        let zoneID = CKRecordZone.ID(zoneName: liste.zoneName, ownerName: liste.ownerName ?? CKCurrentUserDefaultName)
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

