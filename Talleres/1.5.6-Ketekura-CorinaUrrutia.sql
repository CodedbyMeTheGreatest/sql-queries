
--  Caso 2  --

SELECT LOWER(e.nombre) "ESPECIALIDAD",
CONCAT(TO_CHAR(m.med_run, '09G999G999'), '-' || m.dv_run) "RUT",
UPPER(m.pnombre || ' ' || m.snombre || ' ' || m.apaterno || ' ' || m.amaterno) "MEDICO"
FROM MEDICO m JOIN ESPECIALIDAD_MEDICO em ON(m.med_run = em.med_run)
JOIN ESPECIALIDAD e ON(e.esp_id = em.esp_id)
WHERE (EXTRACT(YEAR FROM SYSDATE) -1) IN (SELECT EXTRACT(YEAR FROM fecha_atencion) FROM ATENCION)
AND m.med_run IN (SELECT med_run FROM ATENCION GROUP BY med_run HAVING COUNT(ate_id) >= 10)
AND em.fec_ini_espec = (SELECT MAX(em2.fec_ini_espec) FROM ESPECIALIDAD_MEDICO em2 WHERE em2.med_run = em.med_run)
ORDER BY e.nombre, m.apaterno;
--  Fin Caso 2  --

--  Caso 4  --
--Informe 1

SELECT TO_CHAR(a.fecha_atencion, 'YYYY/MM') "AÑO Y MES",
COUNT(a.ate_id) "TOTAL DE ATENCIONES",
TO_CHAR(SUM(a.costo), '$9G999G999') "VALOR TOTAL DE LAS ATENCIONES"
FROM ATENCION a
WHERE EXTRACT(YEAR FROM a.fecha_atencion) IN 
  (EXTRACT(YEAR FROM SYSDATE), EXTRACT(YEAR FROM SYSDATE) -1, EXTRACT(YEAR FROM SYSDATE) -2)
GROUP BY TO_CHAR(a.fecha_atencion, 'YYYY/MM')
HAVING COUNT(a.ate_id) >= (SELECT ROUND(AVG(cantidad)) FROM (SELECT COUNT(ate_id) cantidad FROM atencion WHERE EXTRACT(YEAR FROM fecha_atencion) IN 
  (EXTRACT(YEAR FROM SYSDATE), EXTRACT(YEAR FROM SYSDATE) -1, EXTRACT(YEAR FROM SYSDATE) -2) GROUP BY TO_CHAR(fecha_atencion, 'YYYY/MM')))
ORDER BY "AÑO Y MES";


--Informe 2
SELECT CONCAT(TO_CHAR(p.pac_run,'09G999G999'), '-' || p.dv_run) "RUT PACIENTE",
INITCAP(p.pnombre || ' ' || p.snombre || ' ' || p.apaterno || ' ' || p.amaterno) "NOMBRE PACIENTE",
pa.ate_id "ID ATENCION",
TO_CHAR(pa.fecha_venc_pago, 'DD/MM/YYYY') "FECHA VENCIMIENTO PAGO",
TO_CHAR(pa.fecha_pago, 'DD/MM/YYYY') "FECHA PAGO",
pa.fecha_pago - pa.fecha_venc_pago "DIAS MOROSIDAD",
TO_CHAR(2000 * (pa.fecha_pago - pa.fecha_venc_pago),'$999G999') "VALOR MULTA" 
FROM PACIENTE p JOIN ATENCION a ON(p.pac_run = a.pac_run)
JOIN PAGO_ATENCION pa ON(a.ate_id = pa.ate_id)
WHERE pa.fecha_pago > pa.fecha_venc_pago
AND EXTRACT(YEAR FROM pa.fecha_pago) IN 
  (EXTRACT(YEAR FROM SYSDATE), EXTRACT(YEAR FROM SYSDATE) -1, EXTRACT(YEAR FROM SYSDATE) -2)
AND (pa.fecha_pago - pa.fecha_venc_pago) > 
 (SELECT AVG(pa2.fecha_pago - pa2.fecha_venc_pago) 
  FROM PAGO_ATENCION pa2 JOIN ATENCION a2 ON pa.ate_id = a2.ate_id
  WHERE pa2.fecha_pago > pa2.fecha_venc_pago
   AND EXTRACT(YEAR FROM pa2.fecha_venc_pago) IN 
    (EXTRACT(YEAR FROM SYSDATE), EXTRACT(YEAR FROM SYSDATE) - 1, EXTRACT(YEAR FROM SYSDATE) - 2))
ORDER BY pa.fecha_venc_pago, (pa.fecha_pago - pa.fecha_venc_pago) DESC;
--  Fin Caso 4  --

