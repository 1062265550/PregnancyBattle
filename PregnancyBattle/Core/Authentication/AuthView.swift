import SwiftUI

struct AuthView: View {
    @ObservedObject private var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                // 用户已登录，显示主页
                HomeView()
            } else {
                // 用户未登录，显示登录页
                LoginView()
            }
        }
    }
}

struct HomeView: View {
    @ObservedObject private var authManager = AuthManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                Text("欢迎回来，\(authManager.currentUser?.nickname ?? authManager.currentUser?.username ?? "用户")")
                    .font(.title)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    authManager.logout()
                }) {
                    Text("退出登录")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("孕期大作战")
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}