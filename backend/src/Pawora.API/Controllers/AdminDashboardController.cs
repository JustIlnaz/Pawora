using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Pawora.Core.Entities;
using Pawora.Core.Enums;
using Pawora.Core.Interfaces;
using Pawora.Application.DTOs;

namespace Pawora.API.Controllers;

[Authorize]
[Route("api/admin/dashboard")]
public class AdminDashboardController : ApiControllerBase
{
    private readonly IRepository<Order> _orderRepo;
    private readonly IRepository<Product> _productRepo;
    private readonly IRepository<User> _userRepo;

    public AdminDashboardController(
        IRepository<Order> orderRepo,
        IRepository<Product> productRepo,
        IRepository<User> userRepo)
    {
        _orderRepo = orderRepo;
        _productRepo = productRepo;
        _userRepo = userRepo;
    }

    [HttpGet("stats")]
    public async Task<ActionResult<ApiResponse<DashboardStatsDto>>> GetStats()
    {
        // Simple security check: ensure user role is Admin
        var roleClaim = User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
        if (roleClaim != UserRole.Admin.ToString() && roleClaim != "2")
        {
            return StatusCode(403, ApiResponse<DashboardStatsDto>.Fail("FORBIDDEN", "Only administrators can access this data."));
        }

        var totalOrders = await _orderRepo.Query().CountAsync();
        var totalRevenue = await _orderRepo.Query().SumAsync(o => (decimal?)o.TotalAmount) ?? 0;
        var totalProducts = await _productRepo.Query().CountAsync();
        var totalClients = await _userRepo.Query().Where(u => u.Role == UserRole.Customer).CountAsync();

        var stats = new DashboardStatsDto
        {
            TotalOrders = totalOrders,
            TotalRevenue = totalRevenue,
            TotalProducts = totalProducts,
            TotalClients = totalClients
        };

        return Ok(ApiResponse<DashboardStatsDto>.Ok(stats));
    }
}
