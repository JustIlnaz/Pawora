using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Reviews;

namespace Pawora.Application.Interfaces;

public interface IReviewService
{
    Task<ApiResponse<List<ReviewDto>>> GetProductReviewsAsync(Guid productId);
    Task<ApiResponse<ReviewDto>> CreateReviewAsync(Guid userId, Guid productId, CreateReviewDto dto);
    Task<ApiResponse<ReviewDto>> ReplyToReviewAsync(Guid reviewId, AdminReplyDto dto);
}
