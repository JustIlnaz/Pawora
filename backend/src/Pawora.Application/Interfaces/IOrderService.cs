using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Orders;

namespace Pawora.Application.Interfaces;

public interface IOrderService
{
    Task<ApiResponse<List<OrderDto>>> GetOrdersAsync(Guid userId);
    Task<ApiResponse<List<OrderDto>>> GetAllOrdersAsync();
    Task<ApiResponse<OrderDto>> GetOrderByIdAsync(Guid id);
    Task<ApiResponse<OrderDto>> CreateOrderAsync(Guid userId, CreateOrderDto dto);
    Task<ApiResponse<OrderDto>> UpdateOrderStatusAsync(Guid id, UpdateOrderStatusDto dto);
}
