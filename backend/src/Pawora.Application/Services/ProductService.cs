using Microsoft.EntityFrameworkCore;
using Pawora.Core.Entities;
using Pawora.Core.Interfaces;
using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Products;
using Pawora.Application.Interfaces;
using AutoMapper;

namespace Pawora.Application.Services;

public class ProductService : IProductService
{
    private readonly IRepository<Product> _productRepo;
    private readonly IMapper _mapper;

    public ProductService(IRepository<Product> productRepo, IMapper mapper)
    {
        _productRepo = productRepo;
        _mapper = mapper;
    }

    public async Task<ApiResponse<List<ProductDto>>> GetProductsAsync(ProductFilterDto dto)
    {
        var query = _productRepo.Query().Include(p => p.Shop).Include(p => p.Category).AsQueryable();

        if (!string.IsNullOrEmpty(dto.Search))
            query = query.Where(p => p.Name.Contains(dto.Search) || p.Description != null && p.Description.Contains(dto.Search));
            
        if (dto.CategoryId.HasValue)
            query = query.Where(p => p.CategoryId == dto.CategoryId.Value);
            
        if (dto.ShopId.HasValue)
            query = query.Where(p => p.ShopId == dto.ShopId.Value);

        query = dto.SortBy?.ToLower() switch
        {
            "price_asc" => query.OrderBy(p => p.Price),
            "price_desc" => query.OrderByDescending(p => p.Price),
            "rating" => query.OrderByDescending(p => p.Rating),
            _ => query.OrderByDescending(p => p.CreatedAt)
        };

        var products = await query.Skip(dto.Skip).Take(dto.Take).ToListAsync();
        return ApiResponse<List<ProductDto>>.Ok(_mapper.Map<List<ProductDto>>(products));
    }

    public async Task<ApiResponse<ProductDto>> GetProductByIdAsync(Guid id)
    {
        var product = await _productRepo.Query().Include(p => p.Shop).Include(p => p.Category).FirstOrDefaultAsync(p => p.Id == id);
        if (product == null) return ApiResponse<ProductDto>.Fail("NOT_FOUND", "Product not found");
        return ApiResponse<ProductDto>.Ok(_mapper.Map<ProductDto>(product));
    }

    public async Task<ApiResponse<ProductDto>> CreateProductAsync(CreateProductDto dto)
    {
        var product = _mapper.Map<Product>(dto);
        await _productRepo.AddAsync(product);
        await _productRepo.SaveChangesAsync();
        return await GetProductByIdAsync(product.Id);
    }

    public async Task<ApiResponse<ProductDto>> UpdateProductAsync(Guid id, CreateProductDto dto)
    {
        var product = await _productRepo.GetByIdAsync(id);
        if (product == null) return ApiResponse<ProductDto>.Fail("NOT_FOUND", "Product not found");
        
        _mapper.Map(dto, product);
        await _productRepo.UpdateAsync(product);
        await _productRepo.SaveChangesAsync();
        
        return await GetProductByIdAsync(product.Id);
    }

    public async Task<ApiResponse<bool>> DeleteProductAsync(Guid id)
    {
        var product = await _productRepo.GetByIdAsync(id);
        if (product == null) return ApiResponse<bool>.Fail("NOT_FOUND", "Product not found");
        
        await _productRepo.DeleteAsync(product);
        await _productRepo.SaveChangesAsync();
        return ApiResponse<bool>.Ok(true);
    }
}
