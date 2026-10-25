
-- A. LATAR BELAKANG KEBUTUHAN
-- ---------------------------------------------------------------------
-- Usaha berkembang dari satu jenis tanaman menjadi beberapa tanaman.
-- Batas wajar pengukuran (kelembaban, pH, suhu) berbeda untuk tiap
-- tanaman, sehingga sistem harus menilai hasil pengukuran memakai
-- ambang batas sesuai tanaman yang ditanam di zona tersebut, bukan
-- satu standar per jenis sensor.

-- ---------------------------------------------------------------------
-- B. TINJAUAN NORMALISASI
-- ---------------------------------------------------------------------
-- Sebelumnya:
--   zona_lahan(id_zona, nama_zona, luas_lahan, jenis_tanaman)
--   jenis_sensor(id_jenis, nama_jenis, satuan, nilai_min, nilai_max)
--
-- 1NF : jenis_tanaman berupa teks bebas ("Padi"/"padi") sehingga nilainya
--       tidak seragam. Dijadikan master tanaman dan direferensikan FK.
-- 2NF : batas_min dan batas_max kini ditentukan oleh kombinasi
--       (id_tanaman, id_jenis), bukan id_jenis saja. Bila tetap di
--       jenis_sensor, atribut bergantung pada sebagian kunci. Dipindah
--       ke tabel ambang_batas yang berkunci kandidat komposit.
-- 3NF : tidak ada atribut non-kunci yang bergantung pada atribut
--       non-kunci lain di kedua tabel baru. TERPENUHI.
--
-- Hasil:
--   tanaman(id_tanaman, nama_tanaman)
--   ambang_batas(id_ambang, id_tanaman, id_jenis, batas_min, batas_max)
--   jenis_sensor(id_jenis, nama_jenis, satuan)
--   zona_lahan(id_zona, nama_zona, luas_lahan, id_tanaman)
-- Kardinalitas: TANAMAN (1)--(N) AMBANG_BATAS (N)--(1) JENIS_SENSOR
--               TANAMAN (1)--(N) ZONA_LAHAN

-- ---------------------------------------------------------------------
-- C. PEMBUATAN TABEL (DDL) DAN MIGRASI
-- ---------------------------------------------------------------------

CREATE TABLE `tanaman` (
  `id_tanaman`   int NOT NULL AUTO_INCREMENT,
  `nama_tanaman` varchar(100) NOT NULL,
  PRIMARY KEY (`id_tanaman`),
  UNIQUE KEY `uk_nama_tanaman` (`nama_tanaman`)
) ENGINE=InnoDB;

INSERT INTO `tanaman` (`nama_tanaman`)
SELECT DISTINCT TRIM(`jenis_tanaman`) FROM `zona_lahan`
WHERE `jenis_tanaman` IS NOT NULL AND TRIM(`jenis_tanaman`) <> '';

CREATE TABLE `ambang_batas` (
  `id_ambang`  int NOT NULL AUTO_INCREMENT,
  `id_tanaman` int NOT NULL,
  `id_jenis`   int NOT NULL,
  `batas_min`  decimal(10,2) NOT NULL,
  `batas_max`  decimal(10,2) NOT NULL,
  PRIMARY KEY (`id_ambang`),
  UNIQUE KEY `uk_tanaman_jenis` (`id_tanaman`, `id_jenis`),
  KEY `fk_ambang_jenis` (`id_jenis`),
  CONSTRAINT `fk_ambang_tanaman` FOREIGN KEY (`id_tanaman`)
    REFERENCES `tanaman` (`id_tanaman`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_ambang_jenis` FOREIGN KEY (`id_jenis`)
    REFERENCES `jenis_sensor` (`id_jenis`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_ambang_min_max` CHECK (`batas_min` < `batas_max`)
) ENGINE=InnoDB;

-- Salin batas lama sebagai nilai awal tiap tanaman
INSERT INTO `ambang_batas` (`id_tanaman`, `id_jenis`, `batas_min`, `batas_max`)
SELECT t.`id_tanaman`, js.`id_jenis`, js.`nilai_min`, js.`nilai_max`
FROM `tanaman` t CROSS JOIN `jenis_sensor` js;

-- zona_lahan: ganti teks bebas dengan FK
ALTER TABLE `zona_lahan` ADD COLUMN `id_tanaman` int NULL;
UPDATE `zona_lahan` z
JOIN `tanaman` t ON t.`nama_tanaman` = TRIM(z.`jenis_tanaman`)
SET z.`id_tanaman` = t.`id_tanaman`;
ALTER TABLE `zona_lahan`
  ADD CONSTRAINT `fk_zona_tanaman` FOREIGN KEY (`id_tanaman`)
    REFERENCES `tanaman` (`id_tanaman`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- peringatan: catat aturan yang dilanggar
ALTER TABLE `peringatan` ADD COLUMN `id_ambang` int NULL,
  ADD CONSTRAINT `fk_peringatan_ambang` FOREIGN KEY (`id_ambang`)
    REFERENCES `ambang_batas` (`id_ambang`) ON DELETE RESTRICT ON UPDATE CASCADE;
UPDATE `peringatan` p
JOIN `sensor` s       ON s.`id_sensor` = p.`id_sensor`
JOIN `zona_lahan` z   ON z.`id_zona` = s.`id_zona`
JOIN `ambang_batas` a ON a.`id_tanaman` = z.`id_tanaman` AND a.`id_jenis` = s.`id_jenis`
SET p.`id_ambang` = a.`id_ambang`;

-- Pembersihan kolom lama: jalankan HANYA setelah hasil migrasi dicek
ALTER TABLE `jenis_sensor` DROP COLUMN `nilai_min`, DROP COLUMN `nilai_max`;
ALTER TABLE `zona_lahan`   DROP COLUMN `jenis_tanaman`;

-- ---------------------------------------------------------------------
-- D. PENGISIAN DATA (contoh ilustrasi, bukan acuan agronomis)
-- ---------------------------------------------------------------------
INSERT IGNORE INTO `tanaman` (`nama_tanaman`) VALUES ('Padi'), ('Cabai'), ('Jagung');

UPDATE `ambang_batas` a
JOIN `tanaman` t      ON t.`id_tanaman` = a.`id_tanaman`
JOIN `jenis_sensor` j ON j.`id_jenis` = a.`id_jenis`
SET a.`batas_min` = 60.00, a.`batas_max` = 85.00
WHERE t.`nama_tanaman` = 'Padi' AND j.`nama_jenis` = 'Kelembaban Tanah';

UPDATE `ambang_batas` a
JOIN `tanaman` t      ON t.`id_tanaman` = a.`id_tanaman`
JOIN `jenis_sensor` j ON j.`id_jenis` = a.`id_jenis`
SET a.`batas_min` = 50.00, a.`batas_max` = 70.00
WHERE t.`nama_tanaman` = 'Cabai' AND j.`nama_jenis` = 'Kelembaban Tanah';
