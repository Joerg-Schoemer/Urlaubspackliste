//
//  ShareAnnahmeKoordinator.swift
//  Urlaubspackliste
//
//  Created by Jörg Schömer on 06.09.26.
//


import Foundation
import Combine
import CloudKit
import SwiftData

@MainActor
final class ShareAnnahmeKoordinator: ObservableObject {
    static let shared = ShareAnnahmeKoordinator()
    
    @Published var letzteMetadata: CKShare.Metadata?
    @Published var annahmeZaehler = 0
    @Published var fehler: String?
    
    private init() {}
    
    func annehmen(metadata: CKShare.Metadata) async {
        print("Annahme gestartet für Share: \(metadata.share.recordID)")
        let container = CKContainer(identifier: metadata.containerIdentifier)
        
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                let operation = CKAcceptSharesOperation(shareMetadatas: [metadata])
                operation.perShareResultBlock = { _, result in
                    if case .failure(let error) = result {
                        print("Fehler bei perShareResultBlock: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
                operation.acceptSharesResultBlock = { result in
                    switch result {
                    case .success:
                        print("CKAcceptSharesOperation erfolgreich")
                        continuation.resume()
                    case .failure(let error):
                        print("CKAcceptSharesOperation Fehler: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
                container.add(operation)
            }
            
            letzteMetadata = metadata
            annahmeZaehler += 1
            print("annahmeZaehler jetzt: \(annahmeZaehler)")
        } catch {
            fehler = error.localizedDescription
            print("Annahme fehlgeschlagen: \(error)")
        }
    }
}
