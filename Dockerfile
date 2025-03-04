##########################################################################
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 3000
ENV ASPNETCORE_URLS=http://*:3000

##########################################################################
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

COPY src/DotNetTemplate.csproj .
RUN dotnet restore DotNetTemplate.csproj
COPY . .
WORKDIR /src/.
RUN dotnet build "src/DotNetTemplate.csproj" -c Release -o /app/build

##########################################################################
# Publish the application
FROM build AS publish
RUN dotnet publish "src/DotNetTemplate.csproj" -c Release -o /app/publish

##########################################################################
# Set metadata labels
LABEL maintainer="%CUSTOM_PLUGIN_CREATOR_USERNAME%" \
      name="%CUSTOM_PLUGIN_SERVICE_NAME%" \
      description="%CUSTOM_PLUGIN_SERVICE_NAME%" \
      eu.mia-platform.url="https://www.mia-platform.eu" \
      eu.mia-platform.version="0.1.0" \
      eu.mia-platform.language="c#" \
      eu.mia-platform.framework=".NET 7"

##########################################################################
# Final image, with the published output
FROM base AS final
WORKDIR /app

ARG COMMIT_SHA=<not-specified>
RUN echo "%CUSTOM_PLUGIN_SERVICE_NAME%: $COMMIT_SHA" >> ./commit.sha

COPY --from=publish /app/publish .

CMD ["dotnet", "DotNetTemplate.dll"]
