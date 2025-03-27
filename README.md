# Node.js Multicore Demo with n8n Integration

This project demonstrates a Node.js application using multicore processing, localtunnel for external access, and n8n integration.

## Quick Start

1. Run the setup script:
```bash
./setup.sh
```

This script will:
- Install all required dependencies
- Create the Express.js server with multicore support
- Set up npm scripts for various operations
- Create Nginx configuration (optional)

## Available Commands

After running the setup script, you can use these npm commands:

- `npm start` - Start the multicore Node.js application
- `npm run tunnel` - Create a public URL using localtunnel
- `npm run n8n-local` - Start n8n locally
- `npm run n8n-tunnel` - Start n8n with tunnel access
- `npm run all` - Start everything (Node.js app, tunnel, and n8n)

## Accessing the Applications

1. Local Access:
   - Node.js app: http://localhost:3000
   - n8n: http://localhost:5678

2. Remote Access:
   - The localtunnel URLs will be displayed when you run the respective commands
   - Node.js app tunnel: Run `npm run tunnel`
   - n8n tunnel: Run `npm run n8n-tunnel`

## Nginx Setup (Optional)

An Nginx configuration file is provided in `nginx.conf`. To use it:

1. Copy the configuration to your Nginx sites directory:
```bash
sudo cp nginx.conf /etc/nginx/sites-available/node-multicore
```

2. Create a symbolic link:
```bash
sudo ln -s /etc/nginx/sites-available/node-multicore /etc/nginx/sites-enabled/
```

3. Test and restart Nginx:
```bash
sudo nginx -t
sudo systemctl restart nginx
```

## Features

- Multicore processing using Node.js cluster module
- External access via localtunnel
- n8n workflow automation integration
- Optional Nginx reverse proxy configuration
- Automated setup script
