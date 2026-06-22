using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Products;

namespace Pawora.Application.Interfaces;

public interface IProductService
{
    Task<ApiResponse<List<ProductDto>>> GetProductsAsync(ProductFilterDto dto);
    Task<ApiResponse<ProductDto>> GetProductByIdAsync(Guid id);
    Task<ApiResponse<ProductDto>> CreateProductAsync(CreateProductDto dto);
    Task<ApiResponse<ProductDto>> UpdateProductAsync(Guid id, CreateProductDto dto);
    Task<ApiResponse<bool>> DeleteProductAsync(Guid id);
}

public interface ICategoryService
{
    Task<ApiResponse<List<CategoryDto>>> GetCategoriesAsync();
}
