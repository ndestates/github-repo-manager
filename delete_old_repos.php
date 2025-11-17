<?php

// Load environment variables from .env
function loadEnv($path) {
    if (!file_exists($path)) {
        throw new Exception(".env file not found");
    }
    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        list($name, $value) = explode('=', $line, 2);
        $name = trim($name);
        $value = trim($value);
        putenv("$name=$value");
    }
}

loadEnv('.env');

$token = getenv('GITHUB_TOKEN');
if (!$token) {
    echo "GITHUB_TOKEN not set in .env\n";
    exit(1);
}

$owner = 'ndestates';

// Define phases
// Old: created before 2020-01-01, last updated before 2023-01-01
// Medium: created 2020-2022, last updated 2023-2024
// Recent: created after 2022-01-01, last updated after 2024-01-01

$oldCreated = strtotime('2020-01-01');
$oldUpdated = strtotime('2023-01-01');
$mediumCreatedStart = strtotime('2020-01-01');
$mediumCreatedEnd = strtotime('2023-01-01');
$mediumUpdatedStart = strtotime('2023-01-01');
$mediumUpdatedEnd = strtotime('2025-01-01');
$recentCreated = strtotime('2023-01-01');
$recentUpdated = strtotime('2025-01-01');

$url = "https://api.github.com/users/$owner/repos?per_page=100&type=all";

$context = stream_context_create([
    'http' => [
        'header' => "Authorization: token $token\r\nUser-Agent: PHP-Script\r\n",
    ],
]);

$response = file_get_contents($url, false, $context);
$repos = json_decode($response, true);

if ($repos === null) {
    echo "Error fetching repositories.\n";
    exit(1);
}

$oldRepos = [];
$mediumRepos = [];
$recentRepos = [];

foreach ($repos as $repo) {
    $created = strtotime($repo['created_at']);
    $updated = strtotime($repo['updated_at']);

    if ($created < $oldCreated && $updated < $oldUpdated) {
        $oldRepos[] = $repo;
    } elseif ($created >= $mediumCreatedStart && $created < $mediumCreatedEnd && $updated >= $mediumUpdatedStart && $updated < $mediumUpdatedEnd) {
        $mediumRepos[] = $repo;
    } elseif ($created >= $recentCreated && $updated >= $recentUpdated) {
        $recentRepos[] = $repo;
    }
}

echo "=== RECENT REPOS (Keep) ===\n";
if (empty($recentRepos)) {
    echo "None\n";
} else {
    foreach ($recentRepos as $repo) {
        echo "- {$repo['name']} (Created: {$repo['created_at']}, Updated: {$repo['updated_at']})\n";
    }
}

echo "\n=== MEDIUM REPOS (Archive) ===\n";
if (empty($mediumRepos)) {
    echo "None\n";
} else {
    foreach ($mediumRepos as $repo) {
        echo "- {$repo['name']} (Created: {$repo['created_at']}, Updated: {$repo['updated_at']})\n";
    }
    echo "\nArchive these? (yes/no): ";
    $confirm = trim(fgets(STDIN));
    if (strtolower($confirm) === 'yes') {
        foreach ($mediumRepos as $repo) {
            $archiveUrl = "https://api.github.com/repos/$owner/{$repo['name']}";
            $data = json_encode(['archived' => true]);
            $archiveContext = stream_context_create([
                'http' => [
                    'method' => 'PATCH',
                    'header' => "Authorization: token $token\r\nUser-Agent: PHP-Script\r\nContent-Type: application/json\r\n",
                    'content' => $data,
                ],
            ]);
            $result = file_get_contents($archiveUrl, false, $archiveContext);
            if ($result === false) {
                echo "Failed to archive {$repo['name']}\n";
            } else {
                echo "Archived {$repo['name']}\n";
            }
            sleep(1);
        }
    }
}

echo "\n=== OLD REPOS (Delete) ===\n";
if (empty($oldRepos)) {
    echo "None\n";
} else {
    foreach ($oldRepos as $repo) {
        echo "- {$repo['name']} (Created: {$repo['created_at']}, Updated: {$repo['updated_at']})\n";
    }
    echo "\nDelete these? (yes/no): ";
    $confirm = trim(fgets(STDIN));
    if (strtolower($confirm) === 'yes') {
        foreach ($oldRepos as $repo) {
            $deleteUrl = "https://api.github.com/repos/$owner/{$repo['name']}";
            $deleteContext = stream_context_create([
                'http' => [
                    'method' => 'DELETE',
                    'header' => "Authorization: token $token\r\nUser-Agent: PHP-Script\r\n",
                ],
            ]);
            $result = file_get_contents($deleteUrl, false, $deleteContext);
            if ($result === false) {
                echo "Failed to delete {$repo['name']}\n";
            } else {
                echo "Deleted {$repo['name']}\n";
            }
            sleep(1);
        }
    }
}

echo "Done.\n";
?>