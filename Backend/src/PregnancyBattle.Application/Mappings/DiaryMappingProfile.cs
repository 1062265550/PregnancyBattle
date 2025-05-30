using AutoMapper;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Domain.Entities;
using System.Linq;

namespace PregnancyBattle.Application.Mappings
{
    /// <summary>
    /// 日记映射配置
    /// </summary>
    public class DiaryMappingProfile : Profile
    {
        public DiaryMappingProfile()
        {
            // Diary 映射
            CreateMap<Diary, DiaryDto>()
                .ForMember(dest => dest.Tags, opt => opt.MapFrom(src =>
                    src.Tags != null && src.Tags.Any()
                        ? src.Tags.Select(t => t.Name).ToList()
                        : new List<string>()))
                .ForMember(dest => dest.MediaFiles, opt => opt.MapFrom(src => src.MediaFiles ?? new List<DiaryMedia>()));

            CreateMap<CreateDiaryDto, Diary>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.UserId, opt => opt.Ignore())
                .ForMember(dest => dest.PregnancyWeek, opt => opt.Ignore())
                .ForMember(dest => dest.PregnancyDay, opt => opt.Ignore())
                .ForMember(dest => dest.CreatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.UpdatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.Tags, opt => opt.Ignore())
                .ForMember(dest => dest.MediaFiles, opt => opt.Ignore());

            // DiaryTag 映射
            CreateMap<DiaryTag, DiaryTagDto>();

            CreateMap<string, DiaryTag>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.DiaryId, opt => opt.Ignore())
                .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src))
                .ForMember(dest => dest.CreatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.UpdatedAt, opt => opt.Ignore());

            // DiaryMedia 映射
            CreateMap<DiaryMedia, DiaryMediaDto>();

            CreateMap<CreateDiaryMediaDto, DiaryMedia>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.DiaryId, opt => opt.Ignore())
                .ForMember(dest => dest.CreatedAt, opt => opt.Ignore());


        }
    }
}
