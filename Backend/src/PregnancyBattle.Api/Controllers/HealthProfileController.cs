using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Application.Services;

namespace PregnancyBattle.Api.Controllers
{
    /// <summary>
    /// 健康档案控制器
    /// </summary>
    [Authorize]
    public class HealthProfileController : BaseApiController
    {
        private readonly IHealthProfileService _healthProfileService;
        
        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="healthProfileService">健康档案服务</param>
        public HealthProfileController(IHealthProfileService healthProfileService)
        {
            _healthProfileService = healthProfileService;
        }
        
        /// <summary>
        /// 创建健康档案
        /// </summary>
        /// <param name="createHealthProfileDto">创建健康档案请求</param>
        /// <returns>健康档案信息</returns>
        [HttpPost]
        [ProducesResponseType(typeof(HealthProfileDto), 200)]
        [ProducesResponseType(typeof(ValidationProblemDetails), 400)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        public async Task<IActionResult> CreateHealthProfile([FromBody] CreateHealthProfileDto createHealthProfileDto)
        {
            var userId = GetUserId();
            var healthProfile = await _healthProfileService.CreateHealthProfileAsync(Guid.Parse(userId), createHealthProfileDto);
            return Ok(healthProfile);
        }
        
        /// <summary>
        /// 获取健康档案
        /// </summary>
        /// <returns>健康档案信息</returns>
        [HttpGet]
        [ProducesResponseType(typeof(HealthProfileDto), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> GetHealthProfile()
        {
            var userId = GetUserId();
            var healthProfile = await _healthProfileService.GetHealthProfileAsync(Guid.Parse(userId));
            return Ok(healthProfile);
        }
        
        /// <summary>
        /// 更新健康档案
        /// </summary>
        /// <param name="updateHealthProfileDto">更新健康档案请求</param>
        /// <returns>健康档案信息</returns>
        [HttpPut]
        [ProducesResponseType(typeof(HealthProfileDto), 200)]
        [ProducesResponseType(typeof(ValidationProblemDetails), 400)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> UpdateHealthProfile([FromBody] UpdateHealthProfileDto updateHealthProfileDto)
        {
            var userId = GetUserId();
            var healthProfile = await _healthProfileService.UpdateHealthProfileAsync(Guid.Parse(userId), updateHealthProfileDto);
            return Ok(healthProfile);
        }
        
        /// <summary>
        /// 获取体重变化趋势
        /// </summary>
        /// <returns>体重变化趋势</returns>
        [HttpGet("weight-trend")]
        [ProducesResponseType(typeof(object), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> GetWeightTrend()
        {
            var userId = GetUserId();
            var weightTrend = await _healthProfileService.GetWeightTrendAsync(Guid.Parse(userId));
            return Ok(weightTrend);
        }
        
        /// <summary>
        /// 获取健康风险评估
        /// </summary>
        /// <returns>健康风险评估</returns>
        [HttpGet("risk-assessment")]
        [ProducesResponseType(typeof(object), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> GetHealthRiskAssessment()
        {
            var userId = GetUserId();
            var riskAssessment = await _healthProfileService.GetHealthRiskAssessmentAsync(Guid.Parse(userId));
            return Ok(riskAssessment);
        }
    }
}