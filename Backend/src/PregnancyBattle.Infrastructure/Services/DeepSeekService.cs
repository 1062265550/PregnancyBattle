using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Application.Models;
using PregnancyBattle.Application.Services.Interfaces;

namespace PregnancyBattle.Infrastructure.Services
{
    /// <summary>
    /// DeepSeek AI服务实现
    /// </summary>
    public class DeepSeekService : IDeepSeekService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;
        private readonly ILogger<DeepSeekService> _logger;
        private readonly string _apiKey;
        private readonly string _baseUrl;

        public DeepSeekService(
            HttpClient httpClient,
            IConfiguration configuration,
            ILogger<DeepSeekService> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _logger = logger;
            _apiKey = configuration["DeepSeek:ApiKey"] ?? "sk-335bd568c4994abda7306900f4565196";
            _baseUrl = configuration["DeepSeek:BaseUrl"] ?? "https://api.deepseek.com/v1";

            _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {_apiKey}");
            _httpClient.DefaultRequestHeaders.Add("User-Agent", "PregnancyBattle/1.0");
        }

        public async Task<ServiceResult<HealthRiskAnalysisDto>> GenerateHealthRiskAnalysisAsync(
            HealthProfileDto healthProfile,
            PregnancyInfoDto? pregnancyInfo = null)
        {
            try
            {
                var prompt = BuildHealthAnalysisPrompt(healthProfile, pregnancyInfo);
                var response = await CallDeepSeekApiAsync(prompt);

                if (response == null)
                {
                    return ServiceResult<HealthRiskAnalysisDto>.FailureResult("AI服务暂时不可用", "ServiceUnavailable");
                }

                var analysis = ParseHealthAnalysisResponse(response);
                return ServiceResult<HealthRiskAnalysisDto>.SuccessResult(analysis);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "生成健康风险分析时发生错误");
                return ServiceResult<HealthRiskAnalysisDto>.FailureResult("生成分析失败", "InternalError");
            }
        }

        public async Task<ServiceResult<PersonalizedRecommendationsDto>> GeneratePersonalizedRecommendationsAsync(
            HealthProfileDto healthProfile,
            PregnancyInfoDto? pregnancyInfo,
            List<string> riskFactors)
        {
            try
            {
                var prompt = BuildRecommendationsPrompt(healthProfile, pregnancyInfo, riskFactors);
                var response = await CallDeepSeekApiAsync(prompt);

                if (response == null)
                {
                    return ServiceResult<PersonalizedRecommendationsDto>.FailureResult("AI服务暂时不可用", "ServiceUnavailable");
                }

                var recommendations = ParseRecommendationsResponse(response);
                return ServiceResult<PersonalizedRecommendationsDto>.SuccessResult(recommendations);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "生成个性化建议时发生错误");
                return ServiceResult<PersonalizedRecommendationsDto>.FailureResult("生成建议失败", "InternalError");
            }
        }

        public async Task<bool> IsServiceAvailableAsync()
        {
            try
            {
                var testPrompt = "请回复'服务正常'";
                var response = await CallDeepSeekApiAsync(testPrompt);
                return !string.IsNullOrEmpty(response);
            }
            catch
            {
                return false;
            }
        }

        private string BuildHealthAnalysisPrompt(HealthProfileDto healthProfile, PregnancyInfoDto? pregnancyInfo)
        {
            var currentWeek = pregnancyInfo?.CurrentWeek ?? 0;
            var pregnancyStage = pregnancyInfo?.PregnancyStage ?? "未知";
            var weightGain = healthProfile.CurrentWeight - healthProfile.PrePregnancyWeight;

            var prompt = $@"
作为专业的妇产科医生，请基于以下孕妇健康档案信息，提供详细的健康风险评估分析。

**患者基本信息：**
- 年龄：{healthProfile.Age}岁
- 身高：{healthProfile.Height}cm
- 孕前体重：{healthProfile.PrePregnancyWeight}kg
- 当前体重：{healthProfile.CurrentWeight}kg
- 体重变化：{(weightGain >= 0 ? "+" : "")}{weightGain:F1}kg
- BMI：{healthProfile.Bmi:F1}
- 血型：{healthProfile.BloodType}
- 当前孕周：{currentWeek}周
- 孕期阶段：{pregnancyStage}

**健康史信息：**
- 个人病史：{healthProfile.MedicalHistory ?? "无"}
- 家族病史：{healthProfile.FamilyHistory ?? "无"}
- 过敏史：{healthProfile.AllergiesHistory ?? "无"}
- 既往孕产史：{healthProfile.ObstetricHistory ?? "无"}
- 吸烟情况：{(healthProfile.IsSmoking ? "是" : "否")}
- 饮酒情况：{(healthProfile.IsDrinking ? "是" : "否")}

请按照以下JSON格式返回详细分析结果，必须包含至少4个详细分析项：
{{
  ""overallAssessment"": ""基于以上信息的整体健康状况评估，包括主要风险点和优势，120字以内"",
  ""detailedAnalyses"": [
    {{
      ""category"": ""BMI与体重管理"",
      ""dataValue"": ""BMI {healthProfile.Bmi:F1}，体重变化{(weightGain >= 0 ? "+" : "")}{weightGain:F1}kg"",
      ""analysis"": ""详细分析BMI状况和体重变化趋势，是否在正常范围内，80字以内"",
      ""impact"": ""对母体和胎儿的具体影响，包括并发症风险，60字以内"",
      ""recommendation"": ""具体的体重管理建议，包括目标体重增长范围，60字以内"",
      ""severity"": ""低/中/高""
    }},
    {{
      ""category"": ""年龄相关风险"",
      ""dataValue"": ""{healthProfile.Age}岁"",
      ""analysis"": ""分析年龄对孕期的影响，是否属于高龄产妇，相关风险评估，80字以内"",
      ""impact"": ""年龄因素对妊娠结局的影响，包括胎儿和母体风险，60字以内"",
      ""recommendation"": ""针对年龄的具体监测和预防建议，60字以内"",
      ""severity"": ""低/中/高""
    }},
    {{
      ""category"": ""生活习惯评估"",
      ""dataValue"": ""吸烟：{(healthProfile.IsSmoking ? "是" : "否")}，饮酒：{(healthProfile.IsDrinking ? "是" : "否")}"",
      ""analysis"": ""评估生活习惯对孕期的影响，包括吸烟饮酒等不良习惯，80字以内"",
      ""impact"": ""不良生活习惯对胎儿发育和母体健康的具体影响，60字以内"",
      ""recommendation"": ""生活方式改善的具体建议和戒除方法，60字以内"",
      ""severity"": ""低/中/高""
    }},
    {{
      ""category"": ""病史风险分析"",
      ""dataValue"": ""个人病史：{(string.IsNullOrEmpty(healthProfile.MedicalHistory) ? "无" : "有")}，家族史：{(string.IsNullOrEmpty(healthProfile.FamilyHistory) ? "无" : "有")}"",
      ""analysis"": ""分析个人病史和家族史对当前妊娠的影响和风险，80字以内"",
      ""impact"": ""既往病史对孕期并发症和胎儿健康的潜在影响，60字以内"",
      ""recommendation"": ""针对病史的监测建议和预防措施，60字以内"",
      ""severity"": ""低/中/高""
    }}
  ],
  ""comprehensiveRecommendation"": ""综合以上分析，提供全面的孕期健康管理建议，包括重点关注事项和行动计划，150字以内"",
  ""riskScore"": 1到10的整数风险评分,
  ""riskLevel"": ""低/中/高""
}}

**重要要求：**
1. 必须严格按照JSON格式返回，不要添加任何其他文字
2. 所有字段都必须有实际内容，不能为空
3. 分析要专业准确，基于循证医学
4. 语言通俗易懂，避免过于专业的术语
5. 建议要具体可行，有实际指导意义
6. 风险评分要客观合理，综合考虑所有因素
7. 每个分析项的内容要详细充实，不能过于简单
";

            return prompt;
        }

        private string BuildRecommendationsPrompt(HealthProfileDto healthProfile, PregnancyInfoDto? pregnancyInfo, List<string> riskFactors)
        {
            var currentWeek = pregnancyInfo?.CurrentWeek ?? 0;
            var riskFactorsText = string.Join("、", riskFactors);
            var weightGain = healthProfile.CurrentWeight - healthProfile.PrePregnancyWeight;

            var prompt = $@"
作为专业的妇产科医生和营养师，请基于以下孕妇信息和识别的风险因素，提供详细的个性化健康管理建议。

**患者详细信息：**
- 年龄：{healthProfile.Age}岁
- BMI：{healthProfile.Bmi:F1}
- 身高：{healthProfile.Height}cm
- 孕前体重：{healthProfile.PrePregnancyWeight}kg
- 当前体重：{healthProfile.CurrentWeight}kg
- 体重变化：{(weightGain >= 0 ? "+" : "")}{weightGain:F1}kg
- 当前孕周：{currentWeek}周
- 识别的风险因素：{(riskFactors.Any() ? riskFactorsText : "无特殊风险因素")}

**健康状况：**
- 个人病史：{healthProfile.MedicalHistory ?? "无"}
- 家族病史：{healthProfile.FamilyHistory ?? "无"}
- 过敏史：{healthProfile.AllergiesHistory ?? "无"}
- 既往孕产史：{healthProfile.ObstetricHistory ?? "无"}
- 生活习惯：吸烟({(healthProfile.IsSmoking ? "是" : "否")})、饮酒({(healthProfile.IsDrinking ? "是" : "否")})

请按照以下JSON格式返回详细的个性化建议，必须包含至少5个分类建议：
{{
  ""categoryRecommendations"": [
    {{
      ""category"": ""营养管理"",
      ""title"": ""个性化营养指导方案"",
      ""description"": ""基于当前BMI和孕周的详细营养管理建议，包括每日营养需求和饮食搭配，120字以内"",
      ""priority"": ""高"",
      ""actionItems"": [""每日蛋白质摄入建议"", ""叶酸和维生素补充方案"", ""钙铁锌等微量元素补充"", ""避免的食物清单""]
    }},
    {{
      ""category"": ""体重管理"",
      ""title"": ""科学体重控制方案"",
      ""description"": ""基于当前体重变化趋势的个性化体重管理计划，包括目标体重和监测频率，120字以内"",
      ""priority"": ""高"",
      ""actionItems"": [""每周体重增长目标"", ""体重监测频率"", ""饮食控制要点"", ""体重异常时的应对措施""]
    }},
    {{
      ""category"": ""运动健身"",
      ""title"": ""孕期安全运动计划"",
      ""description"": ""适合当前孕周和身体状况的运动建议，包括运动类型、强度和注意事项，120字以内"",
      ""priority"": ""中"",
      ""actionItems"": [""推荐的运动类型"", ""每周运动频率"", ""运动强度控制"", ""运动时的注意事项""]
    }},
    {{
      ""category"": ""生活方式"",
      ""title"": ""健康生活方式指导"",
      ""description"": ""包括作息调整、环境改善、心理健康等全方位生活方式建议，120字以内"",
      ""priority"": ""中"",
      ""actionItems"": [""作息时间安排"", ""环境安全要求"", ""压力管理方法"", ""社交活动建议""]
    }},
    {{
      ""category"": ""产检监测"",
      ""title"": ""个性化产检计划"",
      ""description"": ""基于风险因素的针对性产检和监测建议，包括检查项目和频率，120字以内"",
      ""priority"": ""高"",
      ""actionItems"": [""常规产检时间安排"", ""特殊检查项目"", ""自我监测要点"", ""异常情况处理""]
    }}
  ],
  ""dietPlan"": ""详细的每日饮食计划，包括三餐搭配建议、营养重点和饮食禁忌，针对当前BMI和孕周特点，150字以内"",
  ""exercisePlan"": ""具体的运动计划，包括运动类型、时间安排、强度控制和安全注意事项，120字以内"",
  ""lifestyleAdjustments"": ""生活方式调整建议，包括作息、环境、心理健康等方面的具体改善措施，120字以内"",
  ""monitoringAdvice"": ""日常监测建议，包括体重、血压、胎动等自我监测要点和频率，100字以内"",
  ""warningSignsToWatch"": [""异常阴道出血或分泌物"", ""剧烈腹痛或子宫收缩"", ""持续头痛或视力模糊"", ""胎动异常减少或消失"", ""严重恶心呕吐影响进食"", ""发热超过38度""]
}}

**重要要求：**
1. 必须严格按照JSON格式返回，不要添加任何其他文字
2. 所有字段都必须有详细实际内容，不能为空或过于简单
3. 建议要针对性强，基于具体的风险因素和个人情况
4. 行动项要具体可操作，有实际指导价值
5. 优先级要合理设置，反映建议的重要程度
6. 警告信号要全面，涵盖孕期常见的危险征象
7. 内容要专业准确，符合最新的孕期保健指南
";

            return prompt;
        }

        private async Task<string?> CallDeepSeekApiAsync(string prompt)
        {
            try
            {
                var requestBody = new
                {
                    model = "deepseek-chat",
                    messages = new[]
                    {
                        new { role = "system", content = "你是一位专业的妇产科医生，具有丰富的孕期健康管理经验。请严格按照用户要求的JSON格式返回详细的医疗建议，确保所有字段都有内容。" },
                        new { role = "user", content = prompt }
                    },
                    temperature = 0.3,
                    max_tokens = 3000, // 增加token数量以支持详细内容
                    top_p = 0.9,
                    stream = false // 明确指定非流式请求
                };

                var json = JsonSerializer.Serialize(requestBody);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                _logger.LogInformation("开始调用DeepSeek API...");
                var startTime = DateTime.UtcNow;

                var response = await _httpClient.PostAsync($"{_baseUrl}/chat/completions", content);

                var elapsed = DateTime.UtcNow - startTime;
                _logger.LogInformation($"DeepSeek API调用耗时: {elapsed.TotalSeconds:F2}秒");

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogWarning($"DeepSeek API调用失败: {response.StatusCode}");
                    var errorContent = await response.Content.ReadAsStringAsync();
                    _logger.LogWarning($"错误详情: {errorContent}");
                    return null;
                }

                var responseContent = await response.Content.ReadAsStringAsync();

                // 处理可能的空行（根据文档说明）
                var cleanedContent = responseContent.Replace("\n\n", "\n").Trim();

                var responseObj = JsonSerializer.Deserialize<JsonElement>(cleanedContent);

                if (responseObj.TryGetProperty("choices", out var choices) &&
                    choices.GetArrayLength() > 0)
                {
                    var firstChoice = choices[0];
                    if (firstChoice.TryGetProperty("message", out var message) &&
                        message.TryGetProperty("content", out var messageContent))
                    {
                        var result = messageContent.GetString();
                        _logger.LogInformation($"DeepSeek API调用成功，返回内容长度: {result?.Length ?? 0}");
                        return result;
                    }
                }

                _logger.LogWarning("DeepSeek API响应格式异常");
                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "调用DeepSeek API时发生错误");
                return null;
            }
        }

        private HealthRiskAnalysisDto ParseHealthAnalysisResponse(string response)
        {
            try
            {
                _logger.LogInformation($"开始解析AI分析响应，响应长度: {response?.Length ?? 0}");

                if (string.IsNullOrWhiteSpace(response))
                {
                    _logger.LogWarning("AI分析响应为空");
                    return CreateFallbackAnalysis();
                }

                // 记录原始响应内容（截取前500字符用于调试）
                _logger.LogInformation($"AI分析响应内容预览: {response.Substring(0, Math.Min(500, response.Length))}...");

                // 尝试从响应中提取JSON
                var jsonStart = response.IndexOf('{');
                var jsonEnd = response.LastIndexOf('}');

                if (jsonStart >= 0 && jsonEnd > jsonStart)
                {
                    var jsonContent = response.Substring(jsonStart, jsonEnd - jsonStart + 1);
                    _logger.LogInformation($"提取的JSON内容长度: {jsonContent.Length}");

                    var options = new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true,
                        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                    };

                    var result = JsonSerializer.Deserialize<HealthRiskAnalysisDto>(jsonContent, options);

                    if (result != null)
                    {
                        _logger.LogInformation($"AI分析解析成功，包含 {result.DetailedAnalyses?.Count ?? 0} 个详细分析项");

                        // 验证解析结果的完整性
                        if (string.IsNullOrEmpty(result.OverallAssessment) ||
                            result.DetailedAnalyses == null ||
                            result.DetailedAnalyses.Count == 0)
                        {
                            _logger.LogWarning("AI分析解析结果不完整，使用备用分析");
                            return CreateFallbackAnalysis();
                        }

                        return result;
                    }
                }

                _logger.LogWarning("无法从响应中提取有效的JSON内容");
                return CreateFallbackAnalysis();
            }
            catch (JsonException ex)
            {
                _logger.LogError(ex, $"JSON解析失败: {ex.Message}");
                return CreateFallbackAnalysis();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "解析AI分析响应时发生未知错误");
                return CreateFallbackAnalysis();
            }
        }

        private PersonalizedRecommendationsDto ParseRecommendationsResponse(string response)
        {
            try
            {
                _logger.LogInformation($"开始解析个性化建议响应，响应长度: {response?.Length ?? 0}");

                if (string.IsNullOrWhiteSpace(response))
                {
                    _logger.LogWarning("个性化建议响应为空");
                    return CreateFallbackRecommendations();
                }

                // 记录原始响应内容（截取前500字符用于调试）
                _logger.LogInformation($"个性化建议响应内容预览: {response.Substring(0, Math.Min(500, response.Length))}...");

                var jsonStart = response.IndexOf('{');
                var jsonEnd = response.LastIndexOf('}');

                if (jsonStart >= 0 && jsonEnd > jsonStart)
                {
                    var jsonContent = response.Substring(jsonStart, jsonEnd - jsonStart + 1);
                    _logger.LogInformation($"提取的JSON内容长度: {jsonContent.Length}");

                    var options = new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true,
                        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                    };

                    var result = JsonSerializer.Deserialize<PersonalizedRecommendationsDto>(jsonContent, options);

                    if (result != null)
                    {
                        _logger.LogInformation($"个性化建议解析成功，包含 {result.CategoryRecommendations?.Count ?? 0} 个分类建议");

                        // 验证解析结果的完整性 - 只要有分类建议就认为是有效的
                        if (result.CategoryRecommendations == null ||
                            result.CategoryRecommendations.Count == 0)
                        {
                            _logger.LogWarning("个性化建议解析结果不完整，使用备用建议");
                            return CreateFallbackRecommendations();
                        }

                        // 如果某些字段为空，设置默认值
                        if (string.IsNullOrEmpty(result.DietPlan))
                        {
                            result.DietPlan = "请根据个人情况制定合理的饮食计划，建议咨询营养师获取专业指导。";
                        }
                        if (string.IsNullOrEmpty(result.ExercisePlan))
                        {
                            result.ExercisePlan = "请根据孕周和身体状况选择适合的运动方式，建议咨询医生获取专业指导。";
                        }
                        if (string.IsNullOrEmpty(result.LifestyleAdjustments))
                        {
                            result.LifestyleAdjustments = "保持健康的生活方式，规律作息，避免有害物质接触。";
                        }
                        if (string.IsNullOrEmpty(result.MonitoringAdvice))
                        {
                            result.MonitoringAdvice = "定期监测身体状况，按时产检，记录身体变化。";
                        }
                        if (result.WarningSignsToWatch == null || result.WarningSignsToWatch.Count == 0)
                        {
                            result.WarningSignsToWatch = new List<string> { "如有任何异常症状，请及时就医" };
                        }

                        return result;
                    }
                }

                _logger.LogWarning("无法从响应中提取有效的JSON内容");
                return CreateFallbackRecommendations();
            }
            catch (JsonException ex)
            {
                _logger.LogError(ex, $"个性化建议JSON解析失败: {ex.Message}");
                return CreateFallbackRecommendations();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "解析个性化建议响应时发生未知错误");
                return CreateFallbackRecommendations();
            }
        }

        private HealthRiskAnalysisDto CreateFallbackAnalysis()
        {
            _logger.LogWarning("使用备用健康风险分析");
            return new HealthRiskAnalysisDto
            {
                OverallAssessment = "当前AI智能分析服务暂时不可用，系统已为您提供基础的健康评估。建议您咨询专业医生获取更详细的个性化评估和指导。",
                ComprehensiveRecommendation = "请定期进行产前检查，保持均衡饮食和适量运动，注意休息和心理健康。如有任何不适或疑问，请及时咨询您的产科医生。",
                RiskScore = 5,
                RiskLevel = "中",
                DetailedAnalyses = new List<DetailedAnalysisDto>
                {
                    new DetailedAnalysisDto
                    {
                        Category = "服务状态",
                        DataValue = "AI服务暂时不可用",
                        Analysis = "智能分析功能当前无法正常工作，可能是由于网络连接或服务器问题导致",
                        Impact = "无法提供个性化的详细健康风险分析",
                        Recommendation = "建议稍后重试或直接咨询专业医生",
                        Severity = "低"
                    },
                    new DetailedAnalysisDto
                    {
                        Category = "基础建议",
                        DataValue = "通用指导",
                        Analysis = "基于一般孕期保健原则，建议遵循标准的孕期健康管理要求",
                        Impact = "遵循基础建议有助于维护孕期健康",
                        Recommendation = "定期产检、均衡饮食、适量运动、充足休息",
                        Severity = "低"
                    }
                }
            };
        }

        private PersonalizedRecommendationsDto CreateFallbackRecommendations()
        {
            _logger.LogWarning("使用备用个性化建议");
            return new PersonalizedRecommendationsDto
            {
                DietPlan = "建议保持均衡饮食，每日摄入充足的蛋白质、维生素和矿物质。多吃新鲜蔬菜水果，适量补充叶酸、钙质和铁元素。避免生食、高汞鱼类和过量咖啡因。",
                ExercisePlan = "建议进行适量的孕期安全运动，如每日30分钟的散步、孕妇瑜伽或游泳。避免剧烈运动和有跌倒风险的活动，运动前请咨询医生。",
                LifestyleAdjustments = "保持规律作息，每晚7-9小时充足睡眠。避免吸烟饮酒，减少压力，保持心情愉悦。创造安全舒适的居住环境，避免接触有害化学物质。",
                MonitoringAdvice = "定期监测体重变化、血压和胎动情况。按时进行产前检查，记录身体变化和不适症状，及时与医生沟通。",
                WarningSignsToWatch = new List<string> {
                    "异常阴道出血或分泌物",
                    "剧烈腹痛或持续子宫收缩",
                    "持续头痛或视力模糊",
                    "胎动明显减少或消失",
                    "严重恶心呕吐影响进食",
                    "发热超过38度",
                    "呼吸困难或胸痛",
                    "严重水肿"
                },
                CategoryRecommendations = new List<CategoryRecommendationDto>
                {
                    new CategoryRecommendationDto
                    {
                        Category = "营养管理",
                        Title = "孕期营养基础指导",
                        Description = "AI个性化服务暂时不可用，以下是基于一般孕期营养需求的建议。请根据个人情况调整，并咨询营养师获取专业指导。",
                        Priority = "高",
                        ActionItems = new List<string> {
                            "每日补充叶酸400-800微克",
                            "增加蛋白质摄入至每日70-100克",
                            "补充钙质1000-1200毫克",
                            "避免生食和高汞鱼类"
                        }
                    },
                    new CategoryRecommendationDto
                    {
                        Category = "体重管理",
                        Title = "孕期体重控制基础方案",
                        Description = "根据孕前BMI合理控制体重增长，正常BMI孕妇建议整个孕期增重11.5-16公斤。具体目标请咨询医生。",
                        Priority = "高",
                        ActionItems = new List<string> {
                            "每周称重1-2次",
                            "记录体重变化趋势",
                            "控制高热量食物摄入",
                            "保持适量运动"
                        }
                    },
                    new CategoryRecommendationDto
                    {
                        Category = "产检监测",
                        Title = "标准产检计划",
                        Description = "按照标准产检时间表进行定期检查，及时发现和处理孕期问题。如有特殊情况，请增加检查频率。",
                        Priority = "高",
                        ActionItems = new List<string> {
                            "孕早期每月1次产检",
                            "孕中期每2周1次产检",
                            "孕晚期每周1次产检",
                            "按时进行各项筛查"
                        }
                    }
                }
            };
        }
    }
}
