using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using PregnancyBattle.Domain.Services;
using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;
using MimeKit.Text;

namespace PregnancyBattle.Infrastructure.Services.Email
{
    /// <summary>
    /// 邮件服务实现
    /// </summary>
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<EmailService> _logger;

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="configuration">配置</param>
        /// <param name="logger">日志</param>
        public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        /// <summary>
        /// 发送验证码邮件
        /// </summary>
        /// <param name="to">收件人邮箱</param>
        /// <param name="code">验证码</param>
        /// <returns>是否发送成功</returns>
        public async Task<bool> SendVerificationCodeAsync(string to, string code)
        {
            try
            {
                // 从配置中获取邮件设置
                var smtpServer = _configuration["Email:SmtpServer"] ?? "smtp.126.com";
                var smtpPort = int.Parse(_configuration["Email:SmtpPort"] ?? "465");
                var enableSsl = bool.Parse(_configuration["Email:EnableSsl"] ?? "true");
                var fromEmail = _configuration["Email:FromEmail"] ?? "your-email@126.com";
                var fromName = _configuration["Email:FromName"] ?? "孕期大作战";
                var username = _configuration["Email:Username"] ?? fromEmail;
                var password = _configuration["Email:Password"] ?? "FRatQzdkvybvdfZm"; // 授权密码

                // 创建邮件消息
                var email = new MimeMessage();
                email.From.Add(new MailboxAddress(fromName, fromEmail));
                email.To.Add(new MailboxAddress("", to));
                email.Subject = "【孕期大作战】验证码";

                // 创建HTML邮件内容
                var htmlBody = $@"
                    <html>
                    <head>
                        <style>
                            body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                            .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                            .header {{ background-color: #f8f9fa; padding: 10px; text-align: center; }}
                            .content {{ padding: 20px; }}
                            .code {{ font-size: 24px; font-weight: bold; color: #007bff; letter-spacing: 5px; }}
                            .footer {{ font-size: 12px; color: #6c757d; margin-top: 20px; }}
                        </style>
                    </head>
                    <body>
                        <div class='container'>
                            <div class='header'>
                                <h2>孕期大作战</h2>
                            </div>
                            <div class='content'>
                                <p>您好，</p>
                                <p>您正在进行密码重置操作，验证码为：</p>
                                <p class='code'>{code}</p>
                                <p>验证码有效期为5分钟，请勿将验证码泄露给他人。</p>
                                <p>如果您没有进行此操作，请忽略此邮件。</p>
                            </div>
                            <div class='footer'>
                                <p>此邮件由系统自动发送，请勿回复。</p>
                                <p>© {DateTime.Now.Year} 孕期大作战 版权所有</p>
                            </div>
                        </div>
                    </body>
                    </html>
                ";

                email.Body = new TextPart(TextFormat.Html) { Text = htmlBody };

                // 记录SMTP配置信息
                _logger.LogInformation($"SMTP配置: 服务器={smtpServer}, 端口={smtpPort}, SSL={enableSsl}, 用户名={username}");

                // 创建SMTP客户端并发送邮件
                using var smtp = new SmtpClient();

                // 设置客户端选项
                smtp.Timeout = 60000; // 60秒超时

                _logger.LogInformation($"开始连接SMTP服务器: {smtpServer}:{smtpPort}");

                // 根据端口选择合适的安全选项
                SecureSocketOptions secureSocketOptions;
                if (smtpPort == 465)
                {
                    secureSocketOptions = SecureSocketOptions.SslOnConnect;
                }
                else if (smtpPort == 587)
                {
                    secureSocketOptions = SecureSocketOptions.StartTls;
                }
                else if (smtpPort == 25)
                {
                    secureSocketOptions = enableSsl ? SecureSocketOptions.StartTls : SecureSocketOptions.None;
                }
                else
                {
                    secureSocketOptions = enableSsl ? SecureSocketOptions.Auto : SecureSocketOptions.None;
                }

                _logger.LogInformation($"使用安全选项: {secureSocketOptions}");

                // 连接到SMTP服务器
                await smtp.ConnectAsync(smtpServer, smtpPort, secureSocketOptions);

                // 如果需要身份验证
                if (!string.IsNullOrEmpty(username) && !string.IsNullOrEmpty(password))
                {
                    _logger.LogInformation($"使用用户名 {username} 进行身份验证");
                    await smtp.AuthenticateAsync(username, password);
                }

                // 发送邮件
                _logger.LogInformation($"开始发送邮件到: {to}");
                await smtp.SendAsync(email);
                _logger.LogInformation($"邮件发送完成");

                // 断开连接
                await smtp.DisconnectAsync(true);

                _logger.LogInformation($"验证码邮件发送成功: {to}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"验证码邮件发送失败: {to}, 错误: {ex.Message}");
                return false;
            }
        }
    }
}
