# 日记模块 API 对接文档

## 概述

本文档描述了孕期大作战iOS应用中日记模块与后端API的对接实现。已成功对接前5个日记相关API接口，提供完整的日记管理功能。

## 已实现的API接口

### 1. 创建日记 ✅
- **接口**: `POST /api/diaries`
- **功能**: 创建新的日记条目
- **实现**: `DiaryService.createDiary(request:)`
- **支持功能**:
  - 标题和内容输入
  - 情绪选择（7种情绪类型）
  - 日期选择
  - 标签管理
  - 媒体文件上传（预留接口）

### 2. 获取日记详情 ✅
- **接口**: `GET /api/diaries/{id}`
- **功能**: 获取指定ID的日记详情
- **实现**: `DiaryService.getDiary(diaryId:)`
- **支持功能**:
  - 完整日记内容展示
  - 情绪和标签显示
  - 媒体文件列表
  - 创建和修改时间

### 3. 获取用户所有日记 ✅
- **接口**: `GET /api/diaries`
- **功能**: 分页获取当前用户的所有日记
- **实现**: `DiaryService.getUserDiaries(page:pageSize:sortBy:sortDirection:)`
- **支持功能**:
  - 分页加载
  - 排序选项（按日期/创建时间）
  - 下拉刷新
  - 无限滚动加载

### 4. 根据日期范围获取日记 ✅
- **接口**: `GET /api/diaries/date-range`
- **功能**: 根据指定日期范围筛选日记
- **实现**: `DiaryService.getDiariesByDateRange(startDate:endDate:...)`
- **支持功能**:
  - 灵活的日期范围选择
  - 与分页功能结合
  - 日期选择器UI

### 5. 根据标签获取日记 ✅
- **接口**: `GET /api/diaries/tag/{tag}`
- **功能**: 根据标签筛选日记
- **实现**: `DiaryService.getDiariesByTag(tag:...)`
- **支持功能**:
  - 标签筛选
  - URL编码处理
  - 标签管理界面

### 6. 根据情绪获取日记 ✅
- **接口**: `GET /api/diaries/mood/{mood}`
- **功能**: 根据情绪筛选日记
- **实现**: `DiaryService.getDiariesByMood(mood:...)`
- **支持功能**:
  - 情绪筛选（7种情绪类型）
  - 分页支持
  - 排序选项

### 7. 更新日记 ✅
- **接口**: `PUT /api/diaries/{id}`
- **功能**: 更新指定ID的日记
- **实现**: `DiaryService.updateDiary(diaryId:request:)`
- **支持功能**:
  - 标题和内容更新
  - 情绪状态修改
  - 日期调整
  - 权限验证

### 8. 删除日记 ✅
- **接口**: `DELETE /api/diaries/{id}`
- **功能**: 删除指定ID的日记
- **实现**: `DiaryService.deleteDiary(diaryId:)`
- **支持功能**:
  - 安全删除验证
  - 权限验证
  - UI确认对话框

### 9. 添加日记标签 ✅
- **接口**: `POST /api/diaries/{id}/tags`
- **功能**: 为指定日记添加标签
- **实现**: `DiaryService.addDiaryTags(diaryId:tags:)`
- **支持功能**:
  - 批量添加标签
  - 标签去重处理
  - 实时UI更新

### 10. 删除日记标签 ✅
- **接口**: `DELETE /api/diaries/{id}/tags/{tag}`
- **功能**: 删除指定日记的指定标签
- **实现**: `DiaryService.deleteDiaryTag(diaryId:tag:)`
- **支持功能**:
  - 单个标签删除
  - URL编码处理
  - 实时UI更新

### 11. 添加日记媒体文件 ✅
- **接口**: `POST /api/diaries/{id}/media`
- **功能**: 为指定日记添加媒体文件
- **实现**: `DiaryService.addDiaryMedia(diaryId:request:)`
- **支持功能**:
  - 支持图片、视频、音频
  - 媒体描述信息
  - 实时UI更新

### 12. 删除日记媒体文件 ✅
- **接口**: `DELETE /api/diaries/{diaryId}/media/{mediaId}`
- **功能**: 删除指定日记的指定媒体文件
- **实现**: `DiaryService.deleteDiaryMedia(diaryId:mediaId:)`
- **支持功能**:
  - 安全删除验证
  - 实时UI更新

## 项目结构

