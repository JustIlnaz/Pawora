using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Pets;
using Pawora.Application.Interfaces;

namespace Pawora.API.Controllers;

[Authorize]
[Route("api/pets")]
public class PetsController : ApiControllerBase
{
    private readonly IPetService _petService;

    public PetsController(IPetService petService)
    {
        _petService = petService;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<PetDto>>>> GetPets()
    {
        var result = await _petService.GetPetsAsync(UserId);
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ApiResponse<PetDto>>> GetPetById(Guid id)
    {
        var result = await _petService.GetPetByIdAsync(id);
        if (!result.Success)
            return NotFound(result);
        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<PetDto>>> CreatePet([FromBody] CreatePetDto dto)
    {
        var result = await _petService.CreatePetAsync(UserId, dto);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<ApiResponse<PetDto>>> UpdatePet(Guid id, [FromBody] CreatePetDto dto)
    {
        var result = await _petService.UpdatePetAsync(id, dto);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeletePet(Guid id)
    {
        var result = await _petService.DeletePetAsync(id);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }
}
