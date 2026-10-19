-- TABEL INDUK 1: PENGGUNA --
CREATE TABLE pengguna (
    id_pengguna    INT          NOT NULL AUTO_INCREMENT,
    nama_pengguna  VARCHAR(100) NOT NULL,
    username       VARCHAR(50)  NOT NULL,
    password_hash  VARCHAR(255) NOT NULL,
    role           ENUM('admin','petugas','manajer') NOT NULL DEFAULT 'petugas',
    PRIMARY KEY (id_pengguna),
    CONSTRAINT uq_pengguna_username UNIQUE (username)
);

-- TABEL INDUK 2: ZONA_LAHAN --
CREATE TABLE zona_lahan (
    id_zona     INT           NOT NULL AUTO_INCREMENT,
    nama_zona   VARCHAR(100)  NOT NULL,
    luas_lahan  DECIMAL(10,2) NOT NULL COMMENT 'Luas dalam hektar',
    PRIMARY KEY (id_zona)
);

-- TABEL TRANSAKSI/ANAK: LAPORAN --
CREATE TABLE laporan (
    id_laporan       INT      NOT NULL AUTO_INCREMENT,
    id_pengguna      INT      NOT NULL,
    id_zona          INT      NOT NULL,
    tanggal_laporan  DATE     NOT NULL,
    ringkasan        TEXT     NOT NULL,
    rekomendasi      TEXT     NULL,
    PRIMARY KEY (id_laporan),
    CONSTRAINT fk_laporan_pengguna
        FOREIGN KEY (id_pengguna) REFERENCES pengguna (id_pengguna)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_laporan_zona
        FOREIGN KEY (id_zona) REFERENCES zona_lahan (id_zona)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);
