using System;
using System.Threading.Tasks;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Application.Models;

namespace PregnancyBattle.Application.Services
{
    /// <summary>
    /// 孕期信息服务接口
    /// </summary>
    public interface IPregnancyInfoService
    {
        /// <summary>
        /// 创建孕期信息
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="createDto">创建孕期信息请求</param>
        /// <returns>孕期信息</returns>
        Task<ServiceResult<PregnancyInfoDto>> CreatePregnancyInfoAsync(Guid userId, CreatePregnancyInfoDto createDto);
        
        /// <summary>
        /// 获取孕期信息
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>孕期信息</returns>
        Task<ServiceResult<PregnancyInfoDto>> GetPregnancyInfoAsync(Guid userId);
        
        /// <summary>
        /// 更新孕期信息
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="updateDto">更新孕期信息请求</param>
        /// <returns>孕期信息</returns>
        Task<ServiceResult<PregnancyInfoDto>> UpdatePregnancyInfoAsync(Guid userId, UpdatePregnancyInfoDto updateDto);
        
        /// <summary>
        /// 计算当前孕周和孕天
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>孕期信息</returns>
        Task<ServiceResult<PregnancyInfoDto>> GetCurrentWeekAndDayAsync(Guid userId);
    }
}