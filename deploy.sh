#!/bin/bash

# Node Multicore Demo Deployment Script
# This script helps with manual deployment of the application

set -e  # Exit on error

# Display help message
function show_help {
  echo "Node Multicore Demo Deployment Script"
  echo ""
  echo "Usage: ./deploy.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -e, --env ENV      Set environment (dev, staging, prod) [default: dev]"
  echo "  -p, --port PORT    Set port number [default: 3000]"
  echo "  -d, --docker       Use Docker for deployment"
  echo "  -r, --run          Run the application without full deployment"
  echo "  -n, --nginx        Use nginx as reverse proxy"
  echo "  -h, --help         Show this help message"
  echo ""
}

# Default values
ENV="dev"
PORT=3000
USE_DOCKER=false
RUN_ONLY=false
USE_NGINX=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -e|--env)
      ENV="$2"
      shift
      shift
      ;;
    -p|--port)
      PORT="$2"
      shift
      shift
      ;;
    -d|--docker)
      USE_DOCKER=true
      shift
      ;;
    -r|--run)
      RUN_ONLY=true
      shift
      ;;
    -n|--nginx)
      USE_NGINX=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

if [ "$RUN_ONLY" = true ]; then
  echo "Running Node Multicore Demo in $ENV environment on port $PORT"
else
  echo "Deploying Node Multicore Demo to $ENV environment on port $PORT"
fi

# Create .env file
echo "Creating .env file..."
cat > .env << EOF
NODE_ENV=$ENV
PORT=$PORT
EOF

# Function to install localtunnel
function install_localtunnel {
  if ! command -v lt &> /dev/null; then
    echo "Localtunnel is not installed. Installing localtunnel..."
    npm install -g localtunnel
    echo "Localtunnel has been installed successfully."
  fi
}

# Function to configure and start nginx
function configure_nginx {
  echo "Configuring nginx..."
  
  # Check if nginx is installed
  if ! command -v nginx &> /dev/null; then
    echo "Nginx is not installed. Installing nginx..."
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      # Linux installation
      sudo apt-get update
      sudo apt-get install -y nginx
      sudo systemctl enable nginx
      sudo systemctl start nginx
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS installation
      if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew first..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      brew install nginx
      brew services start nginx
    else
      echo "Unsupported OS for automatic nginx installation."
      echo "Please install nginx manually."
      return 1
    fi
  fi
  
  # Update nginx configuration
  echo "Updating nginx configuration..."
  NGINX_CONF="server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}"

  # Detect OS and set nginx config path
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    echo "$NGINX_CONF" | sudo tee /etc/nginx/sites-available/node-multicore-demo > /dev/null
    sudo ln -sf /etc/nginx/sites-available/node-multicore-demo /etc/nginx/sites-enabled/
    sudo nginx -t && sudo systemctl reload nginx
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    NGINX_PATH=$(brew --prefix)/etc/nginx
    echo "$NGINX_CONF" > "$NGINX_PATH/servers/node-multicore-demo.conf"
    brew services restart nginx
  else
    echo "Unsupported OS for nginx configuration."
    return 1
  fi
  
  echo "Nginx configured successfully."
}

# Function to start localtunnel
function start_localtunnel {
  echo "Starting localtunnel to expose port $PORT..."
  install_localtunnel
  
  # Start localtunnel in background and capture URL
  lt --port $PORT > .lt_output 2>&1 &
  LT_PID=$!
  
  # Wait for localtunnel to start and extract URL
  sleep 3
  if [ -f .lt_output ]; then
    LT_URL=$(grep -o 'https://[^ ]*' .lt_output | head -1)
    if [ -n "$LT_URL" ]; then
      echo "🌐 Your application is publicly available at: $LT_URL"
      echo "LT_URL=$LT_URL" >> .env
    else
      echo "Failed to extract localtunnel URL. Check .lt_output for details."
    fi
  else
    echo "Failed to start localtunnel."
  fi
}

# Function to run the npm project
function run_npm_project {
  # Check if Node.js is installed
  if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Installing Node.js..."
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      # Linux installation
      echo "Detected Linux OS. Installing Node.js..."
      curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
      sudo apt-get install -y nodejs
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS installation
      echo "Detected macOS. Installing Node.js using Homebrew..."
      if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew first..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      brew install node
    else
      echo "Unsupported OS for automatic Node.js installation."
      echo "Please install Node.js manually from https://nodejs.org/"
      exit 1
    fi
  fi
  
  # Install dependencies
  echo "Installing dependencies..."
  npm install
  
  # Start the application
  echo "Starting the application..."
  echo "Application is running at http://localhost:$PORT"
  
  # Always start localtunnel before starting the server
  start_localtunnel
  
  if [ "$ENV" = "prod" ]; then
    # Use PM2 for production if available
    if command -v pm2 &> /dev/null; then
      echo "Using PM2 for production deployment..."
      pm2 start server.js --name "node-multicore-demo" -i max
    else
      echo "PM2 not found. Using standard Node.js..."
      nohup node server.js > app.log 2>&1 &
    fi
  else
    # For development, start with nodemon if available
    if command -v nodemon &> /dev/null; then
      echo "Using Nodemon for development..."
      nodemon server.js
    else
      echo "Nodemon not found. Using standard Node.js..."
      node server.js
    fi
  fi
}

# Configure nginx if requested
if [ "$USE_NGINX" = true ]; then
  configure_nginx
fi

# Run only mode - just start the application
if [ "$RUN_ONLY" = true ]; then
  run_npm_project
  exit 0
fi

# Full deployment mode
if [ "$USE_DOCKER" = true ]; then
  echo "Using Docker for deployment..."
  
  # Check if Docker is installed, install if not
  if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      # Linux installation
      echo "Detected Linux OS. Installing Docker..."
      sudo apt-get update
      sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io
      sudo systemctl enable docker
      sudo systemctl start docker
      sudo usermod -aG docker $USER
      echo "Docker has been installed successfully."
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS installation
      echo "Detected macOS. Installing Docker using Homebrew..."
      if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew first..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      brew install --cask docker
      echo "Docker has been installed. Please start Docker Desktop application."
      open -a Docker
      # Wait for Docker to start
      echo "Waiting for Docker to start..."
      while ! docker info &>/dev/null; do
        echo -n "."
        sleep 2
      done
      echo "Docker is now running."
    else
      echo "Unsupported OS for automatic Docker installation."
      echo "Please install Docker manually from https://docs.docker.com/get-docker/"
      exit 1
    fi
  fi
  
  # Check if Docker Compose is installed, install if not
  if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      # Linux installation
      sudo curl -L "https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose
      echo "Docker Compose has been installed successfully."
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS - Docker Compose is included with Docker Desktop
      echo "Docker Compose is included with Docker Desktop on macOS."
    else
      echo "Unsupported OS for automatic Docker Compose installation."
      echo "Please install Docker Compose manually from https://docs.docker.com/compose/install/"
      exit 1
    fi
  fi
  
  # Build and start Docker containers
  echo "Building and starting Docker containers..."
  docker-compose build
  docker-compose up -d
  
  echo "Deployment completed successfully!"
  echo "Application is running at http://localhost:$PORT"
  
  # Start localtunnel before running the application
  start_localtunnel
else
  echo "Using direct Node.js deployment..."
  echo "Deployment completed successfully!"
  run_npm_project
fi
