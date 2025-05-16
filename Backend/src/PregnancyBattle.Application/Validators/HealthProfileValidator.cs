using FluentValidation;
using PregnancyBattle.Application.DTOs;

namespace PregnancyBattle.Application.Validators
{
    /// <summary>
    /// 创建健康档案请求验证器
    /// </summary>
    public class CreateHealthProfileValidator : AbstractValidator<CreateHealthProfileDto>
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public CreateHealthProfileValidator()
        {
            RuleFor(x => x.Height)
                .NotEmpty().WithMessage("身高不能为空")
                .InclusiveBetween(100, 250).WithMessage("身高必须在100-250厘米之间");
            
            RuleFor(x => x.PrePregnancyWeight)
                .NotEmpty().WithMessage("孕前体重不能为空")
                .InclusiveBetween(30, 200).WithMessage("孕前体重必须在30-200千克之间");
            
            RuleFor(x => x.CurrentWeight)
                .NotEmpty().WithMessage("当前体重不能为空")
                .InclusiveBetween(30, 200).WithMessage("当前体重必须在30-200千克之间");
            
            RuleFor(x => x.BloodType)
                .NotEmpty().WithMessage("血型不能为空")
                .Must(x => x == "A" || x == "B" || x == "AB" || x == "O" || 
                           x == "A+" || x == "A-" || x == "B+" || x == "B-" || 
                           x == "AB+" || x == "AB-" || x == "O+" || x == "O-")
                .WithMessage("血型格式不正确");
            
            RuleFor(x => x.Age)
                .NotEmpty().WithMessage("年龄不能为空")
                .InclusiveBetween(18, 60).WithMessage("年龄必须在18-60岁之间");
        }
    }
    
    /// <summary>
    /// 更新健康档案请求验证器
    /// </summary>
    public class UpdateHealthProfileValidator : AbstractValidator<UpdateHealthProfileDto>
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public UpdateHealthProfileValidator()
        {
            When(x => x.Height.HasValue, () =>
            {
                RuleFor(x => x.Height)
                    .InclusiveBetween(100, 250).WithMessage("身高必须在100-250厘米之间");
            });
            
            When(x => x.CurrentWeight.HasValue, () =>
            {
                RuleFor(x => x.CurrentWeight)
                    .InclusiveBetween(30, 200).WithMessage("当前体重必须在30-200千克之间");
            });
            
            When(x => !string.IsNullOrEmpty(x.BloodType), () =>
            {
                RuleFor(x => x.BloodType)
                    .Must(x => x == "A" || x == "B" || x == "AB" || x == "O" || 
                               x == "A+" || x == "A-" || x == "B+" || x == "B-" || 
                               x == "AB+" || x == "AB-" || x == "O+" || x == "O-")
                    .WithMessage("血型格式不正确");
            });
        }
    }
}