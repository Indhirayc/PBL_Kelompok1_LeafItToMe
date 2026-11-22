# PBL_Kelompok1_LeafItToMe

Aplikasi deteksi penyakit daun tanaman tomat berbasis **Flutter** dan **Machine Learning**.

---

## Strategi Foto Hybrid (Opsi C)

Tampilan foto riwayat pemindaian memakai strategi hybrid agar offline-tetap-jalan
sekaligus aman saat ganti perangkat:

1. **Lokal dulu** — foto berkas di memori HP / aset bundel ditampilkan langsung
   (instan, tetap tampil saat offline).
2. **Cloud kemudian** — bila berkas lokal hilang, foto ditarik dari URL cloud
   (Cloudinary) dalam versi **terkompresi** (`f_auto,q_auto,w_800`).
3. **Cache permanen** — hasil unduhan disimpan di penyimpanan aplikasi
   (`leaf_photo_cache`) sehingga pembukaan berikutnya instan dan hemat memori.
4. **HP baru** — riwayat scan otomatis dipulihkan dari Firestore saat data
   lokal kosong (`ScanRepository.restoreFromCloud`), lalu foto ditarik dari
   cloud oleh cache hybrid.

Implementasi: [photo_cache_service.dart](mobile_app/lib/core/services/photo_cache_service.dart),
[scanned_leaf_image.dart](mobile_app/lib/features/history/widgets/scanned_leaf_image.dart).
