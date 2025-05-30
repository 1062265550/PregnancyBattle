import SwiftUI

/// 日记筛选视图
/// 提供多种筛选选项，包括情绪、标签、日期范围等
struct DiaryFilterView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @Environment(\.dismiss) private var dismiss

    // 临时筛选状态
    @State private var tempMoodFilter: MoodType?
    @State private var tempTagFilters: Set<String> = []
    @State private var tempStartDate: Date?
    @State private var tempEndDate: Date?
    @State private var tempSortBy: String = "diaryDate"
    @State private var tempSortDirection: String = "desc"

    // UI状态
    @State private var showingDatePicker = false
    @State private var datePickerType: DatePickerType = .start

    enum DatePickerType {
        case start
        case end
    }

    var body: some View {
        NavigationView {
            Form {
                // 情绪筛选
                moodFilterSection

                // 标签筛选
                tagFilterSection

                // 日期范围筛选
                dateRangeSection

                // 排序选项
                sortingSection

                // 操作按钮
                actionSection
            }
            .navigationTitle("筛选日记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("应用") {
                        applyFilters()
                    }
                }
            }
            .onAppear {
                loadCurrentFilters()
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(
                title: datePickerType == .start ? "选择开始日期" : "选择结束日期",
                selectedDate: Binding(
                    get: {
                        if datePickerType == .start {
                            return tempStartDate ?? Date()
                        } else {
                            return tempEndDate ?? Date()
                        }
                    },
                    set: { newDate in
                        if datePickerType == .start {
                            tempStartDate = newDate
                        } else {
                            tempEndDate = newDate
                        }
                    }
                ),
                minimumDate: datePickerType == .end ? tempStartDate : nil,
                maximumDate: datePickerType == .start ? tempEndDate ?? Date() : Date()
            )
        }
    }

    // MARK: - 情绪筛选部分

    private var moodFilterSection: some View {
        Section("按情绪筛选") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(MoodType.allCases, id: \.self) { mood in
                    MoodFilterButton(
                        mood: mood,
                        isSelected: tempMoodFilter == mood
                    ) {
                        tempMoodFilter = tempMoodFilter == mood ? nil : mood
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - 标签筛选部分

    private var tagFilterSection: some View {
        Section("按标签筛选") {
            if viewModel.allTags.isEmpty {
                Text("暂无标签")
                    .foregroundColor(.secondary)
                    .font(.caption)
            } else {
                VStack(spacing: 8) {
                    // 使用 VStack 和 HStack 的组合来替代 LazyVGrid
                    let tagChunks = viewModel.allTags.chunked(into: 3)
                    ForEach(Array(tagChunks.enumerated()), id: \.offset) { index, tagRow in
                        HStack(spacing: 8) {
                            ForEach(tagRow, id: \.self) { tag in
                                TagFilterButton(
                                    tag: tag,
                                    isSelected: tempTagFilters.contains(tag)
                                ) {
                                    if tempTagFilters.contains(tag) {
                                        tempTagFilters.remove(tag)
                                    } else {
                                        tempTagFilters.insert(tag)
                                    }
                                }
                            }
                            // 填充剩余空间
                            if tagRow.count < 3 {
                                ForEach(0..<(3 - tagRow.count), id: \.self) { _ in
                                    Spacer()
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }

    // MARK: - 日期范围筛选部分

    private var dateRangeSection: some View {
        Section("按日期范围筛选") {
            // 开始日期
            HStack {
                Text("开始日期")
                Spacer()
                Button(action: {
                    datePickerType = .start
                    showingDatePicker = true
                }) {
                    Text(tempStartDate != nil ? formatDate(tempStartDate!) : "选择日期")
                        .foregroundColor(tempStartDate != nil ? .primary : .secondary)
                }
            }

            // 结束日期
            HStack {
                Text("结束日期")
                Spacer()
                Button(action: {
                    datePickerType = .end
                    showingDatePicker = true
                }) {
                    Text(tempEndDate != nil ? formatDate(tempEndDate!) : "选择日期")
                        .foregroundColor(tempEndDate != nil ? .primary : .secondary)
                }
            }

            // 清除日期筛选
            if tempStartDate != nil || tempEndDate != nil {
                Button("清除日期筛选") {
                    tempStartDate = nil
                    tempEndDate = nil
                }
                .foregroundColor(.red)
            }
        }
    }

    // MARK: - 排序选项部分

    private var sortingSection: some View {
        Section("排序方式") {
            // 排序字段
            Picker("排序字段", selection: $tempSortBy) {
                Text("日记日期").tag("diaryDate")
                Text("创建时间").tag("createdAt")
            }
            .pickerStyle(SegmentedPickerStyle())

            // 排序方向
            Picker("排序方向", selection: $tempSortDirection) {
                Text("最新在前").tag("desc")
                Text("最旧在前").tag("asc")
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }

    // MARK: - 操作按钮部分

    private var actionSection: some View {
        Section {
            Button("清除所有筛选") {
                clearAllFilters()
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    // MARK: - Helper Methods

    private func loadCurrentFilters() {
        tempMoodFilter = viewModel.selectedMoodFilter
        tempTagFilters = viewModel.selectedTagFilters
        tempStartDate = viewModel.startDateFilter
        tempEndDate = viewModel.endDateFilter
        tempSortBy = viewModel.sortBy
        tempSortDirection = viewModel.sortDirection
    }

    private func applyFilters() {
        Task {
            // 应用多个筛选条件
            await viewModel.setMultipleFilters(
                mood: tempMoodFilter,
                tags: tempTagFilters,
                startDate: tempStartDate,
                endDate: tempEndDate
            )

            // 应用排序
            await viewModel.setSorting(sortBy: tempSortBy, sortDirection: tempSortDirection)
        }
        dismiss()
    }

    private func clearAllFilters() {
        tempMoodFilter = nil
        tempTagFilters.removeAll()
        tempStartDate = nil
        tempEndDate = nil
        tempSortBy = "diaryDate"
        tempSortDirection = "desc"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

// MARK: - 情绪筛选按钮

private struct MoodFilterButton: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(mood.emoji)
                    .font(.title3)

                Text(mood.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
            .foregroundColor(isSelected ? .blue : .primary)
        }
        .buttonStyle(PlainButtonStyle()) // 添加这行来确保按钮样式正确
    }
}

// MARK: - 标签筛选按钮

private struct TagFilterButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("#\(tag)")
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.blue : Color(.systemGray6))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle()) // 添加这行来确保按钮样式正确
    }
}

// MARK: - 日期选择器

private struct DatePickerSheet: View {
    let title: String
    @Binding var selectedDate: Date
    let minimumDate: Date?
    let maximumDate: Date?
    @Environment(\.dismiss) private var dismiss
    @State private var internalDate: Date

    init(title: String, selectedDate: Binding<Date>, minimumDate: Date? = nil, maximumDate: Date? = nil) {
        self.title = title
        self._selectedDate = selectedDate
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self._internalDate = State(initialValue: selectedDate.wrappedValue)
    }

    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    title,
                    selection: $internalDate,
                    in: dateRange,
                    displayedComponents: .date
                )
                .datePickerStyle(WheelDatePickerStyle())
                .environment(\.locale, Locale(identifier: "zh_CN"))
                .padding()

                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        selectedDate = internalDate
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            internalDate = selectedDate
        }
    }

    private var dateRange: ClosedRange<Date> {
        let start = minimumDate ?? Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let end = maximumDate ?? Date()
        return start...end
    }
}

// MARK: - 预览

#Preview {
    DiaryFilterView(viewModel: DiaryViewModel())
}

// MARK: - Array Extension

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
