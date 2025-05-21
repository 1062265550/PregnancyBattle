# 孕期大作战后端API文档

## 一、文档概述

本文档详细描述了"孕期大作战"iOS应用的后端API接口，供前端开发人员进行对接。API服务基于ASP.NET Core框架开发，使用Supabase作为数据库和认证服务。

## 二、API基本信息

- **基础URL**: `https://api.pregnancybattle.com/api` (生产环境)
- **开发环境URL**: `http://localhost:5094/api` (本地开发环境)
- **API版本**: v1
- **数据格式**: JSON
- **认证方式**: Bearer Token (JWT)

## 三、统一响应格式

所有API接口都使用统一的响应格式，包括成功和失败的情况。

### 1. 成功响应格式

```json
{
  "success": true,
  "message": "string", // 可选，成功提示信息
  "data": {} // 可选，响应数据，根据接口不同而不同
}
```

### 2. 失败响应格式

```json
{
  "success": false,
  "message": "string", // 错误消息
  "code": "string" // 可选，错误代码
}
```

### 3. 错误码说明

- 400: 请求参数无效
- 401: 未授权
- 403: 禁止访问
- 404: 资源不存在
- 409: 资源冲突
- 500: 服务器错误

## 四、认证相关API ✅

### 1. 用户注册 ✅

- **URL**: `/users/register`
- **方法**: POST
- **描述**: 注册新用户
- **请求参数**:

```json
{
  "username": "string", // 用户名，必填，3-50个字符
  "email": "string", // 电子邮件，必填，有效的电子邮件格式
  "phoneNumber": "string", // 手机号码，必填，有效的手机号码格式
  "password": "string", // 密码，必填，6-100个字符
  "nickname": "string" // 昵称，选填，最多50个字符
}
```

- **响应**:

