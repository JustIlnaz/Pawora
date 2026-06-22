using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Users;
using Pawora.Application.DTOs.Auth;
using Pawora.Application.Interfaces;

namespace Pawora.API.Controllers;

[Authorize]
[Route("api/users")]
public class UsersController : ApiControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet("profile")]
    public async Task<ActionResult<ApiResponse<UserProfileDto>>> GetProfile()
    {
        var result = await _userService.GetProfileAsync(UserId);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }

    [HttpPut("profile")]
    public async Task<ActionResult<ApiResponse<UserProfileDto>>> UpdateProfile([FromBody] UpdateProfileDto dto)
    {
        var result = await _userService.UpdateProfileAsync(UserId, dto);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }
}
