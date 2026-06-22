namespace Pawora.Application.DTOs.Products;

public class ProductDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal Price { get; set; }
    public decimal? DiscountPrice { get; set; }
    public string? ImageUrl { get; set; }
    public Guid ShopId { get; set; }
    public string? ShopName { get; set; }
    public Guid CategoryId { get; set; }
    public string? CategoryName { get; set; }
    public int Stock { get; set; }
    public double Rating { get; set; }
    public int ReviewCount { get; set; }
}

public class CreateProductDto
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal Price { get; set; }
    public decimal? DiscountPrice { get; set; }
    public string? ImageUrl { get; set; }
    public Guid ShopId { get; set; }
    public Guid CategoryId { get; set; }
    public int Stock { get; set; }
}

public class ProductFilterDto
{
    public string? Search { get; set; }
    public Guid? CategoryId { get; set; }
    public Guid? ShopId { get; set; }
    public int Skip { get; set; } = 0;
    public int Take { get; set; } = 20;
    public string? SortBy { get; set; }
}

public class CategoryDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? IconName { get; set; }
    public int SortOrder { get; set; }
}
