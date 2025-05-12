//
//  ToolsView.swift
//  PregnancyBattle
//
//  Created on 2023/5/12.
//

import SwiftUI

struct ToolsView: View {
    let tools = [
        ToolItem(name: "胎动计数器", icon: "heart.fill", color: .pink),
        ToolItem(name: "宫缩计时器", icon: "timer", color: .orange),
        ToolItem(name: "体重记录", icon: "scalemass.fill", color: .blue),
        ToolItem(name: "待产包清单", icon: "checklist", color: .green),
        ToolItem(name: "产检提醒", icon: "calendar.badge.clock", color: .purple),
        ToolItem(name: "饮食指南", icon: "fork.knife", color: .teal)
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(tools) { tool in
                    ToolItemView(tool: tool)
                }
            }
            .padding()
        }
        .navigationTitle("实用工具")
    }
}

struct ToolItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}

struct ToolItemView: View {
    let tool: ToolItem
    
    var body: some View {
        VStack {
            Image(systemName: tool.icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(tool.color)
                .cornerRadius(15)
            
            Text(tool.name)
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .frame(height: 120)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    NavigationView {
        ToolsView()
    }
}
