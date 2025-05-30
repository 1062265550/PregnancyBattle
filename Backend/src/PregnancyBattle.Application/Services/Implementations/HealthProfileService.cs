using AutoMapper;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Application.Models;
using PregnancyBattle.Application.Services.Interfaces;
using PregnancyBattle.Domain.Entities;
using PregnancyBattle.Domain.Repositories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using PregnancyBattle.Domain.Services; // For IPregnancyInfoService

namespace PregnancyBattle.Application.Services.Implementations
{
    public class HealthProfileService : IHealthProfileService
    {
        private readonly IHealthProfileRepository _healthProfileRepository;
        private readonly IPregnancyInfoRepository _pregnancyInfoRepository; // For pregnancy week/day
        private readonly IHealthRiskAssessmentRepository _healthRiskAssessmentRepository;
        private readonly IMapper _mapper;
        private readonly IDeepSeekService _deepSeekService;

        public HealthProfileService(
            IHealthProfileRepository healthProfileRepository,
            IPregnancyInfoRepository pregnancyInfoRepository,
            IHealthRiskAssessmentRepository healthRiskAssessmentRepository,
            IMapper mapper,
            IDeepSeekService deepSeekService)
        {
            _healthProfileRepository = healthProfileRepository;
            _pregnancyInfoRepository = pregnancyInfoRepository;
            _healthRiskAssessmentRepository = healthRiskAssessmentRepository;
            _mapper = mapper;
            _deepSeekService = deepSeekService;
        }

        public async Task<ServiceResult<HealthProfileDto>> CreateHealthProfileAsync(Guid userId, CreateHealthProfileDto dto)
        {
            if (await _healthProfileRepository.HealthProfileExistsAsync(userId))
            {
                return ServiceResult<HealthProfileDto>.FailureResult("User already has a health profile.", "Conflict");
            }

            var healthProfile = _mapper.Map<HealthProfile>(dto);
            healthProfile.Id = Guid.NewGuid();
            healthProfile.UserId = userId;
            healthProfile.CreatedAt = DateTime.UtcNow;
            healthProfile.UpdatedAt = DateTime.UtcNow;

            await _healthProfileRepository.CreateHealthProfileAsync(healthProfile);

            // Log initial weight
            var pregnancyInfo = await _pregnancyInfoRepository.GetPregnancyInfoByUserIdAsync(userId);
            int? currentWeek = null;
            int? currentDay = null;
            if (pregnancyInfo != null)
            {
                var (week, day, _) = PregnancyCalculator.CalculatePregnancyProgress(pregnancyInfo.LmpDate, pregnancyInfo.DueDate, DateTime.UtcNow);
                currentWeek = week;
                currentDay = day;
            }

            var initialWeightLog = new WeightLog
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Date = DateTime.UtcNow.Date, // Record date part only for daily log
                Weight = healthProfile.CurrentWeight,
                PregnancyWeek = currentWeek,
                PregnancyDay = currentDay,
                Note = "Initial weight record",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            await _healthProfileRepository.AddOrUpdateWeightLogAsync(initialWeightLog);

            var resultDto = _mapper.Map<HealthProfileDto>(healthProfile);
            return ServiceResult<HealthProfileDto>.SuccessResult(resultDto, "Health profile created successfully.");
        }

        public async Task<ServiceResult<HealthProfileDto>> GetHealthProfileAsync(Guid userId)
        {
            var healthProfile = await _healthProfileRepository.GetHealthProfileByUserIdAsync(userId);
            if (healthProfile == null)
            {
                return ServiceResult<HealthProfileDto>.FailureResult("Health profile not found.", "NotFound");
            }
            var resultDto = _mapper.Map<HealthProfileDto>(healthProfile);
            return ServiceResult<HealthProfileDto>.SuccessResult(resultDto);
        }

