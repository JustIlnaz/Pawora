using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Pawora.Core.Entities;
using Pawora.Core.Interfaces;
using Pawora.Application.DTOs;
using Pawora.Application.Interfaces;
using AutoMapper;

namespace Pawora.Application.Services;

public class UserAddressService : IUserAddressService
{
    private readonly IRepository<UserAddress> _addressRepo;
    private readonly IMapper _mapper;

    public UserAddressService(IRepository<UserAddress> addressRepo, IMapper mapper)
    {
        _addressRepo = addressRepo;
        _mapper = mapper;
    }

    public async Task<ApiResponse<List<UserAddressDto>>> GetAddressesAsync(Guid userId)
    {
        var addresses = await _addressRepo.Query()
            .Where(a => a.UserId == userId)
            .OrderByDescending(a => a.IsDefault)
            .ThenByDescending(a => a.CreatedAt)
            .ToListAsync();

        return ApiResponse<List<UserAddressDto>>.Ok(_mapper.Map<List<UserAddressDto>>(addresses));
    }

    public async Task<ApiResponse<UserAddressDto>> AddAddressAsync(Guid userId, CreateUserAddressDto dto)
    {
        var existing = await _addressRepo.Query().Where(a => a.UserId == userId).ToListAsync();
        var isFirst = !existing.Any();

        if (dto.IsDefault || isFirst)
        {
            foreach (var addr in existing)
            {
                if (addr.IsDefault)
                {
                    addr.IsDefault = false;
                    await _addressRepo.UpdateAsync(addr);
                }
            }
        }

        var newAddress = new UserAddress
        {
            UserId = userId,
            AddressText = dto.AddressText,
            IsDefault = dto.IsDefault || isFirst
        };

        await _addressRepo.AddAsync(newAddress);
        await _addressRepo.SaveChangesAsync();

        return ApiResponse<UserAddressDto>.Ok(_mapper.Map<UserAddressDto>(newAddress));
    }

    public async Task<ApiResponse<UserAddressDto>> UpdateAddressAsync(Guid userId, Guid addressId, UpdateUserAddressDto dto)
    {
        var address = await _addressRepo.Query()
            .FirstOrDefaultAsync(a => a.Id == addressId && a.UserId == userId);

        if (address == null)
        {
            return ApiResponse<UserAddressDto>.Fail("NOT_FOUND", "Address not found");
        }

        if (dto.IsDefault && !address.IsDefault)
        {
            var otherAddresses = await _addressRepo.Query()
                .Where(a => a.UserId == userId && a.Id != addressId)
                .ToListAsync();

            foreach (var other in otherAddresses)
            {
                if (other.IsDefault)
                {
                    other.IsDefault = false;
                    await _addressRepo.UpdateAsync(other);
                }
            }
        }

        address.AddressText = dto.AddressText;
        address.IsDefault = dto.IsDefault;

        await _addressRepo.UpdateAsync(address);
        await _addressRepo.SaveChangesAsync();

        return ApiResponse<UserAddressDto>.Ok(_mapper.Map<UserAddressDto>(address));
    }

    public async Task<ApiResponse<bool>> DeleteAddressAsync(Guid userId, Guid addressId)
    {
        var address = await _addressRepo.Query()
            .FirstOrDefaultAsync(a => a.Id == addressId && a.UserId == userId);

        if (address == null)
        {
            return ApiResponse<bool>.Fail("NOT_FOUND", "Address not found");
        }

        bool wasDefault = address.IsDefault;

        await _addressRepo.DeleteAsync(address);
        await _addressRepo.SaveChangesAsync();

        if (wasDefault)
        {
            var remaining = await _addressRepo.Query()
                .Where(a => a.UserId == userId)
                .OrderByDescending(a => a.CreatedAt)
                .FirstOrDefaultAsync();

            if (remaining != null)
            {
                remaining.IsDefault = true;
                await _addressRepo.UpdateAsync(remaining);
                await _addressRepo.SaveChangesAsync();
            }
        }

        return ApiResponse<bool>.Ok(true);
    }

    public async Task<ApiResponse<UserAddressDto>> SetDefaultAddressAsync(Guid userId, Guid addressId)
    {
        var address = await _addressRepo.Query()
            .FirstOrDefaultAsync(a => a.Id == addressId && a.UserId == userId);

        if (address == null)
        {
            return ApiResponse<UserAddressDto>.Fail("NOT_FOUND", "Address not found");
        }

        if (!address.IsDefault)
        {
            var otherAddresses = await _addressRepo.Query()
                .Where(a => a.UserId == userId && a.Id != addressId)
                .ToListAsync();

            foreach (var other in otherAddresses)
            {
                if (other.IsDefault)
                {
                    other.IsDefault = false;
                    await _addressRepo.UpdateAsync(other);
                }
            }

            address.IsDefault = true;
            await _addressRepo.UpdateAsync(address);
            await _addressRepo.SaveChangesAsync();
        }

        return ApiResponse<UserAddressDto>.Ok(_mapper.Map<UserAddressDto>(address));
    }
}
