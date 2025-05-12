//
//  HealthManagementView.swift
//  PregnancyBattle
//
//  Created on 2023/5/12.
//

import SwiftUI

struct HealthManagementView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 体重记录卡片
                VStack(alignment: .leading, spacing: 10) {
                    Text("体重记录")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("孕前体重")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("55 kg")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("当前体重")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("58 kg")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("增长")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("3 kg")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Button(action: {
                        // 添加体重记录
                    }) {
                        Text("记录今日体重")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal)
                
                // 血压记录卡片
                VStack(alignment: .leading, spacing: 10) {
                    Text("血压记录")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("最近记录")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("120/80 mmHg")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("日期")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("2023-05-10")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Button(action: {
                        // 添加血压记录
                    }) {
                        Text("记录今日血压")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal)
                
                // 健康建议卡片
                VStack(alignment: .leading, spacing: 10) {
                    Text("健康建议")
                        .font(.headline)
                    
                    Text("根据您的体重增长情况，建议适当增加蛋白质的摄入，并保持每天30分钟的轻度运动。")
                        .font(.body)
                    
                    Text("免责声明：以上建议仅供参考，具体情况请咨询医生。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("健康管理")
    }
}

#Preview {
    NavigationView {
        HealthManagementView()
    }
}
