<?php
$host = "db"; // Sesuai nama service database di docker-compose.yml
$user = "root";
$pass = "rootpassword";
$db   = "leafittome";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Koneksi database gagal: " . $conn->connect_error]));
}
?>