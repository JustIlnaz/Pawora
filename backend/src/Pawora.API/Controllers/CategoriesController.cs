using Microsoft.AspNetCore.Mvc;
using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Products;
using Pawora.Application.Interfaces;

namespace Pawora.API.Controllers;

[Route("api/categories")]
public class CategoriesController : ApiControllerBase
{
    private readonly ICategoryService _categoryService;

    public CategoriesController(ICategoryService categoryService)
    {
        _categoryService = categoryService;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<CategoryDto>>>> GetCategories()
    {
        var result = await _categoryService.GetCategoriesAsync();
        return Ok(result);
    }
}
