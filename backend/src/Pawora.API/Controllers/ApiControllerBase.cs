using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;

namespace Pawora.API.Controllers;

[ApiController]
public abstract class ApiControllerBase : ControllerBase
{
    protected Guid UserId
    {
        get
        {
            var userIdVal = User.FindFirst(ClaimTypes.NameIdentifier)?.Value 
                ?? User.FindFirst("sub")?.Value;
            return Guid.TryParse(userIdVal, out var guid) ? guid : Guid.Empty;
        }
    }
}
