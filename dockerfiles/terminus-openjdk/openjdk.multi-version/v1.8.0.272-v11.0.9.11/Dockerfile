FROM debian:10

RUN \
    apt update && \
    apt install -y --no-install-recommends apt-transport-https ca-certificates wget dirmngr gnupg software-properties-common && \
    wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && \
    add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && \
    apt update

RUN \
    # use apt search & apt-cache policy to find the correct package name and specific version
    apt install -y --no-install-recommends \
      adoptopenjdk-8-hotspot=8u292-b10-3 \
      adoptopenjdk-11-hotspot=11.0.11+9-3 \
      openjfx \
      maven && \

    rm -rf /var/lib/apt/lists/*

# set default java to 8
RUN update-alternatives --set java /usr/lib/jvm/adoptopenjdk-8-hotspot-amd64/bin/java && \
    update-alternatives --set javac /usr/lib/jvm/adoptopenjdk-8-hotspot-amd64/bin/javac
