FROM node:18-alpine AS build

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Build app
COPY . .
RUN npm run build

# --- Serve with Nginx ---
FROM nginx:1.25-alpine

COPY --from=build /app/build /usr/share/nginx/html

# Default Nginx config is fine for a SPA; adjust if you need history API fallback
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
