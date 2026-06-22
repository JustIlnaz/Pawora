namespace Pawora.Application.DTOs.Reviews;

public class ReviewDto
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public string? UserAvatarUrl { get; set; }
    public Guid ProductId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public string? AdminReply { get; set; }
    public DateTime? AdminReplyCreatedAt { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateReviewDto
{
    public int Rating { get; set; }
    public string? Comment { get; set; }
}

public class AdminReplyDto
{
    public string Reply { get; set; } = string.Empty;
}
