import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var showingRegister = false
    @State private var showingForgotPassword = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题
                Text("孕期大作战")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)

                Text("登录")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.bottom, 20)

                // 登录表单
                VStack(spacing: 15) {
                    TextField("用户名/邮箱/手机号", text: $viewModel.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.horizontal)
                        // 支持中文输入
                        .keyboardType(.default)

                    // 密码输入框 - 禁用自动填充
                    SecureField("密码", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        // 使用oneTimeCode禁用自动填充
                        .textContentType(.oneTimeCode)

                    // 登录按钮
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                            Text("正在登录中...")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    } else {
                        Button(action: {
                            Task {
                                await viewModel.login()
                            }
                        }) {
                            Text("登录")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }

                    // 忘记密码链接
                    Button(action: {
                        showingForgotPassword = true
                    }) {
                        Text("忘记密码？")
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 5)

                    // 注册链接
                    HStack {
                        Text("还没有账号？")
                        Button(action: {
                            showingRegister = true
                        }) {
                            Text("立即注册")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding()

                Spacer()
            }
            .alert(isPresented: $viewModel.showingError) {
                Alert(
                    title: Text("登录失败"),
                    message: Text(viewModel.errorMessage ?? "未知错误"),
                    dismissButton: .default(Text("确定"))
                )
            }
            .sheet(isPresented: $showingRegister) {
                RegisterView()
            }
            .sheet(isPresented: $showingForgotPassword) {
                ForgotPasswordView()
            }
            .navigationBarHidden(true)
        }
    }
}

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showingError = false
    @Published var errorMessage: String?

    init() {
        // 检查是否有刚注册的用户名，如果有则自动填充
        if let lastUsername = UserDefaults.standard.string(forKey: "lastRegisteredUsername") {
            self.username = lastUsername
            // 使用后清除，避免下次登录还自动填充
            UserDefaults.standard.removeObject(forKey: "lastRegisteredUsername")
        }
    }

    func login() async {
        guard !username.isEmpty, !password.isEmpty else {
            DispatchQueue.main.async {
                self.errorMessage = "用户名和密码不能为空"
                self.showingError = true
            }
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
        }

        do {
            try await AuthManager.shared.login(username: username, password: password)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = AuthManager.shared.error
                self.showingError = true
                self.isLoading = false
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}