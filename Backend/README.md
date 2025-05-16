# 孕期大作战后端服务

这是"孕期大作战"iOS应用的后端服务，使用ASP.NET Core和Supabase构建。

## 项目结构

项目采用Clean Architecture（整洁架构）设计，分为以下几层：

- **API层**：处理HTTP请求和响应
- **应用层**：业务逻辑和用例
- **领域层**：核心业务模型和规则
- **基础设施层**：数据访问、外部服务集成等

```
PregnancyBattle.Backend/
├── src/
│   ├── PregnancyBattle.Api/              # API层
│   │   ├── Controllers/                  # API控制器
│   │   ├── Middlewares/                  # 中间件
│   │   ├── Filters/                      # 过滤器
│   │   └── Program.cs                    # 应用入口
│   ├── PregnancyBattle.Application/      # 应用层
│   │   ├── Services/                     # 应用服务
│   │   ├── DTOs/                         # 数据传输对象
│   │   ├── Validators/                   # 请求验证器
│   │   └── Mappings/                     # 对象映射配置
│   ├── PregnancyBattle.Domain/           # 领域层
│   │   ├── Entities/                     # 领域实体
│   │   ├── Repositories/                 # 仓储接口
│   │   ├── Services/                     # 领域服务
│   │   └── Exceptions/                   # 领域异常
│   └── PregnancyBattle.Infrastructure/   # 基础设施层
│       ├── Data/                         # 数据访问
│       │   ├── Repositories/             # 仓储实现
│       │   ├── Contexts/                 # 数据上下文
│       │   └── Scripts/                  # 数据库脚本
│       ├── Services/                     # 外部服务集成
│       │   ├── Supabase/                 # Supabase集成
│       │   └── FileStorage/              # 文件存储服务
│       └── Logging/                      # 日志配置
└── tests/                                # 测试项目
    ├── PregnancyBattle.Api.Tests/        # API测试
    ├── PregnancyBattle.Application.Tests/ # 应用层测试
    └── PregnancyBattle.Infrastructure.Tests/ # 基础设施层测试
```

## 技术栈

- **ASP.NET Core 8.0**：Web API框架
- **Supabase**：数据库和认证服务
- **PostgreSQL**：关系型数据库
- **Dapper**：轻量级ORM
- **AutoMapper**：对象映射
- **FluentValidation**：请求验证
- **Swagger/OpenAPI**：API文档

## 开发环境设置

### 前提条件

- .NET 8.0 SDK
- Visual Studio 2022或Visual Studio Code
- Supabase账号

### 配置步骤

1. 克隆仓库
2. 在Supabase中创建项目
3. 更新`appsettings.json`中的连接字符串和密钥
4. 运行SQL脚本创建数据库表
5. 构建并运行项目

```bash
# 构建项目
dotnet build

# 运行项目
dotnet run --project src/PregnancyBattle.Api/PregnancyBattle.Api.csproj
```

## API端点

API文档可通过Swagger UI访问：`https://localhost:5001/swagger`

主要API端点包括：

- `/api/users`：用户管理
- `/api/pregnancyinfo`：孕期信息
- `/api/diaries`：日记管理
- `/api/healthprofile`：健康档案

## 数据库设计

数据库设计包括以下主要表：

- `users`：用户信息
- `pregnancy_info`：孕期信息
- `user_health_profiles`：用户健康档案
- `diaries`：日记
- `diary_tags`：日记标签
- `diary_media`：日记媒体文件
- `weight_records`：体重记录
- `fetal_movement_records`：胎动记录
- `contraction_records`：宫缩记录
- `prenatal_care_plans`：产检计划
- `prenatal_care_results`：产检结果
- `todo_items`：待办事项
- `pregnancy_guides`：孕期指南内容
- `knowledge_articles`：孕育知识百科
- `community_posts`：社区帖子
- `community_comments`：社区评论
- `community_likes`：社区点赞
- `user_notifications`：用户通知

## 安全性

- 使用JWT进行API认证
- 实现基于角色的访问控制
- 使用HTTPS加密传输
- 敏感数据加密存储
- 实现行级安全策略（RLS）

## 贡献指南

1. Fork仓库
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建Pull Request

## 许可证

[MIT](LICENSE)