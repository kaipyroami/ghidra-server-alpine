FROM openjdk:14-jdk-alpine

RUN apk add --no-cache curl unzip ed bash \
    && curl -fSL https://ghidra-sre.org/ghidra_9.1.2_PUBLIC_20200212.zip -o ghidra.zip \
    && echo 'ebe3fa4e1afd7d97650990b27777bb78bd0427e8e70c1d0ee042aeb52decac61  ghidra.zip' | sha256sum -c \
    && unzip -q ghidra.zip \
    && mv ghidra_9.1.2_PUBLIC ghidra \
    && rm ghidra.zip \
    && apk del --purge curl unzip \
    && rm -rf /tmp/* /var/cache/apk/* \
    && mkdir repos \
    && addgroup -S ghidra \
    && adduser -D -S -G ghidra -h /ghidra -s /bin/bash ghidra \
	&& chown -R ghidra:ghidra /ghidra \
	&& chown root:ghidra /ghidra \
	&& chmod g+w /ghidra \
	&& chown root:ghidra /repos \
	&& chmod g+w /repos \
	&& cd ghidra \
    && sed -i \
    -e 's/^ghidra\.repositories\.dir=.*$/ghidra.repositories.dir=\/repos/g' \
    -e 's/^wrapper\.app\.parameter\.2=/wrapper.app.parameter.4=/g' \
    -e 's/^wrapper\.app\.parameter\.1=-a0$/wrapper.app.parameter.2=-a0/g' server/server.conf \
	&& echo 'wrapper.app.account=ghidra' >> server/server.conf \
	&& echo 'wrapper.app.parameter.3=-u' >> server/server.conf \
	&& echo 'wrapper.app.parameter.1=-ip0.0.0.0' >> server/server.conf


WORKDIR /ghidra


USER ghidra

VOLUME /repos

EXPOSE 13100 13101 13102

CMD ["/bin/bash", "./server/ghidraSvr", "console"]
