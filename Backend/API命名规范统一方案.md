
# API命名规范统一方案

## 一、背景

在项目开发过程中，我们发现API路径的命名存在不一致的情况，例如：

- 有些控制器使用大写开头（如`PregnancyInfo`）
- 有些控制器使用小写（如`healthprofile`）
- 有些控制器使用连字符（如`health-profiles`）
- 存在重复的控制器（如`HealthProfileController`和`HealthProfilesController`）

这种不一致性会导致前端调用困难，增加维护成本，并可能引起混淆。因此，我们制定了统一的API命名规范。

## 二、命名规范

为确保API路径的一致性和可维护性，我们采用以下命名规范：

1. **路径全部使用小写字母**：所有API路径均使用小写字母，例如`/users`而非`/Users`
2. **使用连字符分隔多个单词**：当路径包含多个单词时，使用连字符（-）连接，例如`/health-profiles`而非`/healthprofiles`或`/HealthProfiles`
3. **使用复数形式表示资源集合**：资源集合使用复数形式，例如`/users`、`/diaries`、`/health-profiles`
4. **使用名词而非动词**：API路径使用名词表示资源，而非动词表示操作，操作通过HTTP方法（GET、POST、PUT、DELETE）表示
5. **子资源使用嵌套路径**：子资源通过嵌套路径表示，例如`/users/{id}/posts`表示用户的帖子
6. **查询参数使用camelCase**：查询参数使用camelCase命名法，例如`sortDirection`而非`sort_direction`

## 三、实施方案

### 1. 更新API文档

- 在API文档中添加API命名规范章节
- 更新所有API路径，使其符合命名规范

### 2. 更新控制器路由

- 移除`BaseApiController`中的通用路由`[Route("api/[controller]")]`
- 为每个控制器添加显式路由，例如`[Route("api/health-profiles")]`
- 统一使用小写连字符格式

### 3. 更新前端API调用

- 更新所有前端服务中的API调用路径，使其符合命名规范

### 4. 解决重复控制器问题

- 保留`HealthProfilesController`，使用路由`api/health-profiles`
- 移除`HealthProfileController`（待完成）

## 四、已完成的更改

### 1. API文档更新

- 添加了API命名规范章节
- 更新了所有API路径，使其符合命名规范

### 2. 控制器路由更新

- 移除了`BaseApiController`中的通用路由
- 更新了`PregnancyInfoController`的路由为`api/pregnancy-info`
- 更新了`HealthProfilesController`的路由为`api/health-profiles`

### 3. 前端API调用更新

- 更新了`PregnancyInfoService.swift`中的API调用路径
- 更新了`HealthProfileService.swift`中的API调用路径

## 五、待完成的工作

1. 移除重复的`HealthProfileController`控制器
2. 更新其他控制器的路由（如有）
3. 更新单元测试中的API调用路径（如有）
4. 更新前端其他服务中的API调用路径（如有）

## 六、注意事项

1. 在更新API路径时，需要确保前后端同步更新，避免出现调用错误
2. 对于已经上线的API，需要考虑向后兼容性，可以保留旧路径一段时间，并在新版本中完全移除
3. 在API文档中明确标注API路径的变更，方便前端开发人员进行调整
