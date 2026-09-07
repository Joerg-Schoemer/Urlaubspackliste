//
//  SceneDelegate.swift
//  Urlaubspackliste
//
//  Created by Jörg Schömer on 06.09.26.
//


import UIKit
import CloudKit

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith metadata: CKShare.Metadata) {
        Task {
            await ShareAnnahmeKoordinator.shared.annehmen(metadata: metadata)
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let metadata = connectionOptions.cloudKitShareMetadata {
            Task {
                await ShareAnnahmeKoordinator.shared.annehmen(metadata: metadata)
            }
        }
    }
}