# syntax=docker/dockerfile:1

FROM node:16-slim as base
RUN corepack enable
USER node
RUN corepack prepare pnpm@7.6.0 --activate
WORKDIR /app

FROM base as builder
COPY --chown=node pnpm-workspace.yaml pnpm-lock.yaml ./
RUN pnpm fetch
COPY --chown=node . .
RUN pnpm install --offline --frozen-lockfile && pnpm --filter test build

# This fails because the node user has no permissions on the /pruned directory.
FROM builder as assets
RUN pnpm --filter test deploy pruned

FROM base as release
COPY --chown=node --from=assets /app/pruned ./
ENV NODE_ENV production
CMD ["node", "bin/index.js"]

# When creating /pruned directory the build works.
FROM builder as assets-fixed
USER root
RUN mkdir -p /pruned && chown -R node /pruned
USER node
RUN pnpm --filter test deploy pruned

FROM base as release-fixed
COPY --chown=node --from=assets-fixed /app/pruned ./
ENV NODE_ENV production
CMD ["node", "bin/index.js"]
