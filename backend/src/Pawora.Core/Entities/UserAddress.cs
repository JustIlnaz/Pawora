using System;

namespace Pawora.Core.Entities;

public class UserAddress : BaseEntity
{
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;
    public string AddressText { get; set; } = string.Empty;
    public bool IsDefault { get; set; }
}
