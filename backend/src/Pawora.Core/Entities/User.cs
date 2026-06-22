using Pawora.Core.Enums;

namespace Pawora.Core.Entities;

public class User : BaseEntity
{
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? AvatarUrl { get; set; }
    public UserRole Role { get; set; } = UserRole.Customer;

    public ICollection<Order> Orders { get; set; } = new List<Order>();
    public ICollection<Pet> Pets { get; set; } = new List<Pet>();
    public ICollection<Review> Reviews { get; set; } = new List<Review>();
    public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
    public ICollection<UserAddress> Addresses { get; set; } = new List<UserAddress>();
}
