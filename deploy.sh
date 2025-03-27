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
  echo "  -h, --help         Show this help message"
  echo ""
}

# Default values
ENV="dev"
PORT=3000
USE_DOCKER=false

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

echo "Deploying Node Multicore Demo to $ENV environment on port $PORT"

# Create .env file
echo "Creating .env file..."
cat > .env << EOF
NODE_ENV=$ENV
PORT=$PORT
EOF

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
else
  echo "Using direct Node.js deployment..."
  
  # Check if Node.js is installed
  if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install Node.js first."
    exit 1
  fi
  
  # Install dependencies
  echo "Installing dependencies..."
  npm ci
  
  # Start the application
  echo "Starting the application..."
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
  
  echo "Deployment completed successfully!"
  echo "Application is running at http://localhost:$PORT"
fi
