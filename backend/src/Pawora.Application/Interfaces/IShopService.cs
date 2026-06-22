using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Shops;

namespace Pawora.Application.Interfaces;

public interface IShopService
{
    Task<ApiResponse<List<ShopDto>>> GetShopsAsync();
    Task<ApiResponse<ShopDto>> GetShopByIdAsync(Guid id);
    Task<ApiResponse<List<ShopDto>>> GetNearbyShopsAsync(NearbyShopQueryDto dto);
    Task<ApiResponse<ShopDto>> CreateShopAsync(Guid ownerId, CreateShopDto dto);
    Task<ApiResponse<ShopDto>> UpdateShopAsync(Guid id, CreateShopDto dto);
    Task<ApiResponse<bool>> DeleteShopAsync(Guid id);
}
