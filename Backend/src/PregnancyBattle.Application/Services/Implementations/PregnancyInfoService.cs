using AutoMapper;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Application.Models;
using PregnancyBattle.Domain.Entities;
using PregnancyBattle.Domain.Enums;
using PregnancyBattle.Domain.Repositories;
using System;
using System.Threading.Tasks;

namespace PregnancyBattle.Application.Services.Implementations
{
    public class PregnancyInfoService : IPregnancyInfoService
    {
        private readonly IPregnancyInfoRepository _pregnancyInfoRepository;
        private readonly IMapper _mapper;
        // private readonly IUserRepository _userRepository; // 未来可能需要，例如验证用户是否存在

        public PregnancyInfoService(IPregnancyInfoRepository pregnancyInfoRepository, IMapper mapper /*, IUserRepository userRepository*/)
        {
            _pregnancyInfoRepository = pregnancyInfoRepository;
            _mapper = mapper;
            // _userRepository = userRepository;
        }

        public async Task<ServiceResult<PregnancyInfoDto>> CreatePregnancyInfoAsync(Guid userId, CreatePregnancyInfoDto createDto)
        {
            // 检查用户是否已存在孕期信息
            if (await _pregnancyInfoRepository.ExistsByUserIdAsync(userId))
            {
                return ServiceResult<PregnancyInfoDto>.FailureResult("User already has pregnancy information.", "409");
            }

            // 验证DTO (这里应该用FluentValidation，暂时简化)
            if (createDto.CalculationMethod == PregnancyCalculationMethod.Ultrasound && 
                (!createDto.UltrasoundDate.HasValue || !createDto.UltrasoundWeeks.HasValue || !createDto.UltrasoundDays.HasValue))
            {
                return ServiceResult<PregnancyInfoDto>.FailureResult("Ultrasound details are required when calculation method is Ultrasound.", "400");
            }
            if (createDto.CalculationMethod == PregnancyCalculationMethod.IVF &&
                (!createDto.IvfTransferDate.HasValue || !createDto.IvfEmbryoAge.HasValue))
            {
                return ServiceResult<PregnancyInfoDto>.FailureResult("IVF transfer date and embryo age are required when calculation method is IVF.", "400");
            }
            if (createDto.IsMultiplePregnancy && (!createDto.FetusCount.HasValue || createDto.FetusCount < 2))
            {
                return ServiceResult<PregnancyInfoDto>.FailureResult("Fetus count must be 2 or more for multiple pregnancies.", "400");
            }
            if (createDto.LmpDate.Date > DateTime.Today)
            {
                 return ServiceResult<PregnancyInfoDto>.FailureResult("LMP date cannot be in the future.", "400");
            }

            var pregnancyInfo = new PregnancyInfo(
                userId,
                createDto.LmpDate,
                createDto.CalculationMethod,
                createDto.UltrasoundDate,
                createDto.UltrasoundWeeks,
                createDto.UltrasoundDays,
                createDto.IsMultiplePregnancy,
                createDto.FetusCount,
                createDto.IvfTransferDate,
                createDto.IvfEmbryoAge
            );

            await _pregnancyInfoRepository.AddAsync(pregnancyInfo);
            
            var resultDto = _mapper.Map<PregnancyInfoDto>(pregnancyInfo);
            // 手动计算DTO中的动态字段
            var (currentWeek, currentDay) = pregnancyInfo.GetCurrentGestation();
            resultDto.CurrentWeek = currentWeek;
            resultDto.CurrentDay = currentDay;
            resultDto.PregnancyStage = pregnancyInfo.GetPregnancyStage();
            resultDto.DaysUntilDueDate = pregnancyInfo.GetDaysUntilDueDate();

            return ServiceResult<PregnancyInfoDto>.SuccessResult(resultDto, "Pregnancy information created successfully.");
        }

        public async Task<ServiceResult<PregnancyInfoDto>> GetPregnancyInfoAsync(Guid userId)
        {
            var pregnancyInfo = await _pregnancyInfoRepository.GetByUserIdAsync(userId);
            if (pregnancyInfo == null)
            {
                return ServiceResult<PregnancyInfoDto>.FailureResult("Pregnancy information not found.", "404");
            }

            var dto = _mapper.Map<PregnancyInfoDto>(pregnancyInfo);
            var (currentWeek, currentDay) = pregnancyInfo.GetCurrentGestation();
            dto.CurrentWeek = currentWeek;
            dto.CurrentDay = currentDay;
            dto.PregnancyStage = pregnancyInfo.GetPregnancyStage();
            dto.DaysUntilDueDate = pregnancyInfo.GetDaysUntilDueDate();

            return ServiceResult<PregnancyInfoDto>.SuccessResult(dto);
        }

