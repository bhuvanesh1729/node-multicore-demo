# Deployment Guide for Node Multicore Demo

This document outlines various methods for deploying the Node Multicore Demo application.

## Quick Start (One-Liner Deployment)

### Development Environment
```bash
chmod +x deploy.sh && ./deploy.sh
```

### Production Environment
```bash
chmod +x deploy.sh && ./deploy.sh --env prod
```

### Docker Deployment
```bash
chmod +x deploy.sh && ./deploy.sh --docker
```

### Production Docker Deployment with Custom Port
```bash
chmod +x deploy.sh && ./deploy.sh --env prod --docker --port 8080
```

### Run Application Only (No Deployment)
```bash
chmod +x deploy.sh && ./deploy.sh --run
```

### Expose Application with Localtunnel
```bash
chmod +x deploy.sh && ./deploy.sh --tunnel
```

### Use Nginx as Reverse Proxy
```bash
chmod +x deploy.sh && ./deploy.sh --nginx
```

### Combined Options Example
```bash
chmod +x deploy.sh && ./deploy.sh --env prod --docker --port 8080 --tunnel --nginx
```

Note: The deploy.sh script will automatically install Docker, Docker Compose, Node.js, Localtunnel, and Nginx if they are not already installed on your system.

### Remote Deployment (After pushing to GitHub)

If you've pushed this project to your GitHub repository, you can use these commands to deploy directly from GitHub:

```bash
curl -o- https://raw.githubusercontent.com/bhuvanesh1729/node-multicore-demo/main/deploy.sh | bash
```

```bash
# With options (e.g., for Docker deployment)
curl -o- https://raw.githubusercontent.com/bhuvanesh1729/node-multicore-demo/main/deploy.sh | bash -s -- --docker
```

## Git Repository Setup

### Git Remote Setup Scripts

This project includes several scripts to help with Git repository setup:

#### 1. git-remote-fix.sh (Recommended)

Interactive script with the most features:

```bash
# Make the script executable
chmod +x git-remote-fix.sh

# Show help
./git-remote-fix.sh --help

# Run interactively
./git-remote-fix.sh

# Specify GitHub username
./git-remote-fix.sh --username your-github-username

# Use GitHub CLI to create repository
./git-remote-fix.sh --cli

# Create private repository with GitHub CLI
./git-remote-fix.sh --cli --private
```

#### 2. update-remote.sh

Simple script to update remote URL:

```bash
# Make the script executable
chmod +x update-remote.sh

# Run the script
./update-remote.sh
```

#### 3. fix-remote.sh

Script that uses GitHub CLI to create and push to repository:

```bash
# Make the script executable
chmod +x fix-remote.sh

# Run the script (requires GitHub CLI)
./fix-remote.sh
```

#### 4. git-setup.sh

General Git setup script:

```bash
# Make the script executable
chmod +x git-setup.sh

# Show help
./git-setup.sh --help

# Initialize new repo and add remote
./git-setup.sh --init --url https://github.com/username/node-multicore-demo.git

# Add another remote (e.g., GitLab)
./git-setup.sh --remote gitlab --url https://gitlab.com/username/node-multicore-demo.git

# Push to a specific branch
./git-setup.sh --url https://github.com/username/node-multicore-demo.git --branch develop
```

### Manual Remote Repository Setup

To manually add a remote Git repository and push your code:

```bash
# Add a remote repository
git remote add origin https://github.com/username/node-multicore-demo.git

# Verify remote was added
git remote -v

# Push to the remote repository
git push -u origin main
```

You can also add multiple remote repositories:

```bash
# Add another remote repository (e.g., for GitLab)
git remote add gitlab https://gitlab.com/username/node-multicore-demo.git

# Push to GitLab
git push -u gitlab main
```

### Initial Repository Setup

If you're starting from scratch:

```bash
# Initialize Git repository
git init

# Add all files
git add .

# Commit changes
git commit -m "Initial commit"

# Add remote and push
git remote add origin https://github.com/username/node-multicore-demo.git
git push -u origin main
```

## Quick Start with deploy.sh

For a simplified deployment experience, use the included deployment script:

```bash
# Make the script executable (if not already)
chmod +x deploy.sh

# Show help
./deploy.sh --help

# Deploy with default settings (development mode)
./deploy.sh

# Deploy to production
./deploy.sh --env prod

# Deploy using Docker
./deploy.sh --docker

# Deploy to production on a custom port using Docker
./deploy.sh --env prod --port 8080 --docker

# Run the application without full deployment
./deploy.sh --run

# Run the application in production mode
./deploy.sh --run --env prod

# Expose the application using localtunnel
./deploy.sh --tunnel

# Use nginx as a reverse proxy
./deploy.sh --nginx

# Combined options
./deploy.sh --env prod --docker --tunnel --nginx
```

## Docker Deployment

### Prerequisites
- Docker installed on your system
- Docker Compose installed on your system

### Local Deployment with Docker

1. **Build the Docker image**
   ```bash
   docker-compose build
   ```

2. **Start the application**
   ```bash
   docker-compose up -d
   ```

3. **Check the application status**
   ```bash
   docker-compose ps
   ```

4. **View logs**
   ```bash
   docker-compose logs -f
   ```

5. **Stop the application**
   ```bash
   docker-compose down
   ```

### Production Deployment Considerations

#### Environment Variables
Create a `.env` file in the root directory for environment-specific configurations:
```
NODE_ENV=production
```

#### Scaling
To scale the application (though the app already uses Node.js clustering internally):
```bash
docker-compose up -d --scale app=2
```

#### Resource Limits
The `docker-compose.yml` file includes resource limits. Adjust these based on your server capabilities:
```yaml
deploy:
  resources:
    limits:
      cpus: '0.75'
      memory: 512M
    reservations:
      cpus: '0.25'
      memory: 256M
```

## Kubernetes Deployment

The project includes Kubernetes manifests in the `kubernetes/` directory for deploying to a Kubernetes cluster.

### Prerequisites
- Kubernetes cluster
- kubectl configured to communicate with your cluster
- Docker registry with your application image

### Deployment Steps

1. **Update the image reference**
   
   Edit `kubernetes/deployment.yaml` to replace `${DOCKER_REGISTRY}` with your actual Docker registry URL.

2. **Apply the Kubernetes manifests**
   ```bash
   kubectl apply -f kubernetes/deployment.yaml
   ```

3. **Check deployment status**
   ```bash
   kubectl get deployments
   kubectl get pods
   kubectl get services
   kubectl get ingress
   ```

4. **Access the application**
   
   Update your DNS settings to point `node-multicore-demo.example.com` to your cluster's ingress controller IP address.

## Cloud Deployment Options

### AWS Elastic Beanstalk

1. **Install the EB CLI**
   ```bash
   pip install awsebcli
   ```

2. **Initialize EB application**
   ```bash
   eb init
   ```

3. **Create an environment**
   ```bash
   eb create production-environment
   ```

4. **Deploy the application**
   ```bash
   eb deploy
   ```

### Heroku

1. **Install Heroku CLI**
   ```bash
   npm install -g heroku
   ```

2. **Login to Heroku**
   ```bash
   heroku login
   ```

3. **Create a Heroku app**
   ```bash
   heroku create node-multicore-demo
   ```

4. **Add Heroku Git remote**
   ```bash
   heroku git:remote -a node-multicore-demo
   ```

5. **Deploy to Heroku**
   ```bash
   git push heroku main
   ```

### Digital Ocean App Platform

1. Create a new app on Digital Ocean App Platform
2. Connect your GitHub repository
3. Configure the app settings:
   - Type: Web Service
   - Build Command: `npm install`
   - Run Command: `npm start`
   - HTTP Port: 3000

## CI/CD Integration

### GitHub Actions

Create a `.github/workflows/deploy.yml` file:

```yaml
name: Deploy

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '18'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Run tests
      run: npm test
      
    - name: Deploy to production
      # Add your deployment steps here
      # This could be deploying to AWS, Heroku, etc.
      run: echo "Deployment would happen here"
```

## Monitoring and Maintenance

### Health Checks

The Docker Compose configuration includes health checks. You can also implement external monitoring:

- Use services like UptimeRobot, Pingdom, or New Relic
- Set up alerts for downtime or performance issues

### Logs

For production environments, consider implementing a logging solution:

- ELK Stack (Elasticsearch, Logstash, Kibana)
- Papertrail
- Datadog

### Backups

If your application uses a database, set up regular backups:

- Automated daily backups
- Test restoration procedures regularly

## Troubleshooting

### Common Issues

1. **Port conflicts**
   - Error: "port is already allocated"
   - Solution: Change the port mapping in docker-compose.yml or stop the service using that port

2. **Memory issues**
   - Error: "JavaScript heap out of memory"
   - Solution: Increase memory limits in docker-compose.yml or add NODE_OPTIONS="--max-old-space-size=4096" to environment variables

3. **Container not starting**
   - Check logs: `docker-compose logs app`
   - Verify environment variables and configurations
