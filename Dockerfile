FROM alpine/git AS base

ARG TAG=latest
RUN git clone https://github.com/imputnet/cobalt.git && \
    cd cobalt && \
    ([[ "$TAG" = "latest" ]] || git checkout ${TAG}) && \
    # rm -rf .git && \
    sed -i 's/const apiURL/let apiURL/' web/src/lib/env.ts && \
    PATCH="\
        try {\n\
            const request = new XMLHttpRequest();\n\
            request.open('GET', '/api-url.txt', false);\n\
            request.send();\n\
            if (request.status === 200) { apiURL = request.responseText; }\n\
        } catch (e) { console.error(e); }\n\
        " && \
    sed -i "/let apiURL/a$PATCH" web/src/lib/env.ts

FROM node:alpine AS build

WORKDIR /cobalt
COPY --from=base /git/cobalt .
RUN npm install -g pnpm && \
    pnpm install && \
    cd web && \
    export NODE_ENV=production && \
    pnpm build

FROM lipanski/docker-static-website

COPY --from=build /cobalt/web/build .
