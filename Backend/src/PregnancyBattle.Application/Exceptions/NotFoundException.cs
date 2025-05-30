using System;

namespace PregnancyBattle.Application.Exceptions
{
    /// <summary>
    /// 资源不存在异常
    /// </summary>
    public class NotFoundException : Exception
    {
        public NotFoundException(string message) : base(message)
        {
        }

        public NotFoundException(string message, Exception innerException) : base(message, innerException)
        {
        }
    }
}
