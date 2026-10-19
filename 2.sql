--  data dummy untuk zona_lahan --
INSERT INTO zona_lahan (id_zona, nama_zona, luas_lahan, jenis_tanaman) VALUES
(1, 'Zona A - Blok Utara',   2500.50, 'Padi'),
(2, 'Zona B - Blok Selatan', 1800.75, 'Jagung'),
(3, 'Zona C - Blok Timur',   3200.00, 'Cabai');

-- data dummy untuk pengguna --
INSERT INTO pengguna (id_pengguna, nama_pengguna, username, password, role, email, no_telp) VALUES
(1, 'Tambir', 'tambir_admin',  'hash_password_1', 'Admin_Sistem',     'tambir@smartagri.id', '081234567890'),
(2, 'Siti Aminah',  'siti_lapang', 'hash_password_2', 'Petugas_Lapangan', 'siti@smartagri.id', '081298765432'),
(3, 'Andi Wijaya',  'andi_koord',  'hash_password_3', 'Koordinator',      'andi@smartagri.id', '082111222333');

-- data dummy untuk laporan --
INSERT INTO laporan (id_laporan, id_zona, id_pengguna, tanggal_laporan, ringkasan, rekomendasi) VALUES
(1, 1, 2, '2026-10-15', 'Pertumbuhan tembakau normal, kelembapan tanah baik.',  'Lanjutkan jadwal irigasi rutin.'),
(2, 2, 2, '2026-10-16', 'Ditemukan hama ulat pada daun jagung.',            'Lakukan penyemprotan pestisida organik.'),
(3, 3, 3, '2026-10-17', 'Tanaman cabai mulai berbunga, pH tanah sedikit asam.', 'Tambahkan kapur pertanian.');

-- READ SELECT dari Tabel zona_lahan --
SELECT * FROM zona_lahan;

-- UPDATE data pada Tabel Laporan --
UPDATE laporan
SET rekomendasi = 'Penyemprotan sudah dilakukan, pantau kondisi daun selama 7 hari.'
WHERE id_laporan = 2;

-- DELETE data dari Table  Laporan --
DELETE FROM laporan
WHERE id_laporan = 3;
