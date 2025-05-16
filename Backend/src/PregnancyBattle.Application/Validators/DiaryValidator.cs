using System;
using FluentValidation;
using PregnancyBattle.Application.DTOs;

namespace PregnancyBattle.Application.Validators
{
    /// <summary>
    /// 创建日记请求验证器
    /// </summary>
    public class CreateDiaryValidator : AbstractValidator<CreateDiaryDto>
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public CreateDiaryValidator()
        {
            RuleFor(x => x.Title)
                .NotEmpty().WithMessage("日记标题不能为空")
                .MaximumLength(100).WithMessage("日记标题长度不能超过100个字符");
            
            RuleFor(x => x.Content)
                .NotEmpty().WithMessage("日记内容不能为空");
            
            RuleFor(x => x.DiaryDate)
                .NotEmpty().WithMessage("日记日期不能为空")
                .LessThanOrEqualTo(DateTime.Today).WithMessage("日记日期不能晚于今天");
            
            RuleFor(x => x.Mood)
                .MaximumLength(50).WithMessage("情绪状态长度不能超过50个字符");
            
            RuleForEach(x => x.Tags)
                .NotEmpty().WithMessage("标签不能为空")
                .MaximumLength(50).WithMessage("标签长度不能超过50个字符");
        }
    }
    
    /// <summary>
    /// 更新日记请求验证器
    /// </summary>
    public class UpdateDiaryValidator : AbstractValidator<UpdateDiaryDto>
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public UpdateDiaryValidator()
        {
            When(x => !string.IsNullOrEmpty(x.Title), () =>
            {
                RuleFor(x => x.Title)
                    .MaximumLength(100).WithMessage("日记标题长度不能超过100个字符");
            });
            
            When(x => x.DiaryDate.HasValue, () =>
            {
                RuleFor(x => x.DiaryDate)
                    .LessThanOrEqualTo(DateTime.Today).WithMessage("日记日期不能晚于今天");
            });
            
            When(x => !string.IsNullOrEmpty(x.Mood), () =>
            {
                RuleFor(x => x.Mood)
                    .MaximumLength(50).WithMessage("情绪状态长度不能超过50个字符");
            });
        }
    }
    
    /// <summary>
    /// 添加日记媒体文件请求验证器
    /// </summary>
    public class AddDiaryMediaValidator : AbstractValidator<AddDiaryMediaDto>
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public AddDiaryMediaValidator()
        {
            RuleFor(x => x.MediaType)
                .NotEmpty().WithMessage("媒体类型不能为空")
                .Must(x => x == "Image" || x == "Audio" || x == "Video")
                .WithMessage("媒体类型必须是Image、Audio或Video");
            
            RuleFor(x => x.MediaUrl)
                .NotEmpty().WithMessage("媒体URL不能为空")
                .MaximumLength(500).WithMessage("媒体URL长度不能超过500个字符");
            
            RuleFor(x => x.Description)
                .MaximumLength(200).WithMessage("媒体描述长度不能超过200个字符");
        }
    }
}