using PregnancyBattle.Domain.Enums;
using System;

namespace PregnancyBattle.Domain.Entities
{
    /// <summary>
    /// 孕期信息实体
    /// </summary>
    public class PregnancyInfo : BaseEntity
    {
        /// <summary>
        /// 用户ID
        /// </summary>
        public Guid UserId { get; private set; }
        
        /// <summary>
        /// 末次月经日期 (Last Menstrual Period)
        /// </summary>
        public DateTime LmpDate { get; private set; }
        
        /// <summary>
        /// 预产期
        /// </summary>
        public DateTime DueDate { get; private set; }
        
        /// <summary>
        /// 预产期计算方式
        /// </summary>
        public PregnancyCalculationMethod CalculationMethod { get; private set; }
        
        /// <summary>
        /// B超日期（如果有）
        /// </summary>
        public DateTime? UltrasoundDate { get; private set; }
        
        /// <summary>
        /// B超孕周（如果有）
        /// </summary>
        public int? UltrasoundWeeks { get; private set; }
        
        /// <summary>
        /// B超孕天（如果有）
        /// </summary>
        public int? UltrasoundDays { get; private set; }
        
        /// <summary>
        /// 是否为多胎妊娠
        /// </summary>
        public bool IsMultiplePregnancy { get; private set; }
        
        /// <summary>
        /// 胎儿数量（如果是多胎）
        /// </summary>
        public int? FetusCount { get; private set; }

        /// <summary>
        /// IVF胚胎移植日期（如果有）
        /// </summary>
        public DateTime? IvfTransferDate { get; private set; }

        /// <summary>
        /// IVF移植时胚胎天数（例如3为D3, 5为D5）（如果有）
        /// </summary>
        public int? IvfEmbryoAge { get; private set; }

        // 构造函数用于创建新的孕期信息
        private PregnancyInfo() { } // EF Core needs a private parameterless constructor

        public PregnancyInfo(Guid userId, DateTime lmpDate, PregnancyCalculationMethod calculationMethod,
                             DateTime? ultrasoundDate, int? ultrasoundWeeks, int? ultrasoundDays,
                             bool isMultiplePregnancy, int? fetusCount,
                             DateTime? ivfTransferDate, int? ivfEmbryoAge) // Added IVF parameters
        {
            Id = Guid.NewGuid();
            UserId = userId;
            LmpDate = lmpDate.Date; //确保只存储日期部分
            CalculationMethod = calculationMethod;
            IsMultiplePregnancy = isMultiplePregnancy;
            FetusCount = isMultiplePregnancy ? fetusCount : null;

            if (CalculationMethod == PregnancyCalculationMethod.Ultrasound)
            {
                UltrasoundDate = ultrasoundDate?.Date;
                UltrasoundWeeks = ultrasoundWeeks;
                UltrasoundDays = ultrasoundDays;
                IvfTransferDate = null; // Clear IVF fields if method is Ultrasound
                IvfEmbryoAge = null;
            }
            else if (CalculationMethod == PregnancyCalculationMethod.IVF)
            {
                IvfTransferDate = ivfTransferDate?.Date;
                IvfEmbryoAge = ivfEmbryoAge;
                UltrasoundDate = null; // Clear Ultrasound fields if method is IVF
                UltrasoundWeeks = null;
                UltrasoundDays = null;
            }
            else // LMP or other
            {
                UltrasoundDate = null;
                UltrasoundWeeks = null;
                UltrasoundDays = null;
                IvfTransferDate = null;
                IvfEmbryoAge = null;
            }
            
            DueDate = CalculateDueDate();
        }

