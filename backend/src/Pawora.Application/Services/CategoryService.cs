using Microsoft.EntityFrameworkCore;
using Pawora.Core.Entities;
using Pawora.Core.Interfaces;
using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Products;
using Pawora.Application.Interfaces;
using AutoMapper;

namespace Pawora.Application.Services;

public class CategoryService : ICategoryService
{
    private readonly IRepository<Category> _categoryRepo;
    private readonly IMapper _mapper;

    public CategoryService(IRepository<Category> categoryRepo, IMapper mapper)
    {
        _categoryRepo = categoryRepo;
        _mapper = mapper;
    }

    public async Task<ApiResponse<List<CategoryDto>>> GetCategoriesAsync()
    {
        var categories = await _categoryRepo.Query().OrderBy(c => c.SortOrder).ToListAsync();
        return ApiResponse<List<CategoryDto>>.Ok(_mapper.Map<List<CategoryDto>>(categories));
    }
}
