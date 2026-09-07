//
//  UrlaubspacklisteApp.swift
//  Urlaubspackliste
//
//  Created by Jörg Schömer on 06.09.26.
//

import SwiftUI
import SwiftData

@main
struct UrlaubspacklisteApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PackingList.self,
            PackingItem.self,
            Person.self,
            ItemTemplate.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
