--MADE BY CORINA URRUTIA--

-------TABLES-------
SELECT * FROM CLIENTE;
SELECT * FROM COMUNA;
SELECT * FROM CREDITO;
SELECT * FROM CREDITO_CLIENTE;
SELECT * FROM CUOTA_CREDITO_CLIENTE;
SELECT * FROM FORMA_PAGO;
SELECT * FROM MOVIMIENTO;
SELECT * FROM PRODUCTO_INVERSION;
SELECT * FROM PRODUCTO_INVERSION_CLIENTE;
SELECT * FROM PROFESION_OFICIO;
SELECT * FROM PROVINCIA;
SELECT * FROM REGION;
SELECT * FROM SUCURSAL_BANCO;
SELECT * FROM TIPO_CLIENTE;
SELECT * FROM TIPO_MOVIMIENTO;
----------------------

---CASO 1---

SELECT TO_CHAR(c.numrun, '09G999G999')||'-'||UPPER(c.dvrun) "RUN CLIENTE",
INITCAP(pnombre)||' '||INITCAP(snombre)||' '||INITCAP(appaterno)||' '||INITCAP(apmaterno) "NOMBRE CLIENTE",
po.nombre_prof_ofic "PROFESION/OFICIO",
TO_CHAR(c.fecha_nacimiento, 'DD "de" Month') "DIA DE CUMPLEAÑOS"
FROM CLIENTE c INNER JOIN PROFESION_OFICIO po ON(c.cod_prof_ofic = po.cod_prof_ofic)
WHERE EXTRACT(MONTH FROM c.fecha_nacimiento) = EXTRACT(MONTH FROM SYSDATE) + 5
ORDER BY EXTRACT(DAY FROM c.fecha_nacimiento), c.appaterno;

---CASO 2---

SELECT TO_CHAR(c.numrun, '09G999G999')||'-'||UPPER(c.dvrun) "RUN CLIENTE",
c.pnombre||' '|| c.snombre||' '||c.appaterno||' '||c.apmaterno "NOMBRE CLIENTE",
TO_CHAR(SUM(cc.monto_solicitado), '$9G999G999') "MONTO SOLICITADO CREDITOS",
TO_CHAR((SUM(cc.monto_solicitado)/100000)*1200, '$999G999') "TOTAL PESOS TODOSUMA"
FROM CREDITO_CLIENTE cc INNER JOIN CLIENTE c ON(cc.nro_cliente=c.nro_cliente)
WHERE EXTRACT(YEAR FROM cc.fecha_otorga_cred) = EXTRACT(YEAR FROM SYSDATE) -1
AND ADD_MONTHS(SYSDATE, - 36) < cc.fecha_otorga_cred
GROUP BY c.numrun,c.dvrun,c.pnombre,c.snombre,c.appaterno,c.apmaterno
ORDER BY SUM(cc.monto_solicitado), c.appaterno;

---CASO 3---

SELECT TO_CHAR(cc.fecha_otorga_cred, 'MMYYYY') "MES TRANSACCIÓN",
UPPER(c.nombre_credito) "TIPO CREDITO",
ROUND(SUM(cc.monto_credito)) "MONTO SOLICITADO CREDITO",
ROUND(SUM(CASE
WHEN cc.monto_credito BETWEEN 100000 AND 1000000 THEN cc.monto_credito * 0.01
WHEN cc.monto_credito BETWEEN 1000001 AND 2000000 THEN cc.monto_credito * 0.02
WHEN cc.monto_credito BETWEEN 2000001 AND 4000000 THEN cc.monto_credito * 0.03
WHEN cc.monto_credito BETWEEN 4000001 AND 6000000 THEN cc.monto_credito * 0.04
ELSE cc.monto_credito * 0.07
END)) "APORTE A LA SBIF"
FROM CREDITO_CLIENTE cc INNER JOIN CREDITO c ON(cc.cod_credito = c.cod_credito)
WHERE EXTRACT(YEAR FROM cc.fecha_otorga_cred) = EXTRACT(YEAR FROM SYSDATE) -1
GROUP BY TO_CHAR(cc.fecha_otorga_cred, 'MMYYYY'), c.nombre_credito
ORDER BY "MES TRANSACCIÓN", c.nombre_credito;

---CASO 4---

