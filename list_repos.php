<?php

// GitHub Repository Analyzer
// Lists all repositories for an organization/user with creation and last updated dates

$token = getenv('GITHUB_TOKEN') ?: readline('Enter your GitHub Personal Access Token: ');
$owner = 'ndestates'; // Change if needed

$url = "https://api.github.com/users/$owner/repos?per_page=100&type=all";

$context = stream_context_create([
    'http' => [
        'header' => "Authorization: token $token\r\nUser-Agent: PHP-Script\r\n",
    ],
]);

$response = file_get_contents($url, false, $context);
$repos = json_decode($response, true);

if ($repos === null) {
    echo "Error fetching repositories. Check token and network.\n";
    exit(1);
}

echo "Repository Name | Created At | Updated At | Archived\n";
echo str_repeat('-', 80) . "\n";

foreach ($repos as $repo) {
    $name = $repo['name'];
    $created = date('Y-m-d', strtotime($repo['created_at']));
    $updated = date('Y-m-d', strtotime($repo['updated_at']));
    $archived = $repo['archived'] ? 'Yes' : 'No';

    echo sprintf("%-30s | %s | %s | %s\n", $name, $created, $updated, $archived);
}

echo "\nTotal repositories: " . count($repos) . "\n";
echo "To delete obsolete repos, use: gh repo delete <owner>/<repo> --confirm\n";
?>