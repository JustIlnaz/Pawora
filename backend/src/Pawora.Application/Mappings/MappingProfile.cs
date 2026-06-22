using AutoMapper;
using Pawora.Core.Entities;
using Pawora.Application.DTOs.Auth;
using Pawora.Application.DTOs.Products;
using Pawora.Application.DTOs.Shops;
using Pawora.Application.DTOs.Orders;
using Pawora.Application.DTOs.Reviews;
using Pawora.Application.DTOs.Pets;
using Pawora.Application.DTOs.Users;
using Pawora.Application.DTOs;

namespace Pawora.Application.Mappings;

public class MappingProfile : Profile
{
    public MappingProfile()
    {
        CreateMap<User, UserProfileDto>();
        CreateMap<Category, CategoryDto>();
        
        CreateMap<Shop, ShopDto>();
        CreateMap<CreateShopDto, Shop>();

        CreateMap<Product, ProductDto>()
            .ForMember(dest => dest.ShopName, opt => opt.MapFrom(src => src.Shop.Name))
            .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category.Name));
        CreateMap<CreateProductDto, Product>();

        CreateMap<Order, OrderDto>();
        CreateMap<OrderItem, OrderItemDto>()
            .ForMember(dest => dest.ProductName, opt => opt.MapFrom(src => src.Product.Name))
            .ForMember(dest => dest.ProductImageUrl, opt => opt.MapFrom(src => src.Product.ImageUrl));
        
        CreateMap<Review, ReviewDto>()
            .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.User.FullName))
            .ForMember(dest => dest.UserAvatarUrl, opt => opt.MapFrom(src => src.User.AvatarUrl));
        CreateMap<CreateReviewDto, Review>();

        CreateMap<Pet, PetDto>();
        CreateMap<CreatePetDto, Pet>();

        CreateMap<UserAddress, UserAddressDto>();
        CreateMap<CreateUserAddressDto, UserAddress>();
    }
}
