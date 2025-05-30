//
//  MainTabView.swift
//  PregnancyBattle
//
//  Created on 2023/5/12.
//

import SwiftUI
import Foundation

// 导入健康管理视图
import Charts

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabView {
            // 孕期追踪
            PregnancyTrackerTabView()
            .tabItem {
                Label("追踪", systemImage: "calendar")
            }

            // 健康管理
            NavigationView {
                HealthManagementView()
            }
            .tabItem {
                Label("健康", systemImage: "heart.fill")
            }

            // 日记
            DiaryView()
            .tabItem {
                Label("日记", systemImage: "book.closed")
            }

            // 孕期指南
            NavigationView {
                Text("孕期指南")
                    .navigationTitle("孕期指南")
            }
            .tabItem {
                Label("指南", systemImage: "book.fill")
            }

            // 工具
            NavigationView {
                Text("实用工具")
                    .navigationTitle("实用工具")
            }
            .tabItem {
                Label("工具", systemImage: "hammer.fill")
            }

            // 我的
            NavigationView {
                ProfileView()
                    .navigationTitle("我的")
            }
            .tabItem {
                Label("我的", systemImage: "person.fill")
            }
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