SELECT CONCAT(TO_CHAR(c.numrun, '09G999G999') || '-', UPPER(c.dvrun)) "RUN CLIENTE",
CONCAT(c.pnombre||' ', c.snombre) || ' ' || CONCAT(c.appaterno ||' ',c.apmaterno) "NOMBRE CLIENTE",
TO_CHAR(SUM(pic.monto_total_ahorrado), '$99G999G999') "MONTO TOTAL AHORRADO",
CASE
  WHEN SUM(pic.monto_total_ahorrado) BETWEEN 100000  AND 1000000  THEN 'BRONCE'
  WHEN SUM(pic.monto_total_ahorrado) BETWEEN 1000001 AND 4000000  THEN 'PLATA'
  WHEN SUM(pic.monto_total_ahorrado) BETWEEN 4000001 AND 8000000  THEN 'SILVER'
  WHEN SUM(pic.monto_total_ahorrado) BETWEEN 8000001 AND 15000000 THEN 'GOLD'
  WHEN SUM(pic.monto_total_ahorrado) > 15000000 THEN 'PLATINUM'
END "CATEGORIA CLIENTE"
FROM CLIENTE c JOIN PRODUCTO_INVERSION_CLIENTE pic ON(c.nro_cliente = pic.nro_cliente)
GROUP BY c.numrun, c.dvrun, c.pnombre, c.snombre, c.appaterno, c.apmaterno
HAVING SUM(pic.monto_total_ahorrado) > 99999
ORDER BY c.appaterno, SUM(pic.monto_total_ahorrado) DESC;

---CASE 5---

SELECT EXTRACT(YEAR FROM SYSDATE) "AÑO TRIBUTARIO",
CONCAT(TO_CHAR(c.numrun, '09G999G999')||'-',c.dvrun) "RUN CLIENTE",
INITCAP(c.pnombre ||' '|| CONCAT(SUBSTR(c.snombre, 1,1), '.') ||' '|| c.appaterno ||' ' || c.apmaterno) "NOMBRE CLIENTE",
COUNT(pic.cod_prod_inv) "TOTAL PROD. INV AFECTOS IMPTO",
TO_CHAR(SUM(pic.monto_total_ahorrado), '$99G999G999') "MONTO TOTAL AHORRADO"
FROM CLIENTE c JOIN PRODUCTO_INVERSION_CLIENTE pic ON(c.nro_cliente =  pic.nro_cliente)
JOIN PRODUCTO_INVERSION pi ON(pic.cod_prod_inv = pi.cod_prod_inv)
WHERE pi.nombre_prod_inv = 'Dep�sito a Plazo' OR pi.nombre_prod_inv LIKE 'Fondos Mutuos%'
GROUP BY c.numrun, c.dvrun, c.pnombre, c.snombre, c.appaterno, c.apmaterno 
ORDER BY c.appaterno;

---CASE 6---
--INFORME 1--

SELECT CONCAT(TO_CHAR(c.numrun, '09G999G999')||'-',UPPER(c.dvrun)) "RUN CLIENTE",
INITCAP(c.pnombre||' '|| c.snombre||' '||c.appaterno||' '||c.apmaterno) "NOMBRE CLIENTE",
COUNT(cc.nro_solic_credito) "TOTAL CREDITOS SOLICITADOS",
TO_CHAR(SUM(cc.monto_solicitado),'$99G999G999') "MONTO TOTAL CREDITOS"
FROM CLIENTE c JOIN CREDITO_CLIENTE cc ON(c.nro_cliente = cc.nro_cliente)
WHERE EXTRACT(YEAR FROM cc.fecha_solic_cred) = EXTRACT(YEAR FROM SYSDATE) -1
GROUP BY c.nro_cliente, c.numrun, c.dvrun, c.pnombre, c.snombre, c.appaterno, c.apmaterno
ORDER BY c.appaterno;

--INFORME 2--

SELECT CONCAT(TO_CHAR(c.numrun, '09G999G999')||'-',UPPER(c.dvrun)) "RUN CLIENTE",
INITCAP(c.pnombre||' '|| c.snombre||' '||c.appaterno||' '||c.apmaterno) "NOMBRE CLIENTE",
NVL(TO_CHAR(SUM(
CASE m.cod_tipo_mov 
WHEN 1 THEN m.monto_movimiento
END), '$999G999'), 'No realizó') "ABONOS",
NVL(TO_CHAR(SUM(
CASE m.cod_tipo_mov 
WHEN 2 THEN m.monto_movimiento
END), '$999G999'), 'No realizó') "RESCATES"
FROM CLIENTE c JOIN MOVIMIENTO m ON (c.nro_cliente = m.nro_cliente)
JOIN TIPO_MOVIMIENTO tp ON(m.cod_tipo_mov = tp.cod_tipo_mov)
WHERE EXTRACT(YEAR FROM m.fecha_movimiento) = EXTRACT(YEAR FROM SYSDATE) -1
GROUP BY c.numrun, c.dvrun, c.pnombre, c.snombre, c.appaterno, c.apmaterno
ORDER BY c.appaterno;


--MADE BY CORINA URRUTIA--