# 腾讯云COS配置总结

## 概述
腾讯云COS（Cloud Object Storage）是腾讯云提供的对象存储服务，适用于存储和分发任意类型的文件。在孕期大作战项目中，我们使用腾讯云COS来存储用户上传的媒体文件，如孕期日记中的图片和视频。

## 配置信息

### 1. COS服务配置
在`appsettings.json`中配置腾讯云COS相关信息：

```json
{
  "TencentCos": {
    "SecretId": "YOUR_SECRET_ID_HERE",
    "SecretKey": "YOUR_SECRET_KEY_HERE",
    "BucketName": "YOUR_BUCKET_NAME_HERE",
    "Region": "YOUR_REGION_HERE",
    "BaseUrl": ""
  }
}
```

### 2. 配置说明

| 配置项 | 说明 | 示例值 |
|--------|------|--------|
| SecretId | 腾讯云API密钥的SecretId | AKID... |
| SecretKey | 腾讯云API密钥的SecretKey | ... |
| BucketName | COS存储桶名称 | your-bucket-name |
| Region | 存储桶所在地域 | ap-chengdu |
| BaseUrl | 自定义域名（可选） | https://your-domain.com |

## 安全注意事项

⚠️ **重要提醒**：
- **永远不要将真实的SecretId和SecretKey提交到代码仓库**
- 使用环境变量或配置管理服务来管理敏感信息
- 在生产环境中，建议使用腾讯云的临时密钥机制

### 环境变量配置示例

```bash
export TENCENT_COS_SECRET_ID="your_actual_secret_id"
export TENCENT_COS_SECRET_KEY="your_actual_secret_key"
```

然后在代码中读取环境变量：

```csharp
builder.Configuration["TencentCos:SecretId"] = Environment.GetEnvironmentVariable("TENCENT_COS_SECRET_ID");
builder.Configuration["TencentCos:SecretKey"] = Environment.GetEnvironmentVariable("TENCENT_COS_SECRET_KEY");
```

## 实现说明

### 1. 服务接口
`IFileStorageService` 接口定义了文件存储的基本操作：
- 上传文件
- 删除文件
- 获取文件URL

### 2. 腾讯云COS实现
`TencentCosStorageService` 类实现了 `IFileStorageService` 接口，提供具体的腾讯云COS操作功能。

### 3. 控制器使用
在 `FilesController` 中使用文件存储服务来处理文件上传请求。

## 使用指南

### 1. 获取腾讯云密钥
1. 登录腾讯云控制台
2. 访问 [API密钥管理](https://console.cloud.tencent.com/cam/capi)
3. 创建新的API密钥，获取SecretId和SecretKey

### 2. 创建COS存储桶
1. 登录腾讯云控制台
2. 访问 [对象存储控制台](https://console.cloud.tencent.com/cos5)
3. 创建存储桶，选择合适的地域
4. 配置存储桶权限（建议设置为私有读写）

### 3. 配置域名（可选）
如果需要使用自定义域名：
1. 在COS控制台中配置自定义域名
2. 将BaseUrl设置为自定义域名

## 故障排查

### 常见错误及解决方案

1. **签名错误**
   - 检查SecretId和SecretKey是否正确
   - 确认时间同步正确

2. **权限错误**
   - 检查API密钥是否有COS操作权限
   - 确认存储桶权限设置

3. **网络错误**
   - 检查网络连接
   - 确认地域配置正确

## 费用说明

腾讯云COS按使用量计费，主要包括：
- 存储费用：根据存储的数据量计算
- 请求费用：根据API请求次数计算
- 流量费用：根据下载流量计算

建议定期监控使用量，合理控制成本。

## 最佳实践

1. **文件命名规范**
   - 使用有意义的文件名
   - 按日期/用户ID组织目录结构

2. **文件大小限制**
   - 设置合理的文件大小限制
   - 对大文件进行压缩处理

3. **安全措施**
   - 定期轮换API密钥
   - 使用防盗链功能
   - 配置适当的CORS策略

4. **性能优化**
   - 选择就近的存储地域
   - 使用CDN加速访问
   - 合理设置缓存策略

## 相关文档

- [腾讯云COS官方文档](https://cloud.tencent.com/document/product/436)
- [腾讯云COS .NET SDK](https://cloud.tencent.com/document/product/436/32819)
- [API密钥管理文档](https://cloud.tencent.com/document/product/598/40488)

## 版本历史

- v1.0 (2024-05-30): 初始版本，支持基本的文件上传和删除功能
- 后续版本将支持更多高级功能，如图片处理、视频转码等