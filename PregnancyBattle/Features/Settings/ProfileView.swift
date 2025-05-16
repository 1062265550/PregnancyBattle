//
//  ProfileView.swift
//  PregnancyBattle
//
//  Created on 2023/5/12.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @State private var showingLogoutAlert = false
    var body: some View {
        List {
            // 用户信息
            Section {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(authManager.currentUser?.nickname ?? authManager.currentUser?.username ?? "用户")
                            .font(.headline)

                        Text("孕期第12周")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 8)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }

            // 个人资料
            Section(header: Text("个人资料")) {
                NavigationLink(destination: UserInfoSettingsView()) {
                    SettingRowView(icon: "person.fill", iconColor: .blue, title: "个人信息")
                }

                NavigationLink(destination: Text("孕期信息设置")) {
                    SettingRowView(icon: "calendar", iconColor: .pink, title: "孕期信息")
                }

                NavigationLink(destination: Text("健康数据")) {
                    SettingRowView(icon: "heart.fill", iconColor: .red, title: "健康数据")
                }
            }

            // 应用设置
            Section(header: Text("应用设置")) {
                NavigationLink(destination: Text("通知设置")) {
                    SettingRowView(icon: "bell.fill", iconColor: .orange, title: "通知设置")
                }

                NavigationLink(destination: Text("隐私设置")) {
                    SettingRowView(icon: "lock.fill", iconColor: .green, title: "隐私设置")
                }

                NavigationLink(destination: Text("数据备份")) {
                    SettingRowView(icon: "arrow.clockwise", iconColor: .purple, title: "数据备份")
                }
            }

            // 关于
            Section(header: Text("关于")) {
                NavigationLink(destination: Text("关于我们")) {
                    SettingRowView(icon: "info.circle.fill", iconColor: .blue, title: "关于我们")
                }

                NavigationLink(destination: Text("用户协议")) {
                    SettingRowView(icon: "doc.text.fill", iconColor: .gray, title: "用户协议")
                }

                NavigationLink(destination: Text("隐私政策")) {
                    SettingRowView(icon: "hand.raised.fill", iconColor: .gray, title: "隐私政策")
                }

                NavigationLink(destination: Text("帮助与反馈")) {
                    SettingRowView(icon: "questionmark.circle.fill", iconColor: .teal, title: "帮助与反馈")
                }
            }

            Section {
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    Text("退出登录")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("我的")
        .alert(isPresented: $showingLogoutAlert) {
            Alert(
                title: Text("退出登录"),
                message: Text("确定要退出登录吗？"),
                primaryButton: .destructive(Text("退出")) {
                    authManager.logout()
                },
                secondaryButton: .cancel(Text("取消"))
            )
        }
    }
}

struct SettingRowView: View {
    let icon: String
    let iconColor: Color
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)

            Text(title)
                .padding(.leading, 8)
        }
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}
