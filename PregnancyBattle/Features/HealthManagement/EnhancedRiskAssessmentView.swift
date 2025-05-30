import SwiftUI

public struct EnhancedRiskAssessmentView: View {
    public let riskAssessment: RiskAssessment
    @State private var selectedTab = 0
    @State private var isContentReady = false

    public init(riskAssessment: RiskAssessment) {
        self.riskAssessment = riskAssessment
    }

    public var severityColor: (String) -> Color = { severity in
        switch severity.lowercased() {
        case "低":
            return .green
        case "中":
            return .orange
        case "高":
            return .red
        default:
            return .gray
        }
    }

    public var priorityColor: (String) -> Color = { priority in
        switch priority.lowercased() {
        case "低":
            return .blue
        case "中":
            return .orange
        case "高":
            return .red
        default:
            return .gray
        }
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 标题和AI增强标识
                HStack {
                    Text("健康风险评估")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    if riskAssessment.isAiEnhanced {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.blue)
                            Text("AI增强")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }

                // 选项卡
                if riskAssessment.isAiEnhanced {
                    Picker("评估类型", selection: $selectedTab) {
                        Text("AI智能分析").tag(0)
                        Text("基础评估").tag(1)
                        Text("个性化建议").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // 内容区域 - 添加条件渲染和动画
                Group {
                    if isContentReady {
                        if riskAssessment.isAiEnhanced && selectedTab == 0 {
                            // AI智能分析
                            aiAnalysisView
                        } else if riskAssessment.isAiEnhanced && selectedTab == 2 {
                            // 个性化建议
                            personalizedRecommendationsView
                        } else {
                            // 基础评估
                            basicAssessmentView
                        }
                    } else {
                        // 内容加载中
                        ProgressView("正在加载评估内容...")
                            .frame(maxWidth: .infinity, minHeight: 100)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: isContentReady)
                .animation(.easeInOut(duration: 0.3), value: selectedTab)

                // 免责声明
                disclaimerView
            }
            .padding()
        }
        .onAppear {
            // 确保内容立即显示
            DispatchQueue.main.async {
                isContentReady = true
            }
        }
        .onChange(of: riskAssessment.isAiEnhanced) { _ in
            // 当AI增强状态变化时，重新准备内容
            isContentReady = false
            DispatchQueue.main.async {
                isContentReady = true
            }
        }
    }

    // AI分析视图
    private var aiAnalysisView: some View {
        VStack(alignment: .leading, spacing: 15) {
            if let aiAnalysis = riskAssessment.aiAnalysis {
                // 整体评估
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("整体评估")
                            .font(.headline)
                        Spacer()
                        riskScoreView(score: aiAnalysis.riskScore, level: aiAnalysis.riskLevel)
                    }

                    Text(aiAnalysis.overallAssessment)
                        .font(.body)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }

                // 详细分析
                VStack(alignment: .leading, spacing: 10) {
                    Text("详细分析")
                        .font(.headline)

                    ForEach(aiAnalysis.detailedAnalyses, id: \.id) { analysis in
                        detailedAnalysisCard(analysis: analysis)
                    }
                }

                // 综合建议
                VStack(alignment: .leading, spacing: 8) {
                    Text("综合建议")
                        .font(.headline)

                    Text(aiAnalysis.comprehensiveRecommendation)
                        .font(.body)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
    }

    // 个性化建议视图
    private var personalizedRecommendationsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            if let recommendations = riskAssessment.personalizedRecommendations {
                // 分类建议
                VStack(alignment: .leading, spacing: 10) {
                    Text("专项建议")
                        .font(.headline)

                    ForEach(recommendations.categoryRecommendations, id: \.id) { recommendation in
                        categoryRecommendationCard(recommendation: recommendation)
                    }
                }

                // 生活方式建议
                lifestylePlansView(recommendations: recommendations)

                // 监测建议和警告信号
                monitoringAndWarningsView(recommendations: recommendations)
            }
        }
    }

