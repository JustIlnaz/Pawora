using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Auth;

namespace Pawora.Application.Interfaces;

public interface IAuthService
{
    Task<ApiResponse<TokenResponseDto>> RegisterAsync(RegisterDto dto);
    Task<ApiResponse<TokenResponseDto>> LoginAsync(LoginDto dto);
    Task<ApiResponse<TokenResponseDto>> RefreshTokenAsync(RefreshTokenDto dto);
    Task<ApiResponse<bool>> LogoutAsync(string refreshToken);
}
