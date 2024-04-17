# SDK image to build the project
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /app

# Copy the .csproj file and restore any dependencies (via nuget)
COPY ["Example.csproj", "./"]
RUN dotnet restore "Example.csproj"

# Copy the project files and build for release
COPY . .
RUN dotnet publish "Example.csproj" -c Release -o out

# SDK image for migrations
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS migration-env
WORKDIR /app

# Install EF Core CLI tools
RUN dotnet tool install --global dotnet-ef
ENV PATH="${PATH}:/root/.dotnet/tools"

COPY --from=build-env /app/out .
COPY --from=build-env /app/Example.csproj .

# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build-env /app/out .

ENTRYPOINT ["db:5432", "--", "dotnet", "Example.dll" ]