        // 更新方法
        public void UpdateDetails(DateTime? lmpDate, DateTime? dueDate, PregnancyCalculationMethod? calculationMethod, 
                                DateTime? ultrasoundDate, int? ultrasoundWeeks, int? ultrasoundDays, 
                                bool? isMultiplePregnancy, int? fetusCount,
                                DateTime? ivfTransferDate, int? ivfEmbryoAge) // Added IVF parameters
        {
            if (lmpDate.HasValue)
            {
                LmpDate = lmpDate.Value.Date; 
            }

            if (calculationMethod.HasValue)
            {
                CalculationMethod = calculationMethod.Value;
            }

            if (isMultiplePregnancy.HasValue)
            {
                IsMultiplePregnancy = isMultiplePregnancy.Value;
                FetusCount = IsMultiplePregnancy ? (fetusCount ?? FetusCount) : null;
            }
            else if (fetusCount.HasValue && IsMultiplePregnancy)
            {
                FetusCount = fetusCount.Value;
            }

            if (CalculationMethod == PregnancyCalculationMethod.Ultrasound)
            {
                UltrasoundDate = (ultrasoundDate ?? UltrasoundDate)?.Date;
                UltrasoundWeeks = ultrasoundWeeks ?? UltrasoundWeeks;
                UltrasoundDays = ultrasoundDays ?? UltrasoundDays;
                IvfTransferDate = null; // Clear IVF fields
                IvfEmbryoAge = null;
            }
            else if (CalculationMethod == PregnancyCalculationMethod.IVF)
            {
                IvfTransferDate = (ivfTransferDate ?? IvfTransferDate)?.Date;
                IvfEmbryoAge = ivfEmbryoAge ?? IvfEmbryoAge;
                UltrasoundDate = null; // Clear Ultrasound fields
                UltrasoundWeeks = null;
                UltrasoundDays = null;
            }
            else // LMP or other
            {
                UltrasoundDate = null;
                UltrasoundWeeks = null;
                UltrasoundDays = null;
                IvfTransferDate = null;
                IvfEmbryoAge = null;
            }
            
            if (dueDate.HasValue && CalculationMethod != PregnancyCalculationMethod.LMP)
            {
                DueDate = dueDate.Value.Date;
            }
            else
            {
                DueDate = CalculateDueDate(); 
            }
        }

        private DateTime CalculateDueDate()
        {
            return CalculationMethod switch
            {
                PregnancyCalculationMethod.LMP => LmpDate.AddDays(280),
                PregnancyCalculationMethod.Ultrasound => UltrasoundDate.HasValue && UltrasoundWeeks.HasValue && UltrasoundDays.HasValue
                    ? UltrasoundDate.Value.AddDays(280 - (UltrasoundWeeks.Value * 7 + UltrasoundDays.Value))
                    : LmpDate.AddDays(280), // Fallback if Ultrasound details are incomplete
                PregnancyCalculationMethod.IVF => IvfTransferDate.HasValue && IvfEmbryoAge.HasValue
                    ? IvfTransferDate.Value.AddDays(266 - IvfEmbryoAge.Value) // Standard calculation for IVF based on transfer date and embryo age
                    : LmpDate.AddDays(280), // Fallback if IVF details are incomplete (using LMP as a rough estimate)
                _ => LmpDate.AddDays(280) 
            };
        }

        public (int CurrentWeek, int CurrentDay) GetCurrentGestation()
        {
            int gestationDays;
            if (CalculationMethod == PregnancyCalculationMethod.LMP)
            {
                gestationDays = (int)(DateTime.Today - LmpDate).TotalDays;
            }
            else
            {
                // For Ultrasound or IVF, calculate gestation days based on DueDate
                // Total pregnancy duration is 280 days (40 weeks)
                // Gestation days = Total pregnancy duration - days remaining until due date
                gestationDays = 280 - (int)(DueDate - DateTime.Today).TotalDays;
            }
            
            // Ensure gestationDays is not negative, which can happen if DueDate is in the past for non-LMP methods
            // or LmpDate is in the future for LMP method.
            if (gestationDays < 0) gestationDays = 0; 

            var currentWeek = gestationDays / 7;
            var currentDay = gestationDays % 7;
            return (currentWeek, currentDay);
        }

        public string GetPregnancyStage()
        {
            var (currentWeek, _) = GetCurrentGestation();
            if (currentWeek <= 13) return "早期"; // 孕早期：1-13周
            if (currentWeek <= 27) return "中期"; // 孕中期：14-27周
            return "晚期"; // 孕晚期：28周及以后
        }

        public int GetDaysUntilDueDate()
        {
            return (int)(DueDate - DateTime.Today).TotalDays;
        }
    }
}