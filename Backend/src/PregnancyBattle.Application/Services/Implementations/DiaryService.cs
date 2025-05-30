using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.AspNetCore.Http;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Application.Services.Interfaces;
using PregnancyBattle.Domain.Entities;
using PregnancyBattle.Domain.Repositories;
using PregnancyBattle.Domain.Exceptions;
using Microsoft.Extensions.Logging;

namespace PregnancyBattle.Application.Services.Implementations
{
    /// <summary>
    /// 日记服务实现
    /// </summary>
    public class DiaryService : IDiaryService
    {
        private readonly IDiaryRepository _diaryRepository;
        private readonly IPregnancyInfoRepository _pregnancyInfoRepository;
        private readonly IFileStorageService _fileStorageService;
        private readonly IMapper _mapper;
        private readonly ILogger<DiaryService> _logger;

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="diaryRepository">日记仓储</param>
        /// <param name="pregnancyInfoRepository">孕期信息仓储</param>
        /// <param name="fileStorageService">文件存储服务</param>
        /// <param name="mapper">对象映射器</param>
        /// <param name="logger">日志记录器</param>
        public DiaryService(
            IDiaryRepository diaryRepository,
            IPregnancyInfoRepository pregnancyInfoRepository,
            IFileStorageService fileStorageService,
            IMapper mapper,
            ILogger<DiaryService> logger)
        {
            _diaryRepository = diaryRepository;
            _pregnancyInfoRepository = pregnancyInfoRepository;
            _fileStorageService = fileStorageService;
            _mapper = mapper;
            _logger = logger;
        }

        /// <summary>
        /// 创建日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="createDiaryDto">创建日记请求</param>
        /// <returns>日记信息</returns>
        public async Task<DiaryDto> CreateDiaryAsync(Guid userId, CreateDiaryDto createDiaryDto)
        {
            // 获取孕期信息以计算孕周和孕天
            var pregnancyInfo = await _pregnancyInfoRepository.GetPregnancyInfoByUserIdAsync(userId);

            var diary = new Diary
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Title = createDiaryDto.Title,
                Content = createDiaryDto.Content,
                Mood = createDiaryDto.Mood,
                DiaryDate = createDiaryDto.DiaryDate,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                Tags = new List<DiaryTag>(),
                MediaFiles = new List<DiaryMedia>()
            };

            // 如果有孕期信息，计算孕周和孕天
            if (pregnancyInfo != null)
            {
                var daysSinceLmp = (createDiaryDto.DiaryDate - pregnancyInfo.LmpDate).Days;
                if (daysSinceLmp >= 0)
                {
                    diary.PregnancyWeek = (daysSinceLmp / 7) + 1;
                    diary.PregnancyDay = (daysSinceLmp % 7) + 1;
                }
            }

            // 添加标签
            if (createDiaryDto.Tags?.Any() == true)
            {
                foreach (var tagName in createDiaryDto.Tags)
                {
                    diary.Tags.Add(new DiaryTag
                    {
                        Id = Guid.NewGuid(),
                        DiaryId = diary.Id,
                        Name = tagName,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    });
                }
            }

            // 添加媒体文件
            if (createDiaryDto.MediaFiles?.Any() == true)
            {
                foreach (var mediaFile in createDiaryDto.MediaFiles)
                {
                    diary.MediaFiles.Add(new DiaryMedia
                    {
                        Id = Guid.NewGuid(),
                        DiaryId = diary.Id,
                        MediaType = mediaFile.MediaType,
                        MediaUrl = mediaFile.MediaUrl,
                        Description = mediaFile.Description,
                        CreatedAt = DateTime.UtcNow
                    });
                }
            }

            var createdDiary = await _diaryRepository.AddAsync(diary);
            return _mapper.Map<DiaryDto>(createdDiary);
        }

        /// <summary>
        /// 获取日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <returns>日记信息</returns>
        public async Task<DiaryDto> GetDiaryAsync(Guid userId, Guid diaryId)
        {
            var diary = await _diaryRepository.GetByIdAsync(diaryId);

            if (diary == null)
            {
                throw new NotFoundException("日记不存在");
            }

            if (diary.UserId != userId)
            {
                throw new ForbiddenException("无权访问此日记");
            }

            return _mapper.Map<DiaryDto>(diary);
        }

