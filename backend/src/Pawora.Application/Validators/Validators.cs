using FluentValidation;
using Pawora.Application.DTOs.Auth;
using Pawora.Application.DTOs.Products;
using Pawora.Application.DTOs.Shops;
using Pawora.Application.DTOs.Orders;
using Pawora.Application.DTOs.Pets;
using Pawora.Application.DTOs.Reviews;

namespace Pawora.Application.Validators;

public class RegisterDtoValidator : AbstractValidator<RegisterDto>
{
    public RegisterDtoValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Электронная почта обязательна для заполнения.")
            .EmailAddress().WithMessage("Неверный формат адреса электронной почты.");
        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Пароль обязателен для заполнения.")
            .MinimumLength(6).WithMessage("Пароль должен содержать не менее 6 символов.");
        RuleFor(x => x.FullName)
            .NotEmpty().WithMessage("Имя и фамилия обязательны для заполнения.")
            .MaximumLength(100).WithMessage("Имя и фамилия не должны превышать 100 символов.");
    }
}

public class LoginDtoValidator : AbstractValidator<LoginDto>
{
    public LoginDtoValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Электронная почта обязательна для заполнения.")
            .EmailAddress().WithMessage("Неверный формат адреса электронной почты.");
        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Пароль обязателен для заполнения.");
    }
}

public class CreateShopDtoValidator : AbstractValidator<CreateShopDto>
{
    public CreateShopDtoValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Address).NotEmpty().MaximumLength(200);
        RuleFor(x => x.Latitude).InclusiveBetween(-90, 90);
        RuleFor(x => x.Longitude).InclusiveBetween(-180, 180);
    }
}

public class CreateProductDtoValidator : AbstractValidator<CreateProductDto>
{
    public CreateProductDtoValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Price).GreaterThan(0);
        RuleFor(x => x.Stock).GreaterThanOrEqualTo(0);
        RuleFor(x => x.ShopId).NotEmpty();
        RuleFor(x => x.CategoryId).NotEmpty();
    }
}

public class CreateOrderDtoValidator : AbstractValidator<CreateOrderDto>
{
    public CreateOrderDtoValidator()
    {
        RuleFor(x => x.Items).NotEmpty();
        RuleForEach(x => x.Items).ChildRules(items =>
        {
            items.RuleFor(i => i.ProductId).NotEmpty();
            items.RuleFor(i => i.Quantity).GreaterThan(0);
        });
    }
}

public class CreateReviewDtoValidator : AbstractValidator<CreateReviewDto>
{
    public CreateReviewDtoValidator()
    {
        RuleFor(x => x.Rating).InclusiveBetween(1, 5);
        RuleFor(x => x.Comment).MaximumLength(500);
    }
}

public class CreatePetDtoValidator : AbstractValidator<CreatePetDto>
{
    public CreatePetDtoValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Species).NotEmpty().MaximumLength(50);
    }
}
