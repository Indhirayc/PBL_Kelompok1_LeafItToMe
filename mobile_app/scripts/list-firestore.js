/**
 * LeafItToMe - Lihat isi Firestore tanpa Firebase Console
 * =======================================================
 *
 * Script ini HANYA MEMBACA data. Tidak ada penulisan, update, atau delete.
 * Jadi aman dijalankan kapan saja, termasuk ke project produksi.
 *
 * Kenapa script ini ada?
 *   Firebase Console adalah UI berbasis browser. Kalau ingin melihat data
 *   dari terminal / Antigravity / CI, kita butuh jalur lain. Firebase Admin
 *   SDK bisa membaca Firestore langsung dengan service account.
 *
 * Yang perlu dipahami:
 *   1. Setiap dokumen yang dibaca = 1 read yang dihitung ke kuota Firestore.
 *      Karena itu selalu pakai --limit kalau hanya ingin melihat contoh data.
 *   2. Script ini memakai service account yang sama dengan seed-firestore.js.
 *   3. Kalau environment variable FIRESTORE_EMULATOR_HOST di-set, Admin SDK
 *      otomatis terhubung ke Emulator, bukan ke Firestore cloud.
 *
 * ---------------------------------------------------------------------------
 * CARA PAKAI (dari folder mobile_app)
 * ---------------------------------------------------------------------------
 *
 *   # 1. Ringkasan jumlah dokumen di koleksi master data
 *   npm run list
 *
 *   # 2. Lihat contoh isi satu koleksi (default 5 dokumen)
 *   npm run list -- --collection=diseases
 *   npm run list -- --collection=diseases --limit=10
 *
 *   # 3. Lihat satu dokumen tertentu
 *   npm run list -- --doc=meta/app
 *   npm run list -- --doc=diseases/P001
 *
 *   # 4. Lihat data milik satu user (profil + plants + scans)
 *   npm run list -- --uid=UID_DARI_FIREBASE_AUTH
 *
 *   # 5. Lihat semua koleksi root (auto-discovery)
 *   npm run list -- --all
 *
 *   # 6. Output JSON, cocok untuk diolah script lain
 *   npm run list -- --collection=tools --json
 *
 *   # 7. Jangan potong teks panjang
 *   npm run list -- --collection=guides --full
 *
 *   # 8. Bantuan
 *   npm run list -- --help
 *
 * ---------------------------------------------------------------------------
 * CONTOH MEMBACA HASIL
 * ---------------------------------------------------------------------------
 *
 *   [doc] diseases/P001
 *     label_code       : Bacterial_Spot
 *     nama_penyakit    : Bacterial Spot
 *     gejala           : ["Bercak kecil ...", "..."]
 *     updated_at       : 2026-11-08T10:12:31.000Z
 *
 *   Artinya:
 *   - diseases   = nama koleksi
 *   - P001       = document ID
 *   - updated_at = Timestamp Firestore yang sudah diubah ke ISO string
 *
 * ---------------------------------------------------------------------------
 * TROUBLESHOOTING SINGKAT
 * ---------------------------------------------------------------------------
 *
 *   "Could not load the default credentials"
 *     -> serviceAccountKey.json tidak ada. Letakkan di mobile_app/, atau set
 *        GOOGLE_APPLICATION_CREDENTIALS ke path file JSON service account.
 *
 *   "The database (default) does not exist"
 *     -> Firestore belum dibuat di project ini. Buat database dulu.
 *
 *   "PERMISSION_DENIED"
 *     -> Service account tidak punya role Firestore. Beri role
 *        "Cloud Datastore User" atau "Firebase Admin SDK Administrator".
 *
 *   Hasil kosong padahal seed sudah jalan
 *     -> Cek project ID. Script seed dan script list harus memakai project
 *        yang sama (lihat baris "Project:" di output).
 */

'use strict';

const fs = require('fs');
const path = require('path');
const {
  initializeApp,
  getApps,
  cert,
  applicationDefault,
} = require('firebase-admin/app');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');

// ---------------------------------------------------------------------------
// Konstanta
// ---------------------------------------------------------------------------

const projectRoot = path.resolve(__dirname, '..');
const serviceAccountPath = path.join(projectRoot, 'serviceAccountKey.json');

/**
 * Koleksi master data yang biasanya ingin dilihat pertama kali.
 * Koleksi user tidak dimasukkan karena butuh UID (pakai --uid).
 */
const DEFAULT_COLLECTIONS = ['diseases', 'guides', 'tools', 'products', 'meta'];

/**
 * Diisi saat runtime dari app.options.projectId.
 * Dipakai hanya untuk ditampilkan di header agar mudah memastikan
 * script membaca project yang benar (dev vs prod).
 */
