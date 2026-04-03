# WordPress + Static Site Setup

## Quick Start

```bash
cd projects/wordpress
docker compose up -d
```

- WordPress admin: http://localhost:8080/wp-admin
- Static site preview: http://localhost:8081

## First-Time Setup

Install and activate Simply Static plugin via WP-CLI:

```bash
docker compose run --rm wpcli wp plugin install simply-static --activate
```

Then in WordPress admin:
1. Go to **Simply Static → Settings**
2. Set **Delivery Method** to "Local Directory"
3. Set the **Local Directory** to `/var/www/static`

That's it. Every time you hit **Publish**, the static site auto-regenerates.

## WP-CLI Usage

```bash
# Install a plugin
docker compose run --rm wpcli wp plugin install <slug> --activate

# Export static site manually
docker compose run --rm wpcli wp simply-static run

# Database export
docker compose run --rm wpcli wp db export /var/www/html/backup.sql

# Update all plugins
docker compose run --rm wpcli wp plugin update --all
```

## Environment Variables

Set these in a `.env` file (don't commit it):

```
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_PASSWORD=your_wp_password
```
