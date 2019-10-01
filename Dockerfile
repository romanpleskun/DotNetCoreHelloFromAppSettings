ARG REPO=mcr.microsoft.com/dotnet/core/runtime-deps
FROM $REPO:2.2-alpine3.9

# Disable the invariant mode (set in base image)
RUN apk add --no-cache icu-libs
RUN apk add bash
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

# Install .NET Core SDK
#ENV DOTNET_SDK_VERSION=2.2.402
WORKDIR = /app
RUN mkdir tmp/
COPY /home/RoMkO/Downloads/dotnet-sdk-2.2.402-linux-musl-x64.tar.gz tmp/dotnet.tar.gz
RUN cd tmp /
     && mkdir -p /usr/share/dotnet \
     && tar -C /usr/share/dotnet -xzf dotnet.tar.gz \
     && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
     && rm dotnet.tar.gz 
     
# Enable correct mode for dotnet watch (only mode supported in a container)
ENV DOTNET_USE_POLLING_FILE_WATCHER=true \ 
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip

# Trigger first run experience by running arbitrary cmd to populate local package cache
RUN dotnet --version
COPY /home/RoMkO/Downloads/TeamCity/buildAgent/work/1022b5db3d4c342c/src/DotNetCoreHelloFromAppSettings/bin/Debug/netcoreapp2.0/DotNetCoreHelloFromAppSettings.dll /app/
RUN dotnet DotNetCoreHelloFromAppSettings.dll
