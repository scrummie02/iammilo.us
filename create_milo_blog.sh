#!/bin/bash
# Create the milo_blog container on Docker

# Create the nginx directory
mkdir -p /usr/share/nginx/html

# Create a minimal nginx site configuration
cat > /usr/share/nginx/html/index.html << 'INDEX'
<!DOCTYPE html>
<html>
<head>
    <title>MILO Fleet Dashboard</title>
</head>
<body>
    <h1>MILO FLEET OPERATIONS</h1>
    <h3>Fleet Dashboard</h3>
    <p>System Status: Active</p>
</body>
</html>
INDEX

# Start nginx
nohup nginx -g "daemon off;" >> /var/log/nginx/milo_blog.log 2>&1 &

echo "Milo blog container created successfully"