let resolvedProjectId = '(default)';

// ---------------------------------------------------------------------------
// Parsing argumen
// ---------------------------------------------------------------------------

/**
 * Format argumen yang didukung: --nama=nilai atau --nama
 * Sengaja dibuat manual agar tidak menambah dependency (yargs/commander).
 */
function parseArgs(argv) {
  const options = {
    collection: null,
    doc: null,
    uid: null,
    limit: 5,
    json: false,
    all: false,
    full: false,
    help: false,
  };

  for (const arg of argv) {
    if (!arg.startsWith('--')) {
      continue;
    }

    const [rawKey, rawValue] = arg.slice(2).split('=');
    const key = rawKey.toLowerCase();
    const value = rawValue === undefined ? true : rawValue;

    switch (key) {
      case 'collection':
        options.collection = String(value);
        break;
      case 'doc':
        options.doc = String(value);
        break;
      case 'uid':
        options.uid = String(value);
        break;
      case 'limit': {
        const parsed = Number(value);
        if (!Number.isInteger(parsed) || parsed < 1) {
          throw new Error('--limit harus bilangan bulat >= 1');
        }
        options.limit = parsed;
        break;
      }
      case 'json':
        options.json = true;
        break;
      case 'all':
        options.all = true;
        break;
      case 'full':
        options.full = true;
        break;
      case 'help':
      case 'h':
        options.help = true;
        break;
      default:
        throw new Error(`Argumen tidak dikenal: --${rawKey}`);
    }
  }

  return options;
}

function printHelp() {
  console.log(`
LeafItToMe - list-firestore.js

Pemakaian:
  node scripts/list-firestore.js [opsi]

Opsi:
  --collection=NAMA   Tampilkan contoh dokumen dari satu koleksi.
  --doc=PATH          Tampilkan satu dokumen, contoh: meta/app
  --uid=UID           Tampilkan users/{uid} + plants + scans milik user.
  --limit=N           Jumlah dokumen yang ditampilkan (default 5).
  --all               Tampilkan semua koleksi root beserta jumlahnya.
  --json              Output dalam format JSON.
  --full              Jangan potong teks yang panjang.
  --help              Tampilkan bantuan ini.

Tanpa opsi:
  Menampilkan ringkasan jumlah dokumen koleksi master data.
`);
}

// ---------------------------------------------------------------------------
// Inisialisasi Firebase Admin
// ---------------------------------------------------------------------------

/**
 * Urutan pencarian kredensial:
 *   1. GOOGLE_APPLICATION_CREDENTIALS (paling fleksibel, cocok untuk CI)
 *   2. mobile_app/serviceAccountKey.json (paling mudah untuk lokal)
 *   3. Application Default Credentials (firebase login / gcloud auth)
 */
function initializeAdmin() {
  const existing = getApps();
  if (existing.length > 0) {
    return existing[0];
  }

  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    return initializeApp({ credential: applicationDefault() });
  }

  if (fs.existsSync(serviceAccountPath)) {
    const serviceAccount = require(serviceAccountPath);
    return initializeApp({
      credential: cert(serviceAccount),
      projectId: serviceAccount.project_id,
    });
  }

  return initializeApp({ credential: applicationDefault() });
}

// ---------------------------------------------------------------------------
// Format nilai agar enak dibaca
// ---------------------------------------------------------------------------

/**
 * Firestore mengembalikan tipe khusus yang tidak bisa langsung di-print:
 *   - Timestamp  -> objek detik/nanodetik
 *   - GeoPoint   -> latitude/longitude
 *   - DocumentReference -> path dokumen
 *
 * Fungsi ini menormalkan semuanya menjadi bentuk yang mudah dibaca.
 */
function formatValue(value, full) {
  if (value === null) {
    return '(null)';
  }
  if (value === undefined) {
    return '(undefined)';
  }

  // Timestamp Firestore -> ISO 8601, contoh: 2026-11-08T10:12:31.000Z
  if (value instanceof Timestamp) {
    return value.toDate().toISOString();
  }

  const typeName =
    typeof value === 'object' && value.constructor ? value.constructor.name : '';

  // Referensi ke dokumen lain -> tampilkan path-nya saja
  if (typeName === 'DocumentReference') {
    return `[ref] ${value.path}`;
  }

  // GeoPoint
  if (typeName === 'GeoPoint') {
    return `[geo] ${value.latitude}, ${value.longitude}`;
  }

  if (typeof value === 'string') {
    if (!full && value.length > 220) {
      return `${value.slice(0, 217)}... (${value.length} karakter, pakai --full)`;
    }
    return value;
  }

  if (typeof value === 'number' || typeof value === 'boolean') {
    return String(value);
  }

  // Array dan map: JSON satu baris agar tetap ringkas.
  try {
    const json = JSON.stringify(value);
    if (!full && json.length > 300) {
      return `${json.slice(0, 297)}... (pakai --full)`;
    }
    return json;
  } catch {
    return String(value);
  }
}

