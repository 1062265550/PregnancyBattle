# 孕期大作战 - AI增强健康风险评估功能

## 功能概述

本项目集成了DeepSeek AI服务，为健康风险评估功能提供智能分析和个性化建议。AI增强功能可以基于用户的健康档案数据，生成专业的医疗分析和个性化的健康管理建议。

## 主要特性

### 1. AI智能分析
- **整体健康评估**: 基于用户完整健康档案的综合分析
- **详细分析报告**: 对每个健康指标进行深入分析
- **风险评分**: 1-10分的量化风险评估
- **风险等级**: 低/中/高三级风险分类

### 2. 个性化建议
- **分类专项建议**: 营养、运动、生活方式等分类指导
- **具体行动计划**: 可执行的具体建议
- **优先级排序**: 高/中/低优先级建议
- **监测指导**: 需要关注的健康指标
- **警告信号**: 需要立即就医的症状

### 3. 智能提示词系统
- **专业医疗背景**: 基于妇产科专业知识
- **个性化分析**: 根据具体健康数据定制
- **结构化输出**: 标准JSON格式响应
- **容错处理**: AI服务不可用时的备用方案

## 技术架构

### 后端实现

#### 1. 服务层架构
```
IDeepSeekService (接口)
├── GenerateHealthRiskAnalysisAsync() - 生成健康风险分析
├── GeneratePersonalizedRecommendationsAsync() - 生成个性化建议
└── IsServiceAvailableAsync() - 检查服务可用性

DeepSeekService (实现)
├── CallDeepSeekApiAsync() - 调用AI API
├── BuildHealthAnalysisPrompt() - 构建分析提示词
├── BuildRecommendationsPrompt() - 构建建议提示词
├── ParseHealthAnalysisResponse() - 解析分析响应
└── ParseRecommendationsResponse() - 解析建议响应
```

#### 2. 数据模型扩展
```
RiskAssessmentDto (扩展)
├── 原有字段 (BMI、年龄、医疗风险、基础建议)
├── AiAnalysis (AI分析结果)
├── PersonalizedRecommendations (个性化建议)
└── IsAiEnhanced (AI增强标识)
```

#### 3. 配置管理
```json
{
  "DeepSeek": {
    "ApiKey": "your-api-key",
    "BaseUrl": "https://api.deepseek.com/v1",
    "Enabled": true,
    "TimeoutSeconds": 30,
    "MaxRetries": 3
  }
}
```

### 前端实现

#### 1. 模型定义
- `HealthRiskAnalysis`: AI分析结果模型
- `DetailedAnalysis`: 详细分析项模型
- `PersonalizedRecommendations`: 个性化建议模型
- `CategoryRecommendation`: 分类建议模型

#### 2. UI组件
- `EnhancedRiskAssessmentView`: 增强风险评估视图
- 支持选项卡切换（AI分析/基础评估/个性化建议）
- 响应式设计，适配不同屏幕尺寸

## 使用指南

### 1. API调用示例

#### 获取增强风险评估
```http
GET /api/health-profiles/risk-assessment
Authorization: Bearer {token}
```

#### 响应示例
```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "bmiCategory": "正常",
    "bmiRisk": "体重正常，请保持均衡饮食和适量运动。",
    "ageRisk": "年龄在正常范围内。",
    "medicalRisks": [],
    "recommendations": [...],
    "aiAnalysis": {
      "overallAssessment": "您的整体健康状况良好...",
      "detailedAnalyses": [...],
      "comprehensiveRecommendation": "建议继续保持...",
      "riskScore": 3,
      "riskLevel": "低"
    },
    "personalizedRecommendations": {
      "categoryRecommendations": [...],
      "dietPlan": "建议每日摄入...",
      "exercisePlan": "推荐进行...",
      "lifestyleAdjustments": "保持规律作息...",
      "monitoringAdvice": "定期监测体重...",
      "warningSignsToWatch": ["异常出血", "剧烈腹痛"]
    },
    "isAiEnhanced": true
  }
}
```

