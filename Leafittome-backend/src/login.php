<?php
header("Content-Type: application/json");
include "connect.php";

$data = json_decode(file_get_contents("php://input"), true);
$email = $data['email'] ?? '';
$password = $data['password'] ?? '';

$sql = "SELECT * FROM pengguna WHERE email = '$email'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    // Kondisi 1: Email ditemukan, cek password
    if (password_verify($password, $user['password'])) {
        echo json_encode([
            "status" => "success",
            "message" => "Login berhasil",
            "user" => [
                "id_pengguna" => $user['id_pengguna'],
                "nama_lengkap" => $user['nama_lengkap'],
                "email" => $user['email']
            ]
        ]);
    } else {
        // Kondisi 2: Password salah
        echo json_encode([
            "status" => "error", 
            "message" => "Password yang Anda masukkan salah."
        ]);
    }
} else {
    // Kondisi 3: Email belum terdaftar di database
    echo json_encode([
        "status" => "error", 
        "message" => "Email belum terdaftar. Silakan daftar terlebih dahulu."
    ]);
}
?>