using System;

namespace PregnancyBattle.Application.Exceptions
{
    /// <summary>
    /// 禁止访问异常
    /// </summary>
    public class ForbiddenException : Exception
    {
        public ForbiddenException(string message) : base(message)
        {
        }

        public ForbiddenException(string message, Exception innerException) : base(message, innerException)
        {
        }
    }
}
