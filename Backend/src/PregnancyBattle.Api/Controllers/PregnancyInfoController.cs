using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Application.Services;

namespace PregnancyBattle.Api.Controllers
{
    /// <summary>
    /// 孕期信息控制器
    /// </summary>
    [Authorize]
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
        /// <param name="createPregnancyInfoDto">创建孕期信息请求</param>
        /// <returns>孕期信息</returns>
        [HttpPost]
        [ProducesResponseType(typeof(PregnancyInfoDto), 200)]
        [ProducesResponseType(typeof(ValidationProblemDetails), 400)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        public async Task<IActionResult> CreatePregnancyInfo([FromBody] CreatePregnancyInfoDto createPregnancyInfoDto)
        {
            var userId = GetUserId();
            var pregnancyInfo = await _pregnancyInfoService.CreatePregnancyInfoAsync(Guid.Parse(userId), createPregnancyInfoDto);
            return Ok(pregnancyInfo);
        }
        
        /// <summary>
        /// 获取孕期信息
        /// </summary>
        /// <returns>孕期信息</returns>
        [HttpGet]
        [ProducesResponseType(typeof(PregnancyInfoDto), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> GetPregnancyInfo()
        {
            var userId = GetUserId();
            var pregnancyInfo = await _pregnancyInfoService.GetPregnancyInfoAsync(Guid.Parse(userId));
            return Ok(pregnancyInfo);
        }
        
        /// <summary>
        /// 更新孕期信息
        /// </summary>
        /// <param name="updatePregnancyInfoDto">更新孕期信息请求</param>
        /// <returns>孕期信息</returns>
        [HttpPut]
        [ProducesResponseType(typeof(PregnancyInfoDto), 200)]
        [ProducesResponseType(typeof(ValidationProblemDetails), 400)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> UpdatePregnancyInfo([FromBody] UpdatePregnancyInfoDto updatePregnancyInfoDto)
        {
            var userId = GetUserId();
            var pregnancyInfo = await _pregnancyInfoService.UpdatePregnancyInfoAsync(Guid.Parse(userId), updatePregnancyInfoDto);
            return Ok(pregnancyInfo);
        }
        
        /// <summary>
        /// 计算当前孕周和孕天
        /// </summary>
        /// <returns>孕期信息</returns>
        [HttpGet("current-week")]
        [ProducesResponseType(typeof(PregnancyInfoDto), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> CalculateCurrentPregnancyWeek()
        {
            var userId = GetUserId();
            var pregnancyInfo = await _pregnancyInfoService.CalculateCurrentPregnancyWeekAsync(Guid.Parse(userId));
            return Ok(pregnancyInfo);
        }
    }
}