    // 基础评估视图
    private var basicAssessmentView: some View {
        VStack(alignment: .leading, spacing: 15) {
            // BMI信息
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("BMI分类:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(riskAssessment.bmiCategory)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Text(riskAssessment.bmiRisk)
                    .font(.body)
            }

            // 年龄风险
            VStack(alignment: .leading, spacing: 5) {
                Text("年龄评估:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(riskAssessment.ageRisk)
                    .font(.body)
            }

            // 医疗风险
            if !riskAssessment.medicalRisks.isEmpty {
                Text("医疗风险:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ForEach(riskAssessment.medicalRisks, id: \.id) { risk in
                    HStack(alignment: .top) {
                        Circle()
                            .fill(severityColor(risk.severity))
                            .frame(width: 10, height: 10)
                            .padding(.top, 5)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(risk.type)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(risk.description)
                                .font(.body)
                        }
                    }
                }
            }

            // 健康建议
            Text("健康建议:")
                .font(.subheadline)
                .foregroundColor(.secondary)

            ForEach(riskAssessment.recommendations, id: \.id) { recommendation in
                VStack(alignment: .leading, spacing: 3) {
                    Text(recommendation.category)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(recommendation.description)
                        .font(.body)
                }
                .padding(.vertical, 5)
            }
        }
    }

    // 免责声明
    private var disclaimerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("免责声明")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            if riskAssessment.isAiEnhanced {
                Text("以上AI分析和评估仅供参考，不能替代专业医疗建议。具体情况请咨询医生。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("以上评估仅供参考，具体情况请咨询医生。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // 风险评分视图
    private func riskScoreView(score: Int, level: String) -> some View {
        HStack {
            Text("\(score)/10")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(severityColor(level))

            Text(level)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(severityColor(level).opacity(0.2))
                .foregroundColor(severityColor(level))
                .cornerRadius(8)
        }
    }

    // 详细分析卡片
    private func detailedAnalysisCard(analysis: DetailedAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(analysis.category)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text(analysis.dataValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(6)

                Circle()
                    .fill(severityColor(analysis.severity))
                    .frame(width: 8, height: 8)
            }

            Text(analysis.analysis)
                .font(.body)

            if !analysis.impact.isEmpty {
                HStack(alignment: .top) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("影响：\(analysis.impact)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if !analysis.recommendation.isEmpty {
                HStack(alignment: .top) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("建议：\(analysis.recommendation)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    // 分类建议卡片
    private func categoryRecommendationCard(recommendation: CategoryRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(recommendation.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text(recommendation.priority)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priorityColor(recommendation.priority).opacity(0.2))
                    .foregroundColor(priorityColor(recommendation.priority))
                    .cornerRadius(6)
            }

            Text(recommendation.description)
                .font(.body)

            if !recommendation.actionItems.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("具体行动：")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    ForEach(recommendation.actionItems, id: \.self) { item in
                        HStack(alignment: .top) {
                            Text("•")
                                .foregroundColor(.blue)
                            Text(item)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    // 生活方式计划视图
    private func lifestylePlansView(recommendations: PersonalizedRecommendations) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("生活方式指导")
                .font(.headline)

            if !recommendations.dietPlan.isEmpty {
                planCard(title: "饮食计划", content: recommendations.dietPlan, icon: "fork.knife", color: .green)
            }

            if !recommendations.exercisePlan.isEmpty {
                planCard(title: "运动计划", content: recommendations.exercisePlan, icon: "figure.walk", color: .blue)
            }

            if !recommendations.lifestyleAdjustments.isEmpty {
                planCard(title: "生活调整", content: recommendations.lifestyleAdjustments, icon: "house.fill", color: .orange)
            }
        }
    }

    // 监测和警告视图
    private func monitoringAndWarningsView(recommendations: PersonalizedRecommendations) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if !recommendations.monitoringAdvice.isEmpty {
                planCard(title: "监测建议", content: recommendations.monitoringAdvice, icon: "chart.line.uptrend.xyaxis", color: .purple)
            }

            if !recommendations.warningSignsToWatch.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("警告信号")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    ForEach(recommendations.warningSignsToWatch, id: \.self) { warning in
                        HStack(alignment: .top) {
                            Text("⚠️")
                            Text(warning)
                                .font(.body)
                        }
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }

    // 计划卡片
    private func planCard(title: String, content: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Text(content)
                .font(.body)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}
