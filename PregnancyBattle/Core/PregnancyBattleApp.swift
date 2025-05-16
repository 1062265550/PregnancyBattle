//
//  PregnancyBattleApp.swift
//  PregnancyBattle
//
//  Created by 操汉钊 on 2025/5/12.
//

import SwiftUI

@main
struct PregnancyBattleApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var authManager = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                MainTabView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                AuthView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
