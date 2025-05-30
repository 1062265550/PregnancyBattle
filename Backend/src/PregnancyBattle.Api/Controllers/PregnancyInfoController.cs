using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Application.Services.Interfaces;
using PregnancyBattle.Api.Models;

namespace PregnancyBattle.Api.Controllers
{
    /// <summary>
    /// 孕期信息控制器
    /// </summary>
    [Authorize]
    [Route("api/pregnancy-info")]
    public class PregnancyInfoController : BaseApiController
    {
        private readonly IPregnancyInfoService _pregnancyInfoService;

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="pregnancyInfoService">孕期信息服务</param>
        public PregnancyInfoController(IPregnancyInfoService pregnancyInfoService)
        {
            _pregnancyInfoService = pregnancyInfoService;
        }



        /// <summary>
        /// 创建孕期信息
        /// </summary>
        /// <param name="createDto">创建孕期信息请求</param>
        /// <returns>孕期信息</returns>
        [HttpPost]
        [ProducesResponseType(typeof(ApiResponse<PregnancyInfoDto>), 200)]
        [ProducesResponseType(typeof(ValidationProblemDetails), 400)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        public async Task<IActionResult> CreatePregnancyInfo([FromBody] CreatePregnancyInfoDto createDto)
        {
            var userId = GetUserId();
            var result = await _pregnancyInfoService.CreatePregnancyInfoAsync(Guid.Parse(userId), createDto);
            if (!result.Success)
            {
                return BadRequest(new ApiResponse<object>(false, result.Message ?? "Failed to create pregnancy info", null, result.ErrorCode));
            }
            return Ok(new ApiResponse<PregnancyInfoDto>(true, "Pregnancy info created successfully", result.Data));
        }

        /// <summary>
        /// 获取孕期信息
        /// </summary>
        /// <returns>孕期信息</returns>
        [HttpGet]
        [ProducesResponseType(typeof(ApiResponse<PregnancyInfoDto>), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> GetPregnancyInfo()
        {
            var userId = GetUserId();
            var result = await _pregnancyInfoService.GetPregnancyInfoAsync(Guid.Parse(userId));
            if (!result.Success)
            {
                // API文档中404代表信息不存在，服务层应返回相应ErrorCode
                if (result.ErrorCode == "404")
                {
                    return NotFound(new ApiResponse<object>(false, result.Message ?? "Pregnancy info not found", null, result.ErrorCode));
                }
                return BadRequest(new ApiResponse<object>(false, result.Message ?? "Failed to get pregnancy info", null, result.ErrorCode));
            }
            return Ok(new ApiResponse<PregnancyInfoDto>(true, "Pregnancy info retrieved successfully", result.Data));
        }

        /// <summary>
        /// 更新孕期信息
        /// </summary>
        /// <param name="updateDto">更新孕期信息请求</param>
        /// <returns>孕期信息</returns>
        [HttpPut]
        [ProducesResponseType(typeof(ApiResponse<PregnancyInfoDto>), 200)]
        [ProducesResponseType(typeof(ValidationProblemDetails), 400)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> UpdatePregnancyInfo([FromBody] UpdatePregnancyInfoDto updateDto)
        {
            var userId = GetUserId();
            var result = await _pregnancyInfoService.UpdatePregnancyInfoAsync(Guid.Parse(userId), updateDto);
            if (!result.Success)
            {
                if (result.ErrorCode == "404")
                {
                    return NotFound(new ApiResponse<object>(false, result.Message ?? "Pregnancy info not found to update", null, result.ErrorCode));
                }
                return BadRequest(new ApiResponse<object>(false, result.Message ?? "Failed to update pregnancy info", null, result.ErrorCode));
            }
            return Ok(new ApiResponse<PregnancyInfoDto>(true, "Pregnancy info updated successfully", result.Data));
        }

        /// <summary>
        /// 计算当前孕周和孕天
        /// </summary>
        /// <returns>孕期信息</returns>
        [HttpGet("current-week")]
        [ProducesResponseType(typeof(ApiResponse<PregnancyInfoDto>), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> GetCurrentWeekAndDay()
        {
            var userId = GetUserId();
            var result = await _pregnancyInfoService.GetCurrentWeekAndDayAsync(Guid.Parse(userId));
             if (!result.Success)
            {
                if (result.ErrorCode == "404")
                {
                    return NotFound(new ApiResponse<object>(false, result.Message ?? "Pregnancy info not found", null, result.ErrorCode));
                }
                return BadRequest(new ApiResponse<object>(false, result.Message ?? "Failed to get current week info", null, result.ErrorCode));
            }
            return Ok(new ApiResponse<PregnancyInfoDto>(true, "Current week info retrieved successfully", result.Data));
        }
    }
}