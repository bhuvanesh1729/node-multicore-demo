#!/bin/bash

# Script to fix Git remote and push to GitHub
# This script creates a GitHub repository and updates the remote URL

echo "Fixing GitHub remote repository setup..."

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first:"
    echo "  brew install gh  # macOS"
    echo "  apt install gh   # Ubuntu/Debian"
    echo "Then login with: gh auth login"
    exit 1
fi

# Check if logged in to GitHub
if ! gh auth status &> /dev/null; then
    echo "Please login to GitHub CLI first:"
    echo "  gh auth login"
    exit 1
fi

# Get repository name from current directory
REPO_NAME=$(basename "$(pwd)")
echo "Repository name: $REPO_NAME"

# Create GitHub repository (public by default)
echo "Creating GitHub repository..."
gh repo create "$REPO_NAME" --source=. --push --yes

echo "Repository created and code pushed successfully!"
echo "You can now access your repository on GitHub."

# Show remote information
echo "Remote repository information:"
git remote -v
