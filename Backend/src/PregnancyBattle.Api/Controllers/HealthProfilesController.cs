using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Application.Services.Interfaces;
using System;
using System.Security.Claims;
using System.Threading.Tasks;
using PregnancyBattle.Api.Models;

namespace PregnancyBattle.Api.Controllers
{
    /// <summary>
    /// 健康档案控制器
    /// </summary>
    [ApiController]
    [Route("api/health-profiles")]
    [Authorize]
    public class HealthProfilesController : BaseApiController
    {
        private readonly IHealthProfileService _healthProfileService;

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="healthProfileService">健康档案服务</param>
        public HealthProfilesController(IHealthProfileService healthProfileService)
        {
            _healthProfileService = healthProfileService;
        }

        /// <summary>
        /// 创建健康档案
        /// </summary>
        /// <param name="dto">创建健康档案请求</param>
        /// <returns>健康档案信息</returns>
        [HttpPost]
        [ProducesResponseType(typeof(HealthProfileDto), 201)]
        [ProducesResponseType(typeof(ValidationProblemDetails), 400)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 409)]
        public async Task<IActionResult> CreateHealthProfile([FromBody] CreateHealthProfileDto dto)
        {
            var userId = GetUserId();
            var result = await _healthProfileService.CreateHealthProfileAsync(Guid.Parse(userId), dto);

            if (!result.Success)
            {
                if (result.ErrorCode == "Conflict")
                    return Conflict(new ApiResponse<object>(false, result.Message, null, result.ErrorCode));
                return BadRequest(new ApiResponse<object>(false, result.Message, null, result.ErrorCode));
            }
            // Return 201 Created with the location of the new resource and the resource itself
            return CreatedAtAction(nameof(GetHealthProfile), new { }, result.Data);
        }

        /// <summary>
        /// 获取健康档案
        /// </summary>
        /// <returns>健康档案信息</returns>
        [HttpGet]
        [ProducesResponseType(typeof(ApiResponse<HealthProfileDto>), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> GetHealthProfile()
        {
            var userId = GetUserId();
            var result = await _healthProfileService.GetHealthProfileAsync(Guid.Parse(userId));

            if (!result.Success)
            {
                if (result.ErrorCode == "NotFound")
                    return NotFound(new ApiResponse<object>(false, result.Message, null, result.ErrorCode));
                return BadRequest(new ApiResponse<object>(false, result.Message, null, result.ErrorCode));
            }
            return Success(result.Data, "获取成功");
        }

        /// <summary>
        /// 更新健康档案
        /// </summary>
        /// <param name="dto">更新健康档案请求</param>
        /// <returns>健康档案信息</returns>
        [HttpPut]
        [ProducesResponseType(typeof(ApiResponse<HealthProfileDto>), 200)]
        [ProducesResponseType(typeof(ValidationProblemDetails), 400)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> UpdateHealthProfile([FromBody] UpdateHealthProfileDto dto)
        {
            var userId = GetUserId();
            var result = await _healthProfileService.UpdateHealthProfileAsync(Guid.Parse(userId), dto);

            if (!result.Success)
            {
                if (result.ErrorCode == "NotFound")
                    return NotFound(new ApiResponse<object>(false, result.Message, null, result.ErrorCode));
                return BadRequest(new ApiResponse<object>(false, result.Message, null, result.ErrorCode));
            }
            return Success(result.Data, "更新成功");
        }

        /// <summary>
        /// 记录每日体重
        /// </summary>
        /// <param name="dto">体重记录请求</param>
        /// <returns>体重记录信息</returns>
        [HttpPost("weight-records")]
        [ProducesResponseType(typeof(ApiResponse<WeightRecordResponseDto>), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 400)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> CreateWeightRecord([FromBody] CreateWeightRecordDto dto)
        {
            var userId = GetUserId();
            var result = await _healthProfileService.CreateWeightRecordAsync(Guid.Parse(userId), dto);
            if (!result.Success)
            {
                if (result.ErrorCode == "NotFound")
                    return NotFound(new ApiResponse<object>(false, result.Message, null, result.ErrorCode));
                return BadRequest(new ApiResponse<object>(false, result.Message, null, result.ErrorCode));
            }
            return Success(result.Data, "记录成功");
        }

        /// <summary>
        /// 获取体重变化趋势
        /// </summary>
        /// <returns>体重变化趋势</returns>
        [HttpGet("weight-trend")]
        [ProducesResponseType(typeof(ApiResponse<WeightTrendDto>), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> GetWeightTrend()
        {
            var userId = GetUserId();
            var result = await _healthProfileService.GetWeightTrendAsync(Guid.Parse(userId));
            if (!result.Success)
            {
                if (result.ErrorCode == "NotFound")
                    return NotFound(new ApiResponse<object>(false, result.Message, null, result.ErrorCode));
                return BadRequest(new ApiResponse<object>(false, result.Message, null, result.ErrorCode));
            }
            return Success(result.Data, "获取成功");
        }

        /// <summary>
        /// 获取健康风险评估
        /// </summary>
        /// <returns>健康风险评估</returns>
        [HttpGet("risk-assessment")]
        [ProducesResponseType(typeof(ApiResponse<RiskAssessmentDto>), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> GetRiskAssessment()
        {
            var userId = GetUserId();
            var result = await _healthProfileService.GetRiskAssessmentAsync(Guid.Parse(userId));
            if (!result.Success)
            {
                if (result.ErrorCode == "NotFound")
                    return NotFound(new ApiResponse<object>(false, result.Message, null, result.ErrorCode));
                return BadRequest(new ApiResponse<object>(false, result.Message, null, result.ErrorCode));
            }
            return Success(result.Data, "获取成功");
        }

        /// <summary>
        /// 强制刷新健康风险评估
        /// </summary>
        /// <returns>健康风险评估</returns>
        [HttpPost("risk-assessment/refresh")]
        [ProducesResponseType(typeof(ApiResponse<RiskAssessmentDto>), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        [ProducesResponseType(typeof(ProblemDetails), 500)]
        public async Task<IActionResult> RefreshRiskAssessment()
        {
            var userId = GetUserId();
            var result = await _healthProfileService.RefreshRiskAssessmentAsync(Guid.Parse(userId));
            if (!result.Success)
            {
                if (result.ErrorCode == "NotFound")
                    return NotFound(new ApiResponse<object>(false, result.Message, null, result.ErrorCode));
                return BadRequest(new ApiResponse<object>(false, result.Message, null, result.ErrorCode));
            }
            return Success(result.Data, "风险评估已刷新");
        }
    }
}