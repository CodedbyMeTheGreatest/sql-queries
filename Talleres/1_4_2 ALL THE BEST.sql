--Caso 1- Benjamin-
SELECT TO_CHAR(c.numrun,'99G999G999')||'-'|| c.dvrun "RUN CLIENTE", 
c.pnombre||' '||c.snombre||' '||c.appaterno||' '||c.apmaterno"NOMBRE CLIENTE", 
TO_CHAR(c.fecha_nacimiento,'DD "de" MONTH ')"DIA DE CUMPLEAÑOS",
s.direccion||'/'||r.nombre_region"Dirección Sucursal/REGION SUCURSAL"
FROM CLIENTE c JOIN SUCURSAL_RETAIL s
ON (c.cod_comuna = s.cod_comuna)
AND(c.cod_region = s.cod_region)
AND(c.cod_provincia = s.cod_provincia)
JOIN REGION r 
ON(s.cod_region = r.cod_region)
WHERE EXTRACT(MONTH FROM c.fecha_nacimiento) = EXTRACT(MONTH FROM(ADD_MONTHS('17/08/2026',1))) AND r.cod_region=13
ORDER BY EXTRACT(DAY FROM c.fecha_nacimiento)ASC, c.appaterno ASC;


--Caso 2--

SELECT CONCAT(TO_CHAR(c.numrun, '09G999G999'), '-' || UPPER(c.dvrun)) "RUN CLIENTE",
UPPER(c.pnombre || ' ' || c.snombre || ' ' || c.appaterno || ' ' || c.apmaterno) "NOMBRE CLIENTE",
TO_CHAR(SUM(ttc.monto_transaccion), '$9G999G999') "MONTO COMPRAS/AVANCES/S.AVANCES",
TO_CHAR((SUM(ttc.monto_transaccion) / 10000) * 250, '99G999') "TOTAL PUNTOS ACUMULADOS"
FROM CLIENTE c RIGHT JOIN TARJETA_CLIENTE tc 
    ON(c.numrun = tc.numrun)
RIGHT JOIN TRANSACCION_TARJETA_CLIENTE ttc 
    ON(tc.nro_tarjeta = ttc.nro_tarjeta)
WHERE EXTRACT(YEAR FROM ADD_MONTHS(ttc.fecha_transaccion, 12)) = EXTRACT(YEAR FROM SYSDATE) 
    AND ttc.cod_tptran_tarjeta = 101
GROUP BY c.numrun, c.dvrun, c.pnombre, c.snombre, c.appaterno, c.apmaterno
ORDER BY "TOTAL PUNTOS ACUMULADOS", c.appaterno;

--CASO 3
SELECT TO_CHAR(tc.fecha_transaccion,'mmyyyy') "MES TRANSACCIÓN", 
tt.nombre_tptran_tarjeta"TIPO TRANSACCIÓN", 
TO_CHAR(SUM(tc.monto_total_transaccion),'$999G999G999')"MONTO AVANCES/SUPER AVANCES",
TO_CHAR(SUM(tc.monto_total_transaccion * a.porc_aporte_sbif / 100),'9G999G999')"APORTE A LA SBIF"
FROM TRANSACCION_TARJETA_CLIENTE tc JOIN TIPO_TRANSACCION_TARJETA tt
ON(tc.cod_tptran_tarjeta = tt.cod_tptran_tarjeta)
JOIN APORTE_SBIF a
ON (tc.monto_total_transaccion BETWEEN a.monto_inf_av_sav AND a.monto_sup_av_sav)
WHERE EXTRACT(YEAR FROM tc.fecha_transaccion) = EXTRACT(YEAR FROM SYSDATE) AND tt.cod_tptran_tarjeta in (102,103)
GROUP BY TO_CHAR(tc.fecha_transaccion,'mmyyyy'),tt.nombre_tptran_tarjeta
ORDER BY "MES TRANSACCIÓN","TIPO TRANSACCIÓN" ASC ;

-- Caso 4

