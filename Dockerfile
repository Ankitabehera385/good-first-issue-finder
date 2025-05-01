# Stage 1: Dependencies and Build
FROM node:16-alpine AS builder

WORKDIR /usr/src/app

# Copy only package files first for layer caching
COPY package*.json ./

# Install all dependencies for building
RUN npm ci --ignore-scripts

# Copy source files
COPY . .

# Build the app (e.g., compiles TypeScript, bundles frontend)
RUN npm run build

# Stage 2: Production Image
FROM node:16-alpine AS production

WORKDIR /usr/src/app

# Copy only package files and install production deps
COPY package*.json ./

RUN npm ci --only=production --ignore-scripts

# Copy built output from builder
COPY --from=builder /usr/src/app/build ./build

# Optional: Copy runtime files (e.g., config files, server script)
# Avoid full COPY . . to reduce image size
COPY server.js ./  # or index.js or main.js (as per your app)

# Expose the app port
EXPOSE 3000

# Start the server
CMD ["npm", "run", "run:server"]
