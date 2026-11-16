<?php

declare(strict_types=1);

require __DIR__ . '/../config/database.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

function respond(int $status, mixed $payload): void
{
    http_response_code($status);
    if ($payload !== null) {
        echo json_encode(
            $payload,
            JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
        );
    }
    exit;
}

function fail(int $status, string $message, mixed $details = null): void
{
    $body = ['error' => $message];
    if ($details !== null) {
        $body['details'] = $details;
    }
    respond($status, $body);
}

function request_body(): array
{
    $raw = file_get_contents('php://input') ?: '';
    if (trim($raw) === '') {
        return [];
    }

    $data = json_decode($raw, true);
    if (!is_array($data)) {
        fail(422, 'Body JSON tidak valid.');
    }

    return $data;
}

function require_string(array $data, string $key): string
{
    $value = $data[$key] ?? null;
    if (!is_string($value) || trim($value) === '') {
        fail(422, "Field '$key' wajib diisi.");
    }

    return trim($value);
}

function optional_string(array $data, string $key): ?string
{
    $value = $data[$key] ?? null;
    if ($value === null) {
        return null;
    }
    if (!is_string($value)) {
        fail(422, "Field '$key' harus berupa teks.");
    }

    $value = trim($value);
    return $value === '' ? null : $value;
}

function to_mysql_datetime(string $value): string
{
    try {
        $date = new DateTimeImmutable($value);
    } catch (Throwable) {
        fail(422, 'Format tanggal tidak valid.');
    }

    return $date->format('Y-m-d H:i:s');
}

function optional_date(?string $value): ?string
{
    if ($value === null) {
        return null;
    }

    try {
        return (new DateTimeImmutable($value))->format('Y-m-d');
    } catch (Throwable) {
        return null;
    }
}

function safe_id(string $value): string
{
    $safe = preg_replace('/[^A-Za-z0-9_-]/', '_', $value);
    return $safe === null || $safe === '' ? 'scan' : $safe;
}

function slugify(string $value): string
{
    $slug = strtolower(trim($value));
    $slug = preg_replace('/[^a-z0-9]+/', '_', $slug) ?? '';
    $slug = trim($slug, '_');

    return $slug === '' ? 'penyakit_tidak_diketahui' : $slug;
}

function ensure_pengguna(
    PDO $pdo,
    string $id,
    ?string $namaLengkap,
    ?string $email
): void {
    $namaLengkap = $namaLengkap ?? $id;
    $email = $email ?? ($id . '@local.invalid');

    $stmt = $pdo->prepare(
        'INSERT INTO pengguna (id_pengguna, nama_lengkap, email, created_at)
         VALUES (:id, :nama, :email, NOW())
         ON DUPLICATE KEY UPDATE nama_lengkap = VALUES(nama_lengkap)'
    );
    $stmt->execute([
        ':id' => $id,
        ':nama' => $namaLengkap,
        ':email' => $email,
    ]);
}