SELECT CONCAT(TO_CHAR(c.numrun, '09G999G999'), '-' || UPPER(c.dvrun)) "RUN CLIENTE",
UPPER(c.pnombre || ' ' || c.snombre || ' ' || c.appaterno || ' ' || c.apmaterno) "NOMBRE CLIENTE",
TO_CHAR(NVL(SUM(ttc.monto_total_transaccion), 0), '$9G999G999') "COMPRAS/AVANCES/S.AVANCES",
CASE 
    WHEN NVL(SUM(ttc.monto_total_transaccion), 0) BETWEEN 0 AND 100000 THEN 'SIN CATEGORIZACION'
    WHEN NVL(SUM(ttc.monto_total_transaccion), 0) BETWEEN 100001 AND 1000000 THEN 'BRONCE'
    WHEN NVL(SUM(ttc.monto_total_transaccion), 0) BETWEEN 1000001 AND 4000000 THEN 'PLATA'
    WHEN NVL(SUM(ttc.monto_total_transaccion), 0) BETWEEN 4000001 AND 8000000 THEN 'SILVER'
    WHEN NVL(SUM(ttc.monto_total_transaccion), 0) BETWEEN 8000001 AND 15000000 THEN 'GOLD'
    ELSE 'PLATINUM'
END "CATEGORIZACION DEL CLIENTE"
FROM CLIENTE c JOIN TARJETA_CLIENTE tc 
    ON(c.numrun = tc.numrun)
LEFT JOIN TRANSACCION_TARJETA_CLIENTE ttc 
    ON(tc.nro_tarjeta = ttc.nro_tarjeta)
GROUP BY c.numrun, c.dvrun, c.pnombre, c.snombre, c.appaterno, c.apmaterno
ORDER BY c.appaterno, "MONTO COMPRAS/AVANCES/S.AVANCES" DESC;


SELECT CONCAT(TO_CHAR(c.numrun, '09G999G999'), '-' || UPPER(c.dvrun)) "RUN CLIENTE",
UPPER(c.pnombre || ' ' || c.snombre || ' ' || c.appaterno || ' ' || c.apmaterno) "NOMBRE CLIENTE"
FROM REGION r JOIN PROVINCIA p
    ON(r.cod_region = p.cod_region)
JOIN CLIENTE c JOIN TARJETA_CLIENTE tc 
    ON(c.cod_provincia = p.cod_provincia)
    AND(c.numrun = tc.numrun)
JOIN TRANSACCION_TARJETA_CLIENTE ttc 
    ON(tc.nro_tarjeta = ttc.nro_tarjeta);
    
    
--CASO 5
SELECT TO_CHAR(c.numrun,'99G999G999')||'-'||c.dvrun"RUN CLIENTE", 
INITCAP(c.pnombre)||' '||NVL(SUBSTR(c.snombre,1,1),'')||'. '||INITCAP(c.appaterno)||' '||INITCAP(c.apmaterno) "NOMBRE CLIENTE",
COUNT(ttc.cod_tptran_tarjeta) "TOTAL SUPER AVANCES VIGENTES", 
TO_CHAR(SUM(ttc.monto_total_transaccion),'$9G999G999') "MONTO TOTAL SUPER AVANCES"
FROM CLIENTE c JOIN TARJETA_CLIENTE tc
ON(c.numrun=tc.numrun)
JOIN TRANSACCION_TARJETA_CLIENTE ttc
ON(tc.nro_tarjeta=ttc.nro_tarjeta)
WHERE ttc.cod_tptran_tarjeta= 103
GROUP BY TO_CHAR(c.numrun,'99G999G999'),c.dvrun,c.pnombre,c.snombre,appaterno,c.apmaterno
ORDER BY c.appaterno;


--Caso 6
--Informe 1
SELECT TO_CHAR(c.numrun,'99G999G999')||'-'||c.dvrun"RUN CLIENTE", 
INITCAP(c.pnombre)||' '||NVL(SUBSTR(c.snombre,1,1),'')||'. '||INITCAP(c.appaterno)||' '||INITCAP(c.apmaterno) "NOMBRE CLIENTE",
c.direccion "DIRECCION",
p.nombre_provincia "PROVINCIA", 
r.nombre_region "REGION",
COUNT(
    CASE 
        WHEN ttc.cod_tptran_tarjeta = 101 THEN ttc.nro_transaccion
    END) "COMPRAS VIGENTES",
COALESCE(TO_CHAR(SUM(
    CASE
        WHEN ttc.cod_tptran_tarjeta = 101 THEN ttc.monto_total_transaccion
    END), '$99G999G999'),'$0') "MONTO TOTAL COMPRAS",
