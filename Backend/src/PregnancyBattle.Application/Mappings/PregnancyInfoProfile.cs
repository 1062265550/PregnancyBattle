using AutoMapper;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Domain.Entities;
using PregnancyBattle.Domain.Enums;

namespace PregnancyBattle.Application.Mappings
{
    public class PregnancyInfoProfile : Profile
    {
        public PregnancyInfoProfile()
        {
            CreateMap<PregnancyInfo, PregnancyInfoDto>()
                .ForMember(dest => dest.CalculationMethod, opt => opt.MapFrom(src => src.CalculationMethod.ToString()))
                // CurrentWeek, CurrentDay, PregnancyStage, DaysUntilDueDate 会在Service中手动计算并赋值
                // 因为它们是动态计算的，不直接从实体映射固定值
                ;

            CreateMap<CreatePregnancyInfoDto, PregnancyInfo>()
                // UserId 会在Service中从Token获取并传入构造函数
                .ConstructUsing(dto => new PregnancyInfo(
                    Guid.Empty, // Placeholder for UserId, will be set by service
                    dto.LmpDate,
                    dto.CalculationMethod,
                    dto.UltrasoundDate,
                    dto.UltrasoundWeeks,
                    dto.UltrasoundDays,
                    dto.IsMultiplePregnancy,
                    dto.FetusCount,
                    dto.IvfTransferDate,
                    dto.IvfEmbryoAge
                ));
                // UpdatePregnancyInfoDto 到 PregnancyInfo 的映射不需要了，因为我们使用实体自带的UpdateDetails方法
        }
    }
} 