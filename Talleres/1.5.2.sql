-- Caso 1 --
--informe 1 
SELECT tp.descripcion||','||s.descripcion "SISTEMA_SALUD",
COUNT(a.fecha_atencion)"TOTAL ATENCIONES"
FROM PACIENTE p JOIN SALUD s
ON(p.sal_id=s.sal_id) 
JOIN TIPO_SALUD tp
ON(s.tipo_sal_id=tp.tipo_sal_id)
JOIN ATENCION a 
ON(a.pac_run=p.pac_run)
WHERE s.tipo_sal_id in ('F','I') 
AND EXTRACT (MONTH FROM fecha_atencion) = EXTRACT (MONTH FROM ADD_MONTHS(SYSDATE,-1))
GROUP BY tp.descripcion, s.descripcion
HAVING COUNT(a.fecha_atencion) >(SELECT COUNT(fecha_atencion)/EXTRACT(DAY FROM LAST_DAY(ADD_MONTHS(SYSDATE, -1)))
FROM ATENCION WHERE EXTRACT (MONTH FROM fecha_atencion) = EXTRACT (MONTH FROM ADD_MONTHS(SYSDATE,-1))) 
ORDER BY "SISTEMA_SALUD" ASC;

--informe 2 
SELECT TO_CHAR(p.pac_run,'99G999G999')||'-'||p.dv_run "RUT PACIENTE", 
p.pnombre||' '||p.snombre||' '||p.apaterno||' '||p.amaterno"NOMBRE PACIENTE",
ROUND(MONTHS_BETWEEN(SYSDATE,p.fecha_nacimiento)/12)"AÑOS",
CONCAT(CONCAT(CONCAT('Le corresponde un ',pd.porcentaje_descto),'% de descuento en la primera consulta médico del año '), 
EXTRACT(YEAR FROM SYSDATE)+1)"PORCENTAJE DESCUENTO"
FROM PACIENTE p JOIN PORC_DESCTO_3RA_EDAD pd
ON(ROUND(MONTHS_BETWEEN(SYSDATE,p.fecha_nacimiento)/12) BETWEEN pd.anno_ini AND pd.anno_ter)
JOIN ATENCION a
ON(a.pac_run= p.pac_run)
WHERE ROUND(MONTHS_BETWEEN(SYSDATE,p.fecha_nacimiento)/12) >= 65
GROUP BY(p.pac_run,p.dv_run,p.pnombre,p.snombre,p.apaterno,p.amaterno,p.fecha_nacimiento,pd.porcentaje_descto)
HAVING COUNT(a.fecha_atencion)>4
ORDER BY p.apaterno ASC;
--  Fin Caso 1  --

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

--Caso 3 --

SELECT u.nombre"UNIDAD",
m.pnombre||' '||m.snombre||' '||m.apaterno||' '||m.amaterno"MEDICO", 
m.telefono"TELEFONO", 
CONCAT(SUBSTR(u.nombre,1,2)||''||SUBSTR(m.apaterno,-3,2)||''||SUBSTR(m.telefono,-3,3)||''||
TO_CHAR(m.fecha_contrato,'dd')||''||TO_CHAR(m.fecha_contrato,'mm'),'@medicocktk.cl')"CORREO_MEDICO",
COUNT(a.fecha_atencion)"ATENCIONES_MEDICAS"
FROM MEDICO m JOIN UNIDAD u 
ON(m.uni_id=u.uni_id)
JOIN ATENCION a 
ON(a.med_run=m.med_run)
WHERE EXTRACT(YEAR FROM a.fecha_atencion) = EXTRACT(YEAR FROM SYSDATE)-1
GROUP BY u.nombre,m.pnombre,m.snombre,m.apaterno,m.amaterno,m.telefono,m.fecha_contrato
HAVING COUNT(a.fecha_atencion)<(SELECT MAX(COUNT(fecha_atencion)) FROM atencion 
WHERE EXTRACT(YEAR FROM fecha_atencion) = EXTRACT(YEAR FROM SYSDATE)-1 
GROUP BY med_run)
ORDER BY u.nombre ASC, m.apaterno ASC;

--FALTA ESTO: 
--Esta información además debe quedar almacenada en la tabla MEDICOS_SERVICIO_COMUNIDAD. 

--fin caso 3-- 

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


-- Caso 5-- 
SELECT TO_CHAR(m.med_run,'09G999G999')||'-'||m.dv_run"RUN MEDICO", 
m.pnombre||' '||m.snombre||' '||m.apaterno||' '||m.amaterno "NOMBRE MEDICO", 
COUNT(a.fecha_atencion) "TOTAL ATENCIONES MEDICAS", 
TO_CHAR(m.sueldo_base,'$9G999G999')"SUELDO BASE", 
TO_CHAR(ROUND(225000000 * 0.05)/(SELECT COUNT(med_run) FROM 
    (SELECT med_run FROM ATENCION 
     WHERE EXTRACT(YEAR FROM fecha_atencion) = 2026
     GROUP BY med_run
     HAVING COUNT(*) > 7)),'$99G999G999') "BONIFICACION POR GANANCIAS", 
TO_CHAR(m.sueldo_base + ROUND(225000000 * 0.05) / (SELECT COUNT(med_run) FROM 
    (SELECT med_run FROM ATENCION 
     WHERE EXTRACT(YEAR FROM fecha_atencion) = 2026
     GROUP BY med_run
     HAVING COUNT(fecha_atencion) > 7)), '$999G999G999') "TOTAL GANANCIAS"    
FROM MEDICO m JOIN ATENCION a 
ON(m.med_run=a.med_run)
WHERE EXTRACT(YEAR FROM a.fecha_atencion) = 2026
GROUP BY m.med_run, m.dv_run,m.pnombre, m.snombre, m.apaterno, m.amaterno,m.sueldo_base
HAVING COUNT(a.fecha_atencion) > 7
ORDER BY m.med_run, m.apaterno;

-- Fin caso 5 --


SELECT * FROM PACIENTE;
SELECT * FROM  TIPO_SALUD;
SELECT * FROM  medico;
SELECT * FROM  SALUD;
SELECT * FROM PAGO_ATENCION;
SELECT * FROM  PORC_DESCTO_3RA_EDAD;
SELECT * FROM atencion;
