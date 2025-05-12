//
//  PregnancyGuideView.swift
//  PregnancyBattle
//
//  Created on 2023/5/12.
//

import SwiftUI

struct PregnancyGuideView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 今日提示
                VStack(alignment: .leading, spacing: 10) {
                    Text("今日提示")
                        .font(.headline)
                    
                    Text("第12周：宝宝的大脑正在快速发育")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("这个阶段，宝宝的大脑正在形成更多的神经元连接，这对未来的认知发展非常重要。")
                        .font(.body)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal)
                
                // 妈妈指南
                VStack(alignment: .leading, spacing: 10) {
                    Text("妈妈指南")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        HStack(alignment: .top) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading) {
                                Text("身体变化")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text("你的子宫现在已经长到足够大，可以从腹部感觉到。恶心感可能会减轻。")
                                    .font(.body)
                            }
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.green)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading) {
                                Text("营养建议")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text("确保摄入足够的钙质和铁质。每天至少喝一杯牛奶，多吃绿叶蔬菜。")
                                    .font(.body)
                            }
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading) {
                                Text("注意事项")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text("避免剧烈运动和提重物。如果感到腹痛或出血，请立即就医。")
                                    .font(.body)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal)
                
                // 宝宝发育
                VStack(alignment: .leading, spacing: 10) {
                    Text("宝宝发育")
                        .font(.headline)
                    
                    Text("本周宝宝大小")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("5.4 厘米，约一个柠檬大小")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("宝宝的指甲和牙齿开始形成，肾脏开始产生尿液。")
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
        .navigationTitle("孕期指南")
    }
}

#Preview {
    NavigationView {
        PregnancyGuideView()
    }
}
