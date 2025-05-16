import SwiftUI

struct UserInfoSettingsView: View {
    @StateObject private var viewModel = UserInfoSettingsViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("基本信息")) {
                HStack {
                    Text("用户名")
                    Spacer()
                    Text(viewModel.userProfile?.username ?? "加载中...")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("邮箱")
                    Spacer()
                    Text(viewModel.userProfile?.email ?? "加载中...")
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("手机号")
                    Spacer()
                    Text(viewModel.userProfile?.phoneNumber ?? "加载中...")
                        .foregroundColor(.gray)
                }
            }

            Section(header: Text("可修改信息")) {
                TextField("昵称", text: $viewModel.nickname)
                TextField("头像URL", text: $viewModel.avatarUrl)
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text("错误: \(error)")
                        .foregroundColor(.red)
                }
            }
            
            Section {
                Button(action: {
                    viewModel.updateUserProfile()
                }) {
                    Text(viewModel.isLoading ? "保存中..." : "保存更改")
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle("个人信息设置")
        .onAppear {
            viewModel.fetchUserProfile()
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(title: Text(alertItem.title),
                  message: Text(alertItem.message),
                  dismissButton: .default(Text(alertItem.buttonText)) {
                if alertItem.id == "update_success" {
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
    }
}

struct AlertInfo: Identifiable {
    let id: String
    var title: String = "提示"
    var message: String
    var buttonText: String = "确定"
}

@MainActor
class UserInfoSettingsViewModel: ObservableObject {
    @Published var userProfile: AuthManager.UserInfo?
    @Published var nickname: String = ""
    @Published var avatarUrl: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var alertItem: AlertInfo?

    func fetchUserProfile() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // API响应模型，直接使用 AuthManager.UserInfo 可能会导致解码问题，如果API /users/me 返回的结构与登录时完全一致则可以
                // 为确保一致性，最好定义一个专门针对 /users/me 响应的结构体
                struct UserProfileResponseData: Codable {
                    let id: UUID
                    let username: String
                    let email: String
                    let phoneNumber: String?
                    let nickname: String?
                    let avatarUrl: String?
                    let createdAt: Date
                    let lastLoginAt: Date?
                }
                struct UserProfileResponse: Codable {
                    let success: Bool
                    let data: UserProfileResponseData?
                    let message: String?
                    let code: String?
                }

                let response: UserProfileResponse = try await APIService.shared.request(endpoint: "users/me", method: "GET")

                if response.success, let userData = response.data {
                    self.userProfile = AuthManager.UserInfo(
                        id: userData.id,
                        username: userData.username,
                        email: userData.email,
                        phoneNumber: userData.phoneNumber,
                        nickname: userData.nickname,
                        avatarUrl: userData.avatarUrl,
                        createdAt: userData.createdAt,
                        lastLoginAt: userData.lastLoginAt
                    )
                    self.nickname = userData.nickname ?? ""
                    self.avatarUrl = userData.avatarUrl ?? ""
                } else {
                    self.errorMessage = response.message ?? "获取用户信息失败"
                }
            } catch let apiError as APIError {
                self.errorMessage = AuthManager.shared.handleError(apiError) // 复用AuthManager的错误处理
            } catch {
                self.errorMessage = "发生未知错误: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    func updateUserProfile() {
        isLoading = true
        errorMessage = nil

        Task {
            struct UpdateUserRequest: Codable {
                let nickname: String?
                let avatarUrl: String?
            }
            // API文档中 PUT /users/me 的请求体字段是 nickname 和 avatarUrl
            // 后端 UpdateUserDto 也是这两个字段
            let requestBody = UpdateUserRequest(nickname: self.nickname.isEmpty ? nil : self.nickname,
                                                 avatarUrl: self.avatarUrl.isEmpty ? nil : self.avatarUrl)
            
            // 响应结构应该与获取用户信息时类似，返回更新后的 UserDto
            struct UpdateUserResponseData: Codable {
                 let id: UUID
                 let username: String
                 let email: String
                 let phoneNumber: String?
                 let nickname: String?
                 let avatarUrl: String?
                 let createdAt: Date
                 let lastLoginAt: Date?
            }
            struct UpdateUserResponse: Codable {
                let success: Bool
                let message: String?
                let data: UpdateUserResponseData? // 后端返回更新后的 UserDto
                let code: String?
            }

            do {
                let response: UpdateUserResponse = try await APIService.shared.request(
                    endpoint: "users/me",
                    method: "PUT",
                    body: requestBody
                )

                if response.success, let updatedUserData = response.data {
                    // 更新 AuthManager 中的 currentUser
                    AuthManager.shared.currentUser = AuthManager.UserInfo(
                        id: updatedUserData.id,
                        username: updatedUserData.username,
                        email: updatedUserData.email,
                        phoneNumber: updatedUserData.phoneNumber,
                        nickname: updatedUserData.nickname,
                        avatarUrl: updatedUserData.avatarUrl,
                        createdAt: updatedUserData.createdAt,
                        lastLoginAt: updatedUserData.lastLoginAt
                    )
                    // 更新本地UserDefaults缓存
                    AuthManager.shared.saveCurrentUserToUserDefaults()


                    self.alertItem = AlertInfo(id: "update_success", title: "成功", message: response.message ?? "用户信息更新成功")
                } else {
                    self.errorMessage = response.message ?? "更新用户信息失败"
                    self.alertItem = AlertInfo(id: "update_failure", title: "失败", message: response.message ?? "更新用户信息失败")
                }
            } catch let apiError as APIError {
                 self.errorMessage = AuthManager.shared.handleError(apiError)
                 self.alertItem = AlertInfo(id: "update_error", title: "错误", message: self.errorMessage ?? "更新失败")
            } catch {
                self.errorMessage = "发生未知错误: \(error.localizedDescription)"
                self.alertItem = AlertInfo(id: "update_unknown_error", title: "错误", message: self.errorMessage ?? "发生未知错误")
            }
            isLoading = false
        }
    }
}

#Preview {
    NavigationView {
        UserInfoSettingsView()
    }
} 