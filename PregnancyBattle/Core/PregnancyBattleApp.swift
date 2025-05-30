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
            Group {
                if authManager.isAuthenticated {
                    MainTabView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                } else {
                    AuthView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
            }
            .onAppear {
                // 在应用启动时测试网络连接
                testNetworkConnection()
            }
        }
    }
    
    private func testNetworkConnection() {
        Task {
            do {
                let url = URL(string: "http://127.0.0.1:5094/")!
                let (_, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse {
                    print("[PregnancyBattleApp] 网络连接测试成功: \(httpResponse.statusCode)")
                }
            } catch {
                print("[PregnancyBattleApp] 网络连接测试失败: \(error)")
                print("[PregnancyBattleApp] 错误详情: \(error.localizedDescription)")
            }
        }
    }
}
