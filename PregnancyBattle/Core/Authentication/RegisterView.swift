import SwiftUI
import Foundation

// 自定义颜色 (建议后续移至 Assets.xcassets 或专门的颜色扩展文件)
let warmBackgroundColor = Color(red: 0.98, green: 0.96, blue: 0.94) // 淡米色
let primaryButtonColor = Color(red: 0.99, green: 0.76, blue: 0.65) // 珊瑚粉/蜜桃橙
let secondaryTextColor = Color.gray
let primaryTextColor = Color.black.opacity(0.8)
let fieldBackgroundColor = Color.white.opacity(0.7)

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = RegisterViewModel()
    @State private var isRegisterButtonPressed = false // 用于按钮动画

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) { // 增加整体间距
                    // 标题
                    Text("创建您的专属账号") // 更温馨的标题
                        .font(.system(size: 28, weight: .medium, design: .rounded)) // 更圆润的字体
                        .foregroundColor(primaryTextColor)
                        .padding(.top, 30)

                    // 注册表单
                    VStack(spacing: 18) { // 增加表单内间距
                        CustomTextField(placeholder: "用户名", text: $viewModel.username, keyboardType: .default)
                        CustomTextField(placeholder: "电子邮件", text: $viewModel.email, keyboardType: .emailAddress, autocapitalization: .none)
                        CustomTextField(placeholder: "手机号码", text: $viewModel.phoneNumber, keyboardType: .phonePad)
                        CustomTextField(placeholder: "昵称（选填）", text: $viewModel.nickname, keyboardType: .default)
                        CustomSecureField(placeholder: "密码", text: $viewModel.password)
                        CustomSecureField(placeholder: "确认密码", text: $viewModel.confirmPassword)

                        // 注册按钮
                        Button(action: {
                            Task {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isRegisterButtonPressed = true
                                }
                                await viewModel.register()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isRegisterButtonPressed = false
                                }
                            }
                        }) {
                            Text("立即注册")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.isFormValid ? primaryButtonColor : primaryButtonColor.opacity(0.4))
                                .cornerRadius(12) // 更大的圆角
                                .shadow(color: viewModel.isFormValid ? primaryButtonColor.opacity(0.4) : Color.clear, radius: 5, x: 0, y: 3) // 添加阴影
                                .animation(.easeInOut(duration: 0.2), value: viewModel.isFormValid) // 添加颜色变化动画
                        }
                        .padding(.horizontal)
                        .padding(.top, 10) // 按钮与上方间距
                        .disabled(viewModel.isLoading || !viewModel.isFormValid)
                        .scaleEffect(isRegisterButtonPressed ? 0.95 : 1.0) // 点击动画

                        // 返回登录链接
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("已有账号？返回登录")
                                .foregroundColor(primaryButtonColor.opacity(0.9))
                                .font(.system(size: 15, design: .rounded))
                        }
                        .padding(.top, 15)
                    }
                    .padding(.horizontal, 25) // 左右内边距
                    .padding(.vertical, 20)
                    .background(Color.white.opacity(0.6)) // 表单区域浅色背景
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)


                }
                .padding(.bottom, 20) // 底部额外间距
            }
            .background(warmBackgroundColor.edgesIgnoringSafeArea(.all)) // 应用背景色
            .navigationTitle("") // 使用新的 navigationTitle, 保持标题为空
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill") // 更明显的关闭按钮
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundColor(secondaryTextColor)
            })
            .alert(item: $viewModel.alertItem) { alertItem in // 使用 .alert(item:)
                Alert(
                    title: Text(alertItem.title),
                    message: Text(alertItem.message),
                    dismissButton: .default(Text(alertItem.dismissButtonText)) {
                        if alertItem.id == "success" { // 通过id判断是否是成功弹窗
                            // 注册成功后，保存用户名并返回登录界面
                            UserDefaults.standard.set(viewModel.username, forKey: "lastRegisteredUsername")
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // 避免iPad上的分栏视图
    }
}

// 自定义 TextField 封装
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .sentences
    var disableAutocorrection: Bool? = nil

    var body: some View {
        TextField(placeholder, text: $text)
            .padding(12)
            .background(fieldBackgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .keyboardType(keyboardType)
            .autocapitalization(autocapitalization)
            .disableAutocorrection(disableAutocorrection)
            // 添加中文输入支持
            .environment(\.locale, Locale(identifier: "zh_CN"))
            .font(.system(size: 16, design: .rounded))
    }
}

// 自定义 SecureField 封装
struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField(placeholder, text: $text)
            .padding(12)
            .background(fieldBackgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .textContentType(.oneTimeCode) // 保持禁用自动填充
            .font(.system(size: 16, design: .rounded))
    }
}


// For Alert
struct AlertItem: Identifiable {
    let id: String // "error" or "success"
    let title: String
    let message: String
    var dismissButtonText: String = "确定"
}

@MainActor // 将 ViewModel 标记为在主 Actor 上运行
class RegisterViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var phoneNumber = ""
    @Published var nickname = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    @Published var isLoading = false
    @Published var alertItem: AlertItem? // 修改为使用 AlertItem

    // 计算属性：检查表单是否有效（所有必填字段都已填写且密码一致）
    var isFormValid: Bool {
        !username.isEmpty &&
        !email.isEmpty &&
        !phoneNumber.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword
    }

    func register() async {
        print("[RegisterViewModel] Attempting to register...")
        print("[RegisterViewModel] Username: \(username), Email: \(email), Phone: \(phoneNumber), Nickname: \(nickname.isEmpty ? "N/A" : nickname)")

        // 验证输入
        guard !username.isEmpty else {
            showAlert(id: "error", title: "注册失败", message: "请输入用户名")
            return
        }
        guard !email.isEmpty else {
            showAlert(id: "error", title: "注册失败", message: "请输入电子邮件")
            return
        }
        guard !phoneNumber.isEmpty else {
            showAlert(id: "error", title: "注册失败", message: "请输入手机号码")
            return
        }
        guard !password.isEmpty else {
            showAlert(id: "error", title: "注册失败", message: "请输入密码")
            return
        }

        guard password == confirmPassword else {
            showAlert(id: "error", title: "注册失败", message: "两次输入的密码不一致")
            return
        }

        // 验证邮箱格式
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}" // Correct: \\. in Swift string for literal \. in regex
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            showAlert(id: "error", title: "注册失败", message: "请输入有效的电子邮件地址")
            return
        }

        // 验证手机号格式 (中国大陆11位)
        let phoneRegex = "^1[3-9]\\d{9}$" // Correct: \\d in Swift string for literal \d in regex
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        guard phonePredicate.evaluate(with: phoneNumber) else {
            showAlert(id: "error", title: "注册失败", message: "请输入有效的11位中国大陆手机号码")
            return
        }

        print("[RegisterViewModel] All validations passed.")

        self.isLoading = true

        do {
            print("[RegisterViewModel] Calling AuthManager.shared.register...")
            try await AuthManager.shared.register(
                username: username,
                email: email,
                phoneNumber: phoneNumber,
                password: password,
                nickname: nickname.isEmpty ? nil : nickname
            )
            print("[RegisterViewModel] AuthManager.shared.register successful.")
            showAlert(id: "success", title: "注册成功✅", message: "欢迎加入！请使用您的账号登录。")
        } catch {
            print("[RegisterViewModel] AuthManager.shared.register failed. Error: \(error.localizedDescription)")
            // 从AuthManager获取错误信息，这里会包含后端返回的业务错误信息
            let errorMessage = await MainActor.run { AuthManager.shared.error ?? error.localizedDescription }
            print("[RegisterViewModel] Showing error message: \(errorMessage)")
            // 直接显示错误消息，不添加"发生错误："前缀
            showAlert(id: "error", title: "注册失败", message: errorMessage)
        }

        self.isLoading = false
    }

    private func showAlert(id: String, title: String, message: String, dismissButtonText: String = "确定") {
        self.alertItem = AlertItem(id: id, title: title, message: message, dismissButtonText: dismissButtonText)
        print("[RegisterViewModel] Showing alert: Title: \(title), Message: \(message)")
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}