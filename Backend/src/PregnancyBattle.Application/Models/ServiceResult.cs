namespace PregnancyBattle.Application.Models
{
    public class ServiceResult<T>
    {
        public bool Success { get; set; }
        public T? Data { get; set; }
        public string? Message { get; set; }
        public string? ErrorCode { get; set; }

        public static ServiceResult<T> SuccessResult(T data, string? message = null) =>
            new() { Success = true, Data = data, Message = message };

        public static ServiceResult<T> FailureResult(string message, string? errorCode = null) =>
            new() { Success = false, Message = message, ErrorCode = errorCode };
    }

    public class ServiceResult // For non-generic results
    {
        public bool Success { get; set; }
        public string? Message { get; set; }
        public string? ErrorCode { get; set; }

        public static ServiceResult SuccessResult(string? message = null) =>
            new() { Success = true, Message = message };

        public static ServiceResult FailureResult(string message, string? errorCode = null) =>
            new() { Success = false, Message = message, ErrorCode = errorCode };
    }
} 