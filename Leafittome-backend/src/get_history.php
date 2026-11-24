<?php
header("Content-Type: application/json");
include "connect.php";

$user_id = $_GET['user_id'] ?? '';

if (!empty($user_id)) {
    $sql = "SELECT * FROM riwayat_pemindaian WHERE id_pengguna = '$user_id' ORDER BY tanggal_pemeriksaan DESC";
    $result = $conn->query($sql);
    
    $history = [];
    while($row = $result->fetch_assoc()) {
        $history[] = $row;
    }
    echo json_encode(["status" => "success", "data" => $history]);
} else {
    echo json_encode(["status" => "error", "message" => "User ID diperlukan"]);
}
?>