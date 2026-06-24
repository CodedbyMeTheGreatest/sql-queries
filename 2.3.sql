-------------------
---ACTIVIDAD 2.3---
-------------------



--CASO 1 

CREATE INDEX IDX_PROD_INV_CLIENTES 
ON PRODUCTO_INVERSION_CLIENTE(COD_PROD_INV);

EXPLAIN PLAN FOR
SELECT EXTRACT(YEAR FROM SYSDATE) "AÑO TRIBUTARIO",
       TO_CHAR(c.numrun,'09G999G999') || '-' || UPPER(c.dvrun) "RUN CLIENTE",
       INITCAP(c.pnombre || ' ' || SUBSTR(c.snombre,1,1) || '. ' || c.appaterno || ' ' || c.apmaterno) "NOMBRE CLIENTE",
       COUNT(pic.nro_cliente) "TOTAL PROD. INV AFECTOS IMPTO",
       LPAD(TO_CHAR(SUM(pic.monto_total_ahorrado),'$999G999G999'),21, ' ') "MONTO TOTAL AHORRADO"
FROM cliente c JOIN producto_inversion_cliente pic
ON c.nro_cliente=pic.nro_cliente
WHERE pic.cod_prod_inv IN(30,35,40,45,50,55)
HAVING COUNT( c.nro_cliente)   IN (SELECT MAX(COUNT(*))
                 FROM producto_inversion_cliente
                 GROUP BY nro_cliente)
GROUP BY numrun,c.dvrun,c.pnombre,c.snombre,c.appaterno,c.apmaterno
ORDER BY c.appaterno;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

---CASO 3 

CREATE INDEX IDX_CREDITO_CLIENTE ON CREDITO_CLIENTE (MONTO_CREDITO);

EXPLAIN PLAN FOR
SELECT TO_CHAR(crc.fecha_otorga_cred,'MMYYYY') "MES TRANSACCIÓN",
       c.nombre_credito "TIPO CREDITO",
       SUM(crc.monto_credito) "MONTO SOLICITADO CREDITO",
       SUM(CASE WHEN crc.monto_credito BETWEEN 100000 AND 1000000 THEN ROUND(crc.monto_credito*0.01)
            WHEN crc.monto_credito BETWEEN 1000001 AND 2000000 THEN ROUND(crc.monto_credito*0.02)
            WHEN crc.monto_credito BETWEEN 2000001 AND 4000000 THEN ROUND(crc.monto_credito*0.03)
            WHEN crc.monto_credito BETWEEN 4000001 AND 6000000 THEN ROUND(crc.monto_credito*0.04)
       ELSE ROUND(crc.monto_credito*0.07) END) "APORTE A LA SBIF"
FROM credito_cliente crc JOIN credito c
ON crc.cod_credito=c.cod_credito
AND crc.monto_credito > (SELECT ROUND(AVG(monto_credito)) FROM credito_cliente)
GROUP BY TO_CHAR(crc.fecha_otorga_cred,'MMYYYY'), c.nombre_credito
ORDER BY TO_CHAR(crc.fecha_otorga_cred,'MMYYYY'), c.nombre_credito;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);



