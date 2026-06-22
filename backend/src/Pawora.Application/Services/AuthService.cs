using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Pawora.Core.Entities;
using Pawora.Core.Interfaces;
using Pawora.Application.DTOs;
using Pawora.Application.DTOs.Auth;
using Pawora.Application.DTOs.Users;
using Pawora.Application.Interfaces;
using AutoMapper;

namespace Pawora.Application.Services;

public class AuthService : IAuthService
{
    private readonly IRepository<User> _userRepo;
    private readonly IRepository<RefreshToken> _refreshTokenRepo;
    private readonly IConfiguration _config;
    private readonly IMapper _mapper;

    public AuthService(IRepository<User> userRepo, IRepository<RefreshToken> refreshTokenRepo, IConfiguration config, IMapper mapper)
    {
        _userRepo = userRepo;
        _refreshTokenRepo = refreshTokenRepo;
        _config = config;
        _mapper = mapper;
    }

    public async Task<ApiResponse<TokenResponseDto>> RegisterAsync(RegisterDto dto)
    {
        var existingUser = await _userRepo.Query().FirstOrDefaultAsync(u => u.Email == dto.Email);
        if (existingUser != null)
            return ApiResponse<TokenResponseDto>.Fail("USER_EXISTS", "User with this email already exists.");

        var user = new User
        {
            Email = dto.Email,
            FullName = dto.FullName,
            Phone = dto.Phone,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password)
        };

        if (!string.IsNullOrWhiteSpace(dto.Address))
        {
            user.Addresses.Add(new UserAddress
            {
                AddressText = dto.Address,
                IsDefault = true
            });
        }

        await _userRepo.AddAsync(user);
        await _userRepo.SaveChangesAsync();

        return await GenerateTokenResponse(user);
    }

    public async Task<ApiResponse<TokenResponseDto>> LoginAsync(LoginDto dto)
    {
        var user = await _userRepo.Query().FirstOrDefaultAsync(u => u.Email == dto.Email);
        if (user == null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
            return ApiResponse<TokenResponseDto>.Fail("INVALID_CREDENTIALS", "Invalid email or password.");

        return await GenerateTokenResponse(user);
    }

    public async Task<ApiResponse<TokenResponseDto>> RefreshTokenAsync(RefreshTokenDto dto)
    {
        var tokenRecord = await _refreshTokenRepo.Query().Include(r => r.User).FirstOrDefaultAsync(r => r.Token == dto.RefreshToken);
        
        if (tokenRecord == null || tokenRecord.IsRevoked || tokenRecord.ExpiresAt <= DateTime.UtcNow)
            return ApiResponse<TokenResponseDto>.Fail("INVALID_TOKEN", "Invalid or expired refresh token.");

        tokenRecord.IsRevoked = true;
        await _refreshTokenRepo.UpdateAsync(tokenRecord);
        await _refreshTokenRepo.SaveChangesAsync();

        return await GenerateTokenResponse(tokenRecord.User);
    }

    public async Task<ApiResponse<bool>> LogoutAsync(string refreshToken)
    {
        var tokenRecord = await _refreshTokenRepo.Query().FirstOrDefaultAsync(r => r.Token == refreshToken);
        if (tokenRecord != null)
        {
            tokenRecord.IsRevoked = true;
            await _refreshTokenRepo.UpdateAsync(tokenRecord);
            await _refreshTokenRepo.SaveChangesAsync();
        }
        return ApiResponse<bool>.Ok(true);
    }

    private async Task<ApiResponse<TokenResponseDto>> GenerateTokenResponse(User user)
    {
        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role.ToString())
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["JwtSettings:Secret"]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var expiryMins = int.Parse(_config["JwtSettings:AccessTokenExpirationMinutes"] ?? "15");

        var token = new JwtSecurityToken(
            issuer: _config["JwtSettings:Issuer"],
            audience: _config["JwtSettings:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expiryMins),
            signingCredentials: creds
        );

        var accessToken = new JwtSecurityTokenHandler().WriteToken(token);
        
        var randomNumber = new byte[32];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(randomNumber);
        var refreshTokenString = Convert.ToBase64String(randomNumber);

        var expiryDays = int.Parse(_config["JwtSettings:RefreshTokenExpirationDays"] ?? "7");
        var refreshToken = new RefreshToken
        {
            UserId = user.Id,
            Token = refreshTokenString,
            ExpiresAt = DateTime.UtcNow.AddDays(expiryDays)
        };

        await _refreshTokenRepo.AddAsync(refreshToken);
        await _refreshTokenRepo.SaveChangesAsync();

        return ApiResponse<TokenResponseDto>.Ok(new TokenResponseDto
        {
            AccessToken = accessToken,
            RefreshToken = refreshTokenString,
            User = _mapper.Map<UserProfileDto>(user)
        });
    }
}
