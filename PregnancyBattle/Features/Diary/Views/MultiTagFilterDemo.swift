import SwiftUI

/// 多标签筛选功能演示视图
struct MultiTagFilterDemo: View {
    @StateObject private var viewModel = DiaryViewModel()
    @State private var showingFilterSheet = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题
                Text("多标签筛选功能演示")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()

                // 当前选中的标签显示
                VStack(alignment: .leading, spacing: 10) {
                    Text("当前选中的标签:")
                        .font(.headline)

                    if viewModel.selectedTagFilters.isEmpty {
                        Text("无选中标签")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(viewModel.selectedTagFilters), id: \.self) { tag in
                                    DemoTagChip(
                                        text: "#\(tag)",
                                        isSelected: true,
                                        onRemove: {
                                            Task {
                                                await viewModel.removeTagFilter(tag)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // 可用标签列表
                VStack(alignment: .leading, spacing: 10) {
                    Text("可用标签 (点击添加/移除):")
                        .font(.headline)

                    let availableTags = ["开心", "期待", "紧张", "兴奋", "担心", "感动", "疲惫", "幸福"]

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(availableTags, id: \.self) { tag in
                            DemoTagChip(
                                text: "#\(tag)",
                                isSelected: viewModel.selectedTagFilters.contains(tag),
                                onTap: {
                                    Task {
                                        await viewModel.toggleTagFilter(tag)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // 操作按钮
                VStack(spacing: 12) {
                    Button("清除所有标签") {
                        Task {
                            await viewModel.setTagFilters([])
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.selectedTagFilters.isEmpty)

                    Button("添加示例标签") {
                        Task {
                            await viewModel.setTagFilters(["开心", "期待", "幸福"])
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("打开筛选面板") {
                        showingFilterSheet = true
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                // 说明文字
                Text("这个演示展示了多标签筛选功能。您可以选择多个标签，系统会筛选出包含任意一个或多个选中标签的日记。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()
            .navigationTitle("多标签筛选")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingFilterSheet) {
            DiaryFilterView(viewModel: viewModel)
        }
    }
}

/// 演示标签芯片组件
struct DemoTagChip: View {
    let text: String
    let isSelected: Bool
    var onTap: (() -> Void)? = nil
    var onRemove: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
                .fontWeight(.medium)

            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.blue : Color(.systemGray5))
        )
        .foregroundColor(isSelected ? .white : .primary)
        .onTapGesture {
            onTap?()
        }
    }
}

#Preview {
    MultiTagFilterDemo()
}
