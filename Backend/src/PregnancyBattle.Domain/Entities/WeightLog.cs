using System;

namespace PregnancyBattle.Domain.Entities
{
    public class WeightLog
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public DateTime Date { get; set; } // 记录日期
        public decimal Weight { get; set; } // 体重 (kg)
        public int? PregnancyWeek { get; set; } // 记录时的孕周
        public int? PregnancyDay { get; set; } // 记录时的孕天
        public string? Note { get; set; } // 备注
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}