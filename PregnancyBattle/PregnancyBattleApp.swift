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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