        /// <summary>
        /// 获取用户所有日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表</returns>
        public async Task<PagedDiaryListDto> GetUserDiariesAsync(Guid userId, int page = 1, int pageSize = 10, string sortBy = "diaryDate", string sortDirection = "desc")
        {
            var (items, totalCount) = await _diaryRepository.GetByUserIdAsync(userId, page, pageSize, sortBy, sortDirection);

            var diaryDtos = _mapper.Map<List<DiaryDto>>(items);

            return new PagedDiaryListDto
            {
                Items = diaryDtos,
                TotalCount = totalCount,
                PageCount = (int)Math.Ceiling((double)totalCount / pageSize),
                CurrentPage = page,
                PageSize = pageSize
            };
        }

        /// <summary>
        /// 根据日期范围获取日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="startDate">开始日期</param>
        /// <param name="endDate">结束日期</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表</returns>
        public async Task<PagedDiaryListDto> GetDiariesByDateRangeAsync(Guid userId, DateTime startDate, DateTime endDate, int page = 1, int pageSize = 10, string sortBy = "diaryDate", string sortDirection = "desc")
        {
            var (items, totalCount) = await _diaryRepository.GetByDateRangeAsync(userId, startDate, endDate, page, pageSize, sortBy, sortDirection);

            var diaryDtos = _mapper.Map<List<DiaryDto>>(items);

            return new PagedDiaryListDto
            {
                Items = diaryDtos,
                TotalCount = totalCount,
                PageCount = (int)Math.Ceiling((double)totalCount / pageSize),
                CurrentPage = page,
                PageSize = pageSize
            };
        }

        /// <summary>
        /// 根据标签获取日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="tag">标签</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表</returns>
        public async Task<PagedDiaryListDto> GetDiariesByTagAsync(Guid userId, string tag, int page = 1, int pageSize = 10, string sortBy = "diaryDate", string sortDirection = "desc")
        {
            var (items, totalCount) = await _diaryRepository.GetByTagAsync(userId, tag, page, pageSize, sortBy, sortDirection);

            var diaryDtos = _mapper.Map<List<DiaryDto>>(items);

            return new PagedDiaryListDto
            {
                Items = diaryDtos,
                TotalCount = totalCount,
                PageCount = (int)Math.Ceiling((double)totalCount / pageSize),
                CurrentPage = page,
                PageSize = pageSize
            };
        }

        /// <summary>
        /// 根据情绪获取日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="mood">情绪</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表</returns>
        public async Task<PagedDiaryListDto> GetDiariesByMoodAsync(Guid userId, string mood, int page = 1, int pageSize = 10, string sortBy = "diaryDate", string sortDirection = "desc")
        {
            var (items, totalCount) = await _diaryRepository.GetByMoodAsync(userId, mood, page, pageSize, sortBy, sortDirection);

            var diaryDtos = _mapper.Map<List<DiaryDto>>(items);

            return new PagedDiaryListDto
            {
                Items = diaryDtos,
                TotalCount = totalCount,
                PageCount = (int)Math.Ceiling((double)totalCount / pageSize),
                CurrentPage = page,
                PageSize = pageSize
            };
        }

        /// <summary>
        /// 更新日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <param name="updateDiaryDto">更新日记请求</param>
        /// <returns>日记信息</returns>
        public async Task<DiaryDto> UpdateDiaryAsync(Guid userId, Guid diaryId, UpdateDiaryDto updateDiaryDto)
        {
            var diary = await _diaryRepository.GetByIdAsync(diaryId);

            if (diary == null)
            {
                throw new NotFoundException("日记不存在");
            }

            if (diary.UserId != userId)
            {
                throw new ForbiddenException("无权修改此日记");
            }

            // 更新字段
            if (!string.IsNullOrEmpty(updateDiaryDto.Title))
                diary.Title = updateDiaryDto.Title;

            if (!string.IsNullOrEmpty(updateDiaryDto.Content))
                diary.Content = updateDiaryDto.Content;

            if (!string.IsNullOrEmpty(updateDiaryDto.Mood))
                diary.Mood = updateDiaryDto.Mood;

            if (updateDiaryDto.DiaryDate.HasValue)
            {
                diary.DiaryDate = updateDiaryDto.DiaryDate.Value;

                // 重新计算孕周和孕天
                var pregnancyInfo = await _pregnancyInfoRepository.GetPregnancyInfoByUserIdAsync(userId);
                if (pregnancyInfo != null)
                {
                    var daysSinceLmp = (diary.DiaryDate - pregnancyInfo.LmpDate).Days;
                    if (daysSinceLmp >= 0)
                    {
                        diary.PregnancyWeek = (daysSinceLmp / 7) + 1;
                        diary.PregnancyDay = (daysSinceLmp % 7) + 1;
                    }
                }
            }

            diary.UpdatedAt = DateTime.UtcNow;

            var updatedDiary = await _diaryRepository.UpdateAsync(diary);
            return _mapper.Map<DiaryDto>(updatedDiary);
        }

