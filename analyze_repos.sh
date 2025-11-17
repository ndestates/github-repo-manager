#!/bin/bash

# Repository Analysis Script for ndestates GitHub Account
# Generates comprehensive repository analysis report

OUTPUT_FILE="REPOS_ANALYSIS.md"

# Load token from .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN not found in .env"
    exit 1
fi

echo "# GitHub Repository Analysis for ndestates" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Generated on: $(date)" >> "$OUTPUT_FILE"
echo "Account: ndestates" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Get all repositories
echo "Fetching repository data..."
gh repo list ndestates --json name,createdAt,updatedAt,pushedAt,isArchived,diskUsage --limit 1000 > repos.json

TOTAL_REPOS=$(jq length repos.json)
ARCHIVED_REPOS=$(jq '[.[] | select(.isArchived == true)] | length' repos.json)
ACTIVE_REPOS=$((TOTAL_REPOS - ARCHIVED_REPOS))

echo "## Repository Summary" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "- Total repositories: $TOTAL_REPOS" >> "$OUTPUT_FILE"
echo "- Active repositories: $ACTIVE_REPOS" >> "$OUTPUT_FILE"
echo "- Archived repositories: $ARCHIVED_REPOS" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "## Repository Details" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "| Repository | Created | Last Updated | Last Pushed | Archived | Size (KB) |" >> "$OUTPUT_FILE"
echo "|------------|---------|--------------|-------------|----------|-----------|" >> "$OUTPUT_FILE"

jq -r '.[] | "| \(.name) | \(.createdAt | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%Y-%m-%d")) | \(.updatedAt | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%Y-%m-%d")) | \(.pushedAt | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%Y-%m-%d")) | \(.isArchived) | \(.diskUsage) |"' repos.json >> "$OUTPUT_FILE"

echo "" >> "$OUTPUT_FILE"

# Categorization
echo "## Repository Categorization" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Very old: created before 2020, not updated since 2022
echo "### Phase 1: Very Old Repositories (Created < 2020, Updated < 2023)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
jq -r 'map(select(.createdAt < "2020-01-01T00:00:00Z" and .updatedAt < "2023-01-01T00:00:00Z")) | .[] | "- \(.name) (Created: \(.createdAt | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%Y-%m-%d")), Updated: \(.updatedAt | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%Y-%m-%d")))"' repos.json >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Old: created 2020-2022, not updated since 2023
echo "### Phase 2: Old Repositories (Created 2020-2022, Updated < 2024)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
jq -r 'map(select(.createdAt >= "2020-01-01T00:00:00Z" and .createdAt < "2023-01-01T00:00:00Z" and .updatedAt < "2024-01-01T00:00:00Z")) | .[] | "- \(.name) (Created: \(.createdAt | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%Y-%m-%d")), Updated: \(.updatedAt | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%Y-%m-%d")))"' repos.json >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Medium: created 2023+, updated 2024+
echo "### Phase 3: Recent Repositories (Created 2023+, Updated 2024+)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
jq -r 'map(select(.createdAt >= "2023-01-01T00:00:00Z" and .updatedAt >= "2024-01-01T00:00:00Z")) | .[] | "- \(.name) (Created: \(.createdAt | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%Y-%m-%d")), Updated: \(.updatedAt | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%Y-%m-%d")))"' repos.json >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "## Recommendations" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "- Phase 1 repositories are candidates for deletion (very old, inactive)" >> "$OUTPUT_FILE"
echo "- Phase 2 repositories may be archived" >> "$OUTPUT_FILE"
echo "- Phase 3 repositories should be kept active" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "Analysis complete. See REPOS_ANALYSIS.md"