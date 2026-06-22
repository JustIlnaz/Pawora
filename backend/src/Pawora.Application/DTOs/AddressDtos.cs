using System;

namespace Pawora.Application.DTOs;

public class UserAddressDto
{
    public Guid Id { get; set; }
    public string AddressText { get; set; } = string.Empty;
    public bool IsDefault { get; set; }
}

public class CreateUserAddressDto
{
    public string AddressText { get; set; } = string.Empty;
    public bool IsDefault { get; set; }
}

public class UpdateUserAddressDto
{
    public string AddressText { get; set; } = string.Empty;
    public bool IsDefault { get; set; }
}
