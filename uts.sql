USE smart_agriculture_db;

-- 1. Tabel jenis_sensor --
CREATE TABLE IF NOT EXISTS jenis_sensor (
    id_jenis    INT NOT NULL AUTO_INCREMENT,
    nama_jenis  VARCHAR(100) NOT NULL,
    satuan      VARCHAR(20)  NOT NULL,
    batas_min   DECIMAL(10,2) NOT NULL,
    batas_max   DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_jenis),
    UNIQUE KEY uk_nama_jenis (nama_jenis),
    CONSTRAINT ck_jenis_batas CHECK (batas_min < batas_max)
) ENGINE=InnoDB;

-- 2. Data awal --
INSERT INTO jenis_sensor (nama_jenis, satuan, batas_min, batas_max) VALUES
    ('Kelembaban Tanah', '%',  40.00, 80.00),
    ('Suhu Udara',       '°C', 20.00, 35.00),
    ('pH Tanah',         'pH',  5.50,  7.00);

-- 3. Tambah kolom id_jenis di sensor --
ALTER TABLE sensor ADD COLUMN id_jenis INT NULL AFTER id_zona;

-- 4. Isi id_jenis dari teks jenis_sensor yang lama --
UPDATE sensor s
JOIN jenis_sensor j ON LOWER(TRIM(s.jenis_sensor)) = LOWER(j.nama_jenis)
SET s.id_jenis = j.id_jenis;

-- 5. Cek: hasilnya harus KOSONG sebelum lanjut ke langkah 6
SELECT id_sensor, nama_sensor, jenis_sensor FROM sensor WHERE id_jenis IS NULL;

-- 6. Pasang relasi, hapus kolom lama --
ALTER TABLE sensor
    MODIFY id_jenis INT NOT NULL,
    ADD CONSTRAINT fk_sensor_jenis FOREIGN KEY (id_jenis)
        REFERENCES jenis_sensor (id_jenis)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    DROP COLUMN jenis_sensor,
    DROP COLUMN satuan;

-- 7. Trigger: peringatan otomatis bila nilai ukur di luar batas --
DROP TRIGGER IF EXISTS trg_pengukuran_peringatan;
DELIMITER $$
CREATE TRIGGER trg_pengukuran_peringatan
AFTER INSERT ON pengukuran
FOR EACH ROW
BEGIN
    DECLARE v_min     DECIMAL(10,2);
    DECLARE v_max     DECIMAL(10,2);
    DECLARE v_selisih DECIMAL(10,2);
    DECLARE v_risiko  VARCHAR(30);

    SELECT j.batas_min, j.batas_max INTO v_min, v_max
      FROM sensor s
      JOIN jenis_sensor j ON j.id_jenis = s.id_jenis
     WHERE s.id_sensor = NEW.id_sensor;

    IF NEW.nilai_ukur < v_min OR NEW.nilai_ukur > v_max THEN
        SET v_selisih = IF(NEW.nilai_ukur < v_min,
                           v_min - NEW.nilai_ukur,
                           NEW.nilai_ukur - v_max);
        SET v_risiko = CASE
                           WHEN v_selisih <  0.10 * (v_max - v_min) THEN 'Rendah'
                           WHEN v_selisih <= 0.25 * (v_max - v_min) THEN 'Sedang'
                           ELSE 'Tinggi'
                       END;

        INSERT INTO peringatan
            (id_sensor, waktu_ukur, waktu_peringatan, status_peringatan, tingkat_risiko)
        VALUES
            (NEW.id_sensor, NEW.waktu_ukur, GREATEST(NOW(), NEW.waktu_ukur), 'Aktif', v_risiko);
    END IF;
END$$
DELIMITER ;
