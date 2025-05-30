using System;
using FluentValidation;
using PregnancyBattle.Application.DTOs;

namespace PregnancyBattle.Application.Validators
{
    /// <summary>
    /// 创建日记验证器
    /// </summary>
    public class CreateDiaryDtoValidator : AbstractValidator<CreateDiaryDto>
    {
        public CreateDiaryDtoValidator()
        {
            RuleFor(x => x.Title)
                .NotEmpty().WithMessage("日记标题不能为空")
                .MaximumLength(100).WithMessage("日记标题不能超过100个字符");

            RuleFor(x => x.Content)
                .NotEmpty().WithMessage("日记内容不能为空");

            RuleFor(x => x.Mood)
                .Must(BeValidMood).WithMessage("情绪状态无效")
                .When(x => !string.IsNullOrEmpty(x.Mood));

            RuleFor(x => x.DiaryDate)
                .NotEmpty().WithMessage("日记日期不能为空")
                .Must(date => date.Date <= DateTime.Today).WithMessage("日记日期不能晚于今天");

            RuleFor(x => x.Tags)
                .Must(tags => tags == null || tags.Count <= 10).WithMessage("标签数量不能超过10个")
                .When(x => x.Tags != null);

            RuleForEach(x => x.Tags)
                .NotEmpty().WithMessage("标签名称不能为空")
                .MaximumLength(50).WithMessage("标签名称不能超过50个字符")
                .When(x => x.Tags != null);

            RuleFor(x => x.MediaFiles)
                .Must(mediaFiles => mediaFiles == null || mediaFiles.Count <= 9).WithMessage("媒体文件数量不能超过9个")
                .When(x => x.MediaFiles != null);

            RuleForEach(x => x.MediaFiles)
                .SetValidator(new CreateDiaryMediaDtoValidator())
                .When(x => x.MediaFiles != null);
        }

        private static bool BeValidMood(string mood)
        {
            var validMoods = new[] { "Happy", "Sad", "Angry", "Anxious", "Excited", "Tired", "Neutral" };
            return Array.Exists(validMoods, m => m.Equals(mood, StringComparison.OrdinalIgnoreCase));
        }
    }

    /// <summary>
    /// 创建日记媒体文件验证器
    /// </summary>
    public class CreateDiaryMediaDtoValidator : AbstractValidator<CreateDiaryMediaDto>
    {
        public CreateDiaryMediaDtoValidator()
        {
            RuleFor(x => x.MediaType)
                .NotEmpty().WithMessage("媒体类型不能为空")
                .Must(BeValidMediaType).WithMessage("媒体类型无效");

            RuleFor(x => x.MediaUrl)
                .NotEmpty().WithMessage("媒体URL不能为空")
                .MaximumLength(500).WithMessage("媒体URL不能超过500个字符");

            RuleFor(x => x.Description)
                .MaximumLength(200).WithMessage("媒体描述不能超过200个字符")
                .When(x => !string.IsNullOrEmpty(x.Description));
        }

        private static bool BeValidMediaType(string mediaType)
        {
            var validTypes = new[] { "Image", "Video", "Audio" };
            return Array.Exists(validTypes, t => t.Equals(mediaType, StringComparison.OrdinalIgnoreCase));
        }
    }

    /// <summary>
    /// 更新日记验证器
    /// </summary>
    public class UpdateDiaryDtoValidator : AbstractValidator<UpdateDiaryDto>
    {
        public UpdateDiaryDtoValidator()
        {
            // 确保至少有一个字段被提供
            RuleFor(x => x)
                .Must(x => !string.IsNullOrEmpty(x.Title) ||
                          !string.IsNullOrEmpty(x.Content) ||
                          !string.IsNullOrEmpty(x.Mood) ||
                          x.DiaryDate.HasValue)
                .WithMessage("至少需要提供一个要更新的字段");

            RuleFor(x => x.Title)
                .NotEmpty().WithMessage("日记标题不能为空")
                .MaximumLength(100).WithMessage("日记标题不能超过100个字符")
                .When(x => !string.IsNullOrEmpty(x.Title));

            RuleFor(x => x.Content)
                .NotEmpty().WithMessage("日记内容不能为空")
                .When(x => !string.IsNullOrEmpty(x.Content));

            RuleFor(x => x.Mood)
                .Must(BeValidMood).WithMessage("情绪状态无效")
                .When(x => !string.IsNullOrEmpty(x.Mood));

            RuleFor(x => x.DiaryDate)
                .Must(date => !date.HasValue || date.Value.Date <= DateTime.Today).WithMessage("日记日期不能晚于今天")
                .When(x => x.DiaryDate.HasValue);
        }

        private static bool BeValidMood(string? mood)
        {
            if (string.IsNullOrEmpty(mood)) return false;
            var validMoods = new[] { "Happy", "Sad", "Angry", "Anxious", "Excited", "Tired", "Neutral" };
            return Array.Exists(validMoods, m => m.Equals(mood, StringComparison.OrdinalIgnoreCase));
        }
    }

    /// <summary>
    /// 添加日记标签验证器
    /// </summary>
    public class AddDiaryTagsDtoValidator : AbstractValidator<AddDiaryTagsDto>
    {
        public AddDiaryTagsDtoValidator()
        {
            RuleFor(x => x.Tags)
                .NotEmpty().WithMessage("标签列表不能为空")
                .Must(tags => tags.Count <= 10).WithMessage("标签数量不能超过10个");

            RuleForEach(x => x.Tags)
                .NotEmpty().WithMessage("标签名称不能为空")
                .MaximumLength(50).WithMessage("标签名称不能超过50个字符");
        }
    }

    /// <summary>
    /// 添加日记媒体文件验证器
    /// </summary>
    public class AddDiaryMediaByUrlDtoValidator : AbstractValidator<AddDiaryMediaByUrlDto>
    {
        public AddDiaryMediaByUrlDtoValidator()
        {
            RuleFor(x => x.MediaType)
                .NotEmpty().WithMessage("媒体类型不能为空")
                .Must(BeValidMediaType).WithMessage("媒体类型无效");

            RuleFor(x => x.MediaUrl)
                .NotEmpty().WithMessage("媒体URL不能为空")
                .MaximumLength(500).WithMessage("媒体URL不能超过500个字符");

            RuleFor(x => x.Description)
                .MaximumLength(200).WithMessage("媒体描述不能超过200个字符")
                .When(x => !string.IsNullOrEmpty(x.Description));
        }

        private static bool BeValidMediaType(string mediaType)
        {
            var validTypes = new[] { "Image", "Video", "Audio" };
            return Array.Exists(validTypes, t => t.Equals(mediaType, StringComparison.OrdinalIgnoreCase));
        }
    }
}
