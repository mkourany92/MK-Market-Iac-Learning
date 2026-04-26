# ── Stage 1: install dependencies ──────────────────────────────────────────
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev

# ── Stage 2: production image ───────────────────────────────────────────────
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 8080
USER node
CMD ["node", "server.js"]