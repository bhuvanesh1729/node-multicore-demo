#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Node.js Multicore Demo Project${NC}"

# Create project directory if it doesn't exist
if [ ! -d "node-multicore-demo" ]; then
    echo -e "${GREEN}Creating project directory...${NC}"
    mkdir node-multicore-demo
fi

cd node-multicore-demo

# Initialize npm project if package.json doesn't exist
if [ ! -f "package.json" ]; then
    echo -e "${GREEN}Initializing npm project...${NC}"
    npm init -y
fi

# Install dependencies
echo -e "${GREEN}Installing dependencies...${NC}"
npm install express localtunnel n8n

# Create server.js
echo -e "${GREEN}Creating server.js...${NC}"
cat > server.js << 'EOL'
const express = require('express');
const cluster = require('cluster');
const os = require('os');

const numCPUs = os.cpus().length;

if (cluster.isMaster) {
    console.log(`Master process ${process.pid} is running`);

    // Fork workers
    for (let i = 0; i < numCPUs; i++) {
        cluster.fork();
    }

    cluster.on('exit', (worker, code, signal) => {
        console.log(`Worker ${worker.process.pid} died`);
    });
} else {
    const app = express();
    const port = 3000;

    app.get('/', (req, res) => {
        res.send(`Hello from worker ${process.pid}`);
    });

    app.listen(port, () => {
        console.log(`Worker ${process.pid} listening at http://localhost:${port}`);
    });
}
EOL

# Update package.json scripts
echo -e "${GREEN}Updating package.json scripts...${NC}"
cat > package.json << 'EOL'
{
  "name": "node-multicore-demo",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "tunnel": "lt --port 3000",
    "n8n-local": "n8n start",
    "n8n-tunnel": "n8n start --tunnel",
    "all": "npm start & npm run tunnel & npm run n8n-local"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.17.1",
    "localtunnel": "^2.0.2",
    "n8n": "^0.225.0"
  }
}
EOL

# Create Nginx configuration
echo -e "${GREEN}Creating Nginx configuration...${NC}"
cat > nginx.conf << 'EOL'
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOL

# Make the script executable
chmod +x setup.sh

echo -e "${BLUE}Setup complete! Here's how to use the application:${NC}"
echo -e "${GREEN}1. Start the application: npm start${NC}"
echo -e "${GREEN}2. Start localtunnel: npm run tunnel${NC}"
echo -e "${GREEN}3. Start n8n locally: npm run n8n-local${NC}"
echo -e "${GREEN}4. Start n8n with tunnel: npm run n8n-tunnel${NC}"
echo -e "${GREEN}5. Start everything: npm run all${NC}"
