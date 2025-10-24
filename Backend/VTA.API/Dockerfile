# Use the official .NET 8.0 runtime as base image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

# Use the official .NET 8.0 SDK for building
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ["Backend/VTA.API/VTA.API.csproj", "Backend/VTA.API/"]
RUN dotnet restore "Backend/VTA.API/VTA.API.csproj"

# Copy all source code
COPY . .

# Build the application
WORKDIR "/src/Backend/VTA.API"
RUN dotnet build "VTA.API.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish "VTA.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Create final runtime image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create Assets directory
RUN mkdir -p Assets/Categories Assets/Artefacts Assets/Sounds

ENTRYPOINT ["dotnet", "VTA.API.dll"]