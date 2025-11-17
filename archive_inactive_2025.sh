#!/bin/bash

# Archive Script for Inactive Repositories Since 2025
# Archives repositories not updated since 2024-12-31

# Load token from .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN not found in .env"
    exit 1
fi

CANDIDATES_FILE="inactive_2025_candidates.txt"

if [ ! -f "$CANDIDATES_FILE" ]; then
    echo "Candidates file $CANDIDATES_FILE not found"
    exit 1
fi

echo "Inactive Repositories Since 2025 Archive"
echo "========================================"
echo ""
echo "The following repositories will be archived:"
echo ""

cat "$CANDIDATES_FILE"
echo ""
echo "Total: $(wc -l < "$CANDIDATES_FILE") repositories"
echo ""

read -p "Do you want to proceed with archiving? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

echo "Archiving repositories..."

while read -r line; do
    # Extract repo name from line like "- repo-name (Updated: ...)"
    repo_name=$(echo "$line" | sed 's/- \([^ ]*\) .*/\1/')

    if [ -n "$repo_name" ]; then
        echo "Archiving ndestates/$repo_name..."
        gh repo archive "ndestates/$repo_name" --confirm
        sleep 2  # Rate limit
    fi
done < "$CANDIDATES_FILE"

echo "Inactive 2025 archiving complete."