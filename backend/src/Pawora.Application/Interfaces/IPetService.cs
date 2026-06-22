using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Pets;

namespace Pawora.Application.Interfaces;

public interface IPetService
{
    Task<ApiResponse<List<PetDto>>> GetPetsAsync(Guid userId);
    Task<ApiResponse<PetDto>> GetPetByIdAsync(Guid id);
    Task<ApiResponse<PetDto>> CreatePetAsync(Guid userId, CreatePetDto dto);
    Task<ApiResponse<PetDto>> UpdatePetAsync(Guid id, CreatePetDto dto);
    Task<ApiResponse<bool>> DeletePetAsync(Guid id);
}
