using Microsoft.EntityFrameworkCore;
using Pawora.Core.Entities;
using Pawora.Core.Interfaces;
using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Shops;
using Pawora.Application.Interfaces;
using AutoMapper;

namespace Pawora.Application.Services;

public class ShopService : IShopService
{
    private readonly IRepository<Shop> _shopRepo;
    private readonly IMapper _mapper;

    public ShopService(IRepository<Shop> shopRepo, IMapper mapper)
    {
        _shopRepo = shopRepo;
        _mapper = mapper;
    }

    public async Task<ApiResponse<List<ShopDto>>> GetShopsAsync()
    {
        var shops = await _shopRepo.Query().ToListAsync();
        return ApiResponse<List<ShopDto>>.Ok(_mapper.Map<List<ShopDto>>(shops));
    }

    public async Task<ApiResponse<ShopDto>> GetShopByIdAsync(Guid id)
    {
        var shop = await _shopRepo.GetByIdAsync(id);
        if (shop == null) return ApiResponse<ShopDto>.Fail("NOT_FOUND", "Shop not found");
        return ApiResponse<ShopDto>.Ok(_mapper.Map<ShopDto>(shop));
    }

    public async Task<ApiResponse<List<ShopDto>>> GetNearbyShopsAsync(NearbyShopQueryDto dto)
    {
        var shops = await _shopRepo.Query().ToListAsync();
        var nearbyShops = new List<ShopDto>();

        foreach (var shop in shops)
        {
            var distance = CalculateHaversineDistance(dto.Latitude, dto.Longitude, shop.Latitude, shop.Longitude);
            if (distance <= dto.RadiusKm)
            {
                var shopDto = _mapper.Map<ShopDto>(shop);
                shopDto.Distance = Math.Round(distance, 2);
                nearbyShops.Add(shopDto);
            }
        }

        return ApiResponse<List<ShopDto>>.Ok(nearbyShops.OrderBy(s => s.Distance).ToList());
    }

    public async Task<ApiResponse<ShopDto>> CreateShopAsync(Guid ownerId, CreateShopDto dto)
    {
        var shop = _mapper.Map<Shop>(dto);
        shop.OwnerId = ownerId;
        await _shopRepo.AddAsync(shop);
        await _shopRepo.SaveChangesAsync();
        return ApiResponse<ShopDto>.Ok(_mapper.Map<ShopDto>(shop));
    }

    public async Task<ApiResponse<ShopDto>> UpdateShopAsync(Guid id, CreateShopDto dto)
    {
        var shop = await _shopRepo.GetByIdAsync(id);
        if (shop == null) return ApiResponse<ShopDto>.Fail("NOT_FOUND", "Shop not found");
        
        _mapper.Map(dto, shop);
        await _shopRepo.UpdateAsync(shop);
        await _shopRepo.SaveChangesAsync();
        
        return ApiResponse<ShopDto>.Ok(_mapper.Map<ShopDto>(shop));
    }

    public async Task<ApiResponse<bool>> DeleteShopAsync(Guid id)
    {
        var shop = await _shopRepo.GetByIdAsync(id);
        if (shop == null) return ApiResponse<bool>.Fail("NOT_FOUND", "Shop not found");
        
        await _shopRepo.DeleteAsync(shop);
        await _shopRepo.SaveChangesAsync();
        return ApiResponse<bool>.Ok(true);
    }

    private static double CalculateHaversineDistance(double lat1, double lon1, double lat2, double lon2)
    {
        var R = 6371.0; 
        var dLat = (lat2 - lat1) * Math.PI / 180;
        var dLon = (lon2 - lon1) * Math.PI / 180;
        var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) + 
                Math.Cos(lat1 * Math.PI / 180) * Math.Cos(lat2 * Math.PI / 180) * 
                Math.Sin(dLon / 2) * Math.Sin(dLon / 2);
        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return R * c;
    }
}
