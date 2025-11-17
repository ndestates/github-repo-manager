# GitHub Copilot Instructions for github-repo-manager

## Project Overview
This is a repository management toolkit for the `ndestates` GitHub account. It provides automated scripts for analyzing, categorizing, and cleaning up GitHub repositories based on creation and update dates.

## Architecture
- **Scripts**: Bash and PHP utilities for GitHub API interactions
- **Data Flow**: GitHub CLI/API → JSON data → jq processing → Markdown reports
- **Phasing System**: 
  - Phase 1: Very old repos (created < 2020, updated < 2023) - candidates for deletion
  - Phase 2: Old repos (created 2020-2022, updated < 2024) - archive candidates  
  - Phase 3: Recent repos (created 2023+, updated 2024+) - keep active

## Key Workflows

### Repository Analysis
```bash
# Generate comprehensive analysis
./analyze_repos.sh  # Creates REPOS_ANALYSIS.md and PHASE1_REPOS_ANALYSIS.md
```

### Interactive Cleanup
```bash
# Categorize and manage repos interactively
php delete_old_repos.php
```

### Batch Deletion
```bash
# Delete Phase 1 candidates
./cleanup_phase1_repos.sh
```

## Conventions

### Authentication
- Store `GITHUB_TOKEN` in `.env` file (loaded by scripts)
- Scripts check for token presence before API calls

### Data Formats
- Repository data stored as JSON array from `gh repo list --json`
- Reports generated as Markdown tables with creation/update dates
- Candidate lists as simple text files with repo names

### Naming Patterns
- Repos often prefixed with `nde-`, `ndpm-`, `ndestates-`
- Analysis files: `{PHASE}_REPOS_ANALYSIS.md`
- Data files: `repos.json`, `phase1_candidates.txt`

### Error Handling
- Scripts exit with error if `GITHUB_TOKEN` missing
- API calls include rate limiting (sleep 1-2 seconds between operations)
- Confirmation prompts for destructive operations

## Integration Points
- **GitHub CLI**: Primary tool for repo operations (`gh repo list`, `gh repo delete`)
- **GitHub REST API**: Used by PHP scripts for direct API access
- **jq**: JSON processing for data filtering and formatting
- **stream_context_create()**: PHP for authenticated API requests

## Development Notes
- Prefer Bash for data processing/reporting workflows
- Use PHP for interactive, user-facing operations
- Always test with `--dry-run` or confirmation prompts before actual deletions
- Update date thresholds in scripts as cleanup policies evolve