function ensure_tanaman(
    PDO $pdo,
    string $id,
    string $idPengguna,
    ?string $nama,
    ?string $lokasi,
    ?string $tanggalTanam
): void {
    $nama = $nama ?? 'Tanaman Saya';

    $stmt = $pdo->prepare(
        'INSERT INTO tanaman
            (id_tanaman, id_pengguna, nama_tanaman, lokasi, tanggal_tanam,
             status_sinkronisasi, created_at)
         VALUES (:id, :pengguna, :nama, :lokasi, :tanggal, \'synced\', NOW())
         ON DUPLICATE KEY UPDATE
            nama_tanaman = VALUES(nama_tanaman),
            lokasi = VALUES(lokasi)'
    );
    $stmt->execute([
        ':id' => $id,
        ':pengguna' => $idPengguna,
        ':nama' => $nama,
        ':lokasi' => $lokasi,
        ':tanggal' => optional_date($tanggalTanam),
    ]);
}

function resolve_penyakit(
    PDO $pdo,
    ?string $labelCode,
    ?string $namaPenyakit
): string {
    if ($labelCode === null && $namaPenyakit === null) {
        fail(422, "Field 'nama_penyakit' atau 'label_code' wajib diisi.");
    }

    $inputSlug = slugify($labelCode ?? (string) $namaPenyakit);
    $aliases = [
        'bacterial_spot' => 'Bacterial_Spot',
        'late_blight' => 'Late_Blight',
        'leaf_mold' => 'Leaf_Mold',
        'tylcv' => 'TYLCV',
        'tomato_yellow_leaf_curl_virus' => 'TYLCV',
        'tomato_yellow_leaf_curl_virus_tylcv' => 'TYLCV',
        'healthy' => 'Healthy',
    ];
    $label = $aliases[$inputSlug] ?? ($labelCode ?? $inputSlug);
    $nama = $namaPenyakit ?? $label;

    $stmt = $pdo->prepare(
        'SELECT id_penyakit FROM penyakit
         WHERE LOWER(label_code) = LOWER(:label)
            OR LOWER(nama_penyakit) = LOWER(:nama)
            OR LOWER(label_code) = LOWER(:slug)
         LIMIT 1'
    );
    $stmt->execute([
        ':label' => $label,
        ':nama' => $nama,
        ':slug' => slugify($label),
    ]);

    $row = $stmt->fetch();
    if ($row !== false) {
        return (string) $row['id_penyakit'];
    }

    $id = 'CUSTOM-' . strtoupper(slugify($label));

    $stmt = $pdo->prepare(
        'INSERT INTO penyakit
            (id_penyakit, label_code, nama_penyakit, nama_latin, deskripsi,
             kategori, tingkat_risiko)
         VALUES (:id, :label, :nama, NULL, NULL, NULL, \'sedang\')
         ON DUPLICATE KEY UPDATE nama_penyakit = VALUES(nama_penyakit)'
    );
    $stmt->execute([
        ':id' => $id,
        ':label' => $label,
        ':nama' => $nama,
    ]);

    $stmt = $pdo->prepare(
        'SELECT id_penyakit FROM penyakit
         WHERE id_penyakit = :id OR LOWER(label_code) = LOWER(:label)
         LIMIT 1'
    );
    $stmt->execute([':id' => $id, ':label' => $label]);
    $row = $stmt->fetch();

    return $row === false ? $id : (string) $row['id_penyakit'];
}

function fetch_scan(PDO $pdo, string $id): array
{
    $stmt = $pdo->prepare(
        'SELECT r.id_riwayat, r.id_tanaman, r.id_penyakit, t.id_pengguna,
                t.nama_tanaman, t.lokasi,
                p.label_code, p.nama_penyakit,
                r.foto_daun, r.cloud_image_url, r.confidence_score,
                r.tanggal_pemeriksaan, r.catatan,
                r.status_sinkronisasi, r.synced_at, r.created_at
         FROM riwayat_pemindaian r
         JOIN tanaman t ON t.id_tanaman = r.id_tanaman
         JOIN penyakit p ON p.id_penyakit = r.id_penyakit
         WHERE r.id_riwayat = :id
         LIMIT 1'
    );
    $stmt->execute([':id' => $id]);
    $row = $stmt->fetch();

    if ($row === false) {
        fail(404, 'Riwayat tidak ditemukan.');
    }

    $row['confidence_score'] = (float) $row['confidence_score'];
    return $row;
}

function upsert_scan(PDO $pdo, array $payload): array
{
    $idRiwayat = require_string($payload, 'id_riwayat');
    $idPengguna = require_string($payload, 'id_pengguna');
    $namaPenyakit = optional_string($payload, 'nama_penyakit');
    $labelCode = optional_string($payload, 'label_code');

    $confidence = $payload['confidence_score'] ?? null;
    if (!is_numeric($confidence) || $confidence < 0 || $confidence > 1) {
        fail(422, "Field 'confidence_score' harus angka 0 sampai 1.");
    }

    $tanggalPemeriksaan = to_mysql_datetime(
        require_string($payload, 'tanggal_pemeriksaan')
    );

    $idTanaman = optional_string($payload, 'id_tanaman')
        ?? ('TMT-DEFAULT-' . safe_id($idPengguna));
    $namaTanaman = optional_string($payload, 'nama_tanaman');
    $lokasi = optional_string($payload, 'lokasi');
    $tanggalTanam = optional_string($payload, 'tanggal_tanam');
    $catatan = optional_string($payload, 'catatan');
    $fotoDaun = optional_string($payload, 'foto_daun');

    $pdo->beginTransaction();

    try {
        ensure_pengguna(
            $pdo,
            $idPengguna,
            optional_string($payload, 'nama_lengkap'),
            optional_string($payload, 'email')
        );
        ensure_tanaman(
            $pdo,
            $idTanaman,
            $idPengguna,
            $namaTanaman,
            $lokasi,
            $tanggalTanam
        );
        $idPenyakit = resolve_penyakit($pdo, $labelCode, $namaPenyakit);

        $stmt = $pdo->prepare(
            'INSERT INTO riwayat_pemindaian
                (id_riwayat, id_tanaman, id_penyakit, foto_daun,
                 cloud_image_url, confidence_score, tanggal_pemeriksaan,
                 catatan, status_sinkronisasi, synced_at, created_at)
             VALUES (:id, :tanaman, :penyakit, :foto,
                     NULL, :confidence, :tanggal,
                     :catatan, \'synced\', NOW(), NOW())
             ON DUPLICATE KEY UPDATE
                id_tanaman = VALUES(id_tanaman),
                id_penyakit = VALUES(id_penyakit),
                foto_daun = VALUES(foto_daun),
                confidence_score = VALUES(confidence_score),
                tanggal_pemeriksaan = VALUES(tanggal_pemeriksaan),
                catatan = VALUES(catatan),
                status_sinkronisasi = \'synced\',
                synced_at = COALESCE(synced_at, NOW())'
        );
        $stmt->execute([
            ':id' => $idRiwayat,
            ':tanaman' => $idTanaman,
            ':penyakit' => $idPenyakit,
            ':foto' => $fotoDaun,
            ':confidence' => (float) $confidence,
            ':tanggal' => $tanggalPemeriksaan,
            ':catatan' => $catatan,
        ]);

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    return fetch_scan($pdo, $idRiwayat);
}

function list_scans(PDO $pdo, string $idPengguna): array
{
    $limit = (int) ($_GET['limit'] ?? 100);
    $limit = max(1, min($limit, 500));

    $stmt = $pdo->prepare(
        'SELECT r.id_riwayat, r.id_tanaman, r.id_penyakit, t.id_pengguna,
                t.nama_tanaman, t.lokasi,
                p.label_code, p.nama_penyakit,
                r.foto_daun, r.cloud_image_url, r.confidence_score,
                r.tanggal_pemeriksaan, r.catatan,
                r.status_sinkronisasi, r.synced_at, r.created_at
         FROM riwayat_pemindaian r
         JOIN tanaman t ON t.id_tanaman = r.id_tanaman
         JOIN penyakit p ON p.id_penyakit = r.id_penyakit
         WHERE t.id_pengguna = :pengguna
         ORDER BY r.tanggal_pemeriksaan DESC
         LIMIT :limit'
    );
    $stmt->bindValue(':pengguna', $idPengguna);
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->execute();

    $rows = $stmt->fetchAll();
    foreach ($rows as &$row) {
        $row['confidence_score'] = (float) $row['confidence_score'];
    }
    unset($row);

    return $rows;
}

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
$path = rtrim($path, '/');
if ($path === '') {
    $path = '/';
}

if ($method === 'OPTIONS') {
    http_response_code(204);
    exit;
}

try {
    if ($method === 'GET' && $path === '/api/health') {
        $pdo = db();
        $pdo->query('SELECT 1');
        respond(200, ['status' => 'ok', 'database' => 'connected']);
    }

    if ($method === 'GET' && $path === '/api/scans') {
        $idPengguna = trim((string) ($_GET['id_pengguna'] ?? ''));
        if ($idPengguna === '') {
            fail(422, "Query parameter 'id_pengguna' wajib diisi.");
        }
        respond(200, list_scans(db(), $idPengguna));
    }

    if ($method === 'POST' && $path === '/api/scans') {
        $record = upsert_scan(db(), request_body());
        respond(201, $record);
    }

    if (
        $method === 'POST'
        && preg_match('#^/api/scans/([^/]+)/image$#', $path, $matches) === 1
    ) {
        $idRiwayat = urldecode($matches[1]);
        $pdo = db();

        $stmt = $pdo->prepare(
            'SELECT id_riwayat FROM riwayat_pemindaian WHERE id_riwayat = :id'
        );
        $stmt->execute([':id' => $idRiwayat]);
        if ($stmt->fetch() === false) {
            fail(404, 'Riwayat tidak ditemukan.');
        }

        if (!isset($_FILES['image']) || !is_array($_FILES['image'])) {
            fail(422, "File 'image' wajib dikirim.");
        }

        $file = $_FILES['image'];
        if (($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
            fail(422, 'Upload gambar gagal.');
        }
        if (($file['size'] ?? 0) > 5 * 1024 * 1024) {
            fail(422, 'Ukuran gambar maksimal 5 MB.');
        }

        $finfo = new finfo(FILEINFO_MIME_TYPE);
        $mime = $finfo->file((string) $file['tmp_name']);
        $extensions = [
            'image/jpeg' => 'jpg',
            'image/png' => 'png',
            'image/webp' => 'webp',
        ];
        if (!is_string($mime) || !isset($extensions[$mime])) {
            fail(422, 'Format gambar harus JPG, PNG, atau WEBP.');
        }

        $filename = safe_id($idRiwayat) . '.' . $extensions[$mime];
        $directory = __DIR__ . '/uploads/scans';
        if (!is_dir($directory) && !mkdir($directory, 0775, true)) {
            fail(500, 'Folder upload tidak dapat dibuat.');
        }

        $destination = $directory . '/' . $filename;
        if (!move_uploaded_file((string) $file['tmp_name'], $destination)) {
            fail(500, 'Gambar gagal disimpan.');
        }

        $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
            ? 'https'
            : 'http';
        $host = $_SERVER['HTTP_HOST'] ?? 'localhost:8000';
        $url = $scheme . '://' . $host
            . '/uploads/scans/' . rawurlencode($filename);

        $stmt = $pdo->prepare(
            'UPDATE riwayat_pemindaian
             SET cloud_image_url = :url,
                 status_sinkronisasi = \'synced\',
                 synced_at = COALESCE(synced_at, NOW())
             WHERE id_riwayat = :id'
        );
        $stmt->execute([':url' => $url, ':id' => $idRiwayat]);

        respond(200, [
            'id_riwayat' => $idRiwayat,
            'cloud_image_url' => $url,
        ]);
    }

    if (
        $method === 'DELETE'
        && preg_match('#^/api/scans/([^/]+)$#', $path, $matches) === 1
    ) {
        $idRiwayat = urldecode($matches[1]);
        $stmt = db()->prepare(
            'DELETE FROM riwayat_pemindaian WHERE id_riwayat = :id'
        );
        $stmt->execute([':id' => $idRiwayat]);

        if ($stmt->rowCount() === 0) {
            fail(404, 'Riwayat tidak ditemukan.');
        }

        respond(204, null);
    }

    fail(404, 'Endpoint tidak ditemukan.');
} catch (PDOException $error) {
    respond(500, [
        'error' => 'Database error.',
        'details' => $error->getMessage(),
    ]);
} catch (Throwable $error) {
    respond(500, [
        'error' => 'Server error.',
        'details' => $error->getMessage(),
    ]);
}