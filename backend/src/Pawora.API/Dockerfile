FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

COPY src/Pawora.Core/Pawora.Core.csproj src/Pawora.Core/
COPY src/Pawora.Application/Pawora.Application.csproj src/Pawora.Application/
COPY src/Pawora.DataAccess/Pawora.DataAccess.csproj src/Pawora.DataAccess/
COPY src/Pawora.API/Pawora.API.csproj src/Pawora.API/
RUN dotnet restore src/Pawora.API/Pawora.API.csproj

COPY src/Pawora.Core/ src/Pawora.Core/
COPY src/Pawora.Application/ src/Pawora.Application/
COPY src/Pawora.DataAccess/ src/Pawora.DataAccess/
COPY src/Pawora.API/ src/Pawora.API/
RUN dotnet publish src/Pawora.API/Pawora.API.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Pawora.API.dll"]
