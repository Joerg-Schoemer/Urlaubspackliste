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
    
    @Published var angenommeneMetadata: CKShare.Metadata?
    @Published var fehler: String?
    
    private init() {}
    
    func annehmen(metadata: CKShare.Metadata) async {
        let container = CKContainer(identifier: metadata.containerIdentifier)
        
        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                let operation = CKAcceptSharesOperation(shareMetadatas: [metadata])
                operation.perShareResultBlock = { _, result in
                    if case .failure(let error) = result {
                        continuation.resume(throwing: error)
                    }
                }
                operation.acceptSharesResultBlock = { result in
                    switch result {
                    case .success: continuation.resume()
                    case .failure(let error): continuation.resume(throwing: error)
                    }
                }
                container.add(operation)
            }
            
            angenommeneMetadata = metadata
        } catch {
            fehler = error.localizedDescription
        }
    }
}
