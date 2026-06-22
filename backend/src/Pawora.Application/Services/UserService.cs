using Pawora.Core.Entities;
using Pawora.Core.Interfaces;
using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Users;
using Pawora.Application.DTOs.Auth;
using Pawora.Application.Interfaces;
using AutoMapper;

namespace Pawora.Application.Services;

public class UserService : IUserService
{
    private readonly IRepository<User> _userRepo;
    private readonly IMapper _mapper;

    public UserService(IRepository<User> userRepo, IMapper mapper)
    {
        _userRepo = userRepo;
        _mapper = mapper;
    }

    public async Task<ApiResponse<UserProfileDto>> GetProfileAsync(Guid userId)
    {
        var user = await _userRepo.GetByIdAsync(userId);
        if (user == null) return ApiResponse<UserProfileDto>.Fail("NOT_FOUND", "User not found");
        return ApiResponse<UserProfileDto>.Ok(_mapper.Map<UserProfileDto>(user));
    }

    public async Task<ApiResponse<UserProfileDto>> UpdateProfileAsync(Guid userId, UpdateProfileDto dto)
    {
        var user = await _userRepo.GetByIdAsync(userId);
        if (user == null) return ApiResponse<UserProfileDto>.Fail("NOT_FOUND", "User not found");
        
        user.FullName = dto.FullName;
        user.Phone = dto.Phone;
        user.AvatarUrl = dto.AvatarUrl;
        
        await _userRepo.UpdateAsync(user);
        await _userRepo.SaveChangesAsync();
        
        return ApiResponse<UserProfileDto>.Ok(_mapper.Map<UserProfileDto>(user));
    }
}
