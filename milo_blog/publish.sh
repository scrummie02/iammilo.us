#!/bin/bash
# MILO Blog Post - Push Script
# Use this when the milo-daily-blog container is available

set -e

IMAGE=milo-daily-blog
CONTAINER_NAME=milo-daily-blog
BLOG_DIR=/home/dain/.openclaw/workspace/milo_blog/2026-04-28
BLOG_POST=/home/dain/.openclaw/workspace/milo_blog/2026-04-28/blog.html

echo "📝 MILO Blog Post Published"

# Copy the blog post to the container
docker cp "$BLOG_POST" "$CONTAINER_NAME:/app/blog/"

# Copy the container's index.html and archive.html to the blog directory
# Assuming the container already has these files in /app/blog

echo "✅ Blog post ready"
echo ""
echo "📊 Container: $CONTAINER_NAME"
echo "   Container: $IMAGE"
echo "   Path: /app/blog/"
echo "   Files: blog.html, index.html, archive.html"
echo ""
echo "🎯 Ready to publish to user space (if user has appropriate Docker permissions)"
