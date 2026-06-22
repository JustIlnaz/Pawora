using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Pawora.Application.DTOs;

namespace Pawora.Application.Interfaces;

public interface IUserAddressService
{
    Task<ApiResponse<List<UserAddressDto>>> GetAddressesAsync(Guid userId);
    Task<ApiResponse<UserAddressDto>> AddAddressAsync(Guid userId, CreateUserAddressDto dto);
    Task<ApiResponse<UserAddressDto>> UpdateAddressAsync(Guid userId, Guid addressId, UpdateUserAddressDto dto);
    Task<ApiResponse<bool>> DeleteAddressAsync(Guid userId, Guid addressId);
    Task<ApiResponse<UserAddressDto>> SetDefaultAddressAsync(Guid userId, Guid addressId);
}
