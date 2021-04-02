FROM node:14-alpine

LABEL author="Gustavo Arantes" maintainer="me@arantes.dev"

RUN apk add --no-cache \
  ca-certificates \
  krb5-libs \
  libgcc \
  libintl \
  libssl1.1 \
  libstdc++ \
  zlib

ENV \
  # Configure web servers to bind to port 80 when present
  ASPNETCORE_URLS=http://+:80 \
  # Enable detection of running in a container
  DOTNET_RUNNING_IN_CONTAINER=true \
  # Set the invariant mode since icu_libs isn't included (see https://github.com/dotnet/announcements/issues/20)
  DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true

RUN dotnet_version=3.1.13 \
  && wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Runtime/$dotnet_version/dotnet-runtime-$dotnet_version-linux-musl-x64.tar.gz \
  && dotnet_sha512='40f23e81ca8fa8bcb657e480a475650b2e3c59daad702e2cce0ee8daba18e9703f03bb02a28bd9ae548410b0f503ebdaa6de1079b417798f965217fc0ee94cd0' \
  && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
  && mkdir -p /usr/share/dotnet \
  && tar -C /usr/share/dotnet -oxzf dotnet.tar.gz \
  && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
  && rm dotnet.tar.gz

RUN apk add --no-cache --update libc6-compat ffmpeg \
  && adduser -D -h /home/container container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/ash", "/entrypoint.sh"]