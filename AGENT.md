# 孕期大作战项目指南

## 项目概览

- **项目名称:** 孕期大作战 (PregnancyBattle)
- **平台:** iOS 应用程序
- **核心理念:** 以孕妈妈为中心，提供科学、便捷、温暖的孕期陪伴与指导
- **目标用户:** 孕期女性

## 技术栈

### 前端 (iOS)
- **语言/框架:** Swift (主要使用SwiftUI，结合UIKit)
- **架构模式:** MVVM
- **目录:** `PregnancyBattle/`
- **资源管理:** 遵循`PregnancyBattle/资源管理规范.md`

### 后端
- **语言/框架:** C# ASP.NET Core 8.0
- **架构:** Clean Architecture
- **数据库:** Supabase (PostgreSQL)
- **数据访问:** Dapper, Npgsql
- **认证授权:** JWT, Supabase Auth
- **目录:** `Backend/`

## 重要文档

### 前端文档
- 项目目录结构: `PregnancyBattle/项目目录结构.md`
- 开发计划: `PregnancyBattle/孕期大作战开发计划.md`
- 资源管理规范: `PregnancyBattle/资源管理规范.md`

### 后端文档
- 数据库设计: `Backend/数据库表设计.md`
- 项目架构: `Backend/项目架构文档.md`
- 异常处理: `Backend/全局异常处理文档.md`
- API文档: `Backend/API开发文档.md`
- 开发状态: 目前仅用户认证相关接口已完成，其他接口待开发

## 常用命令

### 前端 (iOS)
- 通过Xcode打开项目: `open PregnancyBattle.xcodeproj`
- 构建项目: 在Xcode中使用快捷键 Cmd+B
- 运行项目: 在Xcode中使用快捷键 Cmd+R
- 测试项目: 在Xcode中使用快捷键 Cmd+U

### 后端 (.NET)
- 构建项目: `dotnet build Backend/PregnancyBattle.Backend.sln`
- 运行项目: `dotnet run --project Backend/src/PregnancyBattle.Api`
- 测试项目: `dotnet test Backend/PregnancyBattle.Backend.sln`

## 代码规范

- 前端遵循Swift官方编码规范
- 后端遵循Clean Architecture架构原则
- 采用MVVM设计模式进行前端开发
- API设计遵循RESTful风格