<?php
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

$id = isset($_GET['id']) ? preg_replace('/[^a-zA-Z0-9]/', '', $_GET['id']) : '';

if (empty($id)) {
    echo "{}";
    exit;
}

$file = __DIR__ . "/matches/$id.json";

if (file_exists($file)) {
    $content = file_get_contents($file);
    if ($content === false || empty($content)) {
        echo "{}";
    } else {
        echo $content;
    }
} else {
    echo "{}"; 
}
?>