        /// <summary>
        /// 删除日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <returns>是否删除成功</returns>
        public async Task<bool> DeleteDiaryAsync(Guid userId, Guid diaryId)
        {
            var diary = await _diaryRepository.GetByIdAsync(diaryId);

            if (diary == null)
            {
                throw new NotFoundException("日记不存在");
            }

            if (diary.UserId != userId)
            {
                throw new ForbiddenException("无权删除此日记");
            }

            return await _diaryRepository.DeleteAsync(diaryId);
        }

        /// <summary>
        /// 添加日记标签
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <param name="addDiaryTagsDto">添加标签请求</param>
        /// <returns>更新后的日记信息</returns>
        public async Task<DiaryDto> AddDiaryTagsAsync(Guid userId, Guid diaryId, AddDiaryTagsDto addDiaryTagsDto)
        {
            var diary = await _diaryRepository.GetByIdAsync(diaryId);

            if (diary == null)
            {
                throw new NotFoundException("日记不存在");
            }

            if (diary.UserId != userId)
            {
                throw new ForbiddenException("无权修改此日记");
            }

            if (addDiaryTagsDto.Tags?.Any() == true)
            {
                await _diaryRepository.AddTagsAsync(diaryId, addDiaryTagsDto.Tags);
            }

            // 重新获取更新后的日记
            var updatedDiary = await _diaryRepository.GetByIdAsync(diaryId);
            return _mapper.Map<DiaryDto>(updatedDiary);
        }

        /// <summary>
        /// 删除日记标签
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <param name="tag">标签名称</param>
        /// <returns>更新后的日记信息</returns>
        public async Task<DiaryDto> DeleteDiaryTagAsync(Guid userId, Guid diaryId, string tag)
        {
            var diary = await _diaryRepository.GetByIdAsync(diaryId);

            if (diary == null)
            {
                throw new NotFoundException("日记不存在");
            }

            if (diary.UserId != userId)
            {
                throw new ForbiddenException("无权修改此日记");
            }

            await _diaryRepository.DeleteTagAsync(diaryId, tag);

            // 重新获取更新后的日记
            var updatedDiary = await _diaryRepository.GetByIdAsync(diaryId);
            return _mapper.Map<DiaryDto>(updatedDiary);
        }

        /// <summary>
        /// 添加日记媒体文件 (使用URL)
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <param name="addDiaryMediaDto">添加媒体文件请求</param>
        /// <returns>媒体文件信息</returns>
        public async Task<DiaryMediaDto> AddDiaryMediaAsync(Guid userId, Guid diaryId, AddDiaryMediaByUrlDto addDiaryMediaDto)
        {
            var diary = await _diaryRepository.GetByIdAsync(diaryId);

            if (diary == null)
            {
                throw new NotFoundException("日记不存在");
            }

            if (diary.UserId != userId)
            {
                throw new ForbiddenException("无权修改此日记");
            }

            var media = await _diaryRepository.AddMediaAsync(diaryId, addDiaryMediaDto.MediaType, addDiaryMediaDto.MediaUrl, addDiaryMediaDto.Description);
            return _mapper.Map<DiaryMediaDto>(media);
        }

