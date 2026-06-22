using Microsoft.EntityFrameworkCore;
using Pawora.Core.Entities;
using Pawora.Core.Enums;

namespace Pawora.DataAccess;

public class PaworaDbContext : DbContext
{
    public PaworaDbContext(DbContextOptions<PaworaDbContext> options) : base(options)
    {
    }
    

    public DbSet<User> Users { get; set; } = null!;
    public DbSet<Shop> Shops { get; set; } = null!;
    public DbSet<Category> Categories { get; set; } = null!;
    public DbSet<Product> Products { get; set; } = null!;
    public DbSet<Order> Orders { get; set; } = null!;
    public DbSet<OrderItem> OrderItems { get; set; } = null!;
    public DbSet<Review> Reviews { get; set; } = null!;
    public DbSet<Pet> Pets { get; set; } = null!;
    public DbSet<RefreshToken> RefreshTokens { get; set; } = null!;
    public DbSet<UserAddress> UserAddresses { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasIndex(u => u.Email).IsUnique();
            entity.HasMany(u => u.Orders).WithOne(o => o.User).HasForeignKey(o => o.UserId).OnDelete(DeleteBehavior.Restrict);
            entity.HasMany(u => u.Pets).WithOne(p => p.User).HasForeignKey(p => p.UserId).OnDelete(DeleteBehavior.Cascade);
            entity.HasMany(u => u.Reviews).WithOne(r => r.User).HasForeignKey(r => r.UserId).OnDelete(DeleteBehavior.Cascade);
            entity.HasMany(u => u.RefreshTokens).WithOne(r => r.User).HasForeignKey(r => r.UserId).OnDelete(DeleteBehavior.Cascade);
            entity.HasMany(u => u.Addresses).WithOne(a => a.User).HasForeignKey(a => a.UserId).OnDelete(DeleteBehavior.Cascade);

            entity.HasData(
                new User
                {
                    Id = Guid.Parse("99999999-9999-9999-9999-999999999999"),
                    Email = "admin@pawora.com",
                    PasswordHash = "$2a$11$Hlhg/XFasR1Zf.GvC1tWbeV3w9D661dYm2G6mR0a/tU.9d.aDkW2q",
                    FullName = "Администратор Pawora",
                    Role = UserRole.Admin,
                    CreatedAt = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                }       
            );
        });

        modelBuilder.Entity<Shop>(entity =>
        {
            entity.HasOne(s => s.Owner).WithMany().HasForeignKey(s => s.OwnerId).OnDelete(DeleteBehavior.Restrict);
            entity.HasMany(s => s.Products).WithOne(p => p.Shop).HasForeignKey(p => p.ShopId).OnDelete(DeleteBehavior.Cascade);

            entity.HasData(
                new Shop
                {
                    Id = Guid.Parse("88888888-8888-8888-8888-888888888888"),
                    Name = "Зоомагазин PAWORA",
                    Description = "Премиальный магазин товаров для домашних животных",
                    Address = "ул. Пушкина, д. 10",
                    Latitude = 55.7558,
                    Longitude = 37.6173,
                    OwnerId = Guid.Parse("99999999-9999-9999-9999-999999999999"),
                    Phone = "+7 (999) 123-45-67",
                    Rating = 4.8,
                    CreatedAt = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)
                }
            );
        });

        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasMany(c => c.Products).WithOne(p => p.Category).HasForeignKey(p => p.CategoryId).OnDelete(DeleteBehavior.Restrict);
            
            entity.HasData(
                new Category { Id = Guid.Parse("11111111-1111-1111-1111-111111111111"), Name = "Food", IconName = "restaurant", SortOrder = 1 },
                new Category { Id = Guid.Parse("22222222-2222-2222-2222-222222222222"), Name = "Toys", IconName = "toys", SortOrder = 2 },
                new Category { Id = Guid.Parse("33333333-3333-3333-3333-333333333333"), Name = "Healthcare", IconName = "health_and_safety", SortOrder = 3 },
                new Category { Id = Guid.Parse("44444444-4444-4444-4444-444444444444"), Name = "Accessories", IconName = "category", SortOrder = 4 },
                new Category { Id = Guid.Parse("55555555-5555-5555-5555-555555555555"), Name = "Grooming", IconName = "content_cut", SortOrder = 5 },
                new Category { Id = Guid.Parse("66666666-6666-6666-6666-666666666666"), Name = "Clothing", IconName = "checkroom", SortOrder = 6 }
            );
        });

        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasMany(p => p.Reviews).WithOne(r => r.Product).HasForeignKey(r => r.ProductId).OnDelete(DeleteBehavior.Cascade);
            entity.HasMany(p => p.OrderItems).WithOne(oi => oi.Product).HasForeignKey(oi => oi.ProductId).OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Order>(entity =>
        {
            entity.HasMany(o => o.Items).WithOne(oi => oi.Order).HasForeignKey(oi => oi.OrderId).OnDelete(DeleteBehavior.Cascade);
        });
    }
}
