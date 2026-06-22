using Microsoft.EntityFrameworkCore;
using Pawora.Core.Entities;
using Pawora.Core.Interfaces;
using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Pets;
using Pawora.Application.Interfaces;
using AutoMapper;

namespace Pawora.Application.Services;

public class PetService : IPetService
{
    private readonly IRepository<Pet> _petRepo;
    private readonly IMapper _mapper;

    public PetService(IRepository<Pet> petRepo, IMapper mapper)
    {
        _petRepo = petRepo;
        _mapper = mapper;
    }

    public async Task<ApiResponse<List<PetDto>>> GetPetsAsync(Guid userId)
    {
        var pets = await _petRepo.Query().Where(p => p.UserId == userId).ToListAsync();
        return ApiResponse<List<PetDto>>.Ok(_mapper.Map<List<PetDto>>(pets));
    }

    public async Task<ApiResponse<PetDto>> GetPetByIdAsync(Guid id)
    {
        var pet = await _petRepo.GetByIdAsync(id);
        if (pet == null) return ApiResponse<PetDto>.Fail("NOT_FOUND", "Pet not found");
        return ApiResponse<PetDto>.Ok(_mapper.Map<PetDto>(pet));
    }

    public async Task<ApiResponse<PetDto>> CreatePetAsync(Guid userId, CreatePetDto dto)
    {
        var pet = _mapper.Map<Pet>(dto);
        pet.UserId = userId;
        await _petRepo.AddAsync(pet);
        await _petRepo.SaveChangesAsync();
        return ApiResponse<PetDto>.Ok(_mapper.Map<PetDto>(pet));
    }

    public async Task<ApiResponse<PetDto>> UpdatePetAsync(Guid id, CreatePetDto dto)
    {
        var pet = await _petRepo.GetByIdAsync(id);
        if (pet == null) return ApiResponse<PetDto>.Fail("NOT_FOUND", "Pet not found");
        
        _mapper.Map(dto, pet);
        await _petRepo.UpdateAsync(pet);
        await _petRepo.SaveChangesAsync();
        
        return ApiResponse<PetDto>.Ok(_mapper.Map<PetDto>(pet));
    }

    public async Task<ApiResponse<bool>> DeletePetAsync(Guid id)
    {
        var pet = await _petRepo.GetByIdAsync(id);
        if (pet == null) return ApiResponse<bool>.Fail("NOT_FOUND", "Pet not found");
        
        await _petRepo.DeleteAsync(pet);
        await _petRepo.SaveChangesAsync();
        return ApiResponse<bool>.Ok(true);
    }
}
