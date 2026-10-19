-- perintah SQL query tunggal yang  memuat keempat komponen sekaligus dalam satu sintaks --
SELECT 
    z.nama_zona,
    z.jenis_tanaman,
    COUNT(l.id_laporan) AS total_laporan
FROM laporan l
JOIN zona_lahan z ON l.id_zona = z.id_zona
WHERE l.tanggal_laporan BETWEEN '2026-10-01' AND '2026-10-31'
GROUP BY z.id_zona, z.nama_zona, z.jenis_tanaman;
