namespace Pawora.Core.Entities;

public class Review : BaseEntity
{
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;

    public Guid ProductId { get; set; }
    public Product Product { get; set; } = null!;

    public int Rating { get; set; }
    public string? Comment { get; set; }

    public string? AdminReply { get; set; }
    public DateTime? AdminReplyCreatedAt { get; set; }
}
