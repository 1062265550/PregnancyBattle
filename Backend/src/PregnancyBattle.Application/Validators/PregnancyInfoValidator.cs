using System;
using FluentValidation;
using PregnancyBattle.Application.DTOs;

namespace PregnancyBattle.Application.Validators
{
    /// <summary>
    /// 创建孕期信息请求验证器
    /// </summary>
    public class CreatePregnancyInfoValidator : AbstractValidator<CreatePregnancyInfoDto>
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public CreatePregnancyInfoValidator()
        {
            RuleFor(x => x.LmpDate)
                .NotEmpty().WithMessage("末次月经日期不能为空")
                .LessThanOrEqualTo(DateTime.Today).WithMessage("末次月经日期不能晚于今天");
            
            RuleFor(x => x.CalculationMethod)
                .NotEmpty().WithMessage("预产期计算方式不能为空")
                .Must(x => x == "LMP" || x == "Ultrasound" || x == "IVF")
                .WithMessage("预产期计算方式必须是LMP、Ultrasound或IVF");
            
            When(x => x.CalculationMethod == "Ultrasound", () =>
            {
                RuleFor(x => x.UltrasoundDate)
                    .NotEmpty().WithMessage("B超日期不能为空")
                    .LessThanOrEqualTo(DateTime.Today).WithMessage("B超日期不能晚于今天");
                
                RuleFor(x => x.UltrasoundWeeks)
                    .NotEmpty().WithMessage("B超孕周不能为空")
                    .InclusiveBetween(0, 42).WithMessage("B超孕周必须在0-42周之间");
                
                RuleFor(x => x.UltrasoundDays)
                    .NotEmpty().WithMessage("B超孕天不能为空")
                    .InclusiveBetween(0, 6).WithMessage("B超孕天必须在0-6天之间");
            });
            
            When(x => x.IsMultiplePregnancy, () =>
            {
                RuleFor(x => x.FetusCount)
                    .NotEmpty().WithMessage("胎儿数量不能为空")
                    .InclusiveBetween(2, 10).WithMessage("胎儿数量必须在2-10个之间");
            });
        }
    }
    
    /// <summary>
    /// 更新孕期信息请求验证器
    /// </summary>
    public class UpdatePregnancyInfoValidator : AbstractValidator<UpdatePregnancyInfoDto>
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public UpdatePregnancyInfoValidator()
        {
            When(x => x.DueDate.HasValue, () =>
            {
                RuleFor(x => x.DueDate)
                    .GreaterThan(DateTime.Today).WithMessage("预产期必须晚于今天");
            });
            
            When(x => !string.IsNullOrEmpty(x.CalculationMethod), () =>
            {
                RuleFor(x => x.CalculationMethod)
                    .Must(x => x == "LMP" || x == "Ultrasound" || x == "IVF")
                    .WithMessage("预产期计算方式必须是LMP、Ultrasound或IVF");
            });
            
            When(x => x.UltrasoundDate.HasValue, () =>
            {
                RuleFor(x => x.UltrasoundDate)
                    .LessThanOrEqualTo(DateTime.Today).WithMessage("B超日期不能晚于今天");
            });
            
            When(x => x.UltrasoundWeeks.HasValue, () =>
            {
                RuleFor(x => x.UltrasoundWeeks)
                    .InclusiveBetween(0, 42).WithMessage("B超孕周必须在0-42周之间");
            });
            
            When(x => x.UltrasoundDays.HasValue, () =>
            {
                RuleFor(x => x.UltrasoundDays)
                    .InclusiveBetween(0, 6).WithMessage("B超孕天必须在0-6天之间");
            });
            
            When(x => x.IsMultiplePregnancy.HasValue && x.IsMultiplePregnancy.Value, () =>
            {
                RuleFor(x => x.FetusCount)
                    .NotEmpty().WithMessage("胎儿数量不能为空")
                    .InclusiveBetween(2, 10).WithMessage("胎儿数量必须在2-10个之间");
            });
        }
    }
}