        public async Task<ServiceResult<HealthProfileDto>> UpdateHealthProfileAsync(Guid userId, UpdateHealthProfileDto dto)
        {
            var healthProfile = await _healthProfileRepository.GetHealthProfileByUserIdAsync(userId);
            if (healthProfile == null)
            {
                return ServiceResult<HealthProfileDto>.FailureResult("Health profile not found.", "NotFound");
            }

            bool weightChanged = dto.CurrentWeight.HasValue && dto.CurrentWeight.Value != healthProfile.CurrentWeight;

            _mapper.Map(dto, healthProfile); // Apply updates from DTO
            healthProfile.UpdatedAt = DateTime.UtcNow;

            await _healthProfileRepository.UpdateHealthProfileAsync(healthProfile);

            if (weightChanged)
            {
                var pregnancyInfo = await _pregnancyInfoRepository.GetPregnancyInfoByUserIdAsync(userId);
                int? currentWeek = null;
                int? currentDay = null;
                if (pregnancyInfo != null)
                {
                    var (week, day, _) = PregnancyCalculator.CalculatePregnancyProgress(pregnancyInfo.LmpDate, pregnancyInfo.DueDate, DateTime.UtcNow);
                    currentWeek = week;
                    currentDay = day;
                }

                var weightLog = new WeightLog
                {
                    Id = Guid.NewGuid(),
                    UserId = userId,
                    Date = DateTime.UtcNow.Date, // Record date part only
                    Weight = healthProfile.CurrentWeight, // This is already updated by mapper
                    PregnancyWeek = currentWeek,
                    PregnancyDay = currentDay,
                    Note = "Weight updated",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                await _healthProfileRepository.AddOrUpdateWeightLogAsync(weightLog);
            }

            var resultDto = _mapper.Map<HealthProfileDto>(healthProfile);
            return ServiceResult<HealthProfileDto>.SuccessResult(resultDto, "Health profile updated successfully.");
        }

        public async Task<ServiceResult<WeightRecordResponseDto>> CreateWeightRecordAsync(Guid userId, CreateWeightRecordDto dto)
        {
            // 验证健康档案是否存在
            var healthProfile = await _healthProfileRepository.GetHealthProfileByUserIdAsync(userId);
            if (healthProfile == null)
            {
                return ServiceResult<WeightRecordResponseDto>.FailureResult("Health profile not found.", "NotFound");
            }

            // 设置记录日期，默认为今天
            var recordDate = dto.RecordDate?.Date ?? DateTime.UtcNow.Date;

            // 验证记录日期不能晚于今天
            if (recordDate > DateTime.UtcNow.Date)
            {
                return ServiceResult<WeightRecordResponseDto>.FailureResult("Record date cannot be in the future.", "InvalidDate");
            }

            // 获取孕期信息以计算孕周和孕天
            var pregnancyInfo = await _pregnancyInfoRepository.GetPregnancyInfoByUserIdAsync(userId);
            int? currentWeek = null;
            int? currentDay = null;
            if (pregnancyInfo != null)
            {
                var (week, day, _) = PregnancyCalculator.CalculatePregnancyProgress(pregnancyInfo.LmpDate, pregnancyInfo.DueDate, recordDate);
                currentWeek = week;
                currentDay = day;
            }

            // 创建体重记录
            var weightLog = new WeightLog
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Date = recordDate,
                Weight = dto.Weight,
                PregnancyWeek = currentWeek,
                PregnancyDay = currentDay,
                Note = dto.Note,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            // 保存体重记录（如果当天已有记录则更新）
            await _healthProfileRepository.AddOrUpdateWeightLogAsync(weightLog);

            // 同时更新健康档案中的当前体重
            healthProfile.CurrentWeight = dto.Weight;
            healthProfile.UpdatedAt = DateTime.UtcNow;
            await _healthProfileRepository.UpdateHealthProfileAsync(healthProfile);

            // 返回结果
            var resultDto = _mapper.Map<WeightRecordResponseDto>(weightLog);
            return ServiceResult<WeightRecordResponseDto>.SuccessResult(resultDto, "Weight record created successfully.");
        }

        public async Task<ServiceResult<WeightTrendDto>> GetWeightTrendAsync(Guid userId)
        {
            var healthProfile = await _healthProfileRepository.GetHealthProfileByUserIdAsync(userId);
            if (healthProfile == null)
            {
                return ServiceResult<WeightTrendDto>.FailureResult("Health profile not found.", "NotFound");
            }

            var pregnancyInfo = await _pregnancyInfoRepository.GetPregnancyInfoByUserIdAsync(userId);
            var weightLogs = await _healthProfileRepository.GetWeightLogsByUserIdAsync(userId, null, null);
            var orderedLogs = weightLogs.OrderBy(w => w.Date).ToList();

            var weightRecords = new List<WeightRecordDto>();

            // 始终添加孕前体重作为起始点（如果有孕期信息）
            if (pregnancyInfo != null)
            {
                weightRecords.Add(new WeightRecordDto
                {
                    Date = pregnancyInfo.LmpDate,
                    Weight = healthProfile.PrePregnancyWeight,
                    PregnancyWeek = 0,
                    PregnancyDay = 0
                });
            }

            // 添加实际的体重记录
            if (orderedLogs.Any())
            {
                var mappedRecords = _mapper.Map<List<WeightRecordDto>>(orderedLogs);
                weightRecords.AddRange(mappedRecords);
            }
            else
            {
                // 如果没有实际记录，但当前体重与孕前体重不同，添加当前体重记录
                if (healthProfile.CurrentWeight != healthProfile.PrePregnancyWeight && pregnancyInfo != null)
                {
                    var currentDate = DateTime.UtcNow.Date;
                    var (week, day, _) = PregnancyCalculator.CalculatePregnancyProgress(pregnancyInfo.LmpDate, pregnancyInfo.DueDate, currentDate);

                    weightRecords.Add(new WeightRecordDto
                    {
                        Date = currentDate,
                        Weight = healthProfile.CurrentWeight,
                        PregnancyWeek = week,
                        PregnancyDay = day
                    });
                }
            }

            // 确保记录按日期排序并去重
            weightRecords = weightRecords
                .GroupBy(r => r.Date.Date)
                .Select(g => g.OrderByDescending(r => r.Date).First()) // 如果同一天有多条记录，取最新的
                .OrderBy(r => r.Date)
                .ToList();

            // 如果只有孕前体重一个点，且当前体重不同，补充当前体重点
            if (weightRecords.Count == 1 && pregnancyInfo != null &&
                healthProfile.CurrentWeight != healthProfile.PrePregnancyWeight)
            {
                var currentDate = DateTime.UtcNow.Date;
                var (week, day, _) = PregnancyCalculator.CalculatePregnancyProgress(pregnancyInfo.LmpDate, pregnancyInfo.DueDate, currentDate);

                weightRecords.Add(new WeightRecordDto
                {
                    Date = currentDate,
                    Weight = healthProfile.CurrentWeight,
                    PregnancyWeek = week,
                    PregnancyDay = day
                });
            }

            var weightTrendDto = new WeightTrendDto
            {
                StartWeight = healthProfile.PrePregnancyWeight,
                CurrentWeight = healthProfile.CurrentWeight,
                WeightGain = healthProfile.CurrentWeight - healthProfile.PrePregnancyWeight,
                WeightRecords = weightRecords,
                RecommendedWeightGain = CalculateRecommendedWeightGain(healthProfile)
            };

            return ServiceResult<WeightTrendDto>.SuccessResult(weightTrendDto);
        }

        private RecommendedWeightGainDto CalculateRecommendedWeightGain(HealthProfile healthProfile)
        {
            // Based on IOM guidelines, simplified. Needs more accurate logic for different pregnancy stages.
            // This is a placeholder. Real implementation should consider pre-pregnancy BMI and current week.
            var prePregnancyBmi = healthProfile.CalculatePrePregnancyBmi();
            var dto = new RecommendedWeightGainDto();

            if (prePregnancyBmi < 18.5m) // Underweight
            {
                dto.Min = 12.5m; dto.Max = 18m;
            }
            else if (prePregnancyBmi < 25m) // Normal weight
            {
                dto.Min = 11.5m; dto.Max = 16m;
            }
            else if (prePregnancyBmi < 30m) // Overweight
            {
                dto.Min = 7m;    dto.Max = 11.5m;
            }
            else // Obese
            {
                dto.Min = 5m;    dto.Max = 9m;
            }
            return dto;
        }

        public async Task<ServiceResult<RiskAssessmentDto>> GetRiskAssessmentAsync(Guid userId)
        {
            var healthProfile = await _healthProfileRepository.GetHealthProfileByUserIdAsync(userId);
            if (healthProfile == null)
            {
                return ServiceResult<RiskAssessmentDto>.FailureResult("Health profile not found.", "NotFound");
            }

            var pregnancyInfo = await _pregnancyInfoRepository.GetPregnancyInfoByUserIdAsync(userId);
            int currentWeek = 0;
            if (pregnancyInfo != null)
            {
                 var (week, _, _) = PregnancyCalculator.CalculatePregnancyProgress(pregnancyInfo.LmpDate, pregnancyInfo.DueDate, DateTime.UtcNow);
                 currentWeek = week;
            }

            // 计算健康档案数据的哈希值
            var healthDataHash = CalculateHealthDataHash(healthProfile);

            // 尝试从缓存中获取风险评估
            var cachedAssessment = await _healthRiskAssessmentRepository.GetByUserIdAndHealthProfileIdAsync(userId, healthProfile.Id);

            RiskAssessmentDto assessment;

            if (cachedAssessment != null && cachedAssessment.HealthDataHash == healthDataHash)
            {
                // 使用缓存的评估结果
                assessment = await ConvertCachedAssessmentToDto(cachedAssessment, healthProfile, pregnancyInfo);
            }
            else
            {
                // 生成新的评估结果
                assessment = await GenerateAndCacheRiskAssessmentAsync(healthProfile, pregnancyInfo, healthDataHash);
            }

            return ServiceResult<RiskAssessmentDto>.SuccessResult(assessment);
        }

        /// <summary>
        /// 强制刷新健康风险评估
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>健康风险评估</returns>
        public async Task<ServiceResult<RiskAssessmentDto>> RefreshRiskAssessmentAsync(Guid userId)
        {
            var healthProfile = await _healthProfileRepository.GetHealthProfileByUserIdAsync(userId);
            if (healthProfile == null)
            {
                return ServiceResult<RiskAssessmentDto>.FailureResult("Health profile not found.", "NotFound");
            }

            var pregnancyInfo = await _pregnancyInfoRepository.GetPregnancyInfoByUserIdAsync(userId);

            // 计算健康档案数据的哈希值
            var healthDataHash = CalculateHealthDataHash(healthProfile);

            // 强制生成新的评估结果，忽略缓存
            var assessment = await GenerateAndCacheRiskAssessmentAsync(healthProfile, pregnancyInfo, healthDataHash);

            return ServiceResult<RiskAssessmentDto>.SuccessResult(assessment);
        }

        /// <summary>
        /// 生成AI增强的风险评估
        /// </summary>
        private async Task<RiskAssessmentDto> GenerateEnhancedRiskAssessmentAsync(HealthProfile healthProfile, PregnancyInfo? pregnancyInfo)
        {
            var assessment = new RiskAssessmentDto();

            try
            {
                // 转换为DTO以便传递给AI服务
                var healthProfileDto = _mapper.Map<HealthProfileDto>(healthProfile);
                var pregnancyInfoDto = pregnancyInfo != null ? _mapper.Map<PregnancyInfoDto>(pregnancyInfo) : null;

                // 分别处理AI分析和个性化建议，避免一个失败影响另一个
                try
                {
                    // 检查AI服务是否可用（快速检查）
                    var isAiAvailable = await _deepSeekService.IsServiceAvailableAsync();

                    if (isAiAvailable)
                    {
                        // 生成AI分析（设置较短超时）
                        var aiAnalysisTask = _deepSeekService.GenerateHealthRiskAnalysisAsync(healthProfileDto, pregnancyInfoDto);
                        var aiTimeoutTask = Task.Delay(TimeSpan.FromSeconds(60));
                        var aiCompletedTask = await Task.WhenAny(aiAnalysisTask, aiTimeoutTask);

                        if (aiCompletedTask == aiAnalysisTask)
                        {
                            var aiAnalysisResult = await aiAnalysisTask;
                            if (aiAnalysisResult.Success)
                            {
                                assessment.AiAnalysis = aiAnalysisResult.Data;
                                assessment.IsAiEnhanced = true;
                                Console.WriteLine("AI分析完成");
                            }
                        }
                        else
                        {
                            Console.WriteLine("AI分析超时");
                        }

                        // 生成个性化建议（独立处理，设置较短超时）
                        var riskFactors = IdentifyRiskFactors(healthProfile);
                        var recommendationsTask = _deepSeekService.GeneratePersonalizedRecommendationsAsync(
                            healthProfileDto, pregnancyInfoDto, riskFactors);
                        var recommendationsTimeoutTask = Task.Delay(TimeSpan.FromSeconds(60));
                        var recommendationsCompletedTask = await Task.WhenAny(recommendationsTask, recommendationsTimeoutTask);

                        if (recommendationsCompletedTask == recommendationsTask)
                        {
                            var recommendationsResult = await recommendationsTask;
                            if (recommendationsResult.Success)
                            {
                                assessment.PersonalizedRecommendations = recommendationsResult.Data;
                                Console.WriteLine("个性化建议完成");
                            }
                            else
                            {
                                Console.WriteLine($"个性化建议生成失败: {recommendationsResult.Message}");
                            }
                        }
                        else
                        {
                            Console.WriteLine("个性化建议超时");
                        }
                    }
                }
                catch (Exception ex)
                {
                    // AI服务失败时记录日志但不影响基础功能
                    Console.WriteLine($"AI服务调用失败: {ex.Message}");
                }
            }
            catch (Exception ex)
            {
                // AI服务失败时记录日志但不影响基础功能
                Console.WriteLine($"生成AI增强风险评估时发生错误: {ex.Message}");
            }

            return assessment;
        }

        /// <summary>
        /// 识别健康档案中的风险因素
        /// </summary>
        private List<string> IdentifyRiskFactors(HealthProfile healthProfile)
        {
            var riskFactors = new List<string>();

            // BMI风险因素
            var bmi = healthProfile.CalculatePrePregnancyBmi();
            if (bmi < 18.5m) riskFactors.Add("体重偏轻");
            else if (bmi >= 25m && bmi < 30m) riskFactors.Add("超重");
            else if (bmi >= 30m) riskFactors.Add("肥胖");

            // 年龄风险因素
            if (healthProfile.Age >= 35) riskFactors.Add("高龄产妇");
            if (healthProfile.Age < 20) riskFactors.Add("年龄偏小");

            // 生活习惯风险因素
            if (healthProfile.IsSmoking) riskFactors.Add("吸烟");
            if (healthProfile.IsDrinking) riskFactors.Add("饮酒");

            // 病史风险因素
            if (!string.IsNullOrWhiteSpace(healthProfile.MedicalHistory)) riskFactors.Add("个人病史");
            if (!string.IsNullOrWhiteSpace(healthProfile.FamilyHistory)) riskFactors.Add("家族病史");
            if (!string.IsNullOrWhiteSpace(healthProfile.AllergiesHistory)) riskFactors.Add("过敏史");
            if (!string.IsNullOrWhiteSpace(healthProfile.ObstetricHistory)) riskFactors.Add("既往孕产史");

            return riskFactors;
        }

        /// <summary>
        /// 计算健康档案数据的哈希值
        /// </summary>
        private string CalculateHealthDataHash(HealthProfile healthProfile)
        {
            var data = new
            {
                healthProfile.Height,
                healthProfile.PrePregnancyWeight,
                healthProfile.CurrentWeight,
                healthProfile.BloodType,
                healthProfile.Age,
                healthProfile.MedicalHistory,
                healthProfile.FamilyHistory,
                healthProfile.AllergiesHistory,
                healthProfile.ObstetricHistory,
                healthProfile.IsSmoking,
                healthProfile.IsDrinking
            };

            var json = JsonSerializer.Serialize(data);
            using var sha256 = SHA256.Create();
            var hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(json));
            return Convert.ToHexString(hashBytes);
        }

