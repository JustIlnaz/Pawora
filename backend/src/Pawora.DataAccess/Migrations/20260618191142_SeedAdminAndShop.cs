using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Pawora.DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class SeedAdminAndShop : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                column: "CreatedAt",
                value: new DateTime(2026, 6, 18, 19, 11, 41, 624, DateTimeKind.Utc).AddTicks(5757));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                column: "CreatedAt",
                value: new DateTime(2026, 6, 18, 19, 11, 41, 624, DateTimeKind.Utc).AddTicks(5760));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "CreatedAt",
                value: new DateTime(2026, 6, 18, 19, 11, 41, 624, DateTimeKind.Utc).AddTicks(5762));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                column: "CreatedAt",
                value: new DateTime(2026, 6, 18, 19, 11, 41, 624, DateTimeKind.Utc).AddTicks(5765));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                column: "CreatedAt",
                value: new DateTime(2026, 6, 18, 19, 11, 41, 624, DateTimeKind.Utc).AddTicks(5775));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("66666666-6666-6666-6666-666666666666"),
                column: "CreatedAt",
                value: new DateTime(2026, 6, 18, 19, 11, 41, 624, DateTimeKind.Utc).AddTicks(5777));

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "AvatarUrl", "CreatedAt", "Email", "FullName", "PasswordHash", "Phone", "Role" },
                values: new object[] { new Guid("99999999-9999-9999-9999-999999999999"), null, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "admin@pawora.com", "Администратор Pawora", "$2a$11$Hlhg/XFasR1Zf.GvC1tWbeV3w9D661dYm2G6mR0a/tU.9d.aDkW2q", null, 2 });

            migrationBuilder.InsertData(
                table: "Shops",
                columns: new[] { "Id", "Address", "CreatedAt", "Description", "ImageUrl", "Latitude", "Longitude", "Name", "OwnerId", "Phone", "Rating" },
                values: new object[] { new Guid("88888888-8888-8888-8888-888888888888"), "ул. Пушкина, д. 10", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Премиальный магазин товаров для домашних животных", null, 55.755800000000001, 37.6173, "Зоомагазин PAWORA", new Guid("99999999-9999-9999-9999-999999999999"), "+7 (999) 123-45-67", 4.7999999999999998 });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Shops",
                keyColumn: "Id",
                keyValue: new Guid("88888888-8888-8888-8888-888888888888"));

            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: new Guid("99999999-9999-9999-9999-999999999999"));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                column: "CreatedAt",
                value: new DateTime(2026, 6, 18, 16, 15, 17, 195, DateTimeKind.Utc).AddTicks(2290));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                column: "CreatedAt",
                value: new DateTime(2026, 6, 18, 16, 15, 17, 195, DateTimeKind.Utc).AddTicks(3044));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "CreatedAt",
                value: new DateTime(2026, 6, 18, 16, 15, 17, 195, DateTimeKind.Utc).AddTicks(3050));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                column: "CreatedAt",
                value: new DateTime(2026, 6, 18, 16, 15, 17, 195, DateTimeKind.Utc).AddTicks(3060));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("55555555-5555-5555-5555-555555555555"),
                column: "CreatedAt",
                value: new DateTime(2026, 6, 18, 16, 15, 17, 195, DateTimeKind.Utc).AddTicks(3062));

            migrationBuilder.UpdateData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("66666666-6666-6666-6666-666666666666"),
                column: "CreatedAt",
                value: new DateTime(2026, 6, 18, 16, 15, 17, 195, DateTimeKind.Utc).AddTicks(3072));
        }
    }
}
