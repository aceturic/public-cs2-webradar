<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$id = isset($_GET['id']) ? preg_replace('/[^a-zA-Z0-9]/', '', $_GET['id']) : '';

if (empty($id)) {
    die(json_encode(["status" => "error", "message" => "No Room ID provided"]));
}

$dir = __DIR__ . '/matches';
if (!is_dir($dir)) {
    if (!mkdir($dir, 0777, true)) {
        die(json_encode(["status" => "error", "message" => "Failed to create matches folder. Check permissions."]));
    }
}

$file = "$dir/$id.json";

$json = file_get_contents('php://input');

if (!empty($json)) {
    $fp = fopen($file, 'w');
    if (!$fp) {
        die(json_encode(["status" => "error", "message" => "Cannot open file for writing. Check permissions."]));
    }

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