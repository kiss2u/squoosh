FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Copy all project files
COPY . .

# Install dependencies
RUN npm ci

# Build application (generates intermediate files first, then move-output.js processes them)
RUN npm run build

# After npm run build, move-output.js should have renamed .tmp/build/static to build/
# But since the build script includes move-output.js, the final artifacts should be in the correct place.
# Looking more carefully at the move script, it moves .tmp/build/static to 'build' directory in root.
# Let's ensure the 'build' directory exists and copy from there.

FROM nginx:alpine

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built assets from builder stage
# After the full build process (rollup + move-output.js), assets are in 'build' directory
COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]