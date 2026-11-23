<?php
header("Content-Type: application/json");
include "connect.php";

$data = json_decode(file_get_contents("php://input"), true);

if (!empty($data)) {
    $id = 'USR-' . time(); // Generate ID unik sederhana
    $nama = $data['nama_lengkap'];
    $email = $data['email'];
    $password = password_hash($data['password'], PASSWORD_DEFAULT); // Enkripsi password

    // Cek email sudah ada atau belum
    $check = $conn->query("SELECT * FROM pengguna WHERE email = '$email'");
    if ($check->num_rows > 0) {
        echo json_encode(["status" => "error", "message" => "Email sudah terdaftar"]);
        exit();
    }

    $sql = "INSERT INTO pengguna (id_pengguna, nama_lengkap, email, password) VALUES ('$id', '$nama', '$email', '$password')";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => "success", "message" => "Registrasi berhasil"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
}
?>