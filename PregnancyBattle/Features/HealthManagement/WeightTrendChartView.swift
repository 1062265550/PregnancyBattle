import SwiftUI
import Charts

public struct WeightTrendChartView: View {
    public let weightTrend: WeightTrend
    public let healthProfile: HealthProfile? // 添加健康档案参数用于获取身高

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }

    private var shortDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }

    // 计算当前BMI
    private var currentBMI: Double {
        guard let profile = healthProfile, profile.height > 0 else { return 0 }
        let heightInMeters = profile.height / 100.0
        return weightTrend.currentWeight / (heightInMeters * heightInMeters)
    }

    // 根据BMI判断体重状态
    private var weightStatus: String {
        let bmi = currentBMI
        if bmi < 18.5 {
            return "偏瘦"
        } else if bmi < 25.0 {
            return "正常"
        } else if bmi < 30.0 {
            return "超重"
        } else {
            return "肥胖"
        }
    }

    // BMI状态对应的颜色
    private var weightStatusColor: Color {
        let bmi = currentBMI
        if bmi < 18.5 {
            return .blue
        } else if bmi < 25.0 {
            return .green
        } else if bmi < 30.0 {
            return .orange
        } else {
            return .red
        }
    }

    // 计算图表的时间范围
    private var chartDateRange: (start: Date, end: Date) {
        guard let firstDate = weightTrend.weightRecords.first?.date else {
            let now = Date()
            return (start: now, end: now)
        }

        let lastDate = weightTrend.weightRecords.last?.date ?? firstDate
        let calendar = Calendar.current

        // 确保至少显示2周的时间范围
        let daysBetween = calendar.dateComponents([.day], from: firstDate, to: lastDate).day ?? 0
        let totalDays = max(daysBetween, 14)

        let endDate = calendar.date(byAdding: .day, value: totalDays, to: firstDate) ?? lastDate
        return (start: firstDate, end: endDate)
    }

    // 计算推荐体重范围的数据点
    private var recommendedWeightData: [(Date, Double, Double)] {
        let range = chartDateRange
        let calendar = Calendar.current

        var data: [(Date, Double, Double)] = []
        let daysBetween = calendar.dateComponents([.day], from: range.start, to: range.end).day ?? 0
        let totalDays = daysBetween
        let stepDays = max(totalDays / 8, 1) // 8-10个数据点

        for i in stride(from: 0, through: totalDays, by: stepDays) {
            if let date = calendar.date(byAdding: .day, value: i, to: range.start) {
                let minWeight = weightTrend.startWeight + weightTrend.recommendedWeightGain.min
                let maxWeight = weightTrend.startWeight + weightTrend.recommendedWeightGain.max
                data.append((date, minWeight, maxWeight))
            }
        }

        return data
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("体重变化趋势")
                .font(.headline)

            if #available(iOS 16.0, *) {
                Chart {
                    // 推荐体重范围（背景区域）
                    ForEach(Array(recommendedWeightData.enumerated()), id: \.offset) { index, data in
                        AreaMark(
                            x: .value("日期", data.0),
                            yStart: .value("最小推荐", data.1),
                            yEnd: .value("最大推荐", data.2)
                        )
                        .foregroundStyle(.green.opacity(0.15))
                    }

                    // 推荐体重范围边界线
                    ForEach(recommendedWeightData, id: \.0) { data in
                        LineMark(
                            x: .value("日期", data.0),
                            y: .value("最小推荐", data.1)
                        )
                        .foregroundStyle(.green.opacity(0.7))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

                        LineMark(
                            x: .value("日期", data.0),
                            y: .value("最大推荐", data.2)
                        )
                        .foregroundStyle(.green.opacity(0.7))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    }

                    // 实际体重线和点
                    ForEach(weightTrend.weightRecords, id: \.id) { record in
                        LineMark(
                            x: .value("日期", record.date),
                            y: .value("体重", record.weight)
                        )
                        .foregroundStyle(Color("hm_color_primary"))
                        .lineStyle(StrokeStyle(lineWidth: 3))

                        PointMark(
                            x: .value("日期", record.date),
                            y: .value("体重", record.weight)
                        )
                        .foregroundStyle(Color("hm_color_primary"))
                        .symbol(Circle().strokeBorder(lineWidth: 2))
                        .symbolSize(100)
                    }
                }
                .frame(height: 240)
                .chartXScale(domain: chartDateRange.start...chartDateRange.end)
                .chartYScale(domain: [
                    min(
                        weightTrend.startWeight - 3,
                        weightTrend.currentWeight - 3,
                        weightTrend.startWeight + weightTrend.recommendedWeightGain.min - 2
                    ),
                    max(
                        weightTrend.currentWeight + 3,
                        weightTrend.startWeight + weightTrend.recommendedWeightGain.max + 2
                    )
                ])
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(.gray.opacity(0.3))
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            .font(.caption)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 6)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(.gray.opacity(0.3))
                        AxisTick()
                        AxisValueLabel()
                            .font(.caption)
                    }
                }

                // 图例
                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color("hm_color_primary"))
                            .frame(width: 10, height: 10)
                        Text("实际体重")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 6) {
                        Rectangle()
                            .fill(.green.opacity(0.7))
                            .frame(width: 16, height: 2)
                        Text("推荐范围")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 8)
            } else {
                // iOS 16以下的替代视图
                Text("体重记录")
                    .font(.subheadline)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(weightTrend.weightRecords, id: \.id) { record in
                            HStack {
                                Text(dateFormatter.string(from: record.date))
                                Spacer()
                                Text("第\(record.pregnancyWeek)周\(record.pregnancyDay)天")
                                Spacer()
                                Text("\(String(format: "%.1f", record.weight)) kg")
                                    .fontWeight(.semibold)
                            }
                            .padding(.vertical, 5)
                            Divider()
                        }
                    }
                }
                .frame(height: 200)
            }

            // 体重统计信息
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("起始体重")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.1f", weightTrend.startWeight)) kg")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    VStack(alignment: .center, spacing: 4) {
                        Text("当前体重")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.1f", weightTrend.currentWeight)) kg")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("增长")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(weightTrend.weightGain >= 0 ? "+" : "")\(String(format: "%.1f", weightTrend.weightGain)) kg")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(weightTrend.weightGain >= 0 ? .green : .red)
                    }
                }

                Divider()

                // BMI信息显示
                if healthProfile != nil && currentBMI > 0 {
                    HStack {
                        Text("当前BMI:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        HStack(spacing: 8) {
                            Text("\(String(format: "%.1f", currentBMI))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("(\(weightStatus))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(weightStatusColor)
                        }
                    }

                    Divider()
                }

                HStack {
                    Text("整个孕期的增重范围:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(String(format: "%.1f", weightTrend.recommendedWeightGain.min)) - \(String(format: "%.1f", weightTrend.recommendedWeightGain.max)) kg")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
