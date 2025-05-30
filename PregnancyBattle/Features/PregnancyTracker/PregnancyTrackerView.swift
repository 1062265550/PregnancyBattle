//
//  PregnancyTrackerView.swift
//  PregnancyBattle
//
//  Created on 2023/5/12.
//

import SwiftUI

struct PregnancyTrackerView: View {
    @StateObject private var viewModel = PregnancyTrackerViewModel()

    // Helper function to mix a color with white
    private func mixWithWhite(_ color: Color, amount: CGFloat = 0.3) -> Color {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        // Mix with white (white is r=1, g=1, b=1)
        // Ensure components do not exceed 1.0
        let newR = min(1.0, r * (1 - amount) + 1 * amount)
        let newG = min(1.0, g * (1 - amount) + 1 * amount)
        let newB = min(1.0, b * (1 - amount) + 1 * amount)

        return Color(red: Double(newR), green: Double(newG), blue: Double(newB), opacity: Double(a))
    }

    // MARK: - Dynamic Colors per Week
    private func dynamicBackgroundColor(forWeek week: Int) -> Color {
        switch week {
        // 孕早期 (0-13 周)
        case 0...4: // 第1个月 (包含第0周)
            return Color("pt_color_tender_sprout_green")
        case 5...8: // 第2个月
            return Color("pt_color_light_apricot")
        case 9...13: // 第3个月
            return Color("pt_color_pale_pink")
        // 孕中期 (14-27 周)
        case 14...17: // 第4个月
            return Color("pt_color_warm_sunshine_yellow")
        case 18...22: // 第5个月 (假设22周结束第五个月)
            return Color("pt_color_peach_pink")
        case 23...27: // 第6-7个月 (用户第七月未指定，沿用第六月或可自定义)
            return Color("pt_color_serene_blue")
        // 孕晚期 (28-40+ 周)
        case 28...31: // 第8个月 (假设31周结束第八个月)
            return Color("pt_color_soft_lavender_purple")
        case 32...36: // 第9个月 (假设36周结束第九个月)
            return Color("pt_color_dusty_rose")
        case 37...42: // 第10个月及以后
            return Color("pt_color_warm_oatmeal")
        default: // 默认或超出范围
            return Color(.systemGray5) // 一个中性的备用颜色
        }
    }

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("加载中...")
            } else if viewModel.showLMPInput {
                lmpInputView
            } else if let pregnancyInfo = viewModel.pregnancyInfo {
                pregnancyInfoView(pregnancyInfo)
            } else {
                VStack {
                    Text("无法加载孕期信息")
                        .font(.headline)

                    if let error = viewModel.error {
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding()
                    }

                    Button("重试") {
                        Task {
                            await viewModel.loadPregnancyInfo()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
        }
        .navigationTitle("孕期追踪")
        .refreshable {
            await viewModel.refreshPregnancyInfo()
        }
    }

    // 孕期信息视图
    private func pregnancyInfoView(_ info: PregnancyInfo) -> some View {
        let pageBackgroundColor = dynamicBackgroundColor(forWeek: info.currentWeek)

        // 定义卡片的前景色和背景色，以便在彩色背景上清晰显示
        let cardForegroundColor: Color = .primary
        let cardSecondaryForegroundColor: Color = .secondary
        let cardBackgroundColor: Color = Color(.systemBackground) // 使用系统背景色以适应深色/浅色模式

        return ZStack {
            pageBackgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) { // 统一模块间距
                    // 孕周信息卡片
                    VStack(alignment: .leading, spacing: 10) {
                        Text("第 \(getDisplayWeek(info)) 周 \(getDisplayDay(info)) 天")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(cardForegroundColor)

                        Text("预产期: \(viewModel.formattedDueDate)")
                            .font(.headline)
                            .foregroundColor(cardForegroundColor)

                        Text("距离预产期还有 \(getDisplayDaysUntilDueDate(info)) 天")
                            .font(.subheadline)
                            .foregroundColor(cardSecondaryForegroundColor)

                        Text("孕期阶段: \(getDisplayPregnancyStage(info))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(cardForegroundColor)

                        Divider()
                            .background(cardSecondaryForegroundColor.opacity(0.5))

                        if info.currentWeek == 0 {
                            Text("受精卵刚刚着床呢，请耐心期待")
                                .font(.body)
                                .foregroundColor(cardSecondaryForegroundColor)
                        } else {
                            Text("宝宝现在大小如同\(viewModel.fetusSizeComparison)")
                                .font(.body)
                                .foregroundColor(cardSecondaryForegroundColor)
                        }
                    }
                    .frame(maxWidth: .infinity) // 确保卡片宽度一致
                    .padding()
                    .background(cardBackgroundColor)
                    .cornerRadius(15) // 统一圆角
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // 统一阴影
                    .padding(.horizontal)

                    // 胎儿发育信息
                    VStack(alignment: .leading, spacing: 10) {
                        Text("本周胎儿发育")
                            .font(.title3) // 调整字号以突出模块标题
                            .fontWeight(.semibold)
                            .foregroundColor(cardForegroundColor)
                            .frame(maxWidth: .infinity, alignment: .leading) // 确保标题文本左对齐并撑满宽度
                        Text(getFetalDevelopmentInfo(forWeek: info.currentWeek))
                            .font(.body)
                            .foregroundColor(cardSecondaryForegroundColor)
                            .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading) // 确保内容文本左对齐并撑满宽度
                    }
                    .frame(maxWidth: .infinity) // 确保卡片宽度一致
                    .padding()
                    .background(cardBackgroundColor)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)

                    // 妈妈变化信息
                    VStack(alignment: .leading, spacing: 10) {
                        Text("妈妈的变化")
                            .font(.title3) // 调整字号以突出模块标题
                            .fontWeight(.semibold)
                            .foregroundColor(cardForegroundColor)
                            .frame(maxWidth: .infinity, alignment: .leading) // 确保标题文本左对齐并撑满宽度
                        Text(getMotherChangesInfo(forWeek: info.currentWeek))
                            .font(.body)
                            .foregroundColor(cardSecondaryForegroundColor)
                            .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading) // 确保内容文本左对齐并撑满宽度
                    }
                    .frame(maxWidth: .infinity) // 确保卡片宽度一致
                    .padding()
                    .background(cardBackgroundColor)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)

                    // 修改孕期信息按钮
                    Button(action: {
                        viewModel.lmpDate = info.lmpDate
                        viewModel.calculationMethod = info.calculationMethod
                        viewModel.ultrasoundDate = info.ultrasoundDate ?? Date()
                        viewModel.ultrasoundWeeks = info.ultrasoundWeeks ?? 0
                        viewModel.ultrasoundDays = info.ultrasoundDays ?? 0
                        viewModel.isMultiplePregnancy = info.isMultiplePregnancy
                        viewModel.fetusCount = info.fetusCount ?? 2
                        viewModel.showLMPInput = true
                    }) {
                        Text("修改孕期信息")
                    }
                    .buttonStyle(PregnancyInfoButtonStyle()) // 应用新的自定义按钮样式
                    .padding(.horizontal) // 与其他卡片左右对齐
                    .padding(.vertical, 10) // 上下间距
                }
                .padding(.vertical) // 给VStack整体一个垂直padding
            }
            .background(Color.clear) // 确保ScrollView背景透明
        }
    }

    // LMP输入视图
    private var lmpInputView: some View {
        ScrollView {
            let today = Date()
            let fortyWeeksInDays: TimeInterval = 40 * 7 * 24 * 60 * 60
            let minLMPDate = Calendar.current.date(byAdding: .day, value: -Int(fortyWeeksInDays / (24*60*60)), to: today) ?? today.addingTimeInterval(-fortyWeeksInDays)
            let minIvfTransferDate = Calendar.current.date(byAdding: .day, value: -259, to: today) ?? today.addingTimeInterval(-259 * 24 * 60 * 60)

            VStack(spacing: 20) {
                Text("设置孕期信息")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                    .foregroundColor(Color("pt_color_primary"))

                // 条件渲染日期选择器 / 信息输入区域
                // 这部分将根据 viewModel.calculationMethod 显示不同的视图
                Group {
                    if viewModel.calculationMethod == .lmp {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("末次月经日期")
                                .font(.headline)
                                .foregroundColor(Color.gray)

                            DatePicker("末次月经",
                                       selection: Binding(
                                           get: { viewModel.lmpDate },
                                           set: { newValue in
                                               viewModel.lmpDate = newValue
                                           }
                                       ),
                                       in: minLMPDate...today,
                                       displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .frame(height: 320) // 添加固定高度
                                .environment(\.locale, Locale(identifier: "zh_CN"))
                        }
                    } else if viewModel.calculationMethod == .ultrasound {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("B超信息")
                                 .font(.title3)
                                 .fontWeight(.semibold)
                                 .foregroundColor(Color("pt_color_primary"))
                                 .padding(.top, 5) //  slight top padding for visual separation

                            // B超日期选择 - 始终可见
                            VStack(alignment: .leading, spacing: 8) {
                                Text("B超日期")
                                    .font(.headline)
                                    .foregroundColor(Color.gray)
                                DatePicker("B超日期",
                                           selection: $viewModel.ultrasoundDate,
                                           in: viewModel.ultrasoundDatePickerEffectiveRange,
                                           displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .frame(height: 320) // 添加固定高度
                            }
                            .environment(\.locale, Locale(identifier: "zh_CN"))

                            // 选择B超孕周 - 只在日期选择后显示
                            if viewModel.ultrasoundSelectionStep != .date {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("B超孕周 (0-40周)")
                                        .font(.headline)
                                        .foregroundColor(Color.gray)
                                    Picker("周", selection: $viewModel.ultrasoundWeeks) {
                                        ForEach(viewModel.ultrasoundWeeksPickerRange, id: \.self) { week in
                                            Text("\(week) 周").tag(week)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(Color("pt_color_primary"))
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(10)
                                }
                                .frame(maxWidth: .infinity)
                                .transition(.opacity)
                            }

                            // 选择B超孕天 - 只在孕周选择后显示
                            if viewModel.ultrasoundSelectionStep == .days {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("B超孕天 (0-6天)")
                                        .font(.headline)
                                        .foregroundColor(Color.gray)
                                    Picker("天", selection: $viewModel.ultrasoundDays) {
                                        ForEach(viewModel.ultrasoundDaysPickerRange, id: \.self) { day in
                                            Text("\(day) 天").tag(day)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(Color("pt_color_primary"))
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(10)
                                }
                                .frame(maxWidth: .infinity)
                                .transition(.opacity)
                            }

                            // 提示信息
                            Text("注意：总孕期不超过40周，各项选择将相互约束")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                        }
                    } else if viewModel.calculationMethod == .ivf {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("试管婴儿信息")
                                 .font(.title3)
                                 .fontWeight(.semibold)
                                 .foregroundColor(Color("pt_color_primary"))
                                 .padding(.top, 5) // slight top padding

                            VStack(alignment: .leading, spacing: 8) {
                                Text("胚胎移植日期")
                                    .font(.headline)
                                    .foregroundColor(Color.gray)
                                DatePicker("胚胎移植日期",
                                           selection: Binding(
                                               get: { viewModel.ivfTransferDate },
                                               set: { newValue in
                                                   viewModel.ivfTransferDate = newValue
                                               }
                                           ),
                                           in: minIvfTransferDate...today,
                                           displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .frame(height: 320) // 添加固定高度
                                    .environment(\.locale, Locale(identifier: "zh_CN"))
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("移植时胚胎天数 (1-7天)")
                                    .font(.headline)
                                    .foregroundColor(Color.gray)
                                Picker("胚胎天数", selection: $viewModel.ivfEmbryoAge) {
                                    ForEach(1..<8) { day in
                                        Text("第 \(day) 天").tag(day)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color("pt_color_primary"))
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(.horizontal) // Apply horizontal padding to the group containing date pickers

                // 计算方式选择 (移到日期选择器下方)
                VStack(alignment: .leading, spacing: 8) {
                    Text("预产期计算方式")
                        .font(.headline)
                        .foregroundColor(Color.gray)

                    Picker("计算方式", selection: $viewModel.calculationMethod) {
                        Text("末次月经").tag(PregnancyCalculationMethod.lmp)
                        Text("B超").tag(PregnancyCalculationMethod.ultrasound)
                        Text("试管婴儿").tag(PregnancyCalculationMethod.ivf)
                    }
                    .pickerStyle(.segmented)
                    .tint(Color("pt_color_primary"))
                    .onChange(of: viewModel.calculationMethod, initial: false) { _, newValue in
                        if newValue == .ultrasound {
                            // 当切换到B超计算方式时，重置B超选择状态
                            viewModel.resetUltrasoundSelectionState()
                        }
                    }
                }
                .padding(.horizontal)

                // 多胎妊娠选择
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("多胎妊娠", isOn: $viewModel.isMultiplePregnancy)
                        .font(.headline)
                        .tint(Color("pt_color_primary"))

                    if viewModel.isMultiplePregnancy {
                        VStack(alignment: .leading, spacing: 8) {
                             Text("胎儿数量 (2-10个)")
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                            Picker("胎儿数量", selection: $viewModel.fetusCount) {
                                ForEach(2..<11) { count in
                                    Text("\(count) 个").tag(count)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color("pt_color_primary"))
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray6).opacity(0.7))
                .cornerRadius(10)
                .padding(.horizontal)

                // 按钮组
                VStack(spacing: 15) {
                    Button(action: {
                        Task {
                            if viewModel.pregnancyInfo == nil {
                                await viewModel.createPregnancyInfo()
                            } else {
                                await viewModel.updatePregnancyInfo()
                            }
                        }
                    }) {
                        Text(viewModel.pregnancyInfo == nil ? "创建新记录" : "确认更新")
                            .fontWeight(.semibold)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("pt_color_primary"))
                            .cornerRadius(12)
                            .shadow(color: Color("pt_color_primary").opacity(0.4), radius: 5, y: 3)
                    }
                    .disabled(viewModel.isLoading)

                    if viewModel.pregnancyInfo != nil {
                        Button("取消编辑") {
                            viewModel.showLMPInput = false
                        }
                        .fontWeight(.semibold)
                        .font(.headline)
                        .foregroundColor(Color("pt_color_primary"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Material.thin)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("pt_color_primary").opacity(0.5), lineWidth: 1)
                        )
                    }
                }
                .padding()

                if let errorText = viewModel.error, !errorText.isEmpty {
                    Text(errorText)
                        .font(.callout)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.bottom, 30)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        // .onTapGesture {
        //     UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        // }
    }

    // 获取胎儿发育信息
    private func getFetalDevelopmentInfo(forWeek week: Int) -> String {
        switch week {
        case 0:
            return "受精卵可能刚刚着床，一个全新的生命故事正在悄悄书写。请放松心情，耐心期待。"
        case 1...4:
            return "胚胎正在形成，开始发育成为胎儿。这个阶段，胎儿的主要器官系统开始形成。"
        case 5...8:
            return "胎儿的心脏开始跳动，四肢开始形成，面部特征开始显现。神经管正在闭合，这将发育成大脑和脊髓。"
        case 9...12:
            return "胎儿的所有器官系统都已形成，现在开始生长和发育。指甲已经开始生长，皮肤变得更加透明，可以看到下面的血管。"
        case 13...16:
            return "胎儿的骨骼开始钙化，肌肉系统发育，可以开始做出简单的动作。胎儿的性别特征开始明显。"
        case 17...20:
            return "胎儿的听力开始发育，可以听到妈妈的心跳和声音。皮肤上开始出现胎脂，这是一种保护皮肤的物质。"
        case 21...24:
            return "胎儿的肺部开始发育，为出生后的呼吸做准备。胎儿的眼睛可以睁开和闭合，开始形成睡眠和觉醒的周期。"
        case 25...28:
            return "胎儿的大脑发育迅速，神经系统变得更加复杂。胎儿开始储存脂肪，皮肤变得不那么透明。"
        case 29...32:
            return "胎儿的肺部继续发育，为出生做准备。胎儿的免疫系统开始发育，从母体获取抗体。"
        case 33...36:
            return "胎儿的大脑和神经系统继续发育。胎儿继续增加体重，为出生做准备。"
        case 37...42:
            return "胎儿已经发育完全，随时可能出生。胎儿的肺部已经成熟，可以在出生后独立呼吸。"
        default:
            return "未知"
        }
    }

    // 获取妈妈变化信息
    private func getMotherChangesInfo(forWeek week: Int) -> String {
        switch week {
        case 0:
            return "现在您可能还没有明显的感觉，身体正在为接下来的奇妙旅程做着细微的准备。保持好心情最重要哦！"
        case 1...4:
            return "你可能会感到疲劳、乳房胀痛和轻微的恶心。这是由于体内激素水平的变化。"
        case 5...8:
            return "晨吐可能会加剧，你可能会对某些气味特别敏感。疲劳感可能会持续，需要更多的休息。"
        case 9...12:
            return "恶心的症状可能会开始缓解，但可能会出现便秘和头痛。你的子宫开始扩大，但腹部可能还不明显。"
        case 13...16:
            return "你可能会感到精力恢复，恶心症状减轻。腹部开始明显隆起，你可能需要穿孕妇装了。"
        case 17...20:
            return "你可能会开始感受到胎动，这是一个令人兴奋的里程碑。你的皮肤可能会变得更加敏感，需要特别护理。"
        case 21...24:
            return "你的腹部继续增大，可能会出现背痛和腿部抽筋。你可能会感到呼吸有些困难，因为子宫压迫了横膈膜。"
        case 25...28:
            return "你可能会出现妊娠纹，这是由于皮肤快速拉伸造成的。你可能会感到更加疲劳，需要更多的休息。"
        case 29...32:
            return "你可能会感到更加不舒服，特别是在睡觉时。你可能会出现脚踝和手部水肿，这是正常的。"
        case 33...36:
            return "你的腹部继续增大，可能会感到呼吸困难和消化不良。你可能会开始感受到假宫缩，这是为分娩做准备。"
        case 37...42:
            return "你已经接近预产期，可能会感到非常不舒服。你可能会注意到分泌物增加，这是为分娩做准备。随时关注分娩征兆。"
        default:
            return "未知"
        }
    }

    // 辅助方法：获取显示的孕周
    private func getDisplayWeek(_ info: PregnancyInfo) -> Int {
        // 检查孕周是否在合理范围内
        if info.currentWeek < 0 || info.currentWeek > 45 {
            // 如果孕周异常，根据预产期重新计算
            let calendar = Calendar.current
            let today = Date()
            let components = calendar.dateComponents([.day], from: today, to: info.dueDate)
            if let daysUntilDueDate = components.day {
                let gestationDays = 280 - daysUntilDueDate
                let week = gestationDays / 7
                return max(0, min(45, week))
            }
            return 0
        }
        return info.currentWeek
    }

    // 辅助方法：获取显示的孕天
    private func getDisplayDay(_ info: PregnancyInfo) -> Int {
        // 检查孕天是否在合理范围内
        if info.currentDay < 0 || info.currentDay > 6 {
            // 如果孕天异常，根据预产期重新计算
            let calendar = Calendar.current
            let today = Date()
            let components = calendar.dateComponents([.day], from: today, to: info.dueDate)
            if let daysUntilDueDate = components.day {
                let gestationDays = 280 - daysUntilDueDate
                let day = gestationDays % 7
                return max(0, min(6, day))
            }
            return 0
        }
        return info.currentDay
    }

    // 辅助方法：获取显示的距离预产期天数
    private func getDisplayDaysUntilDueDate(_ info: PregnancyInfo) -> Int {
        // 检查距离预产期天数是否在合理范围内
        if info.daysUntilDueDate < -100 || info.daysUntilDueDate > 300 {
            // 如果距离预产期天数异常，重新计算
            let calendar = Calendar.current
            let today = Date()
            let components = calendar.dateComponents([.day], from: today, to: info.dueDate)
            return components.day ?? 0
        }
        return info.daysUntilDueDate
    }

    // 辅助方法：获取显示的孕期阶段
    private func getDisplayPregnancyStage(_ info: PregnancyInfo) -> String {
        let week = getDisplayWeek(info)
        if week <= 13 {
            return "早期"
        } else if week <= 27 {
            return "中期"
        } else {
            return "晚期"
        }
    }
}

// MARK: - Custom Button Style
struct PregnancyInfoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack { // 使用 HStack 和 Spacer 来确保文本在按钮内水平居中
            Spacer()
            configuration.label
                .font(.system(size: 17, weight: .medium)) // SF Pro Text, Medium, 17pt
                .foregroundColor(.white) // 白色文字
            Spacer()
        }
        .frame(height: 50) // 设置整个 HStack 的高度
        .background(
            Capsule()
                .fill(configuration.isPressed ? Color("pt_color_modify_button_pressed") : Color("pt_color_modify_button_normal"))
        )
        .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 1.5) // 阴影调整为 Y:1.5pt, blur:3pt, opacity:12%
    }
}

#Preview {
    NavigationView {
        PregnancyTrackerView()
    }
}