        public async Task<ServiceResult<PregnancyInfoDto>> UpdatePregnancyInfoAsync(Guid userId, UpdatePregnancyInfoDto updateDto)
        {
            var pregnancyInfo = await _pregnancyInfoRepository.GetByUserIdAsync(userId);
            if (pregnancyInfo == null)
            {
                return ServiceResult<PregnancyInfoDto>.FailureResult("Pregnancy information not found.", "404");
            }
            
            // 验证DTO
            if (updateDto.CalculationMethod.HasValue && updateDto.CalculationMethod.Value == PregnancyCalculationMethod.Ultrasound && 
                (!updateDto.UltrasoundDate.HasValue && !updateDto.UltrasoundWeeks.HasValue && !updateDto.UltrasoundDays.HasValue))
            {
                 // 如果用户想把计算方式改成B超，但没提供B超的完整信息，则视为错误
                if (!pregnancyInfo.UltrasoundDate.HasValue || !pregnancyInfo.UltrasoundWeeks.HasValue || !pregnancyInfo.UltrasoundDays.HasValue)
                    return ServiceResult<PregnancyInfoDto>.FailureResult("Ultrasound details are required when calculation method is Ultrasound.", "400");
            }
            if (updateDto.CalculationMethod.HasValue && updateDto.CalculationMethod.Value == PregnancyCalculationMethod.IVF &&
                (!updateDto.IvfTransferDate.HasValue && !updateDto.IvfEmbryoAge.HasValue))
            {
                // Similar check for IVF: if changing to IVF, and new IVF details are not provided, check if old ones exist or fail.
                if (!pregnancyInfo.IvfTransferDate.HasValue || !pregnancyInfo.IvfEmbryoAge.HasValue)
                     return ServiceResult<PregnancyInfoDto>.FailureResult("IVF transfer date and embryo age are required when calculation method is IVF.", "400");
            }
            if (updateDto.IsMultiplePregnancy.HasValue && updateDto.IsMultiplePregnancy.Value && 
                (!updateDto.FetusCount.HasValue || updateDto.FetusCount < 2) && 
                (!pregnancyInfo.FetusCount.HasValue || pregnancyInfo.FetusCount <2) )
            {
                return ServiceResult<PregnancyInfoDto>.FailureResult("Fetus count must be 2 or more for multiple pregnancies.", "400");
            }
             if (updateDto.DueDate.HasValue && updateDto.DueDate.Value.Date <= DateTime.Today)
            {
                 return ServiceResult<PregnancyInfoDto>.FailureResult("Due date must be in the future.", "400");
            }


            // 使用领域实体的方法来更新
            pregnancyInfo.UpdateDetails(
                updateDto.LmpDate,
                updateDto.DueDate,
                updateDto.CalculationMethod,
                updateDto.UltrasoundDate,
                updateDto.UltrasoundWeeks,
                updateDto.UltrasoundDays,
                updateDto.IsMultiplePregnancy,
                updateDto.FetusCount,
                updateDto.IvfTransferDate,
                updateDto.IvfEmbryoAge
            );

            await _pregnancyInfoRepository.UpdateAsync(pregnancyInfo);

            var resultDto = _mapper.Map<PregnancyInfoDto>(pregnancyInfo);
            var (currentWeek, currentDay) = pregnancyInfo.GetCurrentGestation();
            resultDto.CurrentWeek = currentWeek;
            resultDto.CurrentDay = currentDay;
            resultDto.PregnancyStage = pregnancyInfo.GetPregnancyStage();
            resultDto.DaysUntilDueDate = pregnancyInfo.GetDaysUntilDueDate();

            return ServiceResult<PregnancyInfoDto>.SuccessResult(resultDto, "Pregnancy information updated successfully.");
        }

        public async Task<ServiceResult<PregnancyInfoDto>> GetCurrentWeekAndDayAsync(Guid userId)
        {
            // 此方法逻辑与GetPregnancyInfoAsync完全一致，因为所需信息都在PregnancyInfo实体中
            return await GetPregnancyInfoAsync(userId);
        }
    }
} 