/**
 * Menampilkan satu dokumen dengan format:
 *
 *   [doc] diseases/P001
 *     label_code    : Bacterial_Spot
 *     nama_penyakit : Bacterial Spot
 *
 * fieldName dipadding agar titik dua sejajar.
 */
function printDocument(snapshot, options) {
  const data = snapshot.data() || {};
  const fields = Object.keys(data).sort();

  console.log(`\n[doc] ${snapshot.ref.path}`);
  console.log(`      id: ${snapshot.id}`);

  if (fields.length === 0) {
    console.log('      (dokumen kosong)');
    return;
  }

  const width = Math.min(
    24,
    Math.max(...fields.map((field) => field.length)),
  );

  for (const field of fields) {
    const label = field.padEnd(width, ' ');
    console.log(`      ${label} : ${formatValue(data[field], options.full)}`);
  }
}

/**
 * Mengubah nilai Firestore menjadi bentuk yang aman untuk JSON.stringify.
 * Tanpa ini, Timestamp akan tampil sebagai { _seconds, _nanoseconds }.
 */
function toJsonSafe(value) {
  if (value instanceof Timestamp) {
    return value.toDate().toISOString();
  }

  if (Array.isArray(value)) {
    return value.map(toJsonSafe);
  }

  if (value && typeof value === 'object') {
    const typeName = value.constructor ? value.constructor.name : '';

    // DocumentReference -> path
    if (typeName === 'DocumentReference') {
      return value.path;
    }

    // GeoPoint -> { lat, lng }
    if (typeName === 'GeoPoint') {
      return { lat: value.latitude, lng: value.longitude };
    }

    const result = {};
    for (const [key, nested] of Object.entries(value)) {
      result[key] = toJsonSafe(nested);
    }
    return result;
  }

  return value;
}

function printJson(payload) {
  console.log(JSON.stringify(toJsonSafe(payload), null, 2));
}

function printHeader(title, projectId, options) {
  if (options.json) {
    return;
  }
  console.log('='.repeat(70));
  console.log(`LeafItToMe - Firestore Viewer`);
  console.log(`Project : ${projectId}`);
  console.log(`Mode    : ${title}`);
  if (process.env.FIRESTORE_EMULATOR_HOST) {
    console.log(`Emulator: ${process.env.FIRESTORE_EMULATOR_HOST}`);
  }
  console.log('='.repeat(70));
}

// ---------------------------------------------------------------------------
// Perintah-perintah
// ---------------------------------------------------------------------------

/**
 * Menghitung dokumen tanpa membaca seluruh isinya.
 * count() memakai aggregation query, jauh lebih murah daripada get().
 */
async function countCollection(db, name) {
  const snapshot = await db.collection(name).count().get();
  return snapshot.data().count;
}

/**
 * Tanpa opsi: ringkasan jumlah dokumen koleksi master data.
 * Ini yang dipakai untuk menjawab "data saya sudah masuk atau belum?".
 */
async function showSummary(db, options) {
  const result = {};

  for (const name of DEFAULT_COLLECTIONS) {
    try {
      result[name] = await countCollection(db, name);
    } catch (error) {
      result[name] = `ERROR: ${error.message}`;
    }
  }

  if (options.json) {
    printJson(result);
    return;
  }

  console.log('\nJumlah dokumen:');
  for (const [name, count] of Object.entries(result)) {
    const value = typeof count === 'number' ? count : count;
    console.log(`  ${name.padEnd(12, ' ')} : ${value}`);
  }

  const total = Object.values(result)
    .filter((value) => typeof value === 'number')
    .reduce((sum, value) => sum + value, 0);

  console.log(`\n  Total        : ${total} dokumen`);

  console.log('\nTips:');
  console.log('  npm run list -- --collection=diseases');
  console.log('  npm run list -- --doc=meta/app');
  console.log('  npm run list -- --uid=<UID>');
}

/**
 * --collection=NAMA
 * Menampilkan sekumpulan dokumen dari satu koleksi.
 */
