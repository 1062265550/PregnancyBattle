import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ForgotPasswordViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题
                Text("找回密码")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top, 20)

                // 步骤指示器
                StepIndicator(currentStep: viewModel.currentStep)
                    .padding(.horizontal)
                    .padding(.bottom, 20)

                // 步骤内容
                Group {
                    if viewModel.currentStep == 1 {
                        // 步骤1：输入邮箱
                        VStack(spacing: 15) {
                            Text("请输入您的邮箱")
                                .font(.headline)
                                .padding(.bottom, 10)

                            TextField("电子邮件", text: $viewModel.email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .keyboardType(.emailAddress)
                                .padding(.horizontal)

                            Button(action: {
                                Task {
                                    await viewModel.sendVerificationCode()
                                }
                            }) {
                                Text("发送验证码")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .disabled(viewModel.isLoading)
                        }
                    } else if viewModel.currentStep == 2 {
                        // 步骤2：输入验证码
                        VStack(spacing: 15) {
                            Text("请输入您收到的验证码")
                                .font(.headline)
                                .padding(.bottom, 10)

                            TextField("验证码", text: $viewModel.verificationCode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .padding(.horizontal)

                            if let expireTime = viewModel.codeExpireTime {
                                Text("验证码将在 \(timeRemaining(from: expireTime)) 后过期")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            Button(action: {
                                Task {
                                    await viewModel.verifyCode()
                                }
                            }) {
                                Text("验证")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .disabled(viewModel.isLoading)

                            Button(action: {
                                Task {
                                    await viewModel.sendVerificationCode()
                                }
                            }) {
                                Text("重新发送验证码")
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 5)
                        }
                    } else if viewModel.currentStep == 3 {
                        // 步骤3：设置新密码
                        VStack(spacing: 15) {
                            Text("请设置新密码")
                                .font(.headline)
                                .padding(.bottom, 10)

                            // 新密码输入框 - 禁用自动填充
                            SecureField("新密码", text: $viewModel.newPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                                // 使用oneTimeCode禁用自动填充
                                .textContentType(.oneTimeCode)

                            // 确认新密码输入框 - 禁用自动填充
                            SecureField("确认新密码", text: $viewModel.confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                                // 使用oneTimeCode禁用自动填充
                                .textContentType(.oneTimeCode)

                            Button(action: {
                                Task {
                                    await viewModel.resetPassword()
                                }
                            }) {
                                Text("重置密码")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .disabled(viewModel.isLoading)
                        }
                    }
                }
                .padding()

                Spacer()

                // 返回登录链接
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("返回登录")
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 20)
            }
            .alert(isPresented: $viewModel.showingError) {
                Alert(
                    title: Text("错误"),
                    message: Text(viewModel.errorMessage ?? "未知错误"),
                    dismissButton: .default(Text("确定"))
                )
            }
            .alert(isPresented: $viewModel.showingSuccess) {
                Alert(
                    title: Text("密码重置成功"),
                    message: Text("请使用新密码登录"),
                    dismissButton: .default(Text("确定")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.primary)
            })
        }
    }

    func timeRemaining(from date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .second], from: Date(), to: date)
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0

        if minutes > 0 {
            return "\(minutes)分\(seconds)秒"
        } else {
            return "\(seconds)秒"
        }
    }
}

struct StepIndicator: View {
    let currentStep: Int
    let totalSteps = 3

    var body: some View {
        HStack {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 20, height: 20)
                    .overlay(
                        Text("\(step)")
                            .font(.caption)
                            .foregroundColor(.white)
                    )

                if step < totalSteps {
                    Rectangle()
                        .fill(step < currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 2)
                }
            }
        }
    }
}

class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var verificationCode = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var currentStep = 1
    @Published var isLoading = false
    @Published var showingError = false
    @Published var showingSuccess = false
    @Published var errorMessage: String?
    @Published var codeExpireTime: Date?

    private var resetToken: String?

    func sendVerificationCode() async {
        // 验证输入
        if email.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "请输入电子邮件"
                self.showingError = true
            }
            return
        }

        // 验证邮箱格式
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            DispatchQueue.main.async {
                self.errorMessage = "请输入有效的电子邮件地址"
                self.showingError = true
            }
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
        }

        do {
            let response = try await AuthManager.shared.sendVerificationCode(
                email: email,
                phoneNumber: "" // 传递空字符串而不是nil，确保后端验证通过
            )

            DispatchQueue.main.async {
                self.isLoading = false
                // 从response.data中获取codeExpireTime
                if let responseData = response.data {
                    self.codeExpireTime = responseData.codeExpireTime
                }
                if self.currentStep == 1 {
                    self.currentStep = 2
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = AuthManager.shared.error
                self.showingError = true
                self.isLoading = false
            }
        }
    }

    func verifyCode() async {
        // 验证输入
        if verificationCode.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "请输入验证码"
                self.showingError = true
            }
            return
        }

        // 验证验证码格式
        let codeRegex = "^\\d{6}$"
        let codePredicate = NSPredicate(format: "SELF MATCHES %@", codeRegex)
        if !codePredicate.evaluate(with: verificationCode) {
            DispatchQueue.main.async {
                self.errorMessage = "验证码必须是6位数字"
                self.showingError = true
            }
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
        }

        do {
            let token = try await AuthManager.shared.verifyCode(
                email: email,
                phoneNumber: "", // 传递空字符串而不是nil，确保后端验证通过
                code: verificationCode
            )

            DispatchQueue.main.async {
                self.isLoading = false
                self.resetToken = token
                self.currentStep = 3
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = AuthManager.shared.error
                self.showingError = true
                self.isLoading = false
            }
        }
    }

    func resetPassword() async {
        // 验证输入
        if newPassword.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "请输入新密码"
                self.showingError = true
            }
            return
        }

        if newPassword != confirmPassword {
            DispatchQueue.main.async {
                self.errorMessage = "两次输入的密码不一致"
                self.showingError = true
            }
            return
        }

        if newPassword.count < 6 {
            DispatchQueue.main.async {
                self.errorMessage = "密码长度不能少于6个字符"
                self.showingError = true
            }
            return
        }

        guard let resetToken = resetToken else {
            DispatchQueue.main.async {
                self.errorMessage = "重置令牌无效，请重新获取验证码"
                self.showingError = true
            }
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
        }

        do {
            try await AuthManager.shared.resetPassword(
                resetToken: resetToken,
                newPassword: newPassword
            )

            DispatchQueue.main.async {
                self.isLoading = false
                self.showingSuccess = true
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = AuthManager.shared.error
                self.showingError = true
                self.isLoading = false
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}