```
PregnancyBattle/Features/Diary/
├── Models/
│   └── Diary.swift                    # 日记相关数据模型
├── Services/
│   └── DiaryService.swift             # 日记API服务层
├── DiaryViewModel.swift               # 日记视图模型
├── Views/
│   ├── DiaryView.swift               # 主日记视图
│   ├── DiaryListView.swift           # 日记列表视图
│   ├── CreateDiaryView.swift         # 创建日记视图
│   ├── DiaryDetailView.swift         # 日记详情视图
│   ├── EditDiaryView.swift           # 编辑日记视图
│   ├── DiaryFilterView.swift         # 筛选视图
│   └── DiaryTestView.swift           # API测试视图
├── DiaryAPITests.swift               # API测试类
└── Diary.xcassets/                   # 日记模块资源文件
```

## 核心功能特性

### 1. 数据模型
- **Diary**: 主日记模型，包含完整的日记信息
- **MoodType**: 情绪枚举，支持7种情绪状态
- **MediaType**: 媒体类型枚举
- **CreateDiaryRequest/UpdateDiaryRequest**: 请求模型
- **PagedDiaryList**: 分页响应模型

### 2. 用户界面
- **现代化设计**: 采用SwiftUI构建，支持iOS 15+
- **响应式布局**: 适配不同屏幕尺寸
- **直观操作**: 简洁的创建和编辑流程
- **丰富筛选**: 支持情绪、标签、日期范围筛选
- **实时反馈**: 加载状态和错误处理

### 3. 性能优化
- **分页加载**: 避免一次性加载大量数据
- **懒加载**: 使用LazyVStack优化列表性能
- **缓存机制**: 合理的数据缓存策略
- **网络优化**: 请求去重和错误重试

## 使用方法

### 1. 基本使用
```swift
// 在MainTabView中已集成
DiaryView()
.tabItem {
    Label("日记", systemImage: "book.closed")
}
```

### 2. API调用示例
```swift
// 创建日记
let request = CreateDiaryRequest(
    title: "今天的心情",
    content: "感觉很好...",
    mood: .happy,
    diaryDate: Date(),
    tags: ["开心", "健康"]
)
let diary = try await DiaryService.shared.createDiary(request: request)

// 获取日记列表
let pagedResult = try await DiaryService.shared.getUserDiaries(
    page: 1,
    pageSize: 10
)
```

### 3. 视图模型使用
```swift
@StateObject private var viewModel = DiaryViewModel()

// 加载日记
await viewModel.loadDiaries()

// 创建日记
await viewModel.createDiary(request: request)

// 筛选日记
await viewModel.setMoodFilter(.happy)
```

## 测试说明

### 1. API测试
- 使用测试账号：用户名 `19991105`，密码 `123456`
- 后端地址：`http://localhost:5094`
- 可通过 `DiaryTestView` 进行API测试

### 2. 测试覆盖
- ✅ 创建日记
- ✅ 获取日记详情
- ✅ 获取日记列表
- ✅ 日期范围筛选
- ✅ 标签筛选
- ✅ 情绪筛选
- ✅ 分页加载
- ✅ 更新日记
- ✅ 删除日记
- ✅ 标签管理（添加/删除）
- ✅ 媒体文件管理（添加/删除）

## 技术要点

### 1. 网络层
- 基于现有的 `APIService` 框架
- 统一的错误处理机制
- 自动的认证token管理
- 请求/响应日志记录

### 2. 数据处理
- JSON编解码使用Codable协议
- 日期格式统一处理
- 枚举类型安全转换
- 可选值合理处理

### 3. 用户体验
- 加载状态指示
- 错误信息友好提示
- 下拉刷新支持
- 无限滚动加载
- 筛选状态可视化

## 后续扩展

### 已完成的API接口
- ✅ 所有12个日记相关API接口已全部对接完成
- ✅ 完整的CRUD操作支持
- ✅ 标签管理功能
- ✅ 媒体文件管理功能
- ✅ 多种筛选和排序方式

### 功能增强
- 富文本编辑器
- 图片/视频上传
- 语音记录
- 日记导出
- 数据统计分析

## 注意事项

1. **认证要求**: 所有API调用都需要有效的JWT token
2. **网络环境**: 确保后端服务运行在 `localhost:5094`
3. **数据格式**: 严格按照API文档的数据格式进行交互
4. **错误处理**: 所有网络请求都包含完整的错误处理逻辑
5. **性能考虑**: 大列表使用分页加载，避免内存问题

## 更新日志

- **v1.0.0** (2024-01-XX): 完成前5个日记API接口对接
  - 创建日记功能
  - 日记列表展示
  - 日记详情查看
  - 多种筛选方式
  - 完整的UI界面

- **v1.1.0** (2024-01-XX): 完成剩余7个日记API接口对接
  - 日记编辑和删除功能
  - 标签管理（添加/删除标签）
  - 媒体文件管理（添加/删除媒体文件）
  - 情绪筛选功能
  - 长按编辑操作
  - 完整的CRUD操作支持