COUNT(
    CASE 
        WHEN ttc.cod_tptran_tarjeta = 102 THEN ttc.nro_transaccion
    END) "AVANCES VIGENTES",
COALESCE(TO_CHAR(SUM(
    CASE
        WHEN ttc.cod_tptran_tarjeta = 102 THEN ttc.monto_total_transaccion
    END), '$99G999G999'),'$0') "MONTO TOTAL AVANCES",
COUNT(
    CASE 
        WHEN ttc.cod_tptran_tarjeta = 103 THEN ttc.nro_transaccion
    END) "SUPER AVANCES VIGENTES",
COALESCE(TO_CHAR(SUM(
    CASE
        WHEN ttc.cod_tptran_tarjeta = 103 THEN ttc.monto_total_transaccion
    END), '$99G999G999'),'$0') "MONTO TOTAL SUPER AVANCES"
FROM REGION r JOIN PROVINCIA p
    ON(r.cod_region = p.cod_region)
RIGHT JOIN CLIENTE c 
    ON(p.cod_region = c.cod_region)
    AND(p.cod_provincia = c.cod_provincia)
LEFT JOIN TARJETA_CLIENTE tc
    ON(c.numrun = tc.numrun)
LEFT JOIN TRANSACCION_TARJETA_CLIENTE ttc
    ON(tc.nro_tarjeta = ttc.nro_tarjeta)
GROUP BY c.numrun,c.dvrun,c.pnombre,c.snombre,appaterno,c.apmaterno, c.direccion, p.nombre_provincia, r.nombre_region
ORDER BY r.nombre_region,c.appaterno;
--Informe 2
SELECT sr.id_sucursal "ID SUCURSAL",
r.nombre_region "REGION",
p.nombre_provincia "PROVINCIA",
co.nombre_comuna "COMUNA",
sr.direccion "DIRECCION",
COUNT(
    CASE 
        WHEN ttc.cod_tptran_tarjeta = 101 THEN ttc.nro_transaccion
    END
) "COMPRAS VIGENTES",
COALESCE(TO_CHAR(SUM(
    CASE 
        WHEN ttc.cod_tptran_tarjeta = 101 THEN ttc.monto_total_transaccion
    END), '$99G999G999'), '$0') "MONTO TOTAL COMPRAS",
COUNT(
    CASE 
        WHEN ttc.cod_tptran_tarjeta = 102 THEN ttc.nro_transaccion
    END
) "AVANCES VIGENTES",
COALESCE(TO_CHAR(SUM(
    CASE 
        WHEN ttc.cod_tptran_tarjeta = 102 THEN ttc.monto_total_transaccion
    END), '$99G999G999'), '$0')"MONTO TOTAL AVANCES",
COUNT(
    CASE 
        WHEN ttc.cod_tptran_tarjeta = 103 THEN ttc.nro_transaccion
    END
) "SUPER AVANCES VIGENTES",
COALESCE(TO_CHAR(SUM(
    CASE 
        WHEN ttc.cod_tptran_tarjeta = 103 THEN ttc.monto_total_transaccion
    END), '$99G999G999'), '$0')"MONTO TOTAL SUPER AVANCES"
FROM REGION r JOIN PROVINCIA p
    ON(r.cod_region = p.cod_region)
JOIN COMUNA co
    ON(p.cod_region = co.cod_region)
    AND(p.cod_provincia = co.cod_provincia)
RIGHT JOIN SUCURSAL_RETAIL sr
    ON(sr.cod_region = r.cod_region)
    AND(sr.cod_provincia = p.cod_provincia)
    AND(sr.cod_comuna = co.cod_comuna)
LEFT JOIN TRANSACCION_TARJETA_CLIENTE ttc
    ON(ttc.id_sucursal = sr.id_sucursal)
GROUP BY sr.id_sucursal, r.nombre_region, p.nombre_provincia, co.nombre_comuna, sr.direccion
ORDER BY r.nombre_region, sr.id_sucursal;

SELECT DISTINCT id_sucursal FROM transaccion_tarjeta_cliente; 
SELECT DISTINCT id_sucursal FROM SUCURSAL_RETAIL;