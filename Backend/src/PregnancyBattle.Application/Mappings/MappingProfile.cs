using AutoMapper;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Domain.Entities;

namespace PregnancyBattle.Application.Mappings
{
    /// <summary>
    /// AutoMapper映射配置
    /// </summary>
    public class MappingProfile : Profile
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public MappingProfile()
        {
            // 用户映射
            CreateMap<User, UserDto>();
            CreateMap<CreateUserDto, User>();
            CreateMap<UpdateUserDto, User>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
            
            // 孕期信息映射
            CreateMap<PregnancyInfo, PregnancyInfoDto>();
            CreateMap<CreatePregnancyInfoDto, PregnancyInfo>();
            CreateMap<UpdatePregnancyInfoDto, PregnancyInfo>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
            
            // 健康档案映射
            CreateMap<UserHealthProfile, HealthProfileDto>();
            CreateMap<CreateHealthProfileDto, UserHealthProfile>();
            CreateMap<UpdateHealthProfileDto, UserHealthProfile>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
            
            // 日记映射
            CreateMap<Diary, DiaryDto>();
            CreateMap<CreateDiaryDto, Diary>();
            CreateMap<UpdateDiaryDto, Diary>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
            
            // 日记标签映射
            CreateMap<DiaryTag, DiaryTagDto>();
            
            // 日记媒体文件映射
            CreateMap<DiaryMedia, DiaryMediaDto>();
            CreateMap<AddDiaryMediaDto, DiaryMedia>();
        }
    }
}