#
# Next.js (workspace) container image for Aliyun FC custom-container runtime
#
FROM node:22-slim AS deps
WORKDIR /workspace

# Workspace manifests
COPY package.json package-lock.json ./
COPY apps/web/package.json apps/web/package.json

# Install all workspace deps (includes `apps/web`)
# Root `postinstall` tries to create local env/venv which is not needed for image builds.
# Skip lifecycle scripts to avoid requiring repo-only helper files.
# Explicitly enable workspaces so `apps/web` dependencies (e.g. `next`) are installed.
RUN npm ci --ignore-scripts --workspaces --include-workspace-root

FROM node:22-slim AS builder
WORKDIR /workspace

COPY --from=deps /workspace/node_modules /workspace/node_modules
COPY --from=deps /workspace/package.json /workspace/package.json
COPY --from=deps /workspace/package-lock.json /workspace/package-lock.json

COPY apps/web /workspace/apps/web

# Build Next.js app
RUN npm run -w apps/web build

FROM node:22-slim AS runner
ENV NODE_ENV=production \
    PORT=9000

WORKDIR /workspace/apps/web

# Runtime needs Next build output, public assets, and node_modules (hoisted)
COPY --from=builder /workspace/apps/web/.next /workspace/apps/web/.next
COPY --from=builder /workspace/apps/web/public /workspace/apps/web/public
COPY --from=builder /workspace/apps/web/package.json /workspace/apps/web/package.json
COPY --from=builder /workspace/apps/web/next.config.js /workspace/apps/web/next.config.js
COPY --from=builder /workspace/node_modules /workspace/node_modules

EXPOSE 9000

CMD ["sh", "-c", "node /workspace/node_modules/next/dist/bin/next start -p ${PORT:-9000}"]
