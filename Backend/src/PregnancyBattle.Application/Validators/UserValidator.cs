using FluentValidation;
using PregnancyBattle.Application.DTOs;

namespace PregnancyBattle.Application.Validators
{
    /// <summary>
    /// 创建用户请求验证器
    /// </summary>
    public class CreateUserValidator : AbstractValidator<CreateUserDto>
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public CreateUserValidator()
        {
            RuleFor(x => x.Username)
                .NotEmpty().WithMessage("用户名不能为空")
                .MinimumLength(3).WithMessage("用户名长度不能少于3个字符")
                .MaximumLength(50).WithMessage("用户名长度不能超过50个字符");

            RuleFor(x => x.Email)
                .NotEmpty().WithMessage("电子邮件不能为空")
                .EmailAddress().WithMessage("电子邮件格式不正确");

            RuleFor(x => x.PhoneNumber)
                .NotEmpty().WithMessage("手机号码不能为空")
                .Matches(@"^1[3-9]\d{9}$").WithMessage("手机号码格式不正确");

            RuleFor(x => x.Password)
                .NotEmpty().WithMessage("密码不能为空")
                .MinimumLength(6).WithMessage("密码长度不能少于6个字符")
                .MaximumLength(100).WithMessage("密码长度不能超过100个字符");

            RuleFor(x => x.Nickname)
                .MaximumLength(50).WithMessage("昵称长度不能超过50个字符");
        }
    }

    /// <summary>
    /// 更新用户请求验证器
    /// </summary>
    public class UpdateUserValidator : AbstractValidator<UpdateUserDto>
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public UpdateUserValidator()
        {
            // 昵称：如果提供了，则验证长度
            When(x => x.Nickname != null, () => {
                RuleFor(x => x.Nickname)
                    .MaximumLength(50).WithMessage("昵称长度不能超过50个字符");
            });

            // 头像URL：如果提供了，则验证长度 (允许空字符串以清空头像)
            When(x => x.AvatarUrl != null, () => {
                RuleFor(x => x.AvatarUrl)
                    .MaximumLength(1024).WithMessage("头像URL长度不能超过1024个字符");
            });
        }
    }

    /// <summary>
    /// 用户登录请求验证器
    /// </summary>
    public class UserLoginValidator : AbstractValidator<UserLoginDto>
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public UserLoginValidator()
        {
            RuleFor(x => x.Username)
                .NotEmpty().WithMessage("用户名/电子邮件/手机号码不能为空");

            RuleFor(x => x.Password)
                .NotEmpty().WithMessage("密码不能为空");
        }
    }

    /// <summary>
    /// 发送验证码请求验证器
    /// </summary>
    public class SendVerificationCodeValidator : AbstractValidator<SendVerificationCodeDto>
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public SendVerificationCodeValidator()
        {
            RuleFor(x => x)
                .Must(x => !string.IsNullOrEmpty(x.Email) || !string.IsNullOrEmpty(x.PhoneNumber))
                .WithMessage("电子邮件或手机号码不能同时为空");

            When(x => !string.IsNullOrEmpty(x.Email), () =>
            {
                RuleFor(x => x.Email)
                    .EmailAddress().WithMessage("电子邮件格式不正确");
            });

            When(x => !string.IsNullOrEmpty(x.PhoneNumber), () =>
            {
                RuleFor(x => x.PhoneNumber)
                    .Matches(@"^1[3-9]\d{9}$").WithMessage("手机号码格式不正确");
            });
        }
    }

    /// <summary>
    /// 验证验证码请求验证器
    /// </summary>
    public class VerifyCodeValidator : AbstractValidator<VerifyCodeDto>
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public VerifyCodeValidator()
        {
            RuleFor(x => x)
                .Must(x => !string.IsNullOrEmpty(x.Email) || !string.IsNullOrEmpty(x.PhoneNumber))
                .WithMessage("电子邮件或手机号码不能同时为空");

            When(x => !string.IsNullOrEmpty(x.Email), () =>
            {
                RuleFor(x => x.Email)
                    .EmailAddress().WithMessage("电子邮件格式不正确");
            });

            When(x => !string.IsNullOrEmpty(x.PhoneNumber), () =>
            {
                RuleFor(x => x.PhoneNumber)
                    .Matches(@"^1[3-9]\d{9}$").WithMessage("手机号码格式不正确");
            });

            RuleFor(x => x.Code)
                .NotEmpty().WithMessage("验证码不能为空")
                .Matches(@"^\d{6}$").WithMessage("验证码必须是6位数字");
        }
    }

    /// <summary>
    /// 重置密码请求验证器
    /// </summary>
    public class ResetPasswordValidator : AbstractValidator<ResetPasswordDto>
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public ResetPasswordValidator()
        {
            RuleFor(x => x.ResetToken)
                .NotEmpty().WithMessage("重置密码令牌不能为空");

            RuleFor(x => x.NewPassword)
                .NotEmpty().WithMessage("新密码不能为空")
                .MinimumLength(6).WithMessage("新密码长度不能少于6个字符")
                .MaximumLength(100).WithMessage("新密码长度不能超过100个字符");
        }
    }
}