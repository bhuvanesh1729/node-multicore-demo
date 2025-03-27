#!/bin/bash

# Git Repository Setup Script
# This script helps with setting up Git remotes and pushing code

set -e  # Exit on error

# Display help message
function show_help {
  echo "Git Repository Setup Script"
  echo ""
  echo "Usage: ./git-setup.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -r, --remote NAME    Remote name [default: origin]"
  echo "  -u, --url URL        Remote URL (required)"
  echo "  -b, --branch BRANCH  Branch name [default: main]"
  echo "  -i, --init           Initialize new Git repository"
  echo "  -h, --help           Show this help message"
  echo ""
}

# Default values
REMOTE_NAME="origin"
BRANCH_NAME="main"
REMOTE_URL=""
INIT_REPO=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -r|--remote)
      REMOTE_NAME="$2"
      shift
      shift
      ;;
    -u|--url)
      REMOTE_URL="$2"
      shift
      shift
      ;;
    -b|--branch)
      BRANCH_NAME="$2"
      shift
      shift
      ;;
    -i|--init)
      INIT_REPO=true
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

# Check if URL is provided
if [ -z "$REMOTE_URL" ]; then
  echo "Error: Remote URL is required"
  echo "Use -u or --url to specify the remote URL"
  show_help
  exit 1
fi

# Initialize repository if requested
if [ "$INIT_REPO" = true ]; then
  echo "Initializing Git repository..."
  
  # Check if .git directory already exists
  if [ -d ".git" ]; then
    echo "Git repository already initialized"
  else
    git init
    echo "Git repository initialized"
  fi
  
  # Add all files
  git add .
  
  # Commit changes
  git commit -m "Initial commit"
  echo "Initial commit created"
fi

# Check if remote already exists
if git remote | grep -q "^$REMOTE_NAME$"; then
  echo "Remote '$REMOTE_NAME' already exists. Updating URL..."
  git remote set-url "$REMOTE_NAME" "$REMOTE_URL"
else
  echo "Adding remote '$REMOTE_NAME'..."
  git remote add "$REMOTE_NAME" "$REMOTE_URL"
fi

# Verify remote was added
echo "Remote repositories:"
git remote -v

# Push to remote
echo "Pushing to remote repository..."
git push -u "$REMOTE_NAME" "$BRANCH_NAME"

echo "Git setup completed successfully!"
