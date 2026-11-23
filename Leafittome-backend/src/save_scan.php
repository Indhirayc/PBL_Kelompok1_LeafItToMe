<?php
header("Content-Type: application/json");
include "connect.php";

$data = json_decode(file_get_contents("php://input"), true);

if (!empty($data)) {
    $id = $data['id'];
    $user_id = $data['user_id'];
    $disease_label = $data['disease_label'];
    $confidence = $data['confidence'];
    $cloud_image_url = $data['cloud_image_url'];
    $scanned_at = $data['scanned_at'];

    // Jika data sudah ada di-update, jika belum lakukan insert
    $sql = "INSERT INTO riwayat_pemindaian (id_riwayat, id_pengguna, id_penyakit, cloud_image_url, confidence_score, tanggal_pemeriksaan) 
            VALUES ('$id', '$user_id', '$disease_label', '$cloud_image_url', '$confidence', '$scanned_at')
            ON DUPLICATE KEY UPDATE cloud_image_url='$cloud_image_url'";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => "success", "message" => "Disimpan ke MySQL"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
}
?>