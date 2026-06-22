using Microsoft.EntityFrameworkCore;
using Pawora.Core.Entities;
using Pawora.Core.Interfaces;
using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Reviews;
using Pawora.Application.Interfaces;
using AutoMapper;

namespace Pawora.Application.Services;

public class ReviewService : IReviewService
{
    private readonly IRepository<Review> _reviewRepo;
    private readonly IRepository<Product> _productRepo;
    private readonly IMapper _mapper;

    public ReviewService(IRepository<Review> reviewRepo, IRepository<Product> productRepo, IMapper mapper)
    {
        _reviewRepo = reviewRepo;
        _productRepo = productRepo;
        _mapper = mapper;
    }

    public async Task<ApiResponse<List<ReviewDto>>> GetProductReviewsAsync(Guid productId)
    {
        var reviews = await _reviewRepo.Query().Include(r => r.User).Where(r => r.ProductId == productId).OrderByDescending(r => r.CreatedAt).ToListAsync();
        return ApiResponse<List<ReviewDto>>.Ok(_mapper.Map<List<ReviewDto>>(reviews));
    }

    public async Task<ApiResponse<ReviewDto>> CreateReviewAsync(Guid userId, Guid productId, CreateReviewDto dto)
    {
        var review = _mapper.Map<Review>(dto);
        review.UserId = userId;
        review.ProductId = productId;
        await _reviewRepo.AddAsync(review);
        await _reviewRepo.SaveChangesAsync();
        
        var product = await _productRepo.Query().Include(p => p.Reviews).FirstOrDefaultAsync(p => p.Id == productId);
        if (product != null)
        {
            product.Rating = product.Reviews.Average(r => r.Rating);
            product.ReviewCount = product.Reviews.Count;
            await _productRepo.UpdateAsync(product);
            await _productRepo.SaveChangesAsync();
        }

        var reviewWithUser = await _reviewRepo.Query().Include(r => r.User).FirstOrDefaultAsync(r => r.Id == review.Id);
        return ApiResponse<ReviewDto>.Ok(_mapper.Map<ReviewDto>(reviewWithUser));
    }

    public async Task<ApiResponse<ReviewDto>> ReplyToReviewAsync(Guid reviewId, AdminReplyDto dto)
    {
        var review = await _reviewRepo.Query().Include(r => r.User).FirstOrDefaultAsync(r => r.Id == reviewId);
        if (review == null)
            return ApiResponse<ReviewDto>.Fail("NOT_FOUND", "Review not found.");

        review.AdminReply = dto.Reply;
        review.AdminReplyCreatedAt = DateTime.UtcNow;

        await _reviewRepo.UpdateAsync(review);
        await _reviewRepo.SaveChangesAsync();

        return ApiResponse<ReviewDto>.Ok(_mapper.Map<ReviewDto>(review));
    }
}
