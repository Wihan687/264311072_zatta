-- ---------------------------------------------------------------------
-- A. LATAR BELAKANG KEBUTUHAN
-- ---------------------------------------------------------------------
-- Sistem harus bisa mengenali hasil pengukuran yang keluar dari batas
-- wajar, contohnya tanah yang terlalu asam atau suhu yang terlalu panas.
-- Supaya aturannya seragam, batas bawah dan atas (nilai_min, nilai_max)
-- disimpan di satu tempat, yaitu master jenis_sensor, sehingga seluruh
-- sensor dengan jenis yang sama otomatis memakai standar yang sama.

-- ---------------------------------------------------------------------
-- B. TINJAUAN NORMALISASI
-- ---------------------------------------------------------------------
-- Struktur sebelumnya:
--   sensor(id_sensor, id_zona, nama_sensor, jenis_sensor,
--          status_sensor, satuan)
--
-- 1NF : Setiap atribut bernilai tunggal dan tiap baris dapat dikenali
--       lewat id_sensor. SUDAH TERPENUHI.
--
-- 2NF : Kunci utama hanya satu kolom (id_sensor), jadi tidak mungkin
--       ada ketergantungan pada sebagian kunci. SUDAH TERPENUHI.
--
-- 3NF : BELUM terpenuhi karena ada ketergantungan transitif:
--           id_sensor -> jenis_sensor -> satuan
--       Satuan sebenarnya ditentukan oleh jenis sensor, bukan oleh
--       masing-masing sensor. Akibatnya "Suhu Udara = °C" ditulis
--       berulang pada setiap sensor suhu, sehingga berisiko terjadi
--       anomali pembaruan dan data yang tidak seragam.
--
-- Penyelesaian: atribut yang bergantung pada jenis sensor dipindahkan
-- ke tabel tersendiri.
--   jenis_sensor(id_jenis, nama_jenis, satuan, nilai_min, nilai_max)
--   sensor(id_sensor, id_zona, id_jenis, nama_sensor, status_sensor)
--
-- Dengan begitu, setiap atribut non-kunci hanya bergantung pada
-- primary key tabelnya sendiri, dan 3NF TERPENUHI.
-- Kardinalitas: JENIS_SENSOR (1) ---- (N) SENSOR

-- ---------------------------------------------------------------------
-- C. PEMBUATAN TABEL (DDL)
-- ---------------------------------------------------------------------

-- Tabel master jenis sensor
CREATE TABLE `jenis_sensor` (
  `id_jenis`   int NOT NULL AUTO_INCREMENT,
  `nama_jenis` varchar(50) NOT NULL,
  `satuan`     varchar(20) NOT NULL,
  `nilai_min`  decimal(10,2) NOT NULL,
  `nilai_max`  decimal(10,2) NOT NULL,
  PRIMARY KEY (`id_jenis`),
  UNIQUE KEY `uk_nama_jenis` (`nama_jenis`),
  CONSTRAINT `chk_ambang_batas` CHECK (`nilai_min` < `nilai_max`)
) ENGINE=InnoDB;

-- Tabel sensor dengan struktur yang sudah dinormalisasi
CREATE TABLE `sensor` (
  `id_sensor`     int NOT NULL AUTO_INCREMENT,
  `id_zona`       int NOT NULL,
  `id_jenis`      int NOT NULL,
  `nama_sensor`   varchar(100) NOT NULL,
  `status_sensor` varchar(30) NOT NULL,
  PRIMARY KEY (`id_sensor`),
  KEY `fk_sensor_zona` (`id_zona`),
  KEY `fk_sensor_jenis` (`id_jenis`),
  KEY `idx_sensor_status` (`status_sensor`),
  CONSTRAINT `fk_sensor_zona` FOREIGN KEY (`id_zona`)
    REFERENCES `zona_lahan` (`id_zona`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_sensor_jenis` FOREIGN KEY (`id_jenis`)
    REFERENCES `jenis_sensor` (`id_jenis`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_status_sensor` CHECK (`status_sensor` IN ('Aktif','Perawatan','Nonaktif'))
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- D. PENGISIAN DATA
-- ---------------------------------------------------------------------

-- Data master jenis sensor
INSERT INTO `jenis_sensor` (`id_jenis`, `nama_jenis`, `satuan`, `nilai_min`, `nilai_max`) VALUES
(1, 'Kelembaban Tanah', '%',  40.00, 80.00),
(2, 'Suhu Udara',       '°C', 20.00, 35.00),
(3, 'pH Tanah',         'pH',  5.50,  7.50);

-- Data sensor
INSERT INTO `sensor` (`id_sensor`, `id_zona`, `id_jenis`, `nama_sensor`, `status_sensor`) VALUES
(1, 1, 1, 'Sensor Kelembaban A1', 'Aktif'),
(2, 1, 2, 'Sensor Suhu A1',       'Aktif'),
(3, 2, 3, 'Sensor pH B1',         'Aktif'),
(4, 2, 1, 'Sensor Kelembaban B1', 'Perawatan'),
(5, 3, 2, 'Sensor Suhu C1',       'Aktif');