```json
{
  "success": true,
  "message": "注册成功",
  "data": {
    "id": "guid", // 用户ID
    "username": "string", // 用户名
    "email": "string", // 电子邮件
    "phoneNumber": "string", // 手机号码
    "nickname": "string", // 昵称
    "avatarUrl": "string", // 头像URL
    "createdAt": "datetime", // 创建时间
    "lastLoginAt": "datetime" // 最后登录时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 409: 用户名或电子邮件已存在

### 2. 用户登录 ✅

- **URL**: `/users/login`
- **方法**: POST
- **描述**: 用户登录
- **请求参数**:

```json
{
  "username": "string", // 用户名/电子邮件/手机号码，必填
  "password": "string" // 密码，必填
}
```

- **响应**:

```json
{
  "success": true,
  "message": "登录成功",
  "data": {
    "accessToken": "string", // 访问令牌
    "refreshToken": "string", // 刷新令牌
    "tokenType": "string", // 令牌类型，固定为"Bearer"
    "expiresIn": "integer", // 过期时间（秒）
    "user": {
      "id": "guid", // 用户ID
      "username": "string", // 用户名
      "email": "string", // 电子邮件
      "phoneNumber": "string", // 手机号码
      "nickname": "string", // 昵称
      "avatarUrl": "string", // 头像URL
      "createdAt": "datetime", // 创建时间
      "lastLoginAt": "datetime" // 最后登录时间
    }
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 用户名或密码错误

### 3. 刷新令牌 ✅

- **URL**: `/users/refresh-token`
- **方法**: POST
- **描述**: 刷新访问令牌
- **请求参数**:

```json
"string" // 刷新令牌
```

- **响应**:

```json
{
  "success": true,
  "message": "令牌刷新成功",
  "data": {
    "accessToken": "string", // 新的访问令牌
    "refreshToken": "string", // 新的刷新令牌
    "tokenType": "string", // 令牌类型，固定为"Bearer"
    "expiresIn": "integer", // 过期时间（秒）
    "user": {
      "id": "guid", // 用户ID
      "username": "string", // 用户名
      "email": "string", // 电子邮件
      "phoneNumber": "string", // 手机号码
      "nickname": "string", // 昵称
      "avatarUrl": "string", // 头像URL
      "createdAt": "datetime", // 创建时间
      "lastLoginAt": "datetime" // 最后登录时间
    }
  }
}
```

- **错误码**:
  - 400: 刷新令牌无效或已过期

### 4. 发送验证码 ✅

- **URL**: `/users/forgot-password/send-code`
- **方法**: POST
- **描述**: 发送验证码到用户邮箱（忘记密码功能）
- **请求参数**:

```json
{
  "email": "string" // 电子邮件，必填，有效的电子邮件格式
}
```

- **响应**:

```json
{
  "success": true,
  "message": "验证码已发送到您的邮箱，请查收",
  "data": {
    "codeExpireTime": "datetime" // 验证码过期时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 404: 用户不存在
  - 500: 发送验证码邮件失败

### 5. 验证验证码 ✅

- **URL**: `/users/forgot-password/verify-code`
- **方法**: POST
- **描述**: 验证用户输入的验证码
- **请求参数**:

```json
{
  "email": "string", // 电子邮件，必填，有效的电子邮件格式
  "code": "string" // 验证码，必填，6位数字
}
```

- **响应**:

```json
{
  "success": true,
  "message": "验证码验证成功",
  "data": {
    "resetToken": "string" // 重置密码令牌，用于重置密码
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 404: 用户不存在
  - 400: 验证码不存在或已过期
  - 400: 验证码错误

### 6. 重置密码 ✅

- **URL**: `/users/forgot-password/reset-password`
- **方法**: POST
- **描述**: 使用重置密码令牌重置密码
- **请求参数**:

```json
{
  "resetToken": "string", // 重置密码令牌，必填
  "newPassword": "string" // 新密码，必填，6-100个字符
}
```

- **响应**:

```json
{
  "success": true,
  "message": "密码重置成功"
}
```

- **错误码**:
  - 400: 请求参数无效
  - 400: 重置密码令牌不存在或已过期
  - 404: 用户不存在

## 五、用户相关API

### 1. 获取当前用户信息 ✅

- **URL**: `/users/me`
- **方法**: GET
- **描述**: 获取当前登录用户的信息
- **请求头**: Authorization: Bearer {accessToken}
- **响应**:

```json
{
  "success": true,
  "data": {
    "id": "guid", // 用户ID
    "username": "string", // 用户名
    "email": "string", // 电子邮件
    "phoneNumber": "string", // 手机号码
    "nickname": "string", // 昵称
    "avatarUrl": "string", // 头像URL
    "createdAt": "datetime", // 创建时间
    "lastLoginAt": "datetime" // 最后登录时间
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 用户不存在

### 2. 更新当前用户信息 ✅

- **URL**: `/users/me`
- **方法**: PUT
- **描述**: 更新当前登录用户的信息
- **请求头**: Authorization: Bearer {accessToken}
- **请求参数**:

```json
{
  "nickname": "string", // 昵称，选填，最多50个字符
  "avatarUrl": "string" // 头像URL，选填，最多500个字符
}
```

- **响应**:

```json
{
  "success": true,
  "message": "更新成功",
  "data": {
    "id": "guid", // 用户ID
    "username": "string", // 用户名
    "email": "string", // 电子邮件
    "phoneNumber": "string", // 手机号码
    "nickname": "string", // 昵称
    "avatarUrl": "string", // 头像URL
    "createdAt": "datetime", // 创建时间
    "lastLoginAt": "datetime" // 最后登录时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 404: 用户不存在

## 六、孕期信息相关API

### 1. 创建孕期信息 ✅

- **URL**: `/pregnancyinfo`
- **方法**: POST
- **描述**: 创建用户的孕期信息
- **请求头**: Authorization: Bearer {accessToken}
- **请求参数**:

```json
{
  "lmpDate": "date", // 末次月经日期，必填，不能晚于今天
  "calculationMethod": "string", // 预产期计算方式，必填，可选值：LMP、Ultrasound、IVF
  "ultrasoundDate": "date", // B超日期，当calculationMethod为Ultrasound时必填，不能晚于今天
  "ultrasoundWeeks": "integer", // B超孕周，当calculationMethod为Ultrasound时必填，0-42周
  "ultrasoundDays": "integer", // B超孕天，当calculationMethod为Ultrasound时必填，0-6天
  "isMultiplePregnancy": "boolean", // 是否多胎妊娠，选填，默认为false
  "fetusCount": "integer" // 胎儿数量，当isMultiplePregnancy为true时必填，2-10个
}
```

- **响应**:

```json
{
  "success": true,
  "message": "孕期信息创建成功",
  "data": {
    "id": "guid", // 孕期信息ID
    "userId": "guid", // 用户ID
    "lmpDate": "date", // 末次月经日期
    "dueDate": "date", // 预产期
    "calculationMethod": "string", // 预产期计算方式
    "ultrasoundDate": "date", // B超日期
    "ultrasoundWeeks": "integer", // B超孕周
    "ultrasoundDays": "integer", // B超孕天
    "isMultiplePregnancy": "boolean", // 是否多胎妊娠
    "fetusCount": "integer", // 胎儿数量
    "currentWeek": "integer", // 当前孕周
    "currentDay": "integer", // 当前孕天
    "pregnancyStage": "string", // 孕期阶段 (早期/中期/晚期)
    "daysUntilDueDate": "integer" // 距离预产期天数
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 409: 用户已有孕期信息

### 2. 获取孕期信息 ✅

- **URL**: `/pregnancyinfo`
- **方法**: GET
- **描述**: 获取当前登录用户的孕期信息
- **请求头**: Authorization: Bearer {accessToken}
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "id": "guid", // 孕期信息ID
    "userId": "guid", // 用户ID
    "lmpDate": "date", // 末次月经日期
    "dueDate": "date", // 预产期
    "calculationMethod": "string", // 预产期计算方式
    "ultrasoundDate": "date", // B超日期
    "ultrasoundWeeks": "integer", // B超孕周
    "ultrasoundDays": "integer", // B超孕天
    "isMultiplePregnancy": "boolean", // 是否多胎妊娠
    "fetusCount": "integer", // 胎儿数量
    "currentWeek": "integer", // 当前孕周
    "currentDay": "integer", // 当前孕天
    "pregnancyStage": "string", // 孕期阶段 (早期/中期/晚期)
    "daysUntilDueDate": "integer" // 距离预产期天数
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 孕期信息不存在

### 3. 更新孕期信息 ✅

- **URL**: `/pregnancyinfo`
- **方法**: PUT
- **描述**: 更新当前登录用户的孕期信息
- **请求头**: Authorization: Bearer {accessToken}
- **请求参数**:

```json
{
  "dueDate": "date", // 预产期，选填，必须晚于今天
  "calculationMethod": "string", // 预产期计算方式，选填，可选值：LMP、Ultrasound、IVF
  "ultrasoundDate": "date", // B超日期，选填，不能晚于今天
  "ultrasoundWeeks": "integer", // B超孕周，选填，0-42周
  "ultrasoundDays": "integer", // B超孕天，选填，0-6天
  "isMultiplePregnancy": "boolean", // 是否多胎妊娠，选填
  "fetusCount": "integer" // 胎儿数量，当isMultiplePregnancy为true时必填，2-10个
}
```

- **响应**:

```json
{
  "success": true,
  "message": "更新成功",
  "data": {
    "id": "guid", // 孕期信息ID
    "userId": "guid", // 用户ID
    "lmpDate": "date", // 末次月经日期
    "dueDate": "date", // 预产期
    "calculationMethod": "string", // 预产期计算方式
    "ultrasoundDate": "date", // B超日期
    "ultrasoundWeeks": "integer", // B超孕周
    "ultrasoundDays": "integer", // B超孕天
    "isMultiplePregnancy": "boolean", // 是否多胎妊娠
    "fetusCount": "integer", // 胎儿数量
    "currentWeek": "integer", // 当前孕周
    "currentDay": "integer", // 当前孕天
    "pregnancyStage": "string", // 孕期阶段 (早期/中期/晚期)
    "daysUntilDueDate": "integer" // 距离预产期天数
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 404: 孕期信息不存在

### 4. 计算当前孕周和孕天 ✅

- **URL**: `/pregnancyinfo/current-week`
- **方法**: GET
- **描述**: 计算当前登录用户的孕周和孕天
- **请求头**: Authorization: Bearer {accessToken}
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "id": "guid", // 孕期信息ID
    "userId": "guid", // 用户ID
    "lmpDate": "date", // 末次月经日期
    "dueDate": "date", // 预产期
    "calculationMethod": "string", // 预产期计算方式
    "ultrasoundDate": "date", // B超日期
    "ultrasoundWeeks": "integer", // B超孕周
    "ultrasoundDays": "integer", // B超孕天
    "isMultiplePregnancy": "boolean", // 是否多胎妊娠
    "fetusCount": "integer", // 胎儿数量
    "currentWeek": "integer", // 当前孕周
    "currentDay": "integer", // 当前孕天
    "pregnancyStage": "string", // 孕期阶段 (早期/中期/晚期)
    "daysUntilDueDate": "integer" // 距离预产期天数
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 孕期信息不存在

## 七、健康档案相关API

### 1. 创建健康档案

- **URL**: `/healthprofile`
- **方法**: POST
- **描述**: 创建用户的健康档案
- **请求头**: Authorization: Bearer {accessToken}
- **请求参数**:

```json
{
  "height": "decimal", // 身高（厘米），必填，100-250厘米
  "prePregnancyWeight": "decimal", // 孕前体重（千克），必填，30-200千克
  "currentWeight": "decimal", // 当前体重（千克），必填，30-200千克
  "bloodType": "string", // 血型，必填，可选值：A、B、AB、O、A+、A-、B+、B-、AB+、AB-、O+、O-
  "age": "integer", // 年龄，必填，18-60岁
  "medicalHistory": "string", // 个人病史，选填
  "familyHistory": "string", // 家族病史，选填
  "allergiesHistory": "string", // 过敏史，选填
  "obstetricHistory": "string", // 既往孕产史，选填
  "isSmoking": "boolean", // 是否吸烟，选填，默认为false
  "isDrinking": "boolean" // 是否饮酒，选填，默认为false
}
```

- **响应**:

```json
{
  "success": true,
  "message": "创建成功",
  "data": {
    "id": "guid", // 健康档案ID
    "userId": "guid", // 用户ID
    "height": "decimal", // 身高（厘米）
    "prePregnancyWeight": "decimal", // 孕前体重（千克）
    "currentWeight": "decimal", // 当前体重（千克）
    "bloodType": "string", // 血型
    "age": "integer", // 年龄
    "medicalHistory": "string", // 个人病史
    "familyHistory": "string", // 家族病史
    "allergiesHistory": "string", // 过敏史
    "obstetricHistory": "string", // 既往孕产史
    "isSmoking": "boolean", // 是否吸烟
    "isDrinking": "boolean", // 是否饮酒
    "createdAt": "datetime", // 创建时间
    "updatedAt": "datetime", // 更新时间
    "bmi": "decimal" // BMI指数
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 409: 用户已有健康档案

### 2. 获取健康档案

- **URL**: `/healthprofile`
- **方法**: GET
- **描述**: 获取当前登录用户的健康档案
- **请求头**: Authorization: Bearer {accessToken}
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "id": "guid", // 健康档案ID
    "userId": "guid", // 用户ID
    "height": "decimal", // 身高（厘米）
    "prePregnancyWeight": "decimal", // 孕前体重（千克）
    "currentWeight": "decimal", // 当前体重（千克）
    "bloodType": "string", // 血型
    "age": "integer", // 年龄
    "medicalHistory": "string", // 个人病史
    "familyHistory": "string", // 家族病史
    "allergiesHistory": "string", // 过敏史
    "obstetricHistory": "string", // 既往孕产史
    "isSmoking": "boolean", // 是否吸烟
    "isDrinking": "boolean", // 是否饮酒
    "createdAt": "datetime", // 创建时间
    "updatedAt": "datetime", // 更新时间
    "bmi": "decimal" // BMI指数
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 健康档案不存在

### 3. 更新健康档案

- **URL**: `/healthprofile`
- **方法**: PUT
- **描述**: 更新当前登录用户的健康档案
- **请求头**: Authorization: Bearer {accessToken}
- **请求参数**:

```json
{
  "height": "decimal", // 身高（厘米），选填，100-250厘米
  "currentWeight": "decimal", // 当前体重（千克），选填，30-200千克
  "bloodType": "string", // 血型，选填，可选值：A、B、AB、O、A+、A-、B+、B-、AB+、AB-、O+、O-
  "medicalHistory": "string", // 个人病史，选填
  "familyHistory": "string", // 家族病史，选填
  "allergiesHistory": "string", // 过敏史，选填
  "obstetricHistory": "string", // 既往孕产史，选填
  "isSmoking": "boolean", // 是否吸烟，选填
  "isDrinking": "boolean" // 是否饮酒，选填
}
```

- **响应**:

```json
{
  "success": true,
  "message": "更新成功",
  "data": {
    "id": "guid", // 健康档案ID
    "userId": "guid", // 用户ID
    "height": "decimal", // 身高（厘米）
    "prePregnancyWeight": "decimal", // 孕前体重（千克）
    "currentWeight": "decimal", // 当前体重（千克）
    "bloodType": "string", // 血型
    "age": "integer", // 年龄
    "medicalHistory": "string", // 个人病史
    "familyHistory": "string", // 家族病史
    "allergiesHistory": "string", // 过敏史
    "obstetricHistory": "string", // 既往孕产史
    "isSmoking": "boolean", // 是否吸烟
    "isDrinking": "boolean", // 是否饮酒
    "createdAt": "datetime", // 创建时间
    "updatedAt": "datetime", // 更新时间
    "bmi": "decimal" // BMI指数
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 404: 健康档案不存在

### 4. 获取体重变化趋势

- **URL**: `/healthprofile/weight-trend`
- **方法**: GET
- **描述**: 获取当前登录用户的体重变化趋势
- **请求头**: Authorization: Bearer {accessToken}
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "weightRecords": [
      {
        "date": "date", // 记录日期
        "weight": "decimal", // 体重（千克）
        "pregnancyWeek": "integer", // 孕周
        "pregnancyDay": "integer" // 孕天
      }
    ],
    "startWeight": "decimal", // 起始体重
    "currentWeight": "decimal", // 当前体重
    "weightGain": "decimal", // 增重
    "recommendedWeightGain": {
      "min": "decimal", // 推荐最小增重
      "max": "decimal" // 推荐最大增重
    }
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 健康档案不存在

### 5. 获取健康风险评估

- **URL**: `/healthprofile/risk-assessment`
- **方法**: GET
- **描述**: 获取当前登录用户的健康风险评估
- **请求头**: Authorization: Bearer {accessToken}
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "bmiCategory": "string", // BMI分类（偏瘦/正常/超重/肥胖）
    "bmiRisk": "string", // BMI风险评估
    "ageRisk": "string", // 年龄风险评估
    "medicalRisks": [
      {
        "type": "string", // 风险类型
        "description": "string", // 风险描述
        "severity": "string" // 严重程度（低/中/高）
      }
    ],
    "recommendations": [
      {
        "category": "string", // 建议类别
        "description": "string" // 建议描述
      }
    ]
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 健康档案不存在

## 七、日记相关API

### 1. 创建日记

- **URL**: `/diaries`
- **方法**: POST
- **描述**: 创建用户的日记
- **请求头**: Authorization: Bearer {accessToken}
- **请求参数**:

```json
{
  "title": "string", // 日记标题，必填，最多100个字符
  "content": "string", // 日记内容，必填
  "mood": "string", // 情绪状态，选填，可选值：Happy、Sad、Angry、Anxious、Excited、Tired、Neutral
  "diaryDate": "date", // 日记日期，必填，不能晚于今天
  "tags": ["string"], // 标签列表，选填
  "mediaFiles": [ // 媒体文件列表，选填
    {
      "mediaType": "string", // 媒体类型，必填，可选值：Image、Video、Audio
      "mediaUrl": "string", // 媒体URL，必填
      "description": "string" // 媒体描述，选填
    }
  ]
}
```

- **响应**:

```json
{
  "success": true,
  "message": "创建成功",
  "data": {
    "id": "guid", // 日记ID
    "userId": "guid", // 用户ID
    "title": "string", // 日记标题
    "content": "string", // 日记内容
    "mood": "string", // 情绪状态
    "diaryDate": "date", // 日记日期
    "pregnancyWeek": "integer", // 孕周
    "pregnancyDay": "integer", // 孕天
    "createdAt": "datetime", // 创建时间
    "updatedAt": "datetime", // 更新时间
    "tags": ["string"], // 标签列表
    "mediaFiles": [ // 媒体文件列表
      {
        "id": "guid", // 媒体文件ID
        "mediaType": "string", // 媒体类型
        "mediaUrl": "string", // 媒体URL
        "description": "string", // 媒体描述
        "createdAt": "datetime" // 创建时间
      }
    ]
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 2. 获取日记

- **URL**: `/diaries/{id}`
- **方法**: GET
- **描述**: 获取指定ID的日记
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 日记ID
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "id": "guid", // 日记ID
    "userId": "guid", // 用户ID
    "title": "string", // 日记标题
    "content": "string", // 日记内容
    "mood": "string", // 情绪状态
    "diaryDate": "date", // 日记日期
    "pregnancyWeek": "integer", // 孕周
    "pregnancyDay": "integer", // 孕天
    "createdAt": "datetime", // 创建时间
    "updatedAt": "datetime", // 更新时间
    "tags": ["string"], // 标签列表
    "mediaFiles": [ // 媒体文件列表
      {
        "id": "guid", // 媒体文件ID
        "mediaType": "string", // 媒体类型
        "mediaUrl": "string", // 媒体URL
        "description": "string", // 媒体描述
        "createdAt": "datetime" // 创建时间
      }
    ]
  }
}
```

- **错误码**:
  - 401: 未授权
  - 403: 禁止访问（尝试访问其他用户的日记）
  - 404: 日记不存在

### 3. 获取用户所有日记

- **URL**: `/diaries`
- **方法**: GET
- **描述**: 获取当前登录用户的所有日记
- **请求头**: Authorization: Bearer {accessToken}
- **查询参数**:
  - page: 页码，默认为1
  - pageSize: 每页数量，默认为10
  - sortBy: 排序字段，可选值：diaryDate、createdAt，默认为diaryDate
  - sortDirection: 排序方向，可选值：asc、desc，默认为desc
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "items": [
      {
        "id": "guid", // 日记ID
        "userId": "guid", // 用户ID
        "title": "string", // 日记标题
        "content": "string", // 日记内容
        "mood": "string", // 情绪状态
        "diaryDate": "date", // 日记日期
        "pregnancyWeek": "integer", // 孕周
        "pregnancyDay": "integer", // 孕天
        "createdAt": "datetime", // 创建时间
        "updatedAt": "datetime", // 更新时间
        "tags": ["string"], // 标签列表
        "mediaFiles": [ // 媒体文件列表
          {
            "id": "guid", // 媒体文件ID
            "mediaType": "string", // 媒体类型
            "mediaUrl": "string", // 媒体URL
            "description": "string", // 媒体描述
            "createdAt": "datetime" // 创建时间
          }
        ]
      }
    ],
    "totalCount": "integer", // 总数量
    "pageCount": "integer", // 总页数
    "currentPage": "integer", // 当前页码
    "pageSize": "integer" // 每页数量
  }
}
```

- **错误码**:
  - 401: 未授权

### 4. 根据日期范围获取日记

- **URL**: `/diaries/date-range`
- **方法**: GET
- **描述**: 根据日期范围获取当前登录用户的日记
- **请求头**: Authorization: Bearer {accessToken}
- **查询参数**:
  - startDate: 开始日期，格式：yyyy-MM-dd
  - endDate: 结束日期，格式：yyyy-MM-dd
  - page: 页码，默认为1
  - pageSize: 每页数量，默认为10
  - sortBy: 排序字段，可选值：diaryDate、createdAt，默认为diaryDate
  - sortDirection: 排序方向，可选值：asc、desc，默认为desc
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "items": [
      {
        "id": "guid", // 日记ID
        "userId": "guid", // 用户ID
        "title": "string", // 日记标题
        "content": "string", // 日记内容
        "mood": "string", // 情绪状态
        "diaryDate": "date", // 日记日期
        "pregnancyWeek": "integer", // 孕周
        "pregnancyDay": "integer", // 孕天
        "createdAt": "datetime", // 创建时间
        "updatedAt": "datetime", // 更新时间
        "tags": ["string"], // 标签列表
        "mediaFiles": [ // 媒体文件列表
          {
            "id": "guid", // 媒体文件ID
            "mediaType": "string", // 媒体类型
            "mediaUrl": "string", // 媒体URL
            "description": "string", // 媒体描述
            "createdAt": "datetime" // 创建时间
          }
        ]
      }
    ],
    "totalCount": "integer", // 总数量
    "pageCount": "integer", // 总页数
    "currentPage": "integer", // 当前页码
    "pageSize": "integer" // 每页数量
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 5. 根据标签获取日记

- **URL**: `/diaries/tag/{tag}`
- **方法**: GET
- **描述**: 根据标签获取当前登录用户的日记
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - tag: 标签名称
- **查询参数**:
  - page: 页码，默认为1
  - pageSize: 每页数量，默认为10
  - sortBy: 排序字段，可选值：diaryDate、createdAt，默认为diaryDate
  - sortDirection: 排序方向，可选值：asc、desc，默认为desc
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "items": [
      {
        "id": "guid", // 日记ID
        "userId": "guid", // 用户ID
        "title": "string", // 日记标题
        "content": "string", // 日记内容
        "mood": "string", // 情绪状态
        "diaryDate": "date", // 日记日期
        "pregnancyWeek": "integer", // 孕周
        "pregnancyDay": "integer", // 孕天
        "createdAt": "datetime", // 创建时间
        "updatedAt": "datetime", // 更新时间
        "tags": ["string"], // 标签列表
        "mediaFiles": [ // 媒体文件列表
          {
            "id": "guid", // 媒体文件ID
            "mediaType": "string", // 媒体类型
            "mediaUrl": "string", // 媒体URL
            "description": "string", // 媒体描述
            "createdAt": "datetime" // 创建时间
          }
        ]
      }
    ],
    "totalCount": "integer", // 总数量
    "pageCount": "integer", // 总页数
    "currentPage": "integer", // 当前页码
    "pageSize": "integer" // 每页数量
  }
}
```

- **错误码**:
  - 401: 未授权

### 6. 根据情绪获取日记

- **URL**: `/diaries/mood/{mood}`
- **方法**: GET
- **描述**: 根据情绪获取当前登录用户的日记
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - mood: 情绪状态，可选值：Happy、Sad、Angry、Anxious、Excited、Tired、Neutral
- **查询参数**:
  - page: 页码，默认为1
  - pageSize: 每页数量，默认为10
  - sortBy: 排序字段，可选值：diaryDate、createdAt，默认为diaryDate
  - sortDirection: 排序方向，可选值：asc、desc，默认为desc
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "items": [
      {
        "id": "guid", // 日记ID
        "userId": "guid", // 用户ID
        "title": "string", // 日记标题
        "content": "string", // 日记内容
        "mood": "string", // 情绪状态
        "diaryDate": "date", // 日记日期
        "pregnancyWeek": "integer", // 孕周
        "pregnancyDay": "integer", // 孕天
        "createdAt": "datetime", // 创建时间
        "updatedAt": "datetime", // 更新时间
        "tags": ["string"], // 标签列表
        "mediaFiles": [ // 媒体文件列表
          {
            "id": "guid", // 媒体文件ID
            "mediaType": "string", // 媒体类型
            "mediaUrl": "string", // 媒体URL
            "description": "string", // 媒体描述
            "createdAt": "datetime" // 创建时间
          }
        ]
      }
    ],
    "totalCount": "integer", // 总数量
    "pageCount": "integer", // 总页数
    "currentPage": "integer", // 当前页码
    "pageSize": "integer" // 每页数量
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 7. 更新日记

- **URL**: `/diaries/{id}`
- **方法**: PUT
- **描述**: 更新指定ID的日记
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 日记ID
- **请求参数**:

```json
{
  "title": "string", // 日记标题，选填，最多100个字符
  "content": "string", // 日记内容，选填
  "mood": "string", // 情绪状态，选填，可选值：Happy、Sad、Angry、Anxious、Excited、Tired、Neutral
  "diaryDate": "date" // 日记日期，选填，不能晚于今天
}
```

- **响应**:

```json
{
  "success": true,
  "message": "更新成功",
  "data": {
    "id": "guid", // 日记ID
    "userId": "guid", // 用户ID
    "title": "string", // 日记标题
    "content": "string", // 日记内容
    "mood": "string", // 情绪状态
    "diaryDate": "date", // 日记日期
    "pregnancyWeek": "integer", // 孕周
    "pregnancyDay": "integer", // 孕天
    "createdAt": "datetime", // 创建时间
    "updatedAt": "datetime", // 更新时间
    "tags": ["string"], // 标签列表
    "mediaFiles": [ // 媒体文件列表
      {
        "id": "guid", // 媒体文件ID
        "mediaType": "string", // 媒体类型
        "mediaUrl": "string", // 媒体URL
        "description": "string", // 媒体描述
        "createdAt": "datetime" // 创建时间
      }
    ]
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 403: 禁止访问（尝试更新其他用户的日记）
  - 404: 日记不存在

### 8. 删除日记

- **URL**: `/diaries/{id}`
- **方法**: DELETE
- **描述**: 删除指定ID的日记
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 日记ID
- **响应**:

```json
{
  "success": true,
  "message": "删除成功"
}
```

- **错误码**:
  - 401: 未授权
  - 403: 禁止访问（尝试删除其他用户的日记）
  - 404: 日记不存在

### 9. 添加日记标签

- **URL**: `/diaries/{id}/tags`
- **方法**: POST
- **描述**: 为指定ID的日记添加标签
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 日记ID
- **请求参数**:

```json
{
  "tags": ["string"] // 标签列表，必填
}
```

- **响应**:

```json
{
  "success": true,
  "message": "操作成功",
  "data": {
    "id": "guid", // 日记ID
    "tags": ["string"] // 更新后的标签列表
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 403: 禁止访问（尝试更新其他用户的日记）
  - 404: 日记不存在

### 10. 删除日记标签

- **URL**: `/diaries/{id}/tags/{tag}`
- **方法**: DELETE
- **描述**: 删除指定ID日记的指定标签
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 日记ID
  - tag: 标签名称
- **响应**:

```json
{
  "success": true,
  "message": "删除成功",
  "data": {
    "id": "guid", // 日记ID
    "tags": ["string"] // 更新后的标签列表
  }
}
```

- **错误码**:
  - 401: 未授权
  - 403: 禁止访问（尝试更新其他用户的日记）
  - 404: 日记不存在或标签不存在

### 11. 添加日记媒体文件

- **URL**: `/diaries/{id}/media`
- **方法**: POST
- **描述**: 为指定ID的日记添加媒体文件
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 日记ID
- **请求参数**:

```json
{
  "mediaType": "string", // 媒体类型，必填，可选值：Image、Video、Audio
  "mediaUrl": "string", // 媒体URL，必填
  "description": "string" // 媒体描述，选填
}
```

- **响应**:

```json
{
  "success": true,
  "message": "操作成功",
  "data": {
    "id": "guid", // 媒体文件ID
    "diaryId": "guid", // 日记ID
    "mediaType": "string", // 媒体类型
    "mediaUrl": "string", // 媒体URL
    "description": "string", // 媒体描述
    "createdAt": "datetime" // 创建时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 403: 禁止访问（尝试更新其他用户的日记）
  - 404: 日记不存在

### 12. 删除日记媒体文件

- **URL**: `/diaries/{diaryId}/media/{mediaId}`
- **方法**: DELETE
- **描述**: 删除指定ID日记的指定媒体文件
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - diaryId: 日记ID
  - mediaId: 媒体文件ID
- **响应**:

```json
{
  "success": true,
  "message": "删除成功"
}
```

- **错误码**:
  - 401: 未授权
  - 403: 禁止访问（尝试更新其他用户的日记）
  - 404: 日记不存在或媒体文件不存在

## 八、胎动和宫缩记录API

### 1. 创建胎动记录

- **URL**: `/fetalmovement`
- **方法**: POST
- **描述**: 创建胎动记录
- **请求头**: Authorization: Bearer {accessToken}
- **请求参数**:

```json
{
  "startTime": "datetime", // 开始时间，必填，不能晚于当前时间
  "endTime": "datetime", // 结束时间，选填，不能早于开始时间且不能晚于当前时间
  "count": "integer", // 胎动次数，必填，1-100次
  "duration": "integer", // 持续时间（秒），选填，计算得出
  "strength": "string", // 强度，选填，可选值：Weak、Moderate、Strong
  "note": "string" // 备注，选填
}
```

- **响应**:

```json
{
  "success": true,
  "message": "创建成功",
  "data": {
    "id": "guid", // 胎动记录ID
    "userId": "guid", // 用户ID
    "startTime": "datetime", // 开始时间
    "endTime": "datetime", // 结束时间
    "count": "integer", // 胎动次数
    "duration": "integer", // 持续时间（秒）
    "strength": "string", // 强度
    "note": "string", // 备注
    "pregnancyWeek": "integer", // 孕周
    "pregnancyDay": "integer", // 孕天
    "createdAt": "datetime" // 创建时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 2. 获取胎动记录

- **URL**: `/fetalmovement/{id}`
- **方法**: GET
- **描述**: 获取指定ID的胎动记录
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 胎动记录ID
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "id": "guid", // 胎动记录ID
    "userId": "guid", // 用户ID
    "startTime": "datetime", // 开始时间
    "endTime": "datetime", // 结束时间
    "count": "integer", // 胎动次数
    "duration": "integer", // 持续时间（秒）
    "strength": "string", // 强度
    "note": "string", // 备注
    "pregnancyWeek": "integer", // 孕周
    "pregnancyDay": "integer", // 孕天
    "createdAt": "datetime" // 创建时间
  }
}
```

- **错误码**:
  - 401: 未授权
  - 403: 禁止访问（尝试访问其他用户的记录）
  - 404: 记录不存在

### 3. 获取用户所有胎动记录

- **URL**: `/fetalmovement`
- **方法**: GET
- **描述**: 获取当前登录用户的所有胎动记录
- **请求头**: Authorization: Bearer {accessToken}
- **查询参数**:
  - page: 页码，默认为1
  - pageSize: 每页数量，默认为10
  - startDate: 开始日期，格式：yyyy-MM-dd
  - endDate: 结束日期，格式：yyyy-MM-dd
  - sortBy: 排序字段，可选值：startTime、count、duration，默认为startTime
  - sortDirection: 排序方向，可选值：asc、desc，默认为desc
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "items": [
      {
        "id": "guid", // 胎动记录ID
        "userId": "guid", // 用户ID
        "startTime": "datetime", // 开始时间
        "endTime": "datetime", // 结束时间
        "count": "integer", // 胎动次数
        "duration": "integer", // 持续时间（秒）
        "strength": "string", // 强度
        "note": "string", // 备注
        "pregnancyWeek": "integer", // 孕周
        "pregnancyDay": "integer", // 孕天
        "createdAt": "datetime" // 创建时间
      }
    ],
    "totalCount": "integer", // 总数量
    "pageCount": "integer", // 总页数
    "currentPage": "integer", // 当前页码
    "pageSize": "integer" // 每页数量
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 4. 更新胎动记录

- **URL**: `/fetalmovement/{id}`
- **方法**: PUT
- **描述**: 更新指定ID的胎动记录
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 胎动记录ID
- **请求参数**:

```json
{
  "startTime": "datetime", // 开始时间，选填，不能晚于当前时间
  "endTime": "datetime", // 结束时间，选填，不能早于开始时间且不能晚于当前时间
  "count": "integer", // 胎动次数，选填，1-100次
  "strength": "string", // 强度，选填，可选值：Weak、Moderate、Strong
  "note": "string" // 备注，选填
}
```

- **响应**:

```json
{
  "success": true,
  "message": "更新成功",
  "data": {
    "id": "guid", // 胎动记录ID
    "userId": "guid", // 用户ID
    "startTime": "datetime", // 开始时间
    "endTime": "datetime", // 结束时间
    "count": "integer", // 胎动次数
    "duration": "integer", // 持续时间（秒）
    "strength": "string", // 强度
    "note": "string", // 备注
    "pregnancyWeek": "integer", // 孕周
    "pregnancyDay": "integer", // 孕天
    "createdAt": "datetime" // 创建时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 403: 禁止访问（尝试更新其他用户的记录）
  - 404: 记录不存在

### 5. 删除胎动记录

- **URL**: `/fetalmovement/{id}`
- **方法**: DELETE
- **描述**: 删除指定ID的胎动记录
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 胎动记录ID
- **响应**:

```json
{
  "success": true
}
```

- **错误码**:
  - 401: 未授权
  - 403: 禁止访问（尝试删除其他用户的记录）
  - 404: 记录不存在

### 6. 获取胎动统计数据

- **URL**: `/fetalmovement/statistics`
- **方法**: GET
- **描述**: 获取当前登录用户的胎动统计数据
- **请求头**: Authorization: Bearer {accessToken}
- **查询参数**:
  - startDate: 开始日期，格式：yyyy-MM-dd
  - endDate: 结束日期，格式：yyyy-MM-dd
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "dailyStats": [
      {
        "date": "date", // 日期
        "totalCount": "integer", // 总次数
        "averageStrength": "string", // 平均强度
        "pregnancyWeek": "integer", // 孕周
        "pregnancyDay": "integer" // 孕天
      }
    ],
    "weeklyStats": [
      {
        "weekStartDate": "date", // 周开始日期
        "weekEndDate": "date", // 周结束日期
        "totalCount": "integer", // 总次数
        "dailyAverage": "decimal", // 日均次数
        "pregnancyWeek": "integer" // 孕周
      }
    ],
    "totalRecords": "integer", // 总记录数
    "averageCountPerDay": "decimal", // 日均次数
    "mostActiveTimeOfDay": "string" // 最活跃时段
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 7. 创建宫缩记录

- **URL**: `/contraction`
- **方法**: POST
- **描述**: 创建宫缩记录
- **请求头**: Authorization: Bearer {accessToken}
- **请求参数**:

```json
{
  "startTime": "datetime", // 开始时间，必填，不能晚于当前时间
  "endTime": "datetime", // 结束时间，必填，不能早于开始时间且不能晚于当前时间
  "duration": "integer", // 持续时间（秒），必填，计算得出
  "intensity": "string", // 强度，必填，可选值：Mild、Moderate、Strong、Severe
  "painLevel": "integer", // 疼痛等级，必填，1-10
  "note": "string" // 备注，选填
}
```

- **响应**:

```json
{
  "success": true,
  "message": "创建成功",
  "data": {
    "id": "guid", // 宫缩记录ID
    "userId": "guid", // 用户ID
    "startTime": "datetime", // 开始时间
    "endTime": "datetime", // 结束时间
    "duration": "integer", // 持续时间（秒）
    "intensity": "string", // 强度
    "painLevel": "integer", // 疼痛等级
    "note": "string", // 备注
    "pregnancyWeek": "integer", // 孕周
    "pregnancyDay": "integer", // 孕天
    "createdAt": "datetime" // 创建时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 8. 获取宫缩记录

- **URL**: `/contraction/{id}`
- **方法**: GET
- **描述**: 获取指定ID的宫缩记录
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 宫缩记录ID
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "id": "guid", // 宫缩记录ID
    "userId": "guid", // 用户ID
    "startTime": "datetime", // 开始时间
    "endTime": "datetime", // 结束时间
    "duration": "integer", // 持续时间（秒）
    "intensity": "string", // 强度
    "painLevel": "integer", // 疼痛等级
    "note": "string", // 备注
    "pregnancyWeek": "integer", // 孕周
    "pregnancyDay": "integer", // 孕天
    "createdAt": "datetime" // 创建时间
  }
}
```

- **错误码**:
  - 401: 未授权
  - 403: 禁止访问（尝试访问其他用户的记录）
  - 404: 记录不存在

### 9. 获取用户所有宫缩记录

- **URL**: `/contraction`
- **方法**: GET
- **描述**: 获取当前登录用户的所有宫缩记录
- **请求头**: Authorization: Bearer {accessToken}
- **查询参数**:
  - page: 页码，默认为1
  - pageSize: 每页数量，默认为10
  - startDate: 开始日期，格式：yyyy-MM-dd
  - endDate: 结束日期，格式：yyyy-MM-dd
  - sortBy: 排序字段，可选值：startTime、duration、intensity、painLevel，默认为startTime
  - sortDirection: 排序方向，可选值：asc、desc，默认为desc
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "items": [
      {
        "id": "guid", // 宫缩记录ID
        "userId": "guid", // 用户ID
        "startTime": "datetime", // 开始时间
        "endTime": "datetime", // 结束时间
        "duration": "integer", // 持续时间（秒）
        "intensity": "string", // 强度
        "painLevel": "integer", // 疼痛等级
        "note": "string", // 备注
        "pregnancyWeek": "integer", // 孕周
        "pregnancyDay": "integer", // 孕天
        "createdAt": "datetime" // 创建时间
      }
    ],
    "totalCount": "integer", // 总数量
    "pageCount": "integer", // 总页数
    "currentPage": "integer", // 当前页码
    "pageSize": "integer" // 每页数量
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 10. 更新宫缩记录

- **URL**: `/contraction/{id}`
- **方法**: PUT
- **描述**: 更新指定ID的宫缩记录
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 宫缩记录ID
- **请求参数**:

```json
{
  "startTime": "datetime", // 开始时间，选填，不能晚于当前时间
  "endTime": "datetime", // 结束时间，选填，不能早于开始时间且不能晚于当前时间
  "intensity": "string", // 强度，选填，可选值：Mild、Moderate、Strong、Severe
  "painLevel": "integer", // 疼痛等级，选填，1-10
  "note": "string" // 备注，选填
}
```

- **响应**:

```json
{
  "success": true,
  "message": "更新成功",
  "data": {
    "id": "guid", // 宫缩记录ID
    "userId": "guid", // 用户ID
    "startTime": "datetime", // 开始时间
    "endTime": "datetime", // 结束时间
    "duration": "integer", // 持续时间（秒）
    "intensity": "string", // 强度
    "painLevel": "integer", // 疼痛等级
    "note": "string", // 备注
    "pregnancyWeek": "integer", // 孕周
    "pregnancyDay": "integer", // 孕天
    "createdAt": "datetime" // 创建时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 403: 禁止访问（尝试更新其他用户的记录）
  - 404: 记录不存在

### 11. 删除宫缩记录

- **URL**: `/contraction/{id}`
- **方法**: DELETE
- **描述**: 删除指定ID的宫缩记录
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 宫缩记录ID
- **响应**:

```json
{
  "success": true
}
```

- **错误码**:
  - 401: 未授权
  - 403: 禁止访问（尝试删除其他用户的记录）
  - 404: 记录不存在

### 12. 获取宫缩统计数据

- **URL**: `/contraction/statistics`
- **方法**: GET
- **描述**: 获取当前登录用户的宫缩统计数据
- **请求头**: Authorization: Bearer {accessToken}
- **查询参数**:
  - startDate: 开始日期，格式：yyyy-MM-dd
  - endDate: 结束日期，格式：yyyy-MM-dd
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "dailyStats": [
      {
        "date": "date", // 日期
        "totalCount": "integer", // 总次数
        "averageDuration": "integer", // 平均持续时间（秒）
        "averageInterval": "integer", // 平均间隔时间（秒）
        "averagePainLevel": "decimal", // 平均疼痛等级
        "pregnancyWeek": "integer", // 孕周
        "pregnancyDay": "integer" // 孕天
      }
    ],
    "weeklyStats": [
      {
        "weekStartDate": "date", // 周开始日期
        "weekEndDate": "date", // 周结束日期
        "totalCount": "integer", // 总次数
        "dailyAverage": "decimal", // 日均次数
        "averageDuration": "integer", // 平均持续时间（秒）
        "averageInterval": "integer", // 平均间隔时间（秒）
        "pregnancyWeek": "integer" // 孕周
      }
    ],
    "totalRecords": "integer", // 总记录数
    "averageCountPerDay": "decimal", // 日均次数
    "averageDuration": "integer", // 平均持续时间（秒）
    "averageInterval": "integer", // 平均间隔时间（秒）
    "laborWarning": "boolean", // 是否有临产警告
    "laborWarningReason": "string" // 临产警告原因
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

## 九、孕期指南和知识百科API

### 1. 获取孕期阶段列表

- **URL**: `/pregnancyguide/stages`
- **方法**: GET
- **描述**: 获取孕期阶段列表
- **请求头**: Authorization: Bearer {accessToken}
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "stages": [
      {
        "id": "guid", // 阶段ID
        "name": "string", // 阶段名称
        "startWeek": "integer", // 开始周数
        "endWeek": "integer", // 结束周数
        "description": "string", // 阶段描述
        "imageUrl": "string" // 阶段图片URL
      }
    ]
  }
}
```

- **错误码**:
  - 401: 未授权

### 2. 获取孕周指南

- **URL**: `/pregnancyguide/weeks/{week}`
- **方法**: GET
- **描述**: 获取指定孕周的指南信息
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - week: 孕周，1-42
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "week": "integer", // 孕周
    "title": "string", // 标题
    "summary": "string", // 摘要
    "babyDevelopment": {
      "size": "string", // 胎儿大小
      "weight": "string", // 胎儿重量
      "length": "string", // 胎儿长度
      "description": "string", // 发育描述
      "imageUrl": "string" // 胎儿发育图片URL
    },
    "motherChanges": {
      "physicalChanges": "string", // 身体变化
      "commonSymptoms": ["string"], // 常见症状
      "weightGain": "string", // 体重增长
      "description": "string" // 详细描述
    },
    "tips": [
      {
        "category": "string", // 提示类别
        "title": "string", // 提示标题
        "content": "string", // 提示内容
        "imageUrl": "string" // 提示图片URL
      }
    ],
    "nutrition": {
      "keyNutrients": ["string"], // 关键营养素
      "foodRecommendations": ["string"], // 食物推荐
      "foodsToAvoid": ["string"], // 需要避免的食物
      "description": "string" // 详细描述
    },
    "exercises": [
      {
        "name": "string", // 运动名称
        "description": "string", // 运动描述
        "benefits": ["string"], // 运动益处
        "cautions": ["string"], // 注意事项
        "imageUrl": "string", // 运动图片URL
        "videoUrl": "string" // 运动视频URL
      }
    ],
    "checkups": [
      {
        "name": "string", // 检查名称
        "description": "string", // 检查描述
        "isRecommended": "boolean", // 是否推荐
        "timing": "string" // 检查时机
      }
    ],
    "faqs": [
      {
        "question": "string", // 问题
        "answer": "string" // 回答
      }
    ],
    "nextSteps": "string" // 下一步建议
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 404: 孕周指南不存在

### 3. 获取当前孕周指南

- **URL**: `/pregnancyguide/current-week`
- **方法**: GET
- **描述**: 获取当前登录用户的当前孕周指南
- **请求头**: Authorization: Bearer {accessToken}
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "week": "integer", // 孕周
    "title": "string", // 标题
    "summary": "string", // 摘要
    "babyDevelopment": {
      "size": "string", // 胎儿大小
      "weight": "string", // 胎儿重量
      "length": "string", // 胎儿长度
      "description": "string", // 发育描述
      "imageUrl": "string" // 胎儿发育图片URL
    },
    "motherChanges": {
      "physicalChanges": "string", // 身体变化
      "commonSymptoms": ["string"], // 常见症状
      "weightGain": "string", // 体重增长
      "description": "string" // 详细描述
    },
    "tips": [
      {
        "category": "string", // 提示类别
        "title": "string", // 提示标题
        "content": "string", // 提示内容
        "imageUrl": "string" // 提示图片URL
      }
    ],
    "nutrition": {
      "keyNutrients": ["string"], // 关键营养素
      "foodRecommendations": ["string"], // 食物推荐
      "foodsToAvoid": ["string"], // 需要避免的食物
      "description": "string" // 详细描述
    },
    "exercises": [
      {
        "name": "string", // 运动名称
        "description": "string", // 运动描述
        "benefits": ["string"], // 运动益处
        "cautions": ["string"], // 注意事项
        "imageUrl": "string", // 运动图片URL
        "videoUrl": "string" // 运动视频URL
      }
    ],
    "checkups": [
      {
        "name": "string", // 检查名称
        "description": "string", // 检查描述
        "isRecommended": "boolean", // 是否推荐
        "timing": "string" // 检查时机
      }
    ],
    "faqs": [
      {
        "question": "string", // 问题
        "answer": "string" // 回答
      }
    ],
    "nextSteps": "string" // 下一步建议
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 孕期信息不存在

### 4. 获取知识分类列表

- **URL**: `/knowledge/categories`
- **方法**: GET
- **描述**: 获取知识分类列表
- **请求头**: Authorization: Bearer {accessToken}
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "categories": [
      {
        "id": "guid", // 分类ID
        "name": "string", // 分类名称
        "description": "string", // 分类描述
        "imageUrl": "string", // 分类图片URL
        "articleCount": "integer" // 文章数量
      }
    ]
  }
}
```

- **错误码**:
  - 401: 未授权

### 5. 获取知识文章列表

- **URL**: `/knowledge/articles`
- **方法**: GET
- **描述**: 获取知识文章列表
- **请求头**: Authorization: Bearer {accessToken}
- **查询参数**:
  - categoryId: 分类ID，选填
  - page: 页码，默认为1
  - pageSize: 每页数量，默认为10
  - sortBy: 排序字段，可选值：createdAt、title、viewCount，默认为createdAt
  - sortDirection: 排序方向，可选值：asc、desc，默认为desc
  - keyword: 关键词，选填
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "items": [
      {
        "id": "guid", // 文章ID
        "categoryId": "guid", // 分类ID
        "categoryName": "string", // 分类名称
        "title": "string", // 文章标题
        "summary": "string", // 文章摘要
        "coverImageUrl": "string", // 封面图片URL
        "author": "string", // 作者
        "viewCount": "integer", // 浏览次数
        "likeCount": "integer", // 点赞次数
        "createdAt": "datetime", // 创建时间
        "updatedAt": "datetime", // 更新时间
        "tags": ["string"] // 标签列表
      }
    ],
    "totalCount": "integer", // 总数量
    "pageCount": "integer", // 总页数
    "currentPage": "integer", // 当前页码
    "pageSize": "integer" // 每页数量
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 6. 获取知识文章详情

- **URL**: `/knowledge/articles/{id}`
- **方法**: GET
- **描述**: 获取指定ID的知识文章详情
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 文章ID
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "id": "guid", // 文章ID
    "categoryId": "guid", // 分类ID
    "categoryName": "string", // 分类名称
    "title": "string", // 文章标题
    "content": "string", // 文章内容
    "summary": "string", // 文章摘要
    "coverImageUrl": "string", // 封面图片URL
    "author": "string", // 作者
    "viewCount": "integer", // 浏览次数
    "likeCount": "integer", // 点赞次数
    "createdAt": "datetime", // 创建时间
    "updatedAt": "datetime", // 更新时间
    "tags": ["string"], // 标签列表
    "relatedArticles": [ // 相关文章
      {
        "id": "guid", // 文章ID
        "title": "string", // 文章标题
        "summary": "string", // 文章摘要
        "coverImageUrl": "string" // 封面图片URL
      }
    ]
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 文章不存在

### 7. 点赞知识文章

- **URL**: `/knowledge/articles/{id}/like`
- **方法**: POST
- **描述**: 点赞指定ID的知识文章
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 文章ID
- **响应**:

```json
{
  "success": true,
  "message": "操作成功",
  "data": {
    "id": "guid", // 文章ID
    "likeCount": "integer" // 更新后的点赞次数
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 文章不存在
  - 409: 已点赞

### 8. 取消点赞知识文章

- **URL**: `/knowledge/articles/{id}/unlike`
- **方法**: POST
- **描述**: 取消点赞指定ID的知识文章
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 文章ID
- **响应**:

```json
{
  "success": true,
  "message": "操作成功",
  "data": {
    "id": "guid", // 文章ID
    "likeCount": "integer" // 更新后的点赞次数
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 文章不存在或未点赞

### 9. 收藏知识文章

- **URL**: `/knowledge/articles/{id}/favorite`
- **方法**: POST
- **描述**: 收藏指定ID的知识文章
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 文章ID
- **响应**:

```json
{
  "success": true,
  "message": "操作成功",
  "data": {
    "id": "guid", // 收藏ID
    "articleId": "guid", // 文章ID
    "userId": "guid", // 用户ID
    "createdAt": "datetime" // 创建时间
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 文章不存在
  - 409: 已收藏

### 10. 取消收藏知识文章

- **URL**: `/knowledge/articles/{id}/unfavorite`
- **方法**: POST
- **描述**: 取消收藏指定ID的知识文章
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 文章ID
- **响应**:

```json
{
  "success": true,
  "message": "操作成功"
}
```

- **错误码**:
  - 401: 未授权
  - 404: 文章不存在或未收藏

### 11. 获取收藏的知识文章列表

- **URL**: `/knowledge/favorites`
- **方法**: GET
- **描述**: 获取当前登录用户收藏的知识文章列表
- **请求头**: Authorization: Bearer {accessToken}
- **查询参数**:
  - page: 页码，默认为1
  - pageSize: 每页数量，默认为10
  - sortBy: 排序字段，可选值：createdAt、title，默认为createdAt
  - sortDirection: 排序方向，可选值：asc、desc，默认为desc
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "items": [
      {
        "id": "guid", // 文章ID
        "categoryId": "guid", // 分类ID
        "categoryName": "string", // 分类名称
        "title": "string", // 文章标题
        "summary": "string", // 文章摘要
        "coverImageUrl": "string", // 封面图片URL
        "author": "string", // 作者
        "viewCount": "integer", // 浏览次数
        "likeCount": "integer", // 点赞次数
        "createdAt": "datetime", // 创建时间
        "updatedAt": "datetime", // 更新时间
        "favoriteTime": "datetime", // 收藏时间
        "tags": ["string"] // 标签列表
      }
    ],
    "totalCount": "integer", // 总数量
    "pageCount": "integer", // 总页数
    "currentPage": "integer", // 当前页码
    "pageSize": "integer" // 每页数量
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 12. 搜索知识文章

- **URL**: `/knowledge/search`
- **方法**: GET
- **描述**: 搜索知识文章
- **请求头**: Authorization: Bearer {accessToken}
- **查询参数**:
  - keyword: 关键词，必填
  - categoryId: 分类ID，选填
  - page: 页码，默认为1
  - pageSize: 每页数量，默认为10
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "items": [
      {
        "id": "guid", // 文章ID
        "categoryId": "guid", // 分类ID
        "categoryName": "string", // 分类名称
        "title": "string", // 文章标题
        "summary": "string", // 文章摘要
        "coverImageUrl": "string", // 封面图片URL
        "author": "string", // 作者
        "viewCount": "integer", // 浏览次数
        "likeCount": "integer", // 点赞次数
        "createdAt": "datetime", // 创建时间
        "updatedAt": "datetime", // 更新时间
        "tags": ["string"], // 标签列表
        "relevance": "decimal" // 相关度
      }
    ],
    "totalCount": "integer", // 总数量
    "pageCount": "integer", // 总页数
    "currentPage": "integer", // 当前页码
    "pageSize": "integer" // 每页数量
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

## 十、社区功能API

### 1. 创建社区帖子

- **URL**: `/community/posts`
- **方法**: POST
- **描述**: 创建社区帖子
- **请求头**: Authorization: Bearer {accessToken}
- **请求参数**:

```json
{
  "title": "string", // 帖子标题，必填，最多100个字符
  "content": "string", // 帖子内容，必填
  "topicIds": ["guid"], // 话题ID列表，选填
  "mediaFiles": [ // 媒体文件列表，选填
    {
      "mediaType": "string", // 媒体类型，必填，可选值：Image、Video、Audio
      "mediaUrl": "string", // 媒体URL，必填
      "description": "string" // 媒体描述，选填
    }
  ],
  "isAnonymous": "boolean" // 是否匿名，选填，默认为false
}
```

- **响应**:

```json
{
  "success": true,
  "message": "创建成功",
  "data": {
    "id": "guid", // 帖子ID
    "userId": "guid", // 用户ID
    "title": "string", // 帖子标题
    "content": "string", // 帖子内容
    "topics": [ // 话题列表
      {
        "id": "guid", // 话题ID
        "name": "string" // 话题名称
      }
    ],
    "mediaFiles": [ // 媒体文件列表
      {
        "id": "guid", // 媒体文件ID
        "mediaType": "string", // 媒体类型
        "mediaUrl": "string", // 媒体URL
        "description": "string", // 媒体描述
        "createdAt": "datetime" // 创建时间
      }
    ],
    "isAnonymous": "boolean", // 是否匿名
    "author": { // 作者信息
      "id": "guid", // 用户ID
      "nickname": "string", // 昵称
      "avatarUrl": "string", // 头像URL
      "pregnancyWeek": "integer" // 孕周
    },
    "viewCount": "integer", // 浏览次数
    "likeCount": "integer", // 点赞次数
    "commentCount": "integer", // 评论次数
    "createdAt": "datetime", // 创建时间
    "updatedAt": "datetime" // 更新时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 2. 获取社区帖子

- **URL**: `/community/posts/{id}`
- **方法**: GET
- **描述**: 获取指定ID的社区帖子
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 帖子ID
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "id": "guid", // 帖子ID
    "userId": "guid", // 用户ID
    "title": "string", // 帖子标题
    "content": "string", // 帖子内容
    "topics": [ // 话题列表
      {
        "id": "guid", // 话题ID
        "name": "string" // 话题名称
      }
    ],
    "mediaFiles": [ // 媒体文件列表
      {
        "id": "guid", // 媒体文件ID
        "mediaType": "string", // 媒体类型
        "mediaUrl": "string", // 媒体URL
        "description": "string", // 媒体描述
        "createdAt": "datetime" // 创建时间
      }
    ],
    "isAnonymous": "boolean", // 是否匿名
    "author": { // 作者信息
      "id": "guid", // 用户ID
      "nickname": "string", // 昵称
      "avatarUrl": "string", // 头像URL
      "pregnancyWeek": "integer" // 孕周
    },
    "viewCount": "integer", // 浏览次数
    "likeCount": "integer", // 点赞次数
    "commentCount": "integer", // 评论次数
    "isLiked": "boolean", // 当前用户是否已点赞
    "isFavorited": "boolean", // 当前用户是否已收藏
    "createdAt": "datetime", // 创建时间
    "updatedAt": "datetime", // 更新时间
    "comments": [ // 评论列表
      {
        "id": "guid", // 评论ID
        "userId": "guid", // 用户ID
        "content": "string", // 评论内容
        "isAnonymous": "boolean", // 是否匿名
        "author": { // 作者信息
          "id": "guid", // 用户ID
          "nickname": "string", // 昵称
          "avatarUrl": "string", // 头像URL
          "pregnancyWeek": "integer" // 孕周
        },
        "likeCount": "integer", // 点赞次数
        "isLiked": "boolean", // 当前用户是否已点赞
        "createdAt": "datetime", // 创建时间
        "replies": [ // 回复列表
          {
            "id": "guid", // 回复ID
            "userId": "guid", // 用户ID
            "content": "string", // 回复内容
            "isAnonymous": "boolean", // 是否匿名
            "author": { // 作者信息
              "id": "guid", // 用户ID
              "nickname": "string", // 昵称
              "avatarUrl": "string", // 头像URL
              "pregnancyWeek": "integer" // 孕周
            },
            "replyToUserId": "guid", // 回复用户ID
            "replyToNickname": "string", // 回复用户昵称
            "likeCount": "integer", // 点赞次数
            "isLiked": "boolean", // 当前用户是否已点赞
            "createdAt": "datetime" // 创建时间
          }
        ]
      }
    ]
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 帖子不存在

### 3. 获取社区帖子列表

- **URL**: `/community/posts`
- **方法**: GET
- **描述**: 获取社区帖子列表
- **请求头**: Authorization: Bearer {accessToken}
- **查询参数**:
  - page: 页码，默认为1
  - pageSize: 每页数量，默认为10
  - sortBy: 排序字段，可选值：createdAt、viewCount、likeCount、commentCount，默认为createdAt
  - sortDirection: 排序方向，可选值：asc、desc，默认为desc
  - topicId: 话题ID，选填
  - userId: 用户ID，选填
  - keyword: 关键词，选填
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "items": [
      {
        "id": "guid", // 帖子ID
        "userId": "guid", // 用户ID
        "title": "string", // 帖子标题
        "content": "string", // 帖子内容
        "topics": [ // 话题列表
          {
            "id": "guid", // 话题ID
            "name": "string" // 话题名称
          }
        ],
        "mediaFiles": [ // 媒体文件列表
          {
            "id": "guid", // 媒体文件ID
            "mediaType": "string", // 媒体类型
            "mediaUrl": "string", // 媒体URL
            "description": "string", // 媒体描述
            "createdAt": "datetime" // 创建时间
          }
        ],
        "isAnonymous": "boolean", // 是否匿名
        "author": { // 作者信息
          "id": "guid", // 用户ID
          "nickname": "string", // 昵称
          "avatarUrl": "string", // 头像URL
          "pregnancyWeek": "integer" // 孕周
        },
        "viewCount": "integer", // 浏览次数
        "likeCount": "integer", // 点赞次数
        "commentCount": "integer", // 评论次数
        "isLiked": "boolean", // 当前用户是否已点赞
        "isFavorited": "boolean", // 当前用户是否已收藏
        "createdAt": "datetime", // 创建时间
        "updatedAt": "datetime" // 更新时间
      }
    ],
    "totalCount": "integer", // 总数量
    "pageCount": "integer", // 总页数
    "currentPage": "integer", // 当前页码
    "pageSize": "integer" // 每页数量
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 4. 更新社区帖子

- **URL**: `/community/posts/{id}`
- **方法**: PUT
- **描述**: 更新指定ID的社区帖子
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 帖子ID
- **请求参数**:

```json
{
  "title": "string", // 帖子标题，选填，最多100个字符
  "content": "string", // 帖子内容，选填
  "topicIds": ["guid"], // 话题ID列表，选填
  "isAnonymous": "boolean" // 是否匿名，选填
}
```

- **响应**:

```json
{
  "success": true,
  "message": "更新成功",
  "data": {
    "id": "guid", // 帖子ID
    "userId": "guid", // 用户ID
    "title": "string", // 帖子标题
    "content": "string", // 帖子内容
    "topics": [ // 话题列表
      {
        "id": "guid", // 话题ID
        "name": "string" // 话题名称
      }
    ],
    "mediaFiles": [ // 媒体文件列表
      {
        "id": "guid", // 媒体文件ID
        "mediaType": "string", // 媒体类型
        "mediaUrl": "string", // 媒体URL
        "description": "string", // 媒体描述
        "createdAt": "datetime" // 创建时间
      }
    ],
    "isAnonymous": "boolean", // 是否匿名
    "author": { // 作者信息
      "id": "guid", // 用户ID
      "nickname": "string", // 昵称
      "avatarUrl": "string", // 头像URL
      "pregnancyWeek": "integer" // 孕周
    },
    "viewCount": "integer", // 浏览次数
    "likeCount": "integer", // 点赞次数
    "commentCount": "integer", // 评论次数
    "createdAt": "datetime", // 创建时间
    "updatedAt": "datetime" // 更新时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 403: 禁止访问（尝试更新其他用户的帖子）
  - 404: 帖子不存在

### 5. 删除社区帖子

- **URL**: `/community/posts/{id}`
- **方法**: DELETE
- **描述**: 删除指定ID的社区帖子
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 帖子ID
- **响应**:

```json
{
  "success": true,
  "message": "删除成功"
}
```

- **错误码**:
  - 401: 未授权
  - 403: 禁止访问（尝试删除其他用户的帖子）
  - 404: 帖子不存在

### 6. 点赞社区帖子

- **URL**: `/community/posts/{id}/like`
- **方法**: POST
- **描述**: 点赞指定ID的社区帖子
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 帖子ID
- **响应**:

```json
{
  "success": true,
  "message": "操作成功",
  "data": {
    "id": "guid", // 帖子ID
    "likeCount": "integer" // 更新后的点赞次数
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 帖子不存在
  - 409: 已点赞

### 7. 取消点赞社区帖子

- **URL**: `/community/posts/{id}/unlike`
- **方法**: POST
- **描述**: 取消点赞指定ID的社区帖子
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 帖子ID
- **响应**:

```json
{
  "success": true,
  "message": "操作成功",
  "data": {
    "id": "guid", // 帖子ID
    "likeCount": "integer" // 更新后的点赞次数
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 帖子不存在或未点赞

### 8. 收藏社区帖子

- **URL**: `/community/posts/{id}/favorite`
- **方法**: POST
- **描述**: 收藏指定ID的社区帖子
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 帖子ID
- **响应**:

```json
{
  "success": true,
  "message": "操作成功",
  "data": {
    "id": "guid", // 收藏ID
    "postId": "guid", // 帖子ID
    "userId": "guid", // 用户ID
    "createdAt": "datetime" // 创建时间
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 帖子不存在
  - 409: 已收藏

### 9. 取消收藏社区帖子

- **URL**: `/community/posts/{id}/unfavorite`
- **方法**: POST
- **描述**: 取消收藏指定ID的社区帖子
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 帖子ID
- **响应**:

```json
{
  "success": true,
  "message": "操作成功"
}
```

- **错误码**:
  - 401: 未授权
  - 404: 帖子不存在或未收藏

### 10. 获取收藏的社区帖子列表

- **URL**: `/community/favorites`
- **方法**: GET
- **描述**: 获取当前登录用户收藏的社区帖子列表
- **请求头**: Authorization: Bearer {accessToken}
- **查询参数**:
  - page: 页码，默认为1
  - pageSize: 每页数量，默认为10
  - sortBy: 排序字段，可选值：createdAt、title，默认为createdAt
  - sortDirection: 排序方向，可选值：asc、desc，默认为desc
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "items": [
      {
        "id": "guid", // 帖子ID
        "userId": "guid", // 用户ID
        "title": "string", // 帖子标题
        "content": "string", // 帖子内容
        "topics": [ // 话题列表
          {
            "id": "guid", // 话题ID
            "name": "string" // 话题名称
          }
        ],
        "mediaFiles": [ // 媒体文件列表
          {
            "id": "guid", // 媒体文件ID
            "mediaType": "string", // 媒体类型
            "mediaUrl": "string", // 媒体URL
            "description": "string", // 媒体描述
            "createdAt": "datetime" // 创建时间
          }
        ],
        "isAnonymous": "boolean", // 是否匿名
        "author": { // 作者信息
          "id": "guid", // 用户ID
          "nickname": "string", // 昵称
          "avatarUrl": "string", // 头像URL
          "pregnancyWeek": "integer" // 孕周
        },
        "viewCount": "integer", // 浏览次数
        "likeCount": "integer", // 点赞次数
        "commentCount": "integer", // 评论次数
        "favoriteTime": "datetime", // 收藏时间
        "createdAt": "datetime", // 创建时间
        "updatedAt": "datetime" // 更新时间
      }
    ],
    "totalCount": "integer", // 总数量
    "pageCount": "integer", // 总页数
    "currentPage": "integer", // 当前页码
    "pageSize": "integer" // 每页数量
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 11. 添加社区帖子评论

- **URL**: `/community/posts/{id}/comments`
- **方法**: POST
- **描述**: 为指定ID的社区帖子添加评论
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 帖子ID
- **请求参数**:

```json
{
  "content": "string", // 评论内容，必填
  "isAnonymous": "boolean" // 是否匿名，选填，默认为false
}
```

- **响应**:

```json
{
  "success": true,
  "message": "创建成功",
  "data": {
    "id": "guid", // 评论ID
    "postId": "guid", // 帖子ID
    "userId": "guid", // 用户ID
    "content": "string", // 评论内容
    "isAnonymous": "boolean", // 是否匿名
    "author": { // 作者信息
      "id": "guid", // 用户ID
      "nickname": "string", // 昵称
      "avatarUrl": "string", // 头像URL
      "pregnancyWeek": "integer" // 孕周
    },
    "likeCount": "integer", // 点赞次数
    "createdAt": "datetime" // 创建时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 404: 帖子不存在

### 12. 回复社区帖子评论

- **URL**: `/community/comments/{id}/replies`
- **方法**: POST
- **描述**: 回复指定ID的社区帖子评论
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 评论ID
- **请求参数**:

```json
{
  "content": "string", // 回复内容，必填
  "replyToUserId": "guid", // 回复用户ID，必填
  "isAnonymous": "boolean" // 是否匿名，选填，默认为false
}
```

- **响应**:

```json
{
  "success": true,
  "message": "创建成功",
  "data": {
    "id": "guid", // 回复ID
    "commentId": "guid", // 评论ID
    "userId": "guid", // 用户ID
    "content": "string", // 回复内容
    "isAnonymous": "boolean", // 是否匿名
    "author": { // 作者信息
      "id": "guid", // 用户ID
      "nickname": "string", // 昵称
      "avatarUrl": "string", // 头像URL
      "pregnancyWeek": "integer" // 孕周
    },
    "replyToUserId": "guid", // 回复用户ID
    "replyToNickname": "string", // 回复用户昵称
    "likeCount": "integer", // 点赞次数
    "createdAt": "datetime" // 创建时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 404: 评论不存在

### 13. 点赞社区帖子评论

- **URL**: `/community/comments/{id}/like`
- **方法**: POST
- **描述**: 点赞指定ID的社区帖子评论
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 评论ID
- **响应**:

```json
{
  "success": true,
  "message": "操作成功",
  "data": {
    "id": "guid", // 评论ID
    "likeCount": "integer" // 更新后的点赞次数
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 评论不存在
  - 409: 已点赞

### 14. 取消点赞社区帖子评论

- **URL**: `/community/comments/{id}/unlike`
- **方法**: POST
- **描述**: 取消点赞指定ID的社区帖子评论
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 评论ID
- **响应**:

```json
{
  "success": true,
  "message": "操作成功",
  "data": {
    "id": "guid", // 评论ID
    "likeCount": "integer" // 更新后的点赞次数
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 评论不存在或未点赞

### 15. 获取社区话题列表

- **URL**: `/community/topics`
- **方法**: GET
- **描述**: 获取社区话题列表
- **请求头**: Authorization: Bearer {accessToken}
- **查询参数**:
  - page: 页码，默认为1
  - pageSize: 每页数量，默认为20
  - keyword: 关键词，选填
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "items": [
      {
        "id": "guid", // 话题ID
        "name": "string", // 话题名称
        "description": "string", // 话题描述
        "imageUrl": "string", // 话题图片URL
        "postCount": "integer", // 帖子数量
        "followerCount": "integer", // 关注者数量
        "isFollowed": "boolean", // 当前用户是否已关注
        "createdAt": "datetime" // 创建时间
      }
    ],
    "totalCount": "integer", // 总数量
    "pageCount": "integer", // 总页数
    "currentPage": "integer", // 当前页码
    "pageSize": "integer" // 每页数量
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 16. 关注社区话题

- **URL**: `/community/topics/{id}/follow`
- **方法**: POST
- **描述**: 关注指定ID的社区话题
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 话题ID
- **响应**:

```json
{
  "success": true,
  "message": "操作成功",
  "data": {
    "id": "guid", // 话题ID
    "followerCount": "integer" // 更新后的关注者数量
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 话题不存在
  - 409: 已关注

### 17. 取消关注社区话题

- **URL**: `/community/topics/{id}/unfollow`
- **方法**: POST
- **描述**: 取消关注指定ID的社区话题
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 话题ID
- **响应**:

```json
{
  "success": true,
  "message": "操作成功",
  "data": {
    "id": "guid", // 话题ID
    "followerCount": "integer" // 更新后的关注者数量
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 话题不存在或未关注

## 十一、产检管家API

### 1. 创建产检计划

- **URL**: `/prenatalcare/plans`
- **方法**: POST
- **描述**: 创建产检计划
- **请求头**: Authorization: Bearer {accessToken}
- **请求参数**:

```json
{
  "name": "string", // 计划名称，必填，最多50个字符
  "description": "string", // 计划描述，选填
  "hospitalId": "guid", // 医院ID，必填
  "doctorId": "guid", // 医生ID，选填
  "startDate": "date", // 开始日期，必填，不能早于今天
  "endDate": "date", // 结束日期，必填，不能早于开始日期
  "checkupItems": [ // 产检项目列表，必填
    {
      "name": "string", // 项目名称，必填
      "description": "string", // 项目描述，选填
      "scheduledDate": "date", // 计划日期，必填，不能早于开始日期且不能晚于结束日期
      "pregnancyWeek": "integer", // 孕周，必填，1-42周
      "isRequired": "boolean", // 是否必须，选填，默认为true
      "note": "string" // 备注，选填
    }
  ]
}
```

- **响应**:

```json
{
  "success": true,
  "message": "创建成功",
  "data": {
    "id": "guid", // 计划ID
    "userId": "guid", // 用户ID
    "name": "string", // 计划名称
    "description": "string", // 计划描述
    "hospital": { // 医院信息
      "id": "guid", // 医院ID
      "name": "string", // 医院名称
      "address": "string", // 医院地址
      "phone": "string", // 医院电话
      "level": "string" // 医院等级
    },
    "doctor": { // 医生信息
      "id": "guid", // 医生ID
      "name": "string", // 医生姓名
      "title": "string", // 医生职称
      "department": "string", // 科室
      "phone": "string" // 医生电话
    },
    "startDate": "date", // 开始日期
    "endDate": "date", // 结束日期
    "checkupItems": [ // 产检项目列表
      {
        "id": "guid", // 项目ID
        "name": "string", // 项目名称
        "description": "string", // 项目描述
        "scheduledDate": "date", // 计划日期
        "pregnancyWeek": "integer", // 孕周
        "isRequired": "boolean", // 是否必须
        "status": "string", // 状态，可选值：Pending、Completed、Missed
        "note": "string", // 备注
        "completedDate": "date", // 完成日期
        "result": "string", // 检查结果
        "resultFiles": [ // 结果文件列表
          {
            "id": "guid", // 文件ID
            "fileType": "string", // 文件类型
            "fileUrl": "string", // 文件URL
            "description": "string", // 文件描述
            "uploadedAt": "datetime" // 上传时间
          }
        ]
      }
    ],
    "createdAt": "datetime", // 创建时间
    "updatedAt": "datetime" // 更新时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 2. 获取产检计划

- **URL**: `/prenatalcare/plans/{id}`
- **方法**: GET
- **描述**: 获取指定ID的产检计划
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 计划ID
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "id": "guid", // 计划ID
    "userId": "guid", // 用户ID
    "name": "string", // 计划名称
    "description": "string", // 计划描述
    "hospital": { // 医院信息
      "id": "guid", // 医院ID
      "name": "string", // 医院名称
      "address": "string", // 医院地址
      "phone": "string", // 医院电话
      "level": "string" // 医院等级
    },
    "doctor": { // 医生信息
      "id": "guid", // 医生ID
      "name": "string", // 医生姓名
      "title": "string", // 医生职称
      "department": "string", // 科室
      "phone": "string" // 医生电话
    },
    "startDate": "date", // 开始日期
    "endDate": "date", // 结束日期
    "checkupItems": [ // 产检项目列表
      {
        "id": "guid", // 项目ID
        "name": "string", // 项目名称
        "description": "string", // 项目描述
        "scheduledDate": "date", // 计划日期
        "pregnancyWeek": "integer", // 孕周
        "isRequired": "boolean", // 是否必须
        "status": "string", // 状态，可选值：Pending、Completed、Missed
        "note": "string", // 备注
        "completedDate": "date", // 完成日期
        "result": "string", // 检查结果
        "resultFiles": [ // 结果文件列表
          {
            "id": "guid", // 文件ID
            "fileType": "string", // 文件类型
            "fileUrl": "string", // 文件URL
            "description": "string", // 文件描述
            "uploadedAt": "datetime" // 上传时间
          }
        ]
      }
    ],
    "createdAt": "datetime", // 创建时间
    "updatedAt": "datetime" // 更新时间
  }
}
```

- **错误码**:
  - 401: 未授权
  - 403: 禁止访问（尝试访问其他用户的计划）
  - 404: 计划不存在

### 3. 获取用户所有产检计划

- **URL**: `/prenatalcare/plans`
- **方法**: GET
- **描述**: 获取当前登录用户的所有产检计划
- **请求头**: Authorization: Bearer {accessToken}
- **查询参数**:
  - page: 页码，默认为1
  - pageSize: 每页数量，默认为10
  - sortBy: 排序字段，可选值：startDate、createdAt，默认为startDate
  - sortDirection: 排序方向，可选值：asc、desc，默认为asc
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "items": [
      {
        "id": "guid", // 计划ID
        "userId": "guid", // 用户ID
        "name": "string", // 计划名称
        "description": "string", // 计划描述
        "hospital": { // 医院信息
          "id": "guid", // 医院ID
          "name": "string", // 医院名称
          "address": "string", // 医院地址
          "phone": "string", // 医院电话
          "level": "string" // 医院等级
        },
        "doctor": { // 医生信息
          "id": "guid", // 医生ID
          "name": "string", // 医生姓名
          "title": "string", // 医生职称
          "department": "string", // 科室
          "phone": "string" // 医生电话
        },
        "startDate": "date", // 开始日期
        "endDate": "date", // 结束日期
        "nextCheckupDate": "date", // 下次产检日期
        "nextCheckupItem": "string", // 下次产检项目
        "completedCount": "integer", // 已完成项目数量
        "totalCount": "integer", // 总项目数量
        "createdAt": "datetime", // 创建时间
        "updatedAt": "datetime" // 更新时间
      }
    ],
    "totalCount": "integer", // 总数量
    "pageCount": "integer", // 总页数
    "currentPage": "integer", // 当前页码
    "pageSize": "integer" // 每页数量
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 4. 更新产检计划

- **URL**: `/prenatalcare/plans/{id}`
- **方法**: PUT
- **描述**: 更新指定ID的产检计划
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 计划ID
- **请求参数**:

```json
{
  "name": "string", // 计划名称，选填，最多50个字符
  "description": "string", // 计划描述，选填
  "hospitalId": "guid", // 医院ID，选填
  "doctorId": "guid", // 医生ID，选填
  "startDate": "date", // 开始日期，选填，不能早于今天
  "endDate": "date" // 结束日期，选填，不能早于开始日期
}
```

- **响应**:

```json
{
  "success": true,
  "message": "更新成功",
  "data": {
    "id": "guid", // 计划ID
    "userId": "guid", // 用户ID
    "name": "string", // 计划名称
    "description": "string", // 计划描述
    "hospital": { // 医院信息
      "id": "guid", // 医院ID
      "name": "string", // 医院名称
      "address": "string", // 医院地址
      "phone": "string", // 医院电话
      "level": "string" // 医院等级
    },
    "doctor": { // 医生信息
      "id": "guid", // 医生ID
      "name": "string", // 医生姓名
      "title": "string", // 医生职称
      "department": "string", // 科室
      "phone": "string" // 医生电话
    },
    "startDate": "date", // 开始日期
    "endDate": "date", // 结束日期
    "checkupItems": [ // 产检项目列表
      {
        "id": "guid", // 项目ID
        "name": "string", // 项目名称
        "description": "string", // 项目描述
        "scheduledDate": "date", // 计划日期
        "pregnancyWeek": "integer", // 孕周
        "isRequired": "boolean", // 是否必须
        "status": "string", // 状态，可选值：Pending、Completed、Missed
        "note": "string", // 备注
        "completedDate": "date", // 完成日期
        "result": "string", // 检查结果
        "resultFiles": [ // 结果文件列表
          {
            "id": "guid", // 文件ID
            "fileType": "string", // 文件类型
            "fileUrl": "string", // 文件URL
            "description": "string", // 文件描述
            "uploadedAt": "datetime" // 上传时间
          }
        ]
      }
    ],
    "createdAt": "datetime", // 创建时间
    "updatedAt": "datetime" // 更新时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 403: 禁止访问（尝试更新其他用户的计划）
  - 404: 计划不存在

### 5. 删除产检计划

- **URL**: `/prenatalcare/plans/{id}`
- **方法**: DELETE
- **描述**: 删除指定ID的产检计划
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 计划ID
- **响应**:

```json
{
  "success": true,
  "message": "删除成功"
}
```

- **错误码**:
  - 401: 未授权
  - 403: 禁止访问（尝试删除其他用户的计划）
  - 404: 计划不存在

### 6. 添加产检项目

- **URL**: `/prenatalcare/plans/{id}/items`
- **方法**: POST
- **描述**: 为指定ID的产检计划添加产检项目
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 计划ID
- **请求参数**:

```json
{
  "name": "string", // 项目名称，必填
  "description": "string", // 项目描述，选填
  "scheduledDate": "date", // 计划日期，必填，不能早于计划开始日期且不能晚于计划结束日期
  "pregnancyWeek": "integer", // 孕周，必填，1-42周
  "isRequired": "boolean", // 是否必须，选填，默认为true
  "note": "string" // 备注，选填
}
```

- **响应**:

```json
{
  "success": true,
  "message": "操作成功",
  "data": {
    "id": "guid", // 项目ID
    "planId": "guid", // 计划ID
    "name": "string", // 项目名称
    "description": "string", // 项目描述
    "scheduledDate": "date", // 计划日期
    "pregnancyWeek": "integer", // 孕周
    "isRequired": "boolean", // 是否必须
    "status": "string", // 状态，可选值：Pending、Completed、Missed
    "note": "string", // 备注
    "createdAt": "datetime" // 创建时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 403: 禁止访问（尝试更新其他用户的计划）
  - 404: 计划不存在

### 7. 更新产检项目

- **URL**: `/prenatalcare/items/{id}`
- **方法**: PUT
- **描述**: 更新指定ID的产检项目
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 项目ID
- **请求参数**:

```json
{
  "name": "string", // 项目名称，选填
  "description": "string", // 项目描述，选填
  "scheduledDate": "date", // 计划日期，选填，不能早于计划开始日期且不能晚于计划结束日期
  "pregnancyWeek": "integer", // 孕周，选填，1-42周
  "isRequired": "boolean", // 是否必须，选填
  "status": "string", // 状态，选填，可选值：Pending、Completed、Missed
  "note": "string", // 备注，选填
  "completedDate": "date", // 完成日期，选填，当status为Completed时必填
  "result": "string" // 检查结果，选填
}
```

- **响应**:

```json
{
  "success": true,
  "message": "更新成功",
  "data": {
    "id": "guid", // 项目ID
    "planId": "guid", // 计划ID
    "name": "string", // 项目名称
    "description": "string", // 项目描述
    "scheduledDate": "date", // 计划日期
    "pregnancyWeek": "integer", // 孕周
    "isRequired": "boolean", // 是否必须
    "status": "string", // 状态，可选值：Pending、Completed、Missed
    "note": "string", // 备注
    "completedDate": "date", // 完成日期
    "result": "string", // 检查结果
    "resultFiles": [ // 结果文件列表
      {
        "id": "guid", // 文件ID
        "fileType": "string", // 文件类型
        "fileUrl": "string", // 文件URL
        "description": "string", // 文件描述
        "uploadedAt": "datetime" // 上传时间
      }
    ],
    "createdAt": "datetime", // 创建时间
    "updatedAt": "datetime" // 更新时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 403: 禁止访问（尝试更新其他用户的项目）
  - 404: 项目不存在

### 8. 删除产检项目

- **URL**: `/prenatalcare/items/{id}`
- **方法**: DELETE
- **描述**: 删除指定ID的产检项目
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 项目ID
- **响应**:

```json
{
  "success": true,
  "message": "删除成功"
}
```

- **错误码**:
  - 401: 未授权
  - 403: 禁止访问（尝试删除其他用户的项目）
  - 404: 项目不存在

### 9. 上传产检结果文件

- **URL**: `/prenatalcare/items/{id}/files`
- **方法**: POST
- **描述**: 为指定ID的产检项目上传结果文件
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 项目ID
- **请求参数**:

```json
{
  "fileType": "string", // 文件类型，必填，可选值：Image、Document、Report
  "fileUrl": "string", // 文件URL，必填
  "description": "string" // 文件描述，选填
}
```

- **响应**:

```json
{
  "success": true,
  "message": "操作成功",
  "data": {
    "id": "guid", // 文件ID
    "itemId": "guid", // 项目ID
    "fileType": "string", // 文件类型
    "fileUrl": "string", // 文件URL
    "description": "string", // 文件描述
    "uploadedAt": "datetime" // 上传时间
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权
  - 403: 禁止访问（尝试更新其他用户的项目）
  - 404: 项目不存在

### 10. 删除产检结果文件

- **URL**: `/prenatalcare/files/{id}`
- **方法**: DELETE
- **描述**: 删除指定ID的产检结果文件
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 文件ID
- **响应**:

```json
{
  "success": true,
  "message": "删除成功"
}
```

- **错误码**:
  - 401: 未授权
  - 403: 禁止访问（尝试删除其他用户的文件）
  - 404: 文件不存在

### 11. 获取医院列表

- **URL**: `/prenatalcare/hospitals`
- **方法**: GET
- **描述**: 获取医院列表
- **请求头**: Authorization: Bearer {accessToken}
- **查询参数**:
  - page: 页码，默认为1
  - pageSize: 每页数量，默认为20
  - keyword: 关键词，选填
  - city: 城市，选填
  - level: 医院等级，选填，可选值：一级、二级、三级
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "items": [
      {
        "id": "guid", // 医院ID
        "name": "string", // 医院名称
        "address": "string", // 医院地址
        "phone": "string", // 医院电话
        "level": "string", // 医院等级
        "city": "string", // 城市
        "province": "string", // 省份
        "description": "string", // 医院描述
        "imageUrl": "string", // 医院图片URL
        "departments": ["string"], // 科室列表
        "createdAt": "datetime" // 创建时间
      }
    ],
    "totalCount": "integer", // 总数量
    "pageCount": "integer", // 总页数
    "currentPage": "integer", // 当前页码
    "pageSize": "integer" // 每页数量
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 12. 获取医院详情

- **URL**: `/prenatalcare/hospitals/{id}`
- **方法**: GET
- **描述**: 获取指定ID的医院详情
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 医院ID
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "id": "guid", // 医院ID
    "name": "string", // 医院名称
    "address": "string", // 医院地址
    "phone": "string", // 医院电话
    "level": "string", // 医院等级
    "city": "string", // 城市
    "province": "string", // 省份
    "description": "string", // 医院描述
    "imageUrl": "string", // 医院图片URL
    "departments": [ // 科室列表
      {
        "id": "guid", // 科室ID
        "name": "string", // 科室名称
        "description": "string" // 科室描述
      }
    ],
    "doctors": [ // 医生列表
      {
        "id": "guid", // 医生ID
        "name": "string", // 医生姓名
        "title": "string", // 医生职称
        "department": "string", // 科室
        "phone": "string", // 医生电话
        "imageUrl": "string", // 医生图片URL
        "description": "string" // 医生描述
      }
    ],
    "createdAt": "datetime" // 创建时间
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 医院不存在

### 13. 获取医生列表

- **URL**: `/prenatalcare/doctors`
- **方法**: GET
- **描述**: 获取医生列表
- **请求头**: Authorization: Bearer {accessToken}
- **查询参数**:
  - page: 页码，默认为1
  - pageSize: 每页数量，默认为20
  - keyword: 关键词，选填
  - hospitalId: 医院ID，选填
  - department: 科室，选填
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "items": [
      {
        "id": "guid", // 医生ID
        "name": "string", // 医生姓名
        "title": "string", // 医生职称
        "department": "string", // 科室
        "phone": "string", // 医生电话
        "imageUrl": "string", // 医生图片URL
        "description": "string", // 医生描述
        "hospital": { // 医院信息
          "id": "guid", // 医院ID
          "name": "string", // 医院名称
          "level": "string" // 医院等级
        },
        "createdAt": "datetime" // 创建时间
      }
    ],
    "totalCount": "integer", // 总数量
    "pageCount": "integer", // 总页数
    "currentPage": "integer", // 当前页码
    "pageSize": "integer" // 每页数量
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权

### 14. 获取医生详情

- **URL**: `/prenatalcare/doctors/{id}`
- **方法**: GET
- **描述**: 获取指定ID的医生详情
- **请求头**: Authorization: Bearer {accessToken}
- **路径参数**:
  - id: 医生ID
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "id": "guid", // 医生ID
    "name": "string", // 医生姓名
    "title": "string", // 医生职称
    "department": "string", // 科室
    "phone": "string", // 医生电话
    "imageUrl": "string", // 医生图片URL
    "description": "string", // 医生描述
    "specialties": ["string"], // 专长列表
    "education": "string", // 教育背景
    "experience": "string", // 工作经验
    "hospital": { // 医院信息
      "id": "guid", // 医院ID
      "name": "string", // 医院名称
      "address": "string", // 医院地址
      "phone": "string", // 医院电话
      "level": "string" // 医院等级
    },
    "createdAt": "datetime" // 创建时间
  }
}
```

- **错误码**:
  - 401: 未授权
  - 404: 医生不存在

### 15. 获取产检项目推荐

- **URL**: `/prenatalcare/recommendations`
- **方法**: GET
- **描述**: 获取产检项目推荐
- **请求头**: Authorization: Bearer {accessToken}
- **查询参数**:
  - pregnancyWeek: 孕周，必填，1-42周
- **响应**:

```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "pregnancyWeek": "integer", // 孕周
    "items": [
      {
        "name": "string", // 项目名称
        "description": "string", // 项目描述
        "isRequired": "boolean", // 是否必须
        "note": "string" // 备注
      }
    ],
    "tips": "string" // 提示信息
  }
}
```

- **错误码**:
  - 400: 请求参数无效
  - 401: 未授权