        /// <summary>
        /// 从缓存的评估结果转换为DTO
        /// </summary>
        private async Task<RiskAssessmentDto> ConvertCachedAssessmentToDto(HealthRiskAssessment cachedAssessment, HealthProfile healthProfile, PregnancyInfo? pregnancyInfo)
        {
            var assessment = new RiskAssessmentDto
            {
                BmiCategory = cachedAssessment.BmiCategory,
                BmiRisk = cachedAssessment.BmiRisk,
                AgeRisk = cachedAssessment.AgeRisk,
                IsAiEnhanced = cachedAssessment.IsAiEnhanced
            };

            // 反序列化AI分析结果
            if (!string.IsNullOrEmpty(cachedAssessment.AiAnalysisJson))
            {
                try
                {
                    assessment.AiAnalysis = JsonSerializer.Deserialize<HealthRiskAnalysisDto>(cachedAssessment.AiAnalysisJson);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"反序列化AI分析结果失败: {ex.Message}");
                }
            }

            // 反序列化个性化建议
            if (!string.IsNullOrEmpty(cachedAssessment.PersonalizedRecommendationsJson))
            {
                try
                {
                    assessment.PersonalizedRecommendations = JsonSerializer.Deserialize<PersonalizedRecommendationsDto>(cachedAssessment.PersonalizedRecommendationsJson);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"反序列化个性化建议失败: {ex.Message}");
                }
            }

            // 重新生成基础的医疗风险和建议（这些可能会根据当前时间变化）
            await PopulateBasicRiskAssessment(assessment, healthProfile, pregnancyInfo);

            return assessment;
        }

        /// <summary>
        /// 生成并缓存风险评估
        /// </summary>
        private async Task<RiskAssessmentDto> GenerateAndCacheRiskAssessmentAsync(HealthProfile healthProfile, PregnancyInfo? pregnancyInfo, string healthDataHash)
        {
            // 生成新的风险评估
            var assessment = await GenerateEnhancedRiskAssessmentAsync(healthProfile, pregnancyInfo);

            // 填充基础风险评估
            await PopulateBasicRiskAssessment(assessment, healthProfile, pregnancyInfo);

            // 缓存到数据库
            try
            {
                var riskAssessmentEntity = new HealthRiskAssessment
                {
                    UserId = healthProfile.UserId,
                    HealthProfileId = healthProfile.Id,
                    BmiCategory = assessment.BmiCategory,
                    BmiRisk = assessment.BmiRisk,
                    AgeRisk = assessment.AgeRisk,
                    IsAiEnhanced = assessment.IsAiEnhanced,
                    HealthDataHash = healthDataHash
                };

                // 序列化AI分析结果
                if (assessment.AiAnalysis != null)
                {
                    riskAssessmentEntity.AiAnalysisJson = JsonSerializer.Serialize(assessment.AiAnalysis);
                }

                // 序列化个性化建议
                if (assessment.PersonalizedRecommendations != null)
                {
                    riskAssessmentEntity.PersonalizedRecommendationsJson = JsonSerializer.Serialize(assessment.PersonalizedRecommendations);
                }

                // 检查是否已存在记录
                var existingAssessment = await _healthRiskAssessmentRepository.GetByUserIdAndHealthProfileIdAsync(healthProfile.UserId, healthProfile.Id);
                if (existingAssessment != null)
                {
                    // 更新现有记录
                    existingAssessment.BmiCategory = riskAssessmentEntity.BmiCategory;
                    existingAssessment.BmiRisk = riskAssessmentEntity.BmiRisk;
                    existingAssessment.AgeRisk = riskAssessmentEntity.AgeRisk;
                    existingAssessment.AiAnalysisJson = riskAssessmentEntity.AiAnalysisJson;
                    existingAssessment.PersonalizedRecommendationsJson = riskAssessmentEntity.PersonalizedRecommendationsJson;
                    existingAssessment.IsAiEnhanced = riskAssessmentEntity.IsAiEnhanced;
                    existingAssessment.HealthDataHash = riskAssessmentEntity.HealthDataHash;

                    await _healthRiskAssessmentRepository.UpdateAsync(existingAssessment);
                }
                else
                {
                    // 创建新记录
                    await _healthRiskAssessmentRepository.CreateAsync(riskAssessmentEntity);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"缓存风险评估失败: {ex.Message}");
                // 即使缓存失败，也返回评估结果
            }

            return assessment;
        }

        /// <summary>
        /// 填充基础风险评估信息
        /// </summary>
        private async Task PopulateBasicRiskAssessment(RiskAssessmentDto assessment, HealthProfile healthProfile, PregnancyInfo? pregnancyInfo)
        {
            // 确保基础字段已设置
            var prePregnancyBmi = healthProfile.CalculatePrePregnancyBmi();
            if (string.IsNullOrEmpty(assessment.BmiCategory))
            {
                if (prePregnancyBmi < 18.5m) { assessment.BmiCategory = "偏瘦"; assessment.BmiRisk = "孕期体重增长不足风险，可能影响胎儿发育。"; }
                else if (prePregnancyBmi < 25m) { assessment.BmiCategory = "正常"; assessment.BmiRisk = "体重正常，请保持均衡饮食和适量运动。"; }
                else if (prePregnancyBmi < 30m) { assessment.BmiCategory = "超重"; assessment.BmiRisk = "妊娠期糖尿病、高血压风险增加，请注意控制体重增长。"; }
                else { assessment.BmiCategory = "肥胖"; assessment.BmiRisk = "妊娠期并发症风险较高，如妊娠期糖尿病、高血压、巨大儿等，请务必在医生指导下管理体重。"; }
            }

            if (string.IsNullOrEmpty(assessment.AgeRisk))
            {
                if (healthProfile.Age >= 35)
                {
                    assessment.AgeRisk = "高龄产妇，请注意监测血压、血糖，并遵医嘱进行相关检查。";
                }
                else
                {
                    assessment.AgeRisk = "年龄在正常范围内。";
                }
            }

            // 重新生成医疗风险和建议（这些可能会根据当前情况变化）
            assessment.MedicalRisks = new List<MedicalRiskDto>();
            assessment.Recommendations = new List<RecommendationDto>();

            // 添加体重管理建议
            assessment.Recommendations.Add(new RecommendationDto { Category = "体重管理", Description = $"根据您孕前BMI ({prePregnancyBmi:F1}) 为 {assessment.BmiCategory}，{assessment.BmiRisk}" });

            // 年龄相关风险和建议
            if (healthProfile.Age >= 35)
            {
                assessment.MedicalRisks.Add(new MedicalRiskDto { Type = "年龄因素", Description = "高龄（≥35岁）可能增加妊娠并发症风险，如妊娠期高血压、糖尿病，以及胎儿染色体异常风险。", Severity = "中" });
                assessment.Recommendations.Add(new RecommendationDto { Category = "高龄注意事项", Description = "建议定期进行产前检查，关注血压、血糖变化，必要时进行无创DNA或羊水穿刺检查。" });
            }

            // 病史相关风险和建议
            if (!string.IsNullOrWhiteSpace(healthProfile.MedicalHistory))
            {
                assessment.MedicalRisks.Add(new MedicalRiskDto { Type = "个人病史", Description = $"存在个人病史: {healthProfile.MedicalHistory}，请咨询医生评估对孕期的影响。", Severity = "中" });
                assessment.Recommendations.Add(new RecommendationDto { Category = "病史管理", Description = $"针对您的个人病史 '{healthProfile.MedicalHistory}'，请务必咨询主治医师，了解其对孕期的潜在影响及管理方案。" });
            }

            if (!string.IsNullOrWhiteSpace(healthProfile.FamilyHistory))
            {
                assessment.MedicalRisks.Add(new MedicalRiskDto { Type = "家族病史", Description = $"存在家族病史: {healthProfile.FamilyHistory}，请告知医生以评估遗传风险。", Severity = "中" });
                assessment.Recommendations.Add(new RecommendationDto { Category = "家族病史", Description = $"您提及的家族病史 '{healthProfile.FamilyHistory}'，建议告知产科医生，以便评估可能的遗传风险及必要的筛查。" });
            }

            if (!string.IsNullOrWhiteSpace(healthProfile.AllergiesHistory))
            {
                assessment.Recommendations.Add(new RecommendationDto { Category = "过敏史", Description = $"请注意避免接触您已知的过敏源: {healthProfile.AllergiesHistory}。" });
            }

            // 生活习惯相关风险和建议
            if (healthProfile.IsSmoking)
            {
                assessment.MedicalRisks.Add(new MedicalRiskDto { Type = "生活习惯", Description = "吸烟对胎儿发育有害，强烈建议戒烟。", Severity = "高" });
                assessment.Recommendations.Add(new RecommendationDto { Category = "戒烟建议", Description = "吸烟会严重影响胎儿的生长发育，并增加早产、低出生体重等风险，请立即戒烟并避免二手烟环境。" });
            }

            if (healthProfile.IsDrinking)
            {
                assessment.MedicalRisks.Add(new MedicalRiskDto { Type = "生活习惯", Description = "孕期饮酒对胎儿有害，强烈建议戒酒。", Severity = "高" });
                assessment.Recommendations.Add(new RecommendationDto { Category = "戒酒建议", Description = "孕期任何剂量的酒精摄入都可能对胎儿造成伤害，导致出生缺陷，请立即停止饮酒。" });
            }

            // 综合评估建议
            if (assessment.MedicalRisks.Count == 0 && assessment.AgeRisk == "年龄在正常范围内。" && (assessment.BmiCategory == "正常" || assessment.BmiCategory == "偏瘦"))
            {
                assessment.Recommendations.Add(new RecommendationDto { Category = "综合评估", Description = "目前您的健康状况总体良好，请继续保持健康的生活方式，定期产检。" });
            }
            else if (assessment.MedicalRisks.Count > 0 || assessment.AgeRisk != "年龄在正常范围内。")
            {
                assessment.Recommendations.Add(new RecommendationDto { Category = "综合建议", Description = "检测到一些潜在风险因素，请密切关注并遵医嘱进行管理。保持积极心态，健康饮食，规律作息。" });
            }
        }
    }
}