FROM node:22-alpine

ENV NODE_OPTIONS=--dns-result-order=ipv4first

WORKDIR /server

RUN npm install pnpm@10.11.1 -g

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./
COPY apps/backend/package.json ./apps/backend/
COPY apps/storefront/package.json ./apps/storefront/

RUN --mount=type=cache,id=pnpm-store,target=/pnpm-store \
    for i in 1 2 3 4 5 6 7 8 9 10; do \
      pnpm install --frozen-lockfile --store-dir /pnpm-store \
        --network-concurrency=4 --fetch-retries=5 --fetch-timeout=120000 && exit 0; \
      echo "attempt $i failed, retrying in 10s"; sleep 10; \
    done; exit 1

COPY . .

EXPOSE 9000 5173 8000

ENTRYPOINT ["./start.sh"]
