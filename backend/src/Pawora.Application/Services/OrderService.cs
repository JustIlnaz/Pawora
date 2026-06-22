using Microsoft.EntityFrameworkCore;
using Pawora.Core.Entities;
using Pawora.Core.Interfaces;
using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Orders;
using Pawora.Application.Interfaces;
using AutoMapper;

namespace Pawora.Application.Services;

public class OrderService : IOrderService
{
    private readonly IRepository<Order> _orderRepo;
    private readonly IRepository<Product> _productRepo;
    private readonly IMapper _mapper;

    public OrderService(IRepository<Order> orderRepo, IRepository<Product> productRepo, IMapper mapper)
    {
        _orderRepo = orderRepo;
        _productRepo = productRepo;
        _mapper = mapper;
    }

    public async Task<ApiResponse<List<OrderDto>>> GetOrdersAsync(Guid userId)
    {
        var orders = await _orderRepo.Query().Include(o => o.Items).ThenInclude(i => i.Product).Where(o => o.UserId == userId).OrderByDescending(o => o.CreatedAt).ToListAsync();
        return ApiResponse<List<OrderDto>>.Ok(_mapper.Map<List<OrderDto>>(orders));
    }

    public async Task<ApiResponse<List<OrderDto>>> GetAllOrdersAsync()
    {
        var orders = await _orderRepo.Query().Include(o => o.Items).ThenInclude(i => i.Product).OrderByDescending(o => o.CreatedAt).ToListAsync();
        return ApiResponse<List<OrderDto>>.Ok(_mapper.Map<List<OrderDto>>(orders));
    }

    public async Task<ApiResponse<OrderDto>> GetOrderByIdAsync(Guid id)
    {
        var order = await _orderRepo.Query().Include(o => o.Items).ThenInclude(i => i.Product).FirstOrDefaultAsync(o => o.Id == id);
        if (order == null) return ApiResponse<OrderDto>.Fail("NOT_FOUND", "Order not found");
        return ApiResponse<OrderDto>.Ok(_mapper.Map<OrderDto>(order));
    }

    public async Task<ApiResponse<OrderDto>> CreateOrderAsync(Guid userId, CreateOrderDto dto)
    {
        var order = new Order
        {
            UserId = userId,
            ShopId = dto.ShopId,
            Address = dto.Address,
            Status = Pawora.Core.Enums.OrderStatus.New
        };

        decimal totalAmount = 0;
        foreach (var item in dto.Items)
        {
            var product = await _productRepo.GetByIdAsync(item.ProductId);
            if (product == null) continue;

            var price = product.DiscountPrice ?? product.Price;
            totalAmount += price * item.Quantity;
            
            order.Items.Add(new OrderItem
            {
                ProductId = item.ProductId,
                Quantity = item.Quantity,
                UnitPrice = price
            });
            
            product.Stock = Math.Max(0, product.Stock - item.Quantity);
            await _productRepo.UpdateAsync(product);
        }

        order.TotalAmount = totalAmount;
        await _orderRepo.AddAsync(order);
        await _orderRepo.SaveChangesAsync();

        return await GetOrderByIdAsync(order.Id);
    }

    public async Task<ApiResponse<OrderDto>> UpdateOrderStatusAsync(Guid id, UpdateOrderStatusDto dto)
    {
        var order = await _orderRepo.Query().Include(o => o.Items).FirstOrDefaultAsync(o => o.Id == id);
        if (order == null) return ApiResponse<OrderDto>.Fail("NOT_FOUND", "Order not found");
        
        var oldStatus = order.Status;
        order.Status = dto.Status;

        if (dto.Status == Pawora.Core.Enums.OrderStatus.Cancelled && oldStatus != Pawora.Core.Enums.OrderStatus.Cancelled)
        {
            foreach (var item in order.Items)
            {
                var product = await _productRepo.GetByIdAsync(item.ProductId);
                if (product != null)
                {
                    product.Stock += item.Quantity;
                    await _productRepo.UpdateAsync(product);
                }
            }
        }

        await _orderRepo.UpdateAsync(order);
        await _orderRepo.SaveChangesAsync();
        
        return await GetOrderByIdAsync(order.Id);
    }
}
