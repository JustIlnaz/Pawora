using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Users;
using Pawora.Application.DTOs.Auth;

namespace Pawora.Application.Interfaces;

public interface IUserService
{
    Task<ApiResponse<UserProfileDto>> GetProfileAsync(Guid userId);
    Task<ApiResponse<UserProfileDto>> UpdateProfileAsync(Guid userId, UpdateProfileDto dto);
}