        /// <summary>
        /// 上传并添加日记媒体文件
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <param name="file">媒体文件</param>
        /// <param name="mediaType">媒体类型</param>
        /// <param name="description">文件描述</param>
        /// <returns>媒体文件信息</returns>
        public async Task<DiaryMediaDto> UploadDiaryMediaAsync(Guid userId, Guid diaryId, IFormFile file, string mediaType, string? description)
        {
            var diary = await _diaryRepository.GetByIdAsync(diaryId);

            if (diary == null)
            {
                throw new NotFoundException("日记不存在");
            }

            if (diary.UserId != userId)
            {
                throw new ForbiddenException("无权修改此日记");
            }

            // 验证文件
            if (file == null || file.Length == 0)
            {
                throw new ArgumentException("文件不能为空");
            }

            // 验证文件大小（限制为10MB）
            const long maxFileSize = 10 * 1024 * 1024; // 10MB
            if (file.Length > maxFileSize)
            {
                throw new ArgumentException("文件大小不能超过10MB");
            }

            // 验证媒体类型
            var validMediaTypes = new[] { "Image", "Video", "Audio" };
            if (!validMediaTypes.Contains(mediaType, StringComparer.OrdinalIgnoreCase))
            {
                throw new ArgumentException("无效的媒体类型");
            }

            // 验证文件扩展名
            var fileExtension = Path.GetExtension(file.FileName).ToLowerInvariant();
            var allowedExtensions = mediaType.ToLowerInvariant() switch
            {
                "image" => new[] { ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp" },
                "video" => new[] { ".mp4", ".mov", ".avi", ".wmv", ".flv" },
                "audio" => new[] { ".mp3", ".wav", ".aac", ".ogg", ".m4a" },
                _ => Array.Empty<string>()
            };

            if (!allowedExtensions.Contains(fileExtension))
            {
                throw new ArgumentException($"不支持的{mediaType}文件格式");
            }

            try
            {
                // 上传文件到存储服务
                using var stream = file.OpenReadStream();
                var fileUrl = await _fileStorageService.UploadFileAsync(stream, file.FileName, file.ContentType, "diary-media");

                // 添加媒体记录到数据库
                var media = await _diaryRepository.AddMediaAsync(diaryId, mediaType, fileUrl, description);
                return _mapper.Map<DiaryMediaDto>(media);
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"文件上传失败：{ex.Message}", ex);
            }
        }

        /// <summary>
        /// 删除日记媒体文件
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <param name="mediaId">媒体文件ID</param>
        /// <returns>是否删除成功</returns>
        public async Task<bool> DeleteDiaryMediaAsync(Guid userId, Guid diaryId, Guid mediaId)
        {
            var diary = await _diaryRepository.GetByIdAsync(diaryId);

            if (diary == null)
            {
                throw new NotFoundException("日记不存在");
            }

            if (diary.UserId != userId)
            {
                throw new ForbiddenException("无权修改此日记");
            }

            // 首先获取媒体文件信息
            var mediaFile = diary.MediaFiles.FirstOrDefault(m => m.Id == mediaId);
            if (mediaFile == null)
            {
                throw new NotFoundException("媒体文件不存在");
            }

            // 从数据库中删除媒体文件记录
            var deleteResult = await _diaryRepository.DeleteMediaAsync(mediaId);
            
            if (deleteResult && !string.IsNullOrEmpty(mediaFile.MediaUrl))
            {
                try
                {
                    // 从腾讯云COS中删除实际文件
                    await _fileStorageService.DeleteFileAsync(mediaFile.MediaUrl);
                    _logger.LogInformation("成功从COS删除媒体文件: {MediaUrl}", mediaFile.MediaUrl);
                }
                catch (Exception ex)
                {
                    // 记录警告但不影响数据库删除的结果
                    _logger.LogWarning(ex, "从COS删除媒体文件失败: {MediaUrl}", mediaFile.MediaUrl);
                }
            }

            return deleteResult;
        }

        /// <summary>
        /// 根据多个条件获取日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="mood">情绪（可选）</param>
        /// <param name="tags">标签列表（可选）</param>
        /// <param name="startDate">开始日期（可选）</param>
        /// <param name="endDate">结束日期（可选）</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表</returns>
        public async Task<PagedDiaryListDto> GetDiariesByMultipleFiltersAsync(
            Guid userId,
            string? mood = null,
            IEnumerable<string>? tags = null,
            DateTime? startDate = null,
            DateTime? endDate = null,
            int page = 1,
            int pageSize = 10,
            string sortBy = "diaryDate",
            string sortDirection = "desc")
        {
            var (items, totalCount) = await _diaryRepository.GetByMultipleFiltersAsync(
                userId, mood, tags, startDate, endDate, page, pageSize, sortBy, sortDirection);

            var diaryDtos = _mapper.Map<List<DiaryDto>>(items);

            return new PagedDiaryListDto
            {
                Items = diaryDtos,
                TotalCount = totalCount,
                CurrentPage = page,
                PageSize = pageSize,
                PageCount = (int)Math.Ceiling((double)totalCount / pageSize)
            };
        }

        /// <summary>
        /// 获取用户所有标签
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>标签列表</returns>
        public async Task<List<string>> GetUserTagsAsync(Guid userId)
        {
            return await _diaryRepository.GetUserTagsAsync(userId);
        }
    }
}
