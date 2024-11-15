FROM alpine/git AS base

ARG TAG=latest
RUN git clone https://github.com/imputnet/cobalt.git && \
    cd cobalt && \
    ([[ "$TAG" = "latest" ]] || git checkout ${TAG})
    # rm -rf .git

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
