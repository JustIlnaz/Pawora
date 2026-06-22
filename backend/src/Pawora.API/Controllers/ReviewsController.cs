using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Reviews;
using Pawora.Application.Interfaces;

namespace Pawora.API.Controllers;

[Route("api/products/{productId:guid}/reviews")]
public class ReviewsController : ApiControllerBase
{
    private readonly IReviewService _reviewService;

    public ReviewsController(IReviewService reviewService)
    {
        _reviewService = reviewService;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<ReviewDto>>>> GetReviews(Guid productId)
    {
        var result = await _reviewService.GetProductReviewsAsync(productId);
        return Ok(result);
    }

    [Authorize]
    [HttpPost]
    public async Task<ActionResult<ApiResponse<ReviewDto>>> CreateReview(Guid productId, [FromBody] CreateReviewDto dto)
    {
        var result = await _reviewService.CreateReviewAsync(UserId, productId, dto);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }

    [Authorize(Roles = "Admin")]
    [HttpPost("{reviewId:guid}/reply")]
    public async Task<ActionResult<ApiResponse<ReviewDto>>> ReplyToReview(Guid reviewId, [FromBody] AdminReplyDto dto)
    {
        var result = await _reviewService.ReplyToReviewAsync(reviewId, dto);
        if (!result.Success)
            return BadRequest(result);
        return Ok(result);
    }
}
