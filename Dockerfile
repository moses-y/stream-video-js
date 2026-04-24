FROM node:22-alpine AS packager
RUN corepack enable
WORKDIR /e2e

COPY sample-apps/ sample-apps/
RUN find sample-apps \! -name "package.json" -mindepth 3 -maxdepth 3 -print | xargs rm -rf

COPY packages/ packages/
RUN find packages \! -name "package.json" -mindepth 2 -maxdepth 2 -print | xargs rm -rf

FROM node:22-bullseye AS runner
RUN corepack enable
WORKDIR /e2e

COPY .yarn/ ./.yarn/
COPY pnpm-lock.yaml package.json .yarnrc.yml ./
COPY --from=packager /e2e/packages ./packages
COPY --from=packager /e2e/sample-apps ./sample-apps

RUN pnpm install

RUN pnpm dlx playwright install chromium
RUN pnpm dlx playwright install-deps

# Copy all sources next
COPY ./packages ./packages
RUN yarn build:react:deps

COPY ./sample-apps/ ./sample-apps/