async function showCollection(db, name, options) {
  const snapshot = await db
    .collection(name)
    .limit(options.limit)
    .get();

  if (!options.json) {
    printHeader(`koleksi ${name}`, resolvedProjectId, options);
    if (snapshot.empty) {
      console.log('\n(koleksi kosong atau belum pernah di-seed)');
      return;
    }
    console.log(
      `\nMenampilkan ${snapshot.size} dokumen (limit ${options.limit}).`,
    );
    snapshot.forEach((doc) => printDocument(doc, options));
    console.log(`\nTotal ditampilkan: ${snapshot.size}`);
    return;
  }

  const payload = snapshot.docs.map((doc) => ({
    id: doc.id,
    path: doc.ref.path,
    data: doc.data(),
  }));
  printJson(payload);
}

/**
 * --doc=PATH
 * Menampilkan satu dokumen, misalnya meta/app atau diseases/P001.
 */
async function showDocument(db, docPath, options) {
  if (!docPath.includes('/')) {
    throw new Error(
      '--doc harus berisi path lengkap, contoh: meta/app atau diseases/P001',
    );
  }

  const snapshot = await db.doc(docPath).get();

  if (!snapshot.exists) {
    if (!options.json) {
      console.log(`\nDokumen tidak ditemukan: ${docPath}`);
    } else {
      printJson({ path: docPath, exists: false });
    }
    return;
  }

  if (options.json) {
    printJson({
      id: snapshot.id,
      path: snapshot.ref.path,
      data: snapshot.data(),
    });
    return;
  }

  printHeader(`dokumen ${docPath}`, resolvedProjectId, options);
  printDocument(snapshot, options);
}

/**
 * --uid=UID
 * Menampilkan data milik satu user:
 *   users/{uid}
 *   users/{uid}/plants
 *   users/{uid}/scans
 */
async function showUser(db, uid, options) {
  const userRef = db.collection('users').doc(uid);

  const [profile, plants, scans] = await Promise.all([
    userRef.get(),
    userRef.collection('plants').limit(options.limit).get(),
    userRef.collection('scans').limit(options.limit).get(),
  ]);

  if (options.json) {
    printJson({
      uid,
      profile: profile.exists ? profile.data() : null,
      plants: plants.docs.map((doc) => ({ id: doc.id, data: doc.data() })),
      scans: scans.docs.map((doc) => ({ id: doc.id, data: doc.data() })),
    });
    return;
  }

  printHeader(`user ${uid}`, resolvedProjectId, options);

  if (profile.exists) {
    printDocument(profile, options);
  } else {
    console.log(`\n[doc] users/${uid} (tidak ditemukan)`);
  }

  console.log(`\nSubkoleksi plants (${plants.size} ditampilkan):`);
  if (plants.empty) {
    console.log('  (kosong)');
  } else {
    plants.forEach((doc) => printDocument(doc, options));
  }

  console.log(`\nSubkoleksi scans (${scans.size} ditampilkan):`);
  if (scans.empty) {
    console.log('  (kosong)');
  } else {
    scans.forEach((doc) => printDocument(doc, options));
  }
}

/**
 * --all
 * Menemukan semua koleksi root secara otomatis, lalu menghitung isinya.
 * Berguna kalau nama koleksi berubah dan tidak ingin mengedit script.
 */
async function showAll(db, options) {
  const collections = await db.listCollections();
  const names = collections.map((collection) => collection.id).sort();

  const result = {};
  for (const name of names) {
    try {
      result[name] = await countCollection(db, name);
    } catch (error) {
      result[name] = `ERROR: ${error.message}`;
    }
  }

  if (options.json) {
    printJson(result);
    return;
  }

  printHeader('semua koleksi root', resolvedProjectId, options);

  if (names.length === 0) {
    console.log('\nBelum ada koleksi di Firestore project ini.');
    return;
  }

  console.log('\nKoleksi root yang ditemukan:');
  for (const [name, count] of Object.entries(result)) {
    console.log(`  ${name.padEnd(16, ' ')} : ${count}`);
  }
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

async function main() {
  const options = parseArgs(process.argv.slice(2));

  if (options.help) {
    printHelp();
    return;
  }

  const app = initializeAdmin();
  const db = getFirestore(app);
  resolvedProjectId = app.options.projectId || '(default)';

  if (options.uid) {
    await showUser(db, options.uid, options);
    return;
  }

  if (options.doc) {
    await showDocument(db, options.doc, options);
    return;
  }

  if (options.collection) {
    await showCollection(db, options.collection, options);
    return;
  }

  if (options.all) {
    await showAll(db, options);
    return;
  }

  printHeader('ringkasan', resolvedProjectId, options);
  await showSummary(db, options);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('\nGagal membaca Firestore:', error.message);
    console.error('Lihat komentar di bagian TROUBLESHOOTING pada file ini.');
    process.exit(1);
  });
