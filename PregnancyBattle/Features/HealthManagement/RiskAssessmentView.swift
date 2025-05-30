import SwiftUI

public struct RiskAssessmentView: View {
    public let riskAssessment: RiskAssessment

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

    public var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("健康风险评估")
                .font(.headline)

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

            // 免责声明
            Text("免责声明：以上评估仅供参考，具体情况请咨询医生。")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 10)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
