using System;

namespace PregnancyBattle.Domain.Entities
{
    public class HealthProfile
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public decimal Height { get; set; } // 身高 (cm)
        public decimal PrePregnancyWeight { get; set; } // 孕前体重 (kg)
        public decimal CurrentWeight { get; set; } // 当前体重 (kg) - 最新体重
        public string BloodType { get; set; } = string.Empty;
        public int Age { get; set; } // 年龄
        public string? MedicalHistory { get; set; } // 个人病史
        public string? FamilyHistory { get; set; } // 家族病史
        public string? AllergiesHistory { get; set; } // 过敏史
        public string? ObstetricHistory { get; set; } // 既往孕产史
        public bool IsSmoking { get; set; }
        public bool IsDrinking { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }

        // BMI 是计算属性，不在数据库中直接存储，但可以在需要时计算
        public decimal CalculateBmi()
        {
            if (Height <= 0) return 0;
            var heightInMeters = Height / 100;
            return CurrentWeight / (heightInMeters * heightInMeters);
        }

        public decimal CalculatePrePregnancyBmi()
        {
            if (Height <= 0) return 0;
            var heightInMeters = Height / 100;
            return PrePregnancyWeight / (heightInMeters * heightInMeters);
        }
    }
} 