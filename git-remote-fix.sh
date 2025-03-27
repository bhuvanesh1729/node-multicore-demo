#!/bin/bash

# Interactive Git Remote Fix Script
# This script helps fix Git remote issues and push to GitHub

set -e  # Exit on error

# Display help message
function show_help {
  echo "Git Remote Fix Script"
  echo ""
  echo "Usage: ./git-remote-fix.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -u, --username USERNAME   GitHub username"
  echo "  -r, --repo REPO           Repository name (defaults to current directory name)"
  echo "  -p, --private             Create private repository (when using GitHub CLI)"
  echo "  -c, --cli                 Use GitHub CLI if available"
  echo "  -h, --help                Show this help message"
  echo ""
}

# Default values
GITHUB_USERNAME=""
REPO_NAME=$(basename "$(pwd)")
USE_GH_CLI=false
PRIVATE_REPO=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -u|--username)
      GITHUB_USERNAME="$2"
      shift
      shift
      ;;
    -r|--repo)
      REPO_NAME="$2"
      shift
      shift
      ;;
    -p|--private)
      PRIVATE_REPO=true
      shift
      ;;
    -c|--cli)
      USE_GH_CLI=true
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

echo "===== Git Remote Fix ====="
echo "Repository name: $REPO_NAME"

# Try to get GitHub username if not provided
if [ -z "$GITHUB_USERNAME" ]; then
  # Try to extract from git config
  GITHUB_USERNAME=$(git config --get user.email | sed 's/@.*//')
  
  if [ -z "$GITHUB_USERNAME" ]; then
    GITHUB_USERNAME=$(git config --get github.user)
  fi
  
  if [ -z "$GITHUB_USERNAME" ]; then
    echo "Enter your GitHub username:"
    read -r GITHUB_USERNAME
    
    if [ -z "$GITHUB_USERNAME" ]; then
      echo "Error: GitHub username is required"
      exit 1
    fi
  else
    echo "Using GitHub username: $GITHUB_USERNAME"
    echo "Is this correct? (y/n)"
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy] ]]; then
      echo "Enter your GitHub username:"
      read -r GITHUB_USERNAME
    fi
  fi
fi

echo "GitHub username: $GITHUB_USERNAME"

# Check current remotes
echo "Current remote repositories:"
git remote -v

# Ask if user wants to remove existing origin
if git remote | grep -q "^origin$"; then
  echo "An 'origin' remote already exists. Do you want to remove it? (y/n)"
  read -r REMOVE_ORIGIN
  if [[ "$REMOVE_ORIGIN" =~ ^[Yy] ]]; then
    echo "Removing existing origin remote..."
    git remote remove origin
  fi
fi

# Set up new remote
GITHUB_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
echo "Setting up remote with URL: $GITHUB_URL"

if ! git remote | grep -q "^origin$"; then
  echo "Adding new origin remote..."
  git remote add origin "$GITHUB_URL"
else
  echo "Updating origin remote URL..."
  git remote set-url origin "$GITHUB_URL"
fi

echo "Remote repository information:"
git remote -v

# Check if GitHub CLI should be used
if [ "$USE_GH_CLI" = true ]; then
  if command -v gh &> /dev/null; then
    echo "GitHub CLI detected. Do you want to create the repository on GitHub? (y/n)"
    read -r CREATE_REPO
    
    if [[ "$CREATE_REPO" =~ ^[Yy] ]]; then
      echo "Creating GitHub repository..."
      
      VISIBILITY=""
      if [ "$PRIVATE_REPO" = true ]; then
        VISIBILITY="--private"
      else
        VISIBILITY="--public"
      fi
      
      gh repo create "$REPO_NAME" --source=. --push $VISIBILITY --yes
      echo "Repository created and code pushed successfully!"
      exit 0
    fi
  else
    echo "GitHub CLI not found. Please create the repository manually."
  fi
fi

# Manual push instructions
echo ""
echo "Next steps:"
echo "1. Create a repository named '$REPO_NAME' on GitHub: https://github.com/new"
echo "2. Run: git push -u origin main"
echo ""
echo "Note: Make sure you have created the repository on GitHub before pushing"
