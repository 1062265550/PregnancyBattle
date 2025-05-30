using FluentValidation;
using PregnancyBattle.Application.DTOs;

namespace PregnancyBattle.Application.Validators
{
    public class CreateHealthProfileDtoValidator : AbstractValidator<CreateHealthProfileDto>
    {
        public CreateHealthProfileDtoValidator()
        {
            RuleFor(x => x.Height).NotEmpty().InclusiveBetween(100, 250).WithMessage("身高必须在100到250厘米之间。");
            RuleFor(x => x.PrePregnancyWeight).NotEmpty().InclusiveBetween(30, 200).WithMessage("孕前体重必须在30到200千克之间。");
            RuleFor(x => x.CurrentWeight).NotEmpty().InclusiveBetween(30, 200).WithMessage("当前体重必须在30到200千克之间。");
            RuleFor(x => x.BloodType).NotEmpty().Must(BeValidBloodType).WithMessage("请输入有效的血型 (A, B, AB, O, A+, A-, B+, B-, AB+, AB-, O+, O-)。");
            RuleFor(x => x.Age).NotEmpty().InclusiveBetween(18, 60).WithMessage("年龄必须在18到60岁之间。");
            RuleFor(x => x.MedicalHistory).MaximumLength(1000);
            RuleFor(x => x.FamilyHistory).MaximumLength(1000);
            RuleFor(x => x.AllergiesHistory).MaximumLength(1000);
            RuleFor(x => x.ObstetricHistory).MaximumLength(1000);
        }

        private bool BeValidBloodType(string bloodType)
        {
            var validBloodTypes = new[] { "A", "B", "AB", "O", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" };
            return validBloodTypes.Contains(bloodType?.ToUpper());
        }
    }

    public class UpdateHealthProfileDtoValidator : AbstractValidator<UpdateHealthProfileDto>
    {
        public UpdateHealthProfileDtoValidator()
        {
            RuleFor(x => x.Height).InclusiveBetween(100, 250).When(x => x.Height.HasValue).WithMessage("身高必须在100到250厘米之间。");
            RuleFor(x => x.CurrentWeight).InclusiveBetween(30, 200).When(x => x.CurrentWeight.HasValue).WithMessage("当前体重必须在30到200千克之间。");
            RuleFor(x => x.BloodType).Must(BeValidBloodType).When(x => !string.IsNullOrEmpty(x.BloodType)).WithMessage("请输入有效的血型 (A, B, AB, O, A+, A-, B+, B-, AB+, AB-, O+, O-)。");
            RuleFor(x => x.MedicalHistory).MaximumLength(1000);
            RuleFor(x => x.FamilyHistory).MaximumLength(1000);
            RuleFor(x => x.AllergiesHistory).MaximumLength(1000);
            RuleFor(x => x.ObstetricHistory).MaximumLength(1000);
        }

        private bool BeValidBloodType(string? bloodType)
        {
            if (string.IsNullOrEmpty(bloodType)) return true; // Allow null or empty for updates if not provided
            var validBloodTypes = new[] { "A", "B", "AB", "O", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" };
            return validBloodTypes.Contains(bloodType.ToUpper());
        }
    }
} 