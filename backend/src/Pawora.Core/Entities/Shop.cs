namespace Pawora.Core.Entities;

public class Shop : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string Address { get; set; } = string.Empty;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string? ImageUrl { get; set; }
    public Guid OwnerId { get; set; }
    public User Owner { get; set; } = null!;
    public string? Phone { get; set; }
    public double Rating { get; set; }

    public ICollection<Product> Products { get; set; } = new List<Product>();
}
