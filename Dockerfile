FROM node:17-alpine AS builder

LABEL MAINTAINER="Noel <cutie@floofy.dev>"
RUN apk update && apk add git ca-certificates

WORKDIR /build/{{app}}
COPY . .
RUN yarn global add typescript eslint
RUN yarn

# https://github.com/webpack/webpack/issues/14532
RUN NEXT_TELEMETRY_DISABLED=1 NODE_OPTIONS=--openssl-legacy-provider NODE_ENV=production yarn build
RUN rm -rf src

FROM node:17-alpine

LABEL MAINTAINER="Noel <cutie@floofy.dev>"

WORKDIR /app/{{ name }}
COPY --from=builder /build/{{app}}/node_modules .
COPY --from=builder /build/{{app}}/.next .
COPY --from=builder /build/{{app}}/package.json .
COPY --from=builder /build/{{app}}/yarn.lock .

USER 1001
ENTRYPOINT [ "yarn", "start" ]
