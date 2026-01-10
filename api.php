<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

// 1. Get and Sanitize ID
$id = isset($_GET['id']) ? preg_replace('/[^a-zA-Z0-9]/', '', $_GET['id']) : '';

if (empty($id)) {
    die(json_encode(["status" => "error", "message" => "No Room ID provided"]));
}

// 2. Force Match Folder Creation
$dir = __DIR__ . '/matches';
if (!is_dir($dir)) {
    if (!mkdir($dir, 0777, true)) {
        die(json_encode(["status" => "error", "message" => "Failed to create matches folder. Check permissions."]));
    }
}

// 3. Define File Path
$file = "$dir/$id.json";

// 4. Get Data
$json = file_get_contents('php://input');

// 5. Write Data (With explicit error checking)
if (!empty($json)) {
    // Try to open file
    $fp = fopen($file, 'w');
    if (!$fp) {
        die(json_encode(["status" => "error", "message" => "Cannot open file for writing. Check permissions."]));
    }

    // Try to lock and write
    if (flock($fp, LOCK_EX)) {
        $written = fwrite($fp, $json);
        fflush($fp);
        flock($fp, LOCK_UN);
        fclose($fp);

        if ($written === false) {
            echo json_encode(["status" => "error", "message" => "Write failed."]);
        } else {
            echo json_encode(["status" => "success", "id" => $id]);
        }
    } else {
        fclose($fp);
        echo json_encode(["status" => "error", "message" => "File locked."]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Empty payload received."]);
}
?>