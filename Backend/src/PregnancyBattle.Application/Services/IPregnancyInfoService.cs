using System;
using System.Threading.Tasks;
using PregnancyBattle.Application.DTOs;

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
        /// <param name="createPregnancyInfoDto">创建孕期信息请求</param>
        /// <returns>孕期信息</returns>
        Task<PregnancyInfoDto> CreatePregnancyInfoAsync(Guid userId, CreatePregnancyInfoDto createPregnancyInfoDto);
        
        /// <summary>
        /// 获取孕期信息
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>孕期信息</returns>
        Task<PregnancyInfoDto> GetPregnancyInfoAsync(Guid userId);
        
        /// <summary>
        /// 更新孕期信息
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="updatePregnancyInfoDto">更新孕期信息请求</param>
        /// <returns>孕期信息</returns>
        Task<PregnancyInfoDto> UpdatePregnancyInfoAsync(Guid userId, UpdatePregnancyInfoDto updatePregnancyInfoDto);
        
        /// <summary>
        /// 计算当前孕周和孕天
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>孕期信息</returns>
        Task<PregnancyInfoDto> CalculateCurrentPregnancyWeekAsync(Guid userId);
    }
}