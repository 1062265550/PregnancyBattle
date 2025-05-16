using System.Threading.Tasks;

namespace PregnancyBattle.Domain.Services
{
    /// <summary>
    /// 邮件服务接口
    /// </summary>
    public interface IEmailService
    {
        /// <summary>
        /// 发送验证码邮件
        /// </summary>
        /// <param name="to">收件人邮箱</param>
        /// <param name="code">验证码</param>
        /// <returns>是否发送成功</returns>
        Task<bool> SendVerificationCodeAsync(string to, string code);
    }
}
