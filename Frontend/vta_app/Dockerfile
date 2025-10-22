# Build stage
FROM ghcr.io/cirruslabs/flutter:3.24.3 AS build

# Create a new non-root user and group
RUN groupadd -r appuser && useradd -r -g appuser -ms /bin/bash appuser

# Give the new user ownership of the Flutter SDK
RUN chown -R appuser:appuser /sdks/flutter

# Set the working directory
WORKDIR /app

RUN chown appuser:appuser /app
# 1. Copy pubspec files and set permissions
COPY --chown=appuser:appuser pubspec.yaml pubspec.lock ./

# 2. Switch to the non-root user
USER appuser

# 3. Run flutter doctor and get dependencies
RUN flutter doctor
RUN flutter pub get

# 4. Now, copy the rest of your application code
COPY --chown=appuser:appuser . .

# 5. Build the web app
RUN flutter build web --profile --no-tree-shake-icons

# --- End of build stage ---


# Runtime stage - use nginx to serve the Flutter web app
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Remove default nginx static assets
RUN rm -rf ./*

# Copy built Flutter web app
# This will now correctly copy the --debug build
COPY --from=build /app/build/web .

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Set environment variable to indicate Docker mode
ENV DOCKER_MODE=true

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]