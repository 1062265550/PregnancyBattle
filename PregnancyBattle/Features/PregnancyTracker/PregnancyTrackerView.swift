//
//  PregnancyTrackerView.swift
//  PregnancyBattle
//
//  Created on 2023/5/12.
//

import SwiftUI

struct PregnancyTrackerView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 孕周信息卡片
                VStack(alignment: .leading, spacing: 10) {
                    Text("第 12 周")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("预产期: 2023年12月25日")
                        .font(.headline)
                    
                    Text("距离预产期还有 180 天")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text("宝宝现在大小如同一个柠檬")
                        .font(.body)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal)
                
                // 胎儿发育信息
                VStack(alignment: .leading, spacing: 10) {
                    Text("本周胎儿发育")
                        .font(.headline)
                    
                    Text("宝宝的指甲已经开始生长，皮肤变得更加透明，可以看到下面的血管。")
                        .font(.body)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal)
                
                // 妈妈变化信息
                VStack(alignment: .leading, spacing: 10) {
                    Text("妈妈的变化")
                        .font(.headline)
                    
                    Text("你可能会感到恶心的症状有所缓解，但可能会出现便秘和头痛。")
                        .font(.body)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("孕期追踪")
    }
}

#Preview {
    NavigationView {
        PregnancyTrackerView()
    }
}
