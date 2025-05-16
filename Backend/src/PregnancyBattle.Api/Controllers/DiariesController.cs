using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Application.Services;

namespace PregnancyBattle.Api.Controllers
{
    /// <summary>
    /// 日记控制器
    /// </summary>
    [Authorize]
    public class DiariesController : BaseApiController
    {
        private readonly IDiaryService _diaryService;
        
        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="diaryService">日记服务</param>
        public DiariesController(IDiaryService diaryService)
        {
            _diaryService = diaryService;
        }
        
        /// <summary>
        /// 创建日记
        /// </summary>
        /// <param name="createDiaryDto">创建日记请求</param>
        /// <returns>日记信息</returns>
        [HttpPost]
        [ProducesResponseType(typeof(DiaryDto), 200)]
        [ProducesResponseType(typeof(ValidationProblemDetails), 400)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        public async Task<IActionResult> CreateDiary([FromBody] CreateDiaryDto createDiaryDto)
        {
            var userId = GetUserId();
            var diary = await _diaryService.CreateDiaryAsync(Guid.Parse(userId), createDiaryDto);
            return Ok(diary);
        }
        
        /// <summary>
        /// 获取日记
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <returns>日记信息</returns>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(DiaryDto), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> GetDiary(Guid id)
        {
            var userId = GetUserId();
            var diary = await _diaryService.GetDiaryAsync(Guid.Parse(userId), id);
            return Ok(diary);
        }
        
        /// <summary>
        /// 获取用户所有日记
        /// </summary>
        /// <returns>日记列表</returns>
        [HttpGet]
        [ProducesResponseType(typeof(DiaryDto[]), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        public async Task<IActionResult> GetUserDiaries()
        {
            var userId = GetUserId();
            var diaries = await _diaryService.GetUserDiariesAsync(Guid.Parse(userId));
            return Ok(diaries);
        }
        
        /// <summary>
        /// 根据日期范围获取日记
        /// </summary>
        /// <param name="startDate">开始日期</param>
        /// <param name="endDate">结束日期</param>
        /// <returns>日记列表</returns>
        [HttpGet("date-range")]
        [ProducesResponseType(typeof(DiaryDto[]), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        public async Task<IActionResult> GetDiariesByDateRange([FromQuery] DateTime startDate, [FromQuery] DateTime endDate)
        {
            var userId = GetUserId();
            var diaries = await _diaryService.GetDiariesByDateRangeAsync(Guid.Parse(userId), startDate, endDate);
            return Ok(diaries);
        }
        
        /// <summary>
        /// 根据标签获取日记
        /// </summary>
        /// <param name="tag">标签</param>
        /// <returns>日记列表</returns>
        [HttpGet("tag/{tag}")]
        [ProducesResponseType(typeof(DiaryDto[]), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        public async Task<IActionResult> GetDiariesByTag(string tag)
        {
            var userId = GetUserId();
            var diaries = await _diaryService.GetDiariesByTagAsync(Guid.Parse(userId), tag);
            return Ok(diaries);
        }
        
        /// <summary>
        /// 根据情绪获取日记
        /// </summary>
        /// <param name="mood">情绪</param>
        /// <returns>日记列表</returns>
        [HttpGet("mood/{mood}")]
        [ProducesResponseType(typeof(DiaryDto[]), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        public async Task<IActionResult> GetDiariesByMood(string mood)
        {
            var userId = GetUserId();
            var diaries = await _diaryService.GetDiariesByMoodAsync(Guid.Parse(userId), mood);
            return Ok(diaries);
        }
        
        /// <summary>
        /// 更新日记
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <param name="updateDiaryDto">更新日记请求</param>
        /// <returns>日记信息</returns>
        [HttpPut("{id}")]
        [ProducesResponseType(typeof(DiaryDto), 200)]
        [ProducesResponseType(typeof(ValidationProblemDetails), 400)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> UpdateDiary(Guid id, [FromBody] UpdateDiaryDto updateDiaryDto)
        {
            var userId = GetUserId();
            var diary = await _diaryService.UpdateDiaryAsync(Guid.Parse(userId), id, updateDiaryDto);
            return Ok(diary);
        }
        
        /// <summary>
        /// 删除日记
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <returns>是否删除成功</returns>
        [HttpDelete("{id}")]
        [ProducesResponseType(typeof(bool), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> DeleteDiary(Guid id)
        {
            var userId = GetUserId();
            var result = await _diaryService.DeleteDiaryAsync(Guid.Parse(userId), id);
            return Ok(result);
        }
        
        /// <summary>
        /// 添加日记标签
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <param name="tagName">标签名称</param>
        /// <returns>标签信息</returns>
        [HttpPost("{id}/tags")]
        [ProducesResponseType(typeof(DiaryTagDto), 200)]
        [ProducesResponseType(typeof(ValidationProblemDetails), 400)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> AddDiaryTag(Guid id, [FromBody] string tagName)
        {
            var userId = GetUserId();
            var tag = await _diaryService.AddDiaryTagAsync(Guid.Parse(userId), id, tagName);
            return Ok(tag);
        }
        
        /// <summary>
        /// 删除日记标签
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <param name="tagId">标签ID</param>
        /// <returns>是否删除成功</returns>
        [HttpDelete("{id}/tags/{tagId}")]
        [ProducesResponseType(typeof(bool), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> DeleteDiaryTag(Guid id, Guid tagId)
        {
            var userId = GetUserId();
            var result = await _diaryService.DeleteDiaryTagAsync(Guid.Parse(userId), id, tagId);
            return Ok(result);
        }
        
        /// <summary>
        /// 添加日记媒体文件
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <param name="addDiaryMediaDto">添加媒体文件请求</param>
        /// <returns>媒体文件信息</returns>
        [HttpPost("{id}/media")]
        [ProducesResponseType(typeof(DiaryMediaDto), 200)]
        [ProducesResponseType(typeof(ValidationProblemDetails), 400)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> AddDiaryMedia(Guid id, [FromBody] AddDiaryMediaDto addDiaryMediaDto)
        {
            var userId = GetUserId();
            var media = await _diaryService.AddDiaryMediaAsync(Guid.Parse(userId), id, addDiaryMediaDto);
            return Ok(media);
        }
        
        /// <summary>
        /// 删除日记媒体文件
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <param name="mediaId">媒体文件ID</param>
        /// <returns>是否删除成功</returns>
        [HttpDelete("{id}/media/{mediaId}")]
        [ProducesResponseType(typeof(bool), 200)]
        [ProducesResponseType(typeof(ProblemDetails), 401)]
        [ProducesResponseType(typeof(ProblemDetails), 404)]
        public async Task<IActionResult> DeleteDiaryMedia(Guid id, Guid mediaId)
        {
            var userId = GetUserId();
            var result = await _diaryService.DeleteDiaryMediaAsync(Guid.Parse(userId), id, mediaId);
            return Ok(result);
        }
    }
}