import SwiftUI

/// 日记主视图
/// 作为日记模块的入口，包含日记列表和筛选功能
struct DiaryView: View {
    @StateObject private var viewModel = DiaryViewModel()
    @State private var showingFilterSheet = false

    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                // 统一的滚动视图
                ScrollView {
                    VStack(spacing: 0) {
                        // 筛选栏
                        filterBar

                        // 日记列表内容
                        diaryListContentScrollable
                    }
                }
                .refreshable {
                    await viewModel.refreshDiaries()
                }
            }
            .navigationTitle("我的日记")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showingCreateDiary = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.primary)
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingFilterSheet = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreateDiary) {
                CreateDiaryView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingFilterSheet) {
                DiaryFilterView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingDiaryDetail) {
                if let diary = viewModel.selectedDiary {
                    DiaryDetailView(diary: diary, viewModel: viewModel)
                }
            }
            .alert("错误", isPresented: .constant(viewModel.error != nil)) {
                if let error = viewModel.error, error.contains("登录已过期") {
                    Button("重新登录") {
                        // 清除错误并导航到登录页面
                        viewModel.clearError()
                        // 这里可以通过通知或其他方式触发导航到登录页面
                        NotificationCenter.default.post(name: NSNotification.Name("ShowLoginView"), object: nil)
                    }
                    Button("取消", role: .cancel) {
                        viewModel.clearError()
                    }
                } else {
                    Button("确定") {
                        viewModel.clearError()
                    }
                }
            } message: {
                if let error = viewModel.error {
                    Text(error)
                }
            }
            .onAppear {
                Task {
                    await viewModel.initialLoad()
                }
            }
        }
    }

    // MARK: - 筛选栏

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // 情绪筛选
                if let mood = viewModel.selectedMoodFilter {
                    FilterChip(
                        title: mood.emoji + " " + mood.displayName,
                        isSelected: true,
                        onTap: {
                            showingFilterSheet = true
                        },
                        onRemove: {
                            Task {
                                await viewModel.setMoodFilter(nil)
                            }
                        }
                    )
                }

                // 标签筛选
                ForEach(Array(viewModel.selectedTagFilters), id: \.self) { tag in
                    FilterChip(
                        title: "#\(tag)",
                        isSelected: true,
                        onTap: {
                            showingFilterSheet = true
                        },
                        onRemove: {
                            Task {
                                await viewModel.removeTagFilter(tag)
                            }
                        }
                    )
                }

                // 日期范围筛选
                if viewModel.startDateFilter != nil || viewModel.endDateFilter != nil {
                    FilterChip(
                        title: "日期筛选",
                        isSelected: true,
                        onTap: {
                            showingFilterSheet = true
                        },
                        onRemove: {
                            Task {
                                await viewModel.setDateRangeFilter(startDate: nil, endDate: nil)
                            }
                        }
                    )
                }

                // 如果有筛选条件，显示清除按钮
                if viewModel.selectedMoodFilter != nil ||
                   !viewModel.selectedTagFilters.isEmpty ||
                   viewModel.startDateFilter != nil {
                    Button("清除筛选") {
                        Task {
                            await viewModel.clearFilters()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    // MARK: - 日记列表内容

    private var diaryListContentScrollable: some View {
        Group {
            if viewModel.isLoading && viewModel.diaries.isEmpty {
                // 加载状态
                VStack(spacing: 16) {
                    ProgressView()
                    Text("加载中...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 200)
            } else if viewModel.diaries.isEmpty {
                // 空状态
                VStack(spacing: 16) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)

                    Text("还没有日记")
                        .font(.title2)
                        .fontWeight(.medium)

                    Text("记录你的孕期点滴，留下美好回忆")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button("写第一篇日记") {
                        viewModel.showingCreateDiary = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 300)
                .padding()
            } else {
                // 使用DiaryListView来显示日记列表，避免重复定义
                DiaryListView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - 筛选标签组件

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            // 主要内容区域 - 点击进入筛选界面
            Button(action: onTap) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }

            // 删除按钮 - 点击清除筛选
            if isSelected {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.blue : Color(.systemGray5))
        )
    }
}

// MARK: - 预览

#Preview {
    DiaryView()
}
