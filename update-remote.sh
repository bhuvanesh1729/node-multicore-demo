#!/bin/bash

# Script to update Git remote URL and push to GitHub
# This script updates the remote URL for an existing repository

echo "Updating GitHub remote repository setup..."

# Function to extract username from git config
get_github_username() {
    local username
    username=$(git config --get user.email | sed 's/@.*//') # Try email first
    if [ -z "$username" ]; then
        username=$(git config --get github.user) # Try github user
    fi
    echo "$username"
}

# Get repository name from current directory
REPO_NAME=$(basename "$(pwd)")
echo "Repository name: $REPO_NAME"

# Try to get GitHub username
GITHUB_USERNAME=$(get_github_username)

if [ -z "$GITHUB_USERNAME" ]; then
    echo "Enter your GitHub username:"
    read -r GITHUB_USERNAME
fi

# Remove existing origin if it exists
if git remote | grep -q "^origin$"; then
    echo "Removing existing origin remote..."
    git remote remove origin
fi

# Add new origin with correct URL
echo "Adding new origin remote..."
GITHUB_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
git remote add origin "$GITHUB_URL"

echo "Remote URL updated to: $GITHUB_URL"
echo "Remote repository information:"
git remote -v

echo ""
echo "Next steps:"
echo "1. Create a repository named '$REPO_NAME' on GitHub if you haven't already"
echo "2. Run: git push -u origin main"
echo ""
echo "Note: Make sure you have created the repository on GitHub before pushing"
