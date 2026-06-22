using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Pawora.Application.DTOs;
using Pawora.Application.Interfaces;

namespace Pawora.API.Controllers;

[Authorize]
[Route("api/user-addresses")]
public class UserAddressesController : ApiControllerBase
{
    private readonly IUserAddressService _addressService;

    public UserAddressesController(IUserAddressService addressService)
    {
        _addressService = addressService;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<UserAddressDto>>>> GetAddresses()
    {
        var result = await _addressService.GetAddressesAsync(UserId);
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<UserAddressDto>>> CreateAddress([FromBody] CreateUserAddressDto dto)
    {
        var result = await _addressService.AddAddressAsync(UserId, dto);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<ApiResponse<UserAddressDto>>> UpdateAddress(Guid id, [FromBody] UpdateUserAddressDto dto)
    {
        var result = await _addressService.UpdateAddressAsync(UserId, id, dto);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteAddress(Guid id)
    {
        var result = await _addressService.DeleteAddressAsync(UserId, id);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }

    [HttpPost("{id:guid}/default")]
    public async Task<ActionResult<ApiResponse<UserAddressDto>>> SetDefault(Guid id)
    {
        var result = await _addressService.SetDefaultAddressAsync(UserId, id);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }
}
