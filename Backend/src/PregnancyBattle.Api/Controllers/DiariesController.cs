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
    /// 日记控制器
    /// </summary>
    [Authorize]
    [Route("api/diaries")]
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
        [ProducesResponseType(typeof(ApiResponse<DiaryDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 400)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        public async Task<IActionResult> CreateDiary([FromBody] CreateDiaryDto createDiaryDto)
        {
            var userId = GetUserId();
            var diary = await _diaryService.CreateDiaryAsync(Guid.Parse(userId), createDiaryDto);
            return Ok(ApiResponse<DiaryDto>.CreateSuccess(diary, "创建成功"));
        }

        /// <summary>
        /// 获取日记
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <returns>日记信息</returns>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(ApiResponse<DiaryDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        [ProducesResponseType(typeof(ApiResponse<object>), 403)]
        [ProducesResponseType(typeof(ApiResponse<object>), 404)]
        public async Task<IActionResult> GetDiary(Guid id)
        {
            var userId = GetUserId();
            var diary = await _diaryService.GetDiaryAsync(Guid.Parse(userId), id);
            return Ok(ApiResponse<DiaryDto>.CreateSuccess(diary, "获取成功"));
        }

        /// <summary>
        /// 获取用户所有日记
        /// </summary>
        /// <param name="page">页码，默认为1</param>
        /// <param name="pageSize">每页数量，默认为10</param>
        /// <param name="sortBy">排序字段，可选值：diaryDate、createdAt，默认为diaryDate</param>
        /// <param name="sortDirection">排序方向，可选值：asc、desc，默认为desc</param>
        /// <returns>分页日记列表</returns>
        [HttpGet]
        [ProducesResponseType(typeof(ApiResponse<PagedDiaryListDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        public async Task<IActionResult> GetUserDiaries(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string sortBy = "diaryDate",
            [FromQuery] string sortDirection = "desc")
        {
            var userId = GetUserId();
            var diaries = await _diaryService.GetUserDiariesAsync(Guid.Parse(userId), page, pageSize, sortBy, sortDirection);
            return Ok(ApiResponse<PagedDiaryListDto>.CreateSuccess(diaries, "获取成功"));
        }

        /// <summary>
        /// 根据日期范围获取日记
        /// </summary>
        /// <param name="startDate">开始日期，格式：yyyy-MM-dd</param>
        /// <param name="endDate">结束日期，格式：yyyy-MM-dd</param>
        /// <param name="page">页码，默认为1</param>
        /// <param name="pageSize">每页数量，默认为10</param>
        /// <param name="sortBy">排序字段，可选值：diaryDate、createdAt，默认为diaryDate</param>
        /// <param name="sortDirection">排序方向，可选值：asc、desc，默认为desc</param>
        /// <returns>分页日记列表</returns>
        [HttpGet("date-range")]
        [ProducesResponseType(typeof(ApiResponse<PagedDiaryListDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 400)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        public async Task<IActionResult> GetDiariesByDateRange(
            [FromQuery] DateTime startDate,
            [FromQuery] DateTime endDate,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string sortBy = "diaryDate",
            [FromQuery] string sortDirection = "desc")
        {
            var userId = GetUserId();
            var diaries = await _diaryService.GetDiariesByDateRangeAsync(Guid.Parse(userId), startDate, endDate, page, pageSize, sortBy, sortDirection);
            return Ok(ApiResponse<PagedDiaryListDto>.CreateSuccess(diaries, "获取成功"));
        }

        /// <summary>
        /// 根据标签获取日记
        /// </summary>
        /// <param name="tag">标签名称</param>
        /// <param name="page">页码，默认为1</param>
        /// <param name="pageSize">每页数量，默认为10</param>
        /// <param name="sortBy">排序字段，可选值：diaryDate、createdAt，默认为diaryDate</param>
        /// <param name="sortDirection">排序方向，可选值：asc、desc，默认为desc</param>
        /// <returns>分页日记列表</returns>
        [HttpGet("tag/{tag}")]
        [ProducesResponseType(typeof(ApiResponse<PagedDiaryListDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        public async Task<IActionResult> GetDiariesByTag(
            string tag,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string sortBy = "diaryDate",
            [FromQuery] string sortDirection = "desc")
        {
            var userId = GetUserId();
            var diaries = await _diaryService.GetDiariesByTagAsync(Guid.Parse(userId), tag, page, pageSize, sortBy, sortDirection);
            return Ok(ApiResponse<PagedDiaryListDto>.CreateSuccess(diaries, "获取成功"));
        }

        /// <summary>
        /// 根据情绪获取日记
        /// </summary>
        /// <param name="mood">情绪状态，可选值：Happy、Sad、Angry、Anxious、Excited、Tired、Neutral</param>
        /// <param name="page">页码，默认为1</param>
        /// <param name="pageSize">每页数量，默认为10</param>
        /// <param name="sortBy">排序字段，可选值：diaryDate、createdAt，默认为diaryDate</param>
        /// <param name="sortDirection">排序方向，可选值：asc、desc，默认为desc</param>
        /// <returns>分页日记列表</returns>
        [HttpGet("mood/{mood}")]
        [ProducesResponseType(typeof(ApiResponse<PagedDiaryListDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 400)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        public async Task<IActionResult> GetDiariesByMood(
            string mood,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string sortBy = "diaryDate",
            [FromQuery] string sortDirection = "desc")
        {
            var userId = GetUserId();
            var diaries = await _diaryService.GetDiariesByMoodAsync(Guid.Parse(userId), mood, page, pageSize, sortBy, sortDirection);
            return Ok(ApiResponse<PagedDiaryListDto>.CreateSuccess(diaries, "获取成功"));
        }

        /// <summary>
        /// 根据多个条件获取日记
        /// </summary>
        /// <param name="mood">情绪状态（可选），可选值：Happy、Sad、Angry、Anxious、Excited、Tired、Neutral</param>
        /// <param name="tags">标签名称列表（可选），支持多个标签，用逗号分隔</param>
        /// <param name="startDate">开始日期（可选），格式：yyyy-MM-dd</param>
        /// <param name="endDate">结束日期（可选），格式：yyyy-MM-dd</param>
        /// <param name="page">页码，默认为1</param>
        /// <param name="pageSize">每页数量，默认为10</param>
        /// <param name="sortBy">排序字段，可选值：diaryDate、createdAt，默认为diaryDate</param>
        /// <param name="sortDirection">排序方向，可选值：asc、desc，默认为desc</param>
        /// <returns>分页日记列表</returns>
        [HttpGet("filter")]
        [ProducesResponseType(typeof(ApiResponse<PagedDiaryListDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 400)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        public async Task<IActionResult> GetDiariesByMultipleFilters(
            [FromQuery] string? mood = null,
            [FromQuery] string? tags = null,
            [FromQuery] DateTime? startDate = null,
            [FromQuery] DateTime? endDate = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string sortBy = "diaryDate",
            [FromQuery] string sortDirection = "desc")
        {
            var userId = GetUserId();

            // 处理标签参数，支持逗号分隔的多个标签
            IEnumerable<string>? tagList = null;
            if (!string.IsNullOrEmpty(tags))
            {
                tagList = tags.Split(',', StringSplitOptions.RemoveEmptyEntries)
                             .Select(t => t.Trim())
                             .Where(t => !string.IsNullOrEmpty(t));
            }

            var diaries = await _diaryService.GetDiariesByMultipleFiltersAsync(
                Guid.Parse(userId), mood, tagList, startDate, endDate, page, pageSize, sortBy, sortDirection);
            return Ok(ApiResponse<PagedDiaryListDto>.CreateSuccess(diaries, "获取成功"));
        }

        /// <summary>
        /// 更新日记
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <param name="updateDiaryDto">更新日记请求</param>
        /// <returns>日记信息</returns>
        [HttpPut("{id}")]
        [ProducesResponseType(typeof(ApiResponse<DiaryDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 400)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        [ProducesResponseType(typeof(ApiResponse<object>), 403)]
        [ProducesResponseType(typeof(ApiResponse<object>), 404)]
        public async Task<IActionResult> UpdateDiary(Guid id, [FromBody] UpdateDiaryDto updateDiaryDto)
        {
            var userId = GetUserId();
            var diary = await _diaryService.UpdateDiaryAsync(Guid.Parse(userId), id, updateDiaryDto);
            return Ok(ApiResponse<DiaryDto>.CreateSuccess(diary, "更新成功"));
        }

        /// <summary>
        /// 删除日记
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <returns>删除结果</returns>
        [HttpDelete("{id}")]
        [ProducesResponseType(typeof(ApiResponse<object>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        [ProducesResponseType(typeof(ApiResponse<object>), 403)]
        [ProducesResponseType(typeof(ApiResponse<object>), 404)]
        public async Task<IActionResult> DeleteDiary(Guid id)
        {
            var userId = GetUserId();
            var result = await _diaryService.DeleteDiaryAsync(Guid.Parse(userId), id);
            return Ok(ApiResponse<object>.CreateSuccess(null, "删除成功"));
        }

        /// <summary>
        /// 添加日记标签
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <param name="addDiaryTagsDto">添加标签请求</param>
        /// <returns>更新后的日记信息</returns>
        [HttpPost("{id}/tags")]
        [ProducesResponseType(typeof(ApiResponse<DiaryDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 400)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        [ProducesResponseType(typeof(ApiResponse<object>), 404)]
        public async Task<IActionResult> AddDiaryTags(Guid id, [FromBody] AddDiaryTagsDto addDiaryTagsDto)
        {
            var userId = GetUserId();
            var diary = await _diaryService.AddDiaryTagsAsync(Guid.Parse(userId), id, addDiaryTagsDto);
            return Ok(ApiResponse<DiaryDto>.CreateSuccess(diary, "标签添加成功"));
        }

        /// <summary>
        /// 删除日记标签
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <param name="tag">标签名称</param>
        /// <returns>更新后的日记信息</returns>
        [HttpDelete("{id}/tags/{tag}")]
        [ProducesResponseType(typeof(ApiResponse<DiaryDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        [ProducesResponseType(typeof(ApiResponse<object>), 404)]
        public async Task<IActionResult> DeleteDiaryTag(Guid id, string tag)
        {
            var userId = GetUserId();
            var diary = await _diaryService.DeleteDiaryTagAsync(Guid.Parse(userId), id, tag);
            return Ok(ApiResponse<DiaryDto>.CreateSuccess(diary, "标签删除成功"));
        }

        /// <summary>
        /// 添加日记媒体文件 (使用URL)
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <param name="addDiaryMediaDto">添加媒体文件请求</param>
        /// <returns>媒体文件信息</returns>
        [HttpPost("{id}/media")]
        [ProducesResponseType(typeof(ApiResponse<DiaryMediaDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 400)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        [ProducesResponseType(typeof(ApiResponse<object>), 403)]
        [ProducesResponseType(typeof(ApiResponse<object>), 404)]
        public async Task<IActionResult> AddDiaryMedia(Guid id, [FromBody] AddDiaryMediaByUrlDto addDiaryMediaDto)
        {
            var userId = GetUserId();
            var media = await _diaryService.AddDiaryMediaAsync(Guid.Parse(userId), id, addDiaryMediaDto);
            return Ok(ApiResponse<DiaryMediaDto>.CreateSuccess(media, "操作成功"));
        }

        /// <summary>
        /// 上传并添加日记媒体文件
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <param name="file">媒体文件</param>
        /// <param name="mediaType">媒体类型（Image、Video、Audio）</param>
        /// <param name="description">文件描述</param>
        /// <returns>媒体文件信息</returns>
        [HttpPost("{id}/media/upload")]
        [ProducesResponseType(typeof(ApiResponse<DiaryMediaDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 400)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        [ProducesResponseType(typeof(ApiResponse<object>), 403)]
        [ProducesResponseType(typeof(ApiResponse<object>), 404)]
        public async Task<IActionResult> UploadDiaryMedia(
            Guid id,
            IFormFile file,
            [FromForm] string mediaType,
            [FromForm] string? description = null)
        {
            var userId = GetUserId();
            var media = await _diaryService.UploadDiaryMediaAsync(Guid.Parse(userId), id, file, mediaType, description);
            return Ok(ApiResponse<DiaryMediaDto>.CreateSuccess(media, "文件上传成功"));
        }

        /// <summary>
        /// 删除日记媒体文件
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <param name="mediaId">媒体文件ID</param>
        /// <returns>删除结果</returns>
        [HttpDelete("{id}/media/{mediaId}")]
        [ProducesResponseType(typeof(ApiResponse<object>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        [ProducesResponseType(typeof(ApiResponse<object>), 403)]
        [ProducesResponseType(typeof(ApiResponse<object>), 404)]
        public async Task<IActionResult> DeleteDiaryMedia(Guid id, Guid mediaId)
        {
            var userId = GetUserId();
            var result = await _diaryService.DeleteDiaryMediaAsync(Guid.Parse(userId), id, mediaId);
            return Ok(ApiResponse<object>.CreateSuccess(null, "删除成功"));
        }

        /// <summary>
        /// 获取用户所有标签
        /// </summary>
        /// <returns>标签列表</returns>
        [HttpGet("tags")]
        [ProducesResponseType(typeof(ApiResponse<List<string>>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        public async Task<IActionResult> GetUserTags()
        {
            var userId = GetUserId();
            var tags = await _diaryService.GetUserTagsAsync(Guid.Parse(userId));
            return Ok(ApiResponse<List<string>>.CreateSuccess(tags, "获取标签成功"));
        }
    }
}