import SwiftUI

public struct RiskAssessmentLoadingView: View {
    @State private var animationAmount: Double = 1.0
    @State private var dotCount: Int = 0
    
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    public var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("健康风险评估")
                .font(.headline)
                .foregroundColor(.primary)
            
            // 加载动画
            VStack(spacing: 15) {
                // 旋转的AI图标
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(animationAmount * 360))
                        .animation(
                            Animation.linear(duration: 2.0)
                                .repeatForever(autoreverses: false),
                            value: animationAmount
                        )
                    
                    Text("AI增强")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // 加载文本
                VStack(spacing: 8) {
                    Text("正在生成风险评估报告\(String(repeating: ".", count: dotCount))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .onReceive(timer) { _ in
                            dotCount = (dotCount + 1) % 4
                        }
                    
                    Text("由于对接了DeepSeek AI，分析过程需要一些时间")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("请耐心等待，我们正在为您提供专业的健康分析")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // 进度条
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.2)
                
                // 提示信息
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.orange)
                        Text("预计等待时间：30-60秒")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                        Text("AI正在分析您的健康数据")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // 免责声明
            Text("AI分析结果仅供参考，具体情况请咨询专业医生")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .onAppear {
            animationAmount = 2.0
        }
    }
}

#Preview {
    RiskAssessmentLoadingView()
        .padding()
}
