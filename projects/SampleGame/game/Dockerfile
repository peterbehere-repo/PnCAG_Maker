FROM lscr.io/linuxserver/webtop:ubuntu-xfce

ARG GODOT_VERSION=4.6-stable
ARG POPOCHIU_REVISION=784d1474ef5fe79285a9da69d550504692a3f7e3

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl unzip \
    && curl --fail --location --retry 3 \
        "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip" \
        --output /tmp/godot.zip \
    && unzip -q /tmp/godot.zip -d /usr/local/bin \
    && mv "/usr/local/bin/Godot_v${GODOT_VERSION}_linux.x86_64" /usr/local/bin/godot \
    && chmod +x /usr/local/bin/godot \
    && curl --fail --location --retry 3 \
        "https://github.com/carenalgas/popochiu/archive/${POPOCHIU_REVISION}.zip" \
        --output /tmp/popochiu.zip \
    && unzip -q /tmp/popochiu.zip -d /tmp \
    && mkdir -p /opt/popochiu/addons \
    && cp -a "/tmp/popochiu-${POPOCHIU_REVISION}/addons/popochiu" /opt/popochiu/addons/ \
    && rm -rf /var/lib/apt/lists/* /tmp/godot.zip /tmp/popochiu.zip \
        "/tmp/popochiu-${POPOCHIU_REVISION}"

WORKDIR /workspace