### 2. 测试接口

#### 测试AI服务状态
```http
GET /api/test/deepseek-status
Authorization: Bearer {token}
```

#### 测试AI分析
```http
POST /api/test/ai-analysis
Authorization: Bearer {token}
Content-Type: application/json

{
  "height": 165,
  "prePregnancyWeight": 55,
  "currentWeight": 58,
  "bloodType": "A+",
  "age": 28,
  "medicalHistory": null,
  "familyHistory": null,
  "allergiesHistory": null,
  "obstetricHistory": null,
  "isSmoking": false,
  "isDrinking": false,
  "currentWeek": 20
}
```

### 3. 前端集成

#### 使用增强风险评估视图
```swift
import SwiftUI

struct HealthProfileView: View {
    @State private var riskAssessment: RiskAssessment?
    
    var body: some View {
        VStack {
            if let assessment = riskAssessment {
                if assessment.isAiEnhanced {
                    EnhancedRiskAssessmentView(riskAssessment: assessment)
                } else {
                    RiskAssessmentView(riskAssessment: assessment)
                }
            }
        }
        .onAppear {
            loadRiskAssessment()
        }
    }
    
    private func loadRiskAssessment() {
        Task {
            do {
                riskAssessment = try await HealthProfileService.shared.getRiskAssessment()
            } catch {
                print("加载风险评估失败: \(error)")
            }
        }
    }
}
```

## 配置说明

### 1. 环境变量
- `DEEPSEEK_API_KEY`: DeepSeek API密钥
- `DEEPSEEK_BASE_URL`: API基础URL（可选）
- `DEEPSEEK_ENABLED`: 是否启用AI功能（可选）

### 2. 依赖注入配置
```csharp
// Program.cs
builder.Services.AddHttpClient<IDeepSeekService, DeepSeekService>();
```

### 3. 服务配置
```csharp
// HealthProfileService构造函数
public HealthProfileService(
    IHealthProfileRepository healthProfileRepository,
    IPregnancyInfoRepository pregnancyInfoRepository,
    IMapper mapper,
    IDeepSeekService deepSeekService) // 新增AI服务依赖
```

## 错误处理

### 1. AI服务不可用
- 自动降级到基础评估功能
- 返回预设的备用建议
- 记录错误日志但不影响用户体验

### 2. API调用失败
- 重试机制（最多3次）
- 超时处理（30秒）
- 优雅降级到基础功能

### 3. 响应解析失败
- JSON解析容错
- 备用数据结构
- 错误信息记录

## 性能优化

### 1. 缓存策略
- 相同健康档案的分析结果缓存
- 避免重复API调用
- 缓存过期时间设置

### 2. 异步处理
- 非阻塞API调用
- 后台任务处理
- 用户体验优先

### 3. 资源管理
- HTTP客户端复用
- 连接池管理
- 内存使用优化

## 安全考虑

### 1. 数据隐私
- 健康数据加密传输
- 不存储敏感信息到AI服务
- 遵循数据保护法规

### 2. API安全
- API密钥安全存储
- 请求签名验证
- 访问频率限制

### 3. 错误信息
- 不暴露内部错误详情
- 用户友好的错误提示
- 安全的日志记录

## 监控和维护

### 1. 性能监控
- API调用成功率
- 响应时间统计
- 错误率监控

### 2. 质量保证
- AI响应质量评估
- 用户反馈收集
- 持续优化改进

### 3. 版本管理
- API版本兼容性
- 功能开关控制
- 渐进式发布

## 未来扩展

### 1. 功能增强
- 多语言支持
- 更多AI模型集成
- 实时健康监测

### 2. 数据分析
- 用户行为分析
- 健康趋势预测
- 个性化推荐优化

### 3. 集成扩展
- 第三方健康设备
- 医疗机构对接
- 家庭医生服务
