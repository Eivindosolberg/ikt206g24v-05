FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /App

# Kopier og gjenopprett Example.csproj
COPY Example.csproj ./
RUN dotnet restore ./Example.csproj

# Kopier alt annet og bygg
COPY . ./
RUN dotnet publish ./Example.csproj -c Release -o out

# Bygg kjøretidsimage
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /App
COPY --from=build-env /App/out .
ENTRYPOINT ["dotnet", "Example.dll"]
