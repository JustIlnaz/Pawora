namespace Pawora.Core.Entities;

public class Pet : BaseEntity
{
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;

    public string Name { get; set; } = string.Empty;
    public string Species { get; set; } = string.Empty;
    public string? Breed { get; set; }
    public DateTime? BirthDate { get; set; }
    public string? ImageUrl { get; set; }
}
