using PregnancyBattle.Domain.Enums;

namespace PregnancyBattle.Application.DTOs
{
    public class CreatePregnancyInfoDto
    {
        public DateTime LmpDate { get; set; }
        public PregnancyCalculationMethod CalculationMethod { get; set; }
        public DateTime? UltrasoundDate { get; set; }
        public int? UltrasoundWeeks { get; set; }
        public int? UltrasoundDays { get; set; }
        public bool IsMultiplePregnancy { get; set; } = false;
        public int? FetusCount { get; set; }
        public DateTime? IvfTransferDate { get; set; }
        public int? IvfEmbryoAge { get; set; }
    }

    public class UpdatePregnancyInfoDto
    {
        public DateTime? LmpDate { get; set; }
        public DateTime? DueDate { get; set; }
        public PregnancyCalculationMethod? CalculationMethod { get; set; }
        public DateTime? UltrasoundDate { get; set; }
        public int? UltrasoundWeeks { get; set; }
        public int? UltrasoundDays { get; set; }
        public bool? IsMultiplePregnancy { get; set; }
        public int? FetusCount { get; set; }
        public DateTime? IvfTransferDate { get; set; }
        public int? IvfEmbryoAge { get; set; }
    }

    public class PregnancyInfoDto
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public DateTime LmpDate { get; set; }
        public DateTime DueDate { get; set; }
        public string CalculationMethod { get; set; }
        public DateTime? UltrasoundDate { get; set; }
        public int? UltrasoundWeeks { get; set; }
        public int? UltrasoundDays { get; set; }
        public DateTime? IvfTransferDate { get; set; }
        public int? IvfEmbryoAge { get; set; }
        public bool IsMultiplePregnancy { get; set; }
        public int? FetusCount { get; set; }
        public int CurrentWeek { get; set; }
        public int CurrentDay { get; set; }
        public string PregnancyStage { get; set; } = string.Empty; // 孕期阶段 (早期/中期/晚期)
        public int DaysUntilDueDate { get; set; }
    }
} 