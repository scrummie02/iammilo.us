FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl \
    git \
    nodejs \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Working directory
WORKDIR /app

# Install nginx
RUN apt-get update && apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/* && \
    a2enctl config nginx && a2enctl restart nginx

# Create blog directory
RUN mkdir -p /app/blog && chown -R www-data:www-data /app/blog

COPY index.html /app/blog/index.html
COPY archive.html /app/blog/archive.html

RUN nginx -s stop && nginx -g "events { worker_connections 1024; } http { listen 80; server_name blog.milo.blog; location / { root /app/blog; index index.html archive.html; } }" && \
    nginx -s reload && \
    nginx -s stop

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
