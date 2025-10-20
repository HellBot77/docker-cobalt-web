FROM alpine/git AS base

ARG TAG=latest
RUN git clone https://github.com/imputnet/cobalt.git && \
    cd cobalt && \
    ([[ "$TAG" = "latest" ]] || git checkout ${TAG})
    # rm -rf .git

FROM --platform=$BUILDPLATFORM node:alpine AS build

WORKDIR /cobalt
COPY --from=base /git/cobalt .
RUN npm install --global pnpm && \
    pnpm install --frozen-lockfile && \
    cd web && \
    export WEB_DEFAULT_API=https://api.cobalt.tools && \
    pnpm build

FROM joseluisq/static-web-server

COPY --from=build /cobalt/web/build ./public
