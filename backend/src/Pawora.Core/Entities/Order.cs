using Pawora.Core.Enums;

namespace Pawora.Core.Entities;

public class Order : BaseEntity
{
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;
    
    public Guid? ShopId { get; set; }
    
    public OrderStatus Status { get; set; } = OrderStatus.New;
    public decimal TotalAmount { get; set; }
    public string? Address { get; set; }

    public ICollection<OrderItem> Items { get; set; } = new List<OrderItem>();
}
