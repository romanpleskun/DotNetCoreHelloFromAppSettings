ARG REPO=mcr.microsoft.com/dotnet/core/runtime-deps
FROM $REPO:2.2-alpine3.9

# Disable the invariant mode (set in base image)
RUN apk add --no-cache icu-libs
RUN apk add bash
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

# Install .NET Core SDK
ENV DOTNET_SDK_VERSION=2.2.402
WORKDIR = /app
RUN wget -O dotnet.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='e23a41f60afa72005e3f5b251f855a080786535b7647eca3d55a8553ce7b3e4ae499150ed936971972a9fe185fbfa674ed4a8a4041fda5dfc73ddb3405afadcd' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet.tar.gz
     
# Enable correct mode for dotnet watch (only mode supported in a container)
ENV DOTNET_USE_POLLING_FILE_WATCHER=true \ 
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip
RUN dotnet --help
ENV HelloValue="Hi there"
COPY src/DotNetCoreHelloFromAppSettings/bin/Debug/netcoreapp2.0/ /app
#RUN dotnet build src/DotNetCoreHelloFromAppSettings.sln -o /app
#RUN dotnet /app/DotNetCoreHelloFromAppSettings.dll
ENTRYPOINT exec dotnet /app/DotNetCoreHelloFromAppSettings.dll
