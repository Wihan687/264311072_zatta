-- 1. Tabel Induk: zona_lahan --
CREATE TABLE zona_lahan (
    id_zona        INT           NOT NULL AUTO_INCREMENT,
    nama_zona      VARCHAR(100)  NOT NULL,
    luas_lahan     DECIMAL(10,2) NOT NULL,
    jenis_tanaman  VARCHAR(100)  NOT NULL,
    PRIMARY KEY (id_zona)
) ENGINE=InnoDB;

-- 2. Tabel Induk: pengguna --
CREATE TABLE pengguna (
    id_pengguna    INT           NOT NULL AUTO_INCREMENT,
    nama_pengguna  VARCHAR(100)  NOT NULL,
    username       VARCHAR(50)   NOT NULL,
    password       VARCHAR(255)  NOT NULL,
    role           ENUM('Admin_Sistem','Petugas_Lapangan','Operator','Koordinator') NOT NULL,
    email          VARCHAR(100)  NOT NULL,
    no_telp        VARCHAR(13)   NULL,
    PRIMARY KEY (id_pengguna),
    UNIQUE KEY uq_pengguna_username (username),
    UNIQUE KEY uq_pengguna_email (email)
) ENGINE=InnoDB;

-- 3. Tabel Transaksi/Anak: laporan --
CREATE TABLE laporan (
    id_laporan       INT   NOT NULL AUTO_INCREMENT,
    id_zona          INT   NOT NULL,
    id_pengguna      INT   NOT NULL,
    tanggal_laporan  DATE  NOT NULL,
    ringkasan        TEXT  NOT NULL,
    rekomendasi      TEXT  NULL,
    PRIMARY KEY (id_laporan),
    CONSTRAINT fk_laporan_zona
        FOREIGN KEY (id_zona) REFERENCES zona_lahan (id_zona)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_laporan_pengguna
        FOREIGN KEY (id_pengguna) REFERENCES pengguna (id_pengguna)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;
