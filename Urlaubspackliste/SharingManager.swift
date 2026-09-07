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
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            operation.isAtomic = true
            operation.savePolicy = .allKeys
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success: continuation.resume()
                case .failure(let error): continuation.resume(throwing: error)
                }
            }
            container.privateCloudDatabase.add(operation)
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
            record["gepacktVonIDs"] = (item.gepacktVon ?? []).map { $0.id.uuidString } as CKRecordValue
            record.parent = parentRef
            records.append(record)
        }
        
        for person in liste.personen ?? [] {
            let recordID = CKRecord.ID(recordName: "Person-\(person.id.uuidString)", zoneID: zoneID)
            let record = CKRecord(recordType: "PersonRecord", recordID: recordID)
            record["name"] = person.name as CKRecordValue
            record["istKind"] = person.istKind as CKRecordValue
            record.parent = parentRef
            records.append(record)
        }
        
        guard !records.isEmpty else { return }
        try await recordsSpeichern(records)
    }
}

