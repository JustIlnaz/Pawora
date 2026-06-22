using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Shops;
using Pawora.Application.Interfaces;

namespace Pawora.API.Controllers;

[Route("api/shops")]
public class ShopsController : ApiControllerBase
{
    private readonly IShopService _shopService;

    public ShopsController(IShopService shopService)
    {
        _shopService = shopService;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<ShopDto>>>> GetShops()
    {
        var result = await _shopService.GetShopsAsync();
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ApiResponse<ShopDto>>> GetShopById(Guid id)
    {
        var result = await _shopService.GetShopByIdAsync(id);
        if (!result.Success)
            return NotFound(result);
        return Ok(result);
    }

    [HttpGet("nearby")]
    public async Task<ActionResult<ApiResponse<List<ShopDto>>>> GetNearbyShops([FromQuery] NearbyShopQueryDto dto)
    {
        var result = await _shopService.GetNearbyShopsAsync(dto);
        return Ok(result);
    }

    [Authorize]
    [HttpPost]
    public async Task<ActionResult<ApiResponse<ShopDto>>> CreateShop([FromBody] CreateShopDto dto)
    {
        var result = await _shopService.CreateShopAsync(UserId, dto);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }

    [Authorize]
    [HttpPut("{id:guid}")]
    public async Task<ActionResult<ApiResponse<ShopDto>>> UpdateShop(Guid id, [FromBody] CreateShopDto dto)
    {
        var result = await _shopService.UpdateShopAsync(id, dto);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }

    [Authorize]
    [HttpDelete("{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteShop(Guid id)
    {
        var result = await _shopService.DeleteShopAsync(id);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }
}
