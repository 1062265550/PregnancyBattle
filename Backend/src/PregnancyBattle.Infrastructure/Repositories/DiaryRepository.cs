using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Dapper;
using Npgsql;
using PregnancyBattle.Domain.Entities;
using PregnancyBattle.Domain.Repositories;

namespace PregnancyBattle.Infrastructure.Repositories
{
    /// <summary>
    /// 日记仓储实现
    /// </summary>
    public class DiaryRepository : IDiaryRepository
    {
        private readonly string _connectionString;

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="connectionString">数据库连接字符串</param>
        public DiaryRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        /// <summary>
        /// 添加日记
        /// </summary>
        /// <param name="entity">日记实体</param>
        /// <returns>添加后的日记</returns>
        public async Task<Diary> AddAsync(Diary entity)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            await connection.OpenAsync();
            using var transaction = await connection.BeginTransactionAsync();

            try
            {
                // 插入日记
                const string diaryQuery = @"
                    INSERT INTO diaries (id, user_id, title, content, mood, diary_date, pregnancy_week, pregnancy_day, created_at, updated_at)
                    VALUES (@Id, @UserId, @Title, @Content, @Mood, @DiaryDate, @PregnancyWeek, @PregnancyDay, @CreatedAt, @UpdatedAt)";

                await connection.ExecuteAsync(diaryQuery, entity, transaction);

                // 插入标签
                if (entity.Tags?.Any() == true)
                {
                    const string tagQuery = @"
                        INSERT INTO diary_tags (id, diary_id, name, created_at, updated_at)
                        VALUES (@Id, @DiaryId, @Name, @CreatedAt, @UpdatedAt)";

                    await connection.ExecuteAsync(tagQuery, entity.Tags, transaction);
                }

                // 插入媒体文件
                if (entity.MediaFiles?.Any() == true)
                {
                    const string mediaQuery = @"
                        INSERT INTO diary_media (id, diary_id, media_type, media_url, description, created_at)
                        VALUES (@Id, @DiaryId, @MediaType, @MediaUrl, @Description, @CreatedAt)";

                    await connection.ExecuteAsync(mediaQuery, entity.MediaFiles, transaction);
                }

                await transaction.CommitAsync();
                return await GetByIdAsync(entity.Id);
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        /// <summary>
        /// 根据ID获取日记
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <returns>日记实体</returns>
        public async Task<Diary> GetByIdAsync(Guid id)
        {
            using var connection = new NpgsqlConnection(_connectionString);

            const string query = @"
                SELECT d.*, dt.id as TagId, dt.name as TagName, dt.created_at as TagCreatedAt, dt.updated_at as TagUpdatedAt,
                       dm.id as MediaId, dm.media_type as MediaType, dm.media_url as MediaUrl,
                       dm.description as MediaDescription, dm.created_at as MediaCreatedAt
                FROM diaries d
                LEFT JOIN diary_tags dt ON d.id = dt.diary_id
                LEFT JOIN diary_media dm ON d.id = dm.diary_id
                WHERE d.id = @Id";

            var diaryDict = new Dictionary<Guid, Diary>();

            await connection.QueryAsync<Diary, DiaryTag, DiaryMedia, Diary>(
                query,
                (diary, tag, media) =>
                {
                    if (!diaryDict.TryGetValue(diary.Id, out var diaryEntry))
                    {
                        diaryEntry = diary;
                        diaryEntry.Tags = new List<DiaryTag>();
                        diaryEntry.MediaFiles = new List<DiaryMedia>();
                        diaryDict.Add(diary.Id, diaryEntry);
                    }

                    if (tag != null && tag.Id != Guid.Empty)
                    {
                        tag.DiaryId = diary.Id;
                        if (!diaryEntry.Tags.Any(t => t.Id == tag.Id))
                        {
                            diaryEntry.Tags.Add(tag);
                        }
                    }

                    if (media != null && media.Id != Guid.Empty)
                    {
                        media.DiaryId = diary.Id;
                        if (!diaryEntry.MediaFiles.Any(m => m.Id == media.Id))
                        {
                            diaryEntry.MediaFiles.Add(media);
                        }
                    }

                    return diaryEntry;
                },
                new { Id = id },
                splitOn: "TagId,MediaId");

            return diaryDict.Values.FirstOrDefault();
        }

        /// <summary>
        /// 获取所有日记
        /// </summary>
        /// <returns>日记列表</returns>
        public async Task<IEnumerable<Diary>> GetAllAsync()
        {
            using var connection = new NpgsqlConnection(_connectionString);

            const string query = @"
                SELECT d.*, dt.id as TagId, dt.name as TagName, dt.created_at as TagCreatedAt, dt.updated_at as TagUpdatedAt,
                       dm.id as MediaId, dm.media_type as MediaType, dm.media_url as MediaUrl,
                       dm.description as MediaDescription, dm.created_at as MediaCreatedAt
                FROM diaries d
                LEFT JOIN diary_tags dt ON d.id = dt.diary_id
                LEFT JOIN diary_media dm ON d.id = dm.diary_id
                ORDER BY d.created_at DESC";

            var diaryDict = new Dictionary<Guid, Diary>();

            await connection.QueryAsync<Diary, DiaryTag, DiaryMedia, Diary>(
                query,
                (diary, tag, media) =>
                {
                    if (!diaryDict.TryGetValue(diary.Id, out var diaryEntry))
                    {
                        diaryEntry = diary;
                        diaryEntry.Tags = new List<DiaryTag>();
                        diaryEntry.MediaFiles = new List<DiaryMedia>();
                        diaryDict.Add(diary.Id, diaryEntry);
                    }

                    if (tag != null && tag.Id != Guid.Empty)
                    {
                        tag.DiaryId = diary.Id;
                        if (!diaryEntry.Tags.Any(t => t.Id == tag.Id))
                        {
                            diaryEntry.Tags.Add(tag);
                        }
                    }

                    if (media != null && media.Id != Guid.Empty)
                    {
                        media.DiaryId = diary.Id;
                        if (!diaryEntry.MediaFiles.Any(m => m.Id == media.Id))
                        {
                            diaryEntry.MediaFiles.Add(media);
                        }
                    }

                    return diaryEntry;
                },
                splitOn: "TagId,MediaId");

            return diaryDict.Values;
        }

        /// <summary>
        /// 更新日记
        /// </summary>
        /// <param name="entity">日记实体</param>
        /// <returns>更新后的日记</returns>
        public async Task<Diary> UpdateAsync(Diary entity)
        {
            using var connection = new NpgsqlConnection(_connectionString);

            const string query = @"
                UPDATE diaries
                SET title = @Title, content = @Content, mood = @Mood, diary_date = @DiaryDate,
                    pregnancy_week = @PregnancyWeek, pregnancy_day = @PregnancyDay, updated_at = @UpdatedAt
                WHERE id = @Id";

            await connection.ExecuteAsync(query, entity);
            return await GetByIdAsync(entity.Id);
        }

        /// <summary>
        /// 删除日记
        /// </summary>
        /// <param name="id">日记ID</param>
        /// <returns>是否删除成功</returns>
        public async Task<bool> DeleteAsync(Guid id)
        {
            using var connection = new NpgsqlConnection(_connectionString);

            const string query = "DELETE FROM diaries WHERE id = @Id";
            var rowsAffected = await connection.ExecuteAsync(query, new { Id = id });
            return rowsAffected > 0;
        }

        /// <summary>
        /// 获取用户的所有日记（分页）
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表和总数</returns>
        public async Task<(IEnumerable<Diary> Items, int TotalCount)> GetByUserIdAsync(Guid userId, int page, int pageSize, string sortBy, string sortDirection)
        {
            using var connection = new NpgsqlConnection(_connectionString);

            // 获取总数
            const string countQuery = "SELECT COUNT(*) FROM diaries WHERE user_id = @UserId";
            var totalCount = await connection.QuerySingleAsync<int>(countQuery, new { UserId = userId });

            // 构建排序字段
            var orderBy = GetOrderByClause(sortBy, sortDirection);
            var offset = (page - 1) * pageSize;

            var query = $@"
                SELECT d.*, dt.id as TagId, dt.name as TagName, dt.created_at as TagCreatedAt, dt.updated_at as TagUpdatedAt,
                       dm.id as MediaId, dm.media_type as MediaType, dm.media_url as MediaUrl,
                       dm.description as MediaDescription, dm.created_at as MediaCreatedAt
                FROM diaries d
                LEFT JOIN diary_tags dt ON d.id = dt.diary_id
                LEFT JOIN diary_media dm ON d.id = dm.diary_id
                WHERE d.user_id = @UserId
                ORDER BY d.{orderBy}
                LIMIT @PageSize OFFSET @Offset";

            var diaryDict = new Dictionary<Guid, Diary>();

            await connection.QueryAsync<Diary, DiaryTag, DiaryMedia, Diary>(
                query,
                (diary, tag, media) =>
                {
                    if (!diaryDict.TryGetValue(diary.Id, out var diaryEntry))
                    {
                        diaryEntry = diary;
                        diaryEntry.Tags = new List<DiaryTag>();
                        diaryEntry.MediaFiles = new List<DiaryMedia>();
                        diaryDict.Add(diary.Id, diaryEntry);
                    }

                    if (tag != null && tag.Id != Guid.Empty)
                    {
                        tag.DiaryId = diary.Id;
                        if (!diaryEntry.Tags.Any(t => t.Id == tag.Id))
                        {
                            diaryEntry.Tags.Add(tag);
                        }
                    }

                    if (media != null && media.Id != Guid.Empty)
                    {
                        media.DiaryId = diary.Id;
                        if (!diaryEntry.MediaFiles.Any(m => m.Id == media.Id))
                        {
                            diaryEntry.MediaFiles.Add(media);
                        }
                    }

                    return diaryEntry;
                },
                new { UserId = userId, PageSize = pageSize, Offset = offset },
                splitOn: "TagId,MediaId");

            return (diaryDict.Values, totalCount);
        }

        /// <summary>
        /// 根据日期范围获取用户日记（分页）
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="startDate">开始日期</param>
        /// <param name="endDate">结束日期</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表和总数</returns>
        public async Task<(IEnumerable<Diary> Items, int TotalCount)> GetByDateRangeAsync(Guid userId, DateTime startDate, DateTime endDate, int page, int pageSize, string sortBy, string sortDirection)
        {
            using var connection = new NpgsqlConnection(_connectionString);

            // 获取总数
            const string countQuery = @"
                SELECT COUNT(*) FROM diaries
                WHERE user_id = @UserId AND diary_date >= @StartDate AND diary_date <= @EndDate";
            var totalCount = await connection.QuerySingleAsync<int>(countQuery, new { UserId = userId, StartDate = startDate, EndDate = endDate });

            // 构建排序字段
            var orderBy = GetOrderByClause(sortBy, sortDirection);
            var offset = (page - 1) * pageSize;

            var query = $@"
                SELECT d.*, dt.id as TagId, dt.name as TagName, dt.created_at as TagCreatedAt, dt.updated_at as TagUpdatedAt,
                       dm.id as MediaId, dm.media_type as MediaType, dm.media_url as MediaUrl,
                       dm.description as MediaDescription, dm.created_at as MediaCreatedAt
                FROM diaries d
                LEFT JOIN diary_tags dt ON d.id = dt.diary_id
                LEFT JOIN diary_media dm ON d.id = dm.diary_id
                WHERE d.user_id = @UserId AND d.diary_date >= @StartDate AND d.diary_date <= @EndDate
                ORDER BY d.{orderBy}
                LIMIT @PageSize OFFSET @Offset";

            var diaryDict = new Dictionary<Guid, Diary>();

            await connection.QueryAsync<Diary, DiaryTag, DiaryMedia, Diary>(
                query,
                (diary, tag, media) =>
                {
                    if (!diaryDict.TryGetValue(diary.Id, out var diaryEntry))
                    {
                        diaryEntry = diary;
                        diaryEntry.Tags = new List<DiaryTag>();
                        diaryEntry.MediaFiles = new List<DiaryMedia>();
                        diaryDict.Add(diary.Id, diaryEntry);
                    }

                    if (tag != null && tag.Id != Guid.Empty)
                    {
                        tag.DiaryId = diary.Id;
                        if (!diaryEntry.Tags.Any(t => t.Id == tag.Id))
                        {
                            diaryEntry.Tags.Add(tag);
                        }
                    }

                    if (media != null && media.Id != Guid.Empty)
                    {
                        media.DiaryId = diary.Id;
                        if (!diaryEntry.MediaFiles.Any(m => m.Id == media.Id))
                        {
                            diaryEntry.MediaFiles.Add(media);
                        }
                    }

                    return diaryEntry;
                },
                new { UserId = userId, StartDate = startDate, EndDate = endDate, PageSize = pageSize, Offset = offset },
                splitOn: "TagId,MediaId");

            return (diaryDict.Values, totalCount);
        }

        /// <summary>
        /// 根据标签获取用户日记（分页）
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="tag">标签</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表和总数</returns>
        public async Task<(IEnumerable<Diary> Items, int TotalCount)> GetByTagAsync(Guid userId, string tag, int page, int pageSize, string sortBy, string sortDirection)
        {
            using var connection = new NpgsqlConnection(_connectionString);

            // 获取总数
            const string countQuery = @"
                SELECT COUNT(DISTINCT d.id) FROM diaries d
                INNER JOIN diary_tags dt ON d.id = dt.diary_id
                WHERE d.user_id = @UserId AND dt.name = @Tag";
            var totalCount = await connection.QuerySingleAsync<int>(countQuery, new { UserId = userId, Tag = tag });

            // 构建排序字段
            var orderBy = GetOrderByClause(sortBy, sortDirection);
            var offset = (page - 1) * pageSize;

            var query = $@"
                SELECT DISTINCT d.*, dt2.id as TagId, dt2.name as TagName, dt2.created_at as TagCreatedAt, dt2.updated_at as TagUpdatedAt,
                       dm.id as MediaId, dm.media_type as MediaType, dm.media_url as MediaUrl,
                       dm.description as MediaDescription, dm.created_at as MediaCreatedAt
                FROM diaries d
                INNER JOIN diary_tags dt ON d.id = dt.diary_id
                LEFT JOIN diary_tags dt2 ON d.id = dt2.diary_id
                LEFT JOIN diary_media dm ON d.id = dm.diary_id
                WHERE d.user_id = @UserId AND dt.name = @Tag
                ORDER BY d.{orderBy}
                LIMIT @PageSize OFFSET @Offset";

            var diaryDict = new Dictionary<Guid, Diary>();

            await connection.QueryAsync<Diary, DiaryTag, DiaryMedia, Diary>(
                query,
                (diary, tagItem, media) =>
                {
                    if (!diaryDict.TryGetValue(diary.Id, out var diaryEntry))
                    {
                        diaryEntry = diary;
                        diaryEntry.Tags = new List<DiaryTag>();
                        diaryEntry.MediaFiles = new List<DiaryMedia>();
                        diaryDict.Add(diary.Id, diaryEntry);
                    }

                    if (tagItem != null && tagItem.Id != Guid.Empty)
                    {
                        tagItem.DiaryId = diary.Id;
                        if (!diaryEntry.Tags.Any(t => t.Id == tagItem.Id))
                        {
                            diaryEntry.Tags.Add(tagItem);
                        }
                    }

                    if (media != null && media.Id != Guid.Empty)
                    {
                        media.DiaryId = diary.Id;
                        if (!diaryEntry.MediaFiles.Any(m => m.Id == media.Id))
                        {
                            diaryEntry.MediaFiles.Add(media);
                        }
                    }

                    return diaryEntry;
                },
                new { UserId = userId, Tag = tag, PageSize = pageSize, Offset = offset },
                splitOn: "TagId,MediaId");

            return (diaryDict.Values, totalCount);
        }

        /// <summary>
        /// 根据情绪获取用户日记（分页）
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="mood">情绪</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表和总数</returns>
        public async Task<(IEnumerable<Diary> Items, int TotalCount)> GetByMoodAsync(Guid userId, string mood, int page, int pageSize, string sortBy, string sortDirection)
        {
            using var connection = new NpgsqlConnection(_connectionString);

            // 获取总数
            const string countQuery = @"
                SELECT COUNT(*) FROM diaries
                WHERE user_id = @UserId AND mood = @Mood";
            var totalCount = await connection.QuerySingleAsync<int>(countQuery, new { UserId = userId, Mood = mood });

            // 构建排序字段
            var orderBy = GetOrderByClause(sortBy, sortDirection);
            var offset = (page - 1) * pageSize;

            var query = $@"
                SELECT d.*, dt.id as TagId, dt.name as TagName, dt.created_at as TagCreatedAt, dt.updated_at as TagUpdatedAt,
                       dm.id as MediaId, dm.media_type as MediaType, dm.media_url as MediaUrl,
                       dm.description as MediaDescription, dm.created_at as MediaCreatedAt
                FROM diaries d
                LEFT JOIN diary_tags dt ON d.id = dt.diary_id
                LEFT JOIN diary_media dm ON d.id = dm.diary_id
                WHERE d.user_id = @UserId AND d.mood = @Mood
                ORDER BY d.{orderBy}
                LIMIT @PageSize OFFSET @Offset";

            var diaryDict = new Dictionary<Guid, Diary>();

            await connection.QueryAsync<Diary, DiaryTag, DiaryMedia, Diary>(
                query,
                (diary, tag, media) =>
                {
                    if (!diaryDict.TryGetValue(diary.Id, out var diaryEntry))
                    {
                        diaryEntry = diary;
                        diaryEntry.Tags = new List<DiaryTag>();
                        diaryEntry.MediaFiles = new List<DiaryMedia>();
                        diaryDict.Add(diary.Id, diaryEntry);
                    }

                    if (tag != null && tag.Id != Guid.Empty)
                    {
                        tag.DiaryId = diary.Id;
                        if (!diaryEntry.Tags.Any(t => t.Id == tag.Id))
                        {
                            diaryEntry.Tags.Add(tag);
                        }
                    }

                    if (media != null && media.Id != Guid.Empty)
                    {
                        media.DiaryId = diary.Id;
                        if (!diaryEntry.MediaFiles.Any(m => m.Id == media.Id))
                        {
                            diaryEntry.MediaFiles.Add(media);
                        }
                    }

                    return diaryEntry;
                },
                new { UserId = userId, Mood = mood, PageSize = pageSize, Offset = offset },
                splitOn: "TagId,MediaId");

            return (diaryDict.Values, totalCount);
        }

        /// <summary>
        /// 添加日记标签
        /// </summary>
        /// <param name="diaryId">日记ID</param>
        /// <param name="tagNames">标签名称列表</param>
        /// <returns>添加后的标签列表</returns>
        public async Task<IEnumerable<DiaryTag>> AddTagsAsync(Guid diaryId, IEnumerable<string> tagNames)
        {
            using var connection = new NpgsqlConnection(_connectionString);

            var tags = tagNames.Select(tagName => new DiaryTag
            {
                Id = Guid.NewGuid(),
                DiaryId = diaryId,
                Name = tagName,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            }).ToList();

            const string query = @"
                INSERT INTO diary_tags (id, diary_id, name, created_at, updated_at)
                VALUES (@Id, @DiaryId, @Name, @CreatedAt, @UpdatedAt)
                ON CONFLICT (diary_id, name) DO NOTHING";

            await connection.ExecuteAsync(query, tags);
            return tags;
        }

        /// <summary>
        /// 删除日记标签
        /// </summary>
        /// <param name="diaryId">日记ID</param>
        /// <param name="tagName">标签名称</param>
        /// <returns>是否删除成功</returns>
        public async Task<bool> DeleteTagAsync(Guid diaryId, string tagName)
        {
            using var connection = new NpgsqlConnection(_connectionString);

            const string query = "DELETE FROM diary_tags WHERE diary_id = @DiaryId AND name = @TagName";
            var rowsAffected = await connection.ExecuteAsync(query, new { DiaryId = diaryId, TagName = tagName });
            return rowsAffected > 0;
        }

        /// <summary>
        /// 添加日记媒体文件
        /// </summary>
        /// <param name="diaryId">日记ID</param>
        /// <param name="mediaType">媒体类型</param>
        /// <param name="mediaUrl">媒体URL</param>
        /// <param name="description">媒体描述</param>
        /// <returns>添加后的媒体文件</returns>
        public async Task<DiaryMedia> AddMediaAsync(Guid diaryId, string mediaType, string mediaUrl, string? description)
        {
            using var connection = new NpgsqlConnection(_connectionString);

            var media = new DiaryMedia
            {
                Id = Guid.NewGuid(),
                DiaryId = diaryId,
                FileId = null, // 不使用fileId
                MediaType = mediaType,
                MediaUrl = mediaUrl,
                Description = description,
                CreatedAt = DateTime.UtcNow
            };

            const string query = @"
                INSERT INTO diary_media (id, diary_id, media_type, media_url, description, created_at)
                VALUES (@Id, @DiaryId, @MediaType, @MediaUrl, @Description, @CreatedAt)";

            await connection.ExecuteAsync(query, media);
            return media;
        }

        /// <summary>
        /// 删除日记媒体文件
        /// </summary>
        /// <param name="mediaId">媒体文件ID</param>
        /// <returns>是否删除成功</returns>
        public async Task<bool> DeleteMediaAsync(Guid mediaId)
        {
            using var connection = new NpgsqlConnection(_connectionString);

            const string query = "DELETE FROM diary_media WHERE id = @MediaId";
            var rowsAffected = await connection.ExecuteAsync(query, new { MediaId = mediaId });
            return rowsAffected > 0;
        }

        /// <summary>
        /// 根据多个条件获取用户日记（分页）
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
        /// <returns>分页日记列表和总数</returns>
        public async Task<(IEnumerable<Diary> Items, int TotalCount)> GetByMultipleFiltersAsync(
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
            using var connection = new NpgsqlConnection(_connectionString);

            // 构建WHERE条件
            var whereConditions = new List<string> { "d.user_id = @UserId" };
            var parameters = new DynamicParameters();
            parameters.Add("UserId", userId);

            // 添加情绪筛选条件
            if (!string.IsNullOrEmpty(mood))
            {
                whereConditions.Add("d.mood = @Mood");
                parameters.Add("Mood", mood);
            }

            // 添加日期范围筛选条件
            if (startDate.HasValue)
            {
                whereConditions.Add("d.diary_date >= @StartDate");
                parameters.Add("StartDate", startDate.Value.Date);
            }

            if (endDate.HasValue)
            {
                whereConditions.Add("d.diary_date <= @EndDate");
                parameters.Add("EndDate", endDate.Value.Date.AddDays(1).AddTicks(-1));
            }

            // 构建基础查询
            var baseQuery = @"
                FROM diaries d
                LEFT JOIN diary_tags dt ON d.id = dt.diary_id
                LEFT JOIN diary_media dm ON d.id = dm.diary_id";

            // 如果有标签筛选，需要特殊处理
            if (tags != null && tags.Any())
            {
                var tagList = tags.ToList();
                var tagParams = new List<string>();
                for (int i = 0; i < tagList.Count; i++)
                {
                    var paramName = $"Tag{i}";
                    tagParams.Add($"dt_filter.name = @{paramName}");
                    parameters.Add(paramName, tagList[i]);
                }

                var tagCondition = string.Join(" OR ", tagParams);
                baseQuery = $@"
                    FROM diaries d
                    INNER JOIN diary_tags dt_filter ON d.id = dt_filter.diary_id AND ({tagCondition})
                    LEFT JOIN diary_tags dt ON d.id = dt.diary_id
                    LEFT JOIN diary_media dm ON d.id = dm.diary_id";
            }

            var whereClause = string.Join(" AND ", whereConditions);

            // 构建排序字段
            var orderBy = GetOrderByClause(sortBy, sortDirection);
            var offset = (page - 1) * pageSize;
            parameters.Add("PageSize", pageSize);
            parameters.Add("Offset", offset);

            // 查询总数
            var countQuery = $@"
                SELECT COUNT(DISTINCT d.id)
                {baseQuery}
                WHERE {whereClause}";

            var totalCount = await connection.QuerySingleAsync<int>(countQuery, parameters);

            // 查询数据
            var query = $@"
                SELECT DISTINCT d.*, dt.id as TagId, dt.name as TagName, dt.created_at as TagCreatedAt, dt.updated_at as TagUpdatedAt,
                       dm.id as MediaId, dm.media_type as MediaType, dm.media_url as MediaUrl,
                       dm.description as MediaDescription, dm.created_at as MediaCreatedAt
                {baseQuery}
                WHERE {whereClause}
                ORDER BY d.{orderBy}
                LIMIT @PageSize OFFSET @Offset";

            var diaryDict = new Dictionary<Guid, Diary>();

            await connection.QueryAsync<Diary, DiaryTag, DiaryMedia, Diary>(
                query,
                (diary, tagItem, media) =>
                {
                    if (!diaryDict.TryGetValue(diary.Id, out var existingDiary))
                    {
                        existingDiary = diary;
                        existingDiary.Tags = new List<DiaryTag>();
                        existingDiary.MediaFiles = new List<DiaryMedia>();
                        diaryDict[diary.Id] = existingDiary;
                    }

                    if (tagItem != null && tagItem.Id != Guid.Empty)
                    {
                        tagItem.DiaryId = diary.Id;
                        if (!existingDiary.Tags.Any(t => t.Id == tagItem.Id))
                        {
                            existingDiary.Tags.Add(tagItem);
                        }
                    }

                    if (media != null && media.Id != Guid.Empty)
                    {
                        media.DiaryId = diary.Id;
                        if (!existingDiary.MediaFiles.Any(m => m.Id == media.Id))
                        {
                            existingDiary.MediaFiles.Add(media);
                        }
                    }

                    return existingDiary;
                },
                parameters,
                splitOn: "TagId,MediaId"
            );

            return (diaryDict.Values, totalCount);
        }

        /// <summary>
        /// 获取用户所有标签
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>标签列表</returns>
        public async Task<List<string>> GetUserTagsAsync(Guid userId)
        {
            using var connection = new NpgsqlConnection(_connectionString);

            const string query = @"
                SELECT DISTINCT dt.name
                FROM diary_tags dt
                INNER JOIN diaries d ON dt.diary_id = d.id
                WHERE d.user_id = @UserId
                ORDER BY dt.name";

            var tags = await connection.QueryAsync<string>(query, new { UserId = userId });
            return tags.ToList();
        }

        /// <summary>
        /// 构建排序子句
        /// </summary>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>排序子句</returns>
        private static string GetOrderByClause(string sortBy, string sortDirection)
        {
            var validSortFields = new Dictionary<string, string>
            {
                { "diaryDate", "diary_date" },
                { "createdAt", "created_at" },
                { "updatedAt", "updated_at" },
                { "title", "title" }
            };

            var field = validSortFields.ContainsKey(sortBy) ? validSortFields[sortBy] : "diary_date";
            var direction = sortDirection?.ToLower() == "asc" ? "ASC" : "DESC";

            return $"{field} {direction}";
        }
    }
}