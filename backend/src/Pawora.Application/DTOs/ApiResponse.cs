namespace Pawora.Application.DTOs;

public class ErrorInfo
{
    public string Code { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
}

public class ApiResponse<T>
{
    public bool Success { get; set; }
    public T? Data { get; set; }
    public ErrorInfo? Error { get; set; }

    public static ApiResponse<T> Ok(T data)
    {
        return new ApiResponse<T> { Success = true, Data = data };
    }

    public static ApiResponse<T> Fail(string code, string message)
    {
        return new ApiResponse<T>
        {
            Success = false,
            Error = new ErrorInfo { Code = code, Message = message }
        };
    }
}
