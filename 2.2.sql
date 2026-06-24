--Requerimiento 1--

--MONTO TOTAL AHORRADO EN TODOS LOS PRODUCTOS DE INVERSIÓN Y/O AHORRO	CATEGORIZACIÓN DEL CLIENTE
--Entre $100.000 y $1.000.000	                                                BRONCE
--Entre $1.000.001 y $4.000.000	                                                PLATA
--Entre $4.000.001 y $8.000.000	                                                SILVER
--Entre $8.000.001 y $15.000.000	                                            GOLD
--Mayor a $15.000.000	                                                        PLATINUM

CREATE OR REPLACE VIEW v_categoria_ahorro_cliente
AS 
SELECT TO_CHAR(c.numrun, '09G999G999') || '-' || UPPER(c.dvrun) "RUN CLIENTE",
c.pnombre || ' ' || c.snombre || ' ' || c.appaterno || ' ' || c.apmaterno "NOMBRE CLIENTE",
po.nombre_prof_ofic "PROFESION U OFICIO",
tc.nombre_tipo_contrato  "TIPO CONTRATO",
    TO_CHAR(SUM(pic.monto_total_ahorrado), '$99G999G999') "MONTO TOTAL AHORRADO",
CASE
    WHEN SUM(pic.monto_total_ahorrado) BETWEEN 100000 AND 1000000 THEN 'BRONCE'
    WHEN SUM(pic.monto_total_ahorrado) BETWEEN 1000001 AND 4000000 THEN 'PLATA'
    WHEN SUM(pic.monto_total_ahorrado) BETWEEN 4000001 AND 8000000 THEN 'SILVER'
    WHEN SUM(pic.monto_total_ahorrado) BETWEEN 8000001 AND 15000000 THEN 'GOLD'
    WHEN SUM(pic.monto_total_ahorrado) > 15000000 THEN 'PLATINUM'
    ELSE ' '
    END "CATEGORIA CLIENTE"
FROM PRODUCTO_INVERSION_CLIENTE pic LEFT JOIN CLIENTE c ON(pic.nro_cliente = c.nro_cliente)
    LEFT JOIN PROFESION_OFICIO po ON(c.cod_prof_ofic = po.cod_prof_ofic)
    LEFT JOIN TIPO_CONTRATO tc ON(c.cod_tipo_contrato = tc.cod_tipo_contrato)
GROUP BY c.numrun, c.dvrun, c.pnombre, c.snombre, c.appaterno, c.apmaterno, po.nombre_prof_ofic, tc.nombre_tipo_contrato
ORDER BY c.appaterno, "MONTO TOTAL AHORRADO" DESC
WITH READ ONLY;

--CASO/REQUERIMIENTO 3 ACTIVIDAD 2.2
DROP SEQUENCE SEQ_SII_RUN_PREFIJO;
DROP SEQUENCE SEQ_SII_RUN_DV;
DROP SEQUENCE SEQ_SII_CANTIDAD;
DROP SEQUENCE SEQ_SII_MONTO;

CREATE SEQUENCE SEQ_SII_RUN_PREFIJO START WITH 10 INCREMENT BY 2  NOCACHE;
CREATE SEQUENCE SEQ_SII_RUN_DV      START WITH 10 INCREMENT BY 30 NOCACHE;
CREATE SEQUENCE SEQ_SII_CANTIDAD    START WITH 1  INCREMENT BY 1  NOCACHE;
CREATE SEQUENCE SEQ_SII_MONTO       MAXVALUE 100 MINVALUE 1 START WITH 100 INCREMENT BY -1 NOCACHE;

DROP FUNCTION FN_NEXT_RUN_PREFIJO;
DROP FUNCTION FN_NEXT_RUN_DV;
DROP FUNCTION FN_NEXT_CANTIDAD;
DROP FUNCTION FN_NEXT_MONTO;

CREATE OR REPLACE FUNCTION FN_NEXT_RUN_PREFIJO RETURN NUMBER IS
BEGIN
   RETURN SEQ_SII_RUN_PREFIJO.NEXTVAL;
END;
/

CREATE OR REPLACE FUNCTION FN_NEXT_RUN_DV RETURN NUMBER IS
BEGIN
   RETURN SEQ_SII_RUN_DV.NEXTVAL;
END;
/

CREATE OR REPLACE FUNCTION FN_NEXT_CANTIDAD RETURN NUMBER IS
BEGIN
   RETURN SEQ_SII_CANTIDAD.NEXTVAL;
END;
/

CREATE OR REPLACE FUNCTION FN_NEXT_MONTO RETURN NUMBER IS
BEGIN
   RETURN SEQ_SII_MONTO.NEXTVAL;
END;
/

CREATE OR REPLACE VIEW VW_INFORME_SII AS
SELECT EXTRACT(YEAR FROM SYSDATE)"ANNO_TRIBURARIO", FN_NEXT_RUN_PREFIJO() || ' ' ||
SUBSTR(LPAD(TO_CHAR(BASE.NUMRUN),8,'0'),1,2) || '.' ||
SUBSTR(LPAD(TO_CHAR(BASE.NUMRUN),8,'0'),3,3) || '.' ||
SUBSTR(LPAD(TO_CHAR(BASE.NUMRUN),8,'0'),6,3) || '-' ||
TO_CHAR( DECODE(UPPER(BASE.DVRUN),'K',10,TO_NUMBER(BASE.DVRUN))+ FN_NEXT_RUN_DV()) "RUN_CLIENTE",
BASE.NOMBRE_CLIENTE "NOMBRE_CLIENTE",
POWER(FN_NEXT_CANTIDAD(),2)*10 + BASE.CANT_PROD "TOTAL_PROD_INV_AFECTOS_OMPTO",
TO_NUMBER(TO_CHAR(BASE.MONTO_TOTAL) || TO_CHAR(FN_NEXT_MONTO())) "MONTO_TOTAL_AHORRADO" FROM (
SELECT C.NUMRUN,C.DVRUN, INITCAP(C.PNOMBRE) || ' ' || SUBSTR(INITCAP(C.SNOMBRE),1,1) || '. ' ||
INITCAP(C.APPATERNO) || ' ' || INITCAP(C.APMATERNO) "NOMBRE_CLIENTE",C.APPATERNO, COUNT(*) "CANT_PROD",
SUM(PIC.MONTO_TOTAL_AHORRADO) "MONTO_TOTAL" FROM CLIENTE C
JOIN PRODUCTO_INVERSION_CLIENTE PIC ON PIC.NRO_CLIENTE = C.NRO_CLIENTE
JOIN PRODUCTO_INVERSION PI ON PI.COD_PROD_INV = PIC.COD_PROD_INV
WHERE PIC.COD_PROD_INV IN (30,35,40,45,50,55)
GROUP BY C.NUMRUN, C.DVRUN, C.PNOMBRE, C.SNOMBRE, C.APPATERNO, C.APMATERNO
ORDER BY C.APPATERNO
) BASE;

SELECT * FROM VW_INFORME_SII;


--Requerimiento 4
--Informe 1
CREATE OR REPLACE VIEW v_total_creditos_cliente
AS 
SELECT TO_CHAR(c.numrun, '09G999G999') || '-' || UPPER(c.dvrun) "RUN CLIENTE",
INITCAP(c.pnombre || ' ' || c.snombre || ' ' || c.appaterno || ' ' || c.apmaterno) "NOMBRE CLIENTE",
COUNT(cc.nro_solic_credito) "TOTAL CREDITOS SOLICITADOS",
TO_CHAR(SUM(cc.monto_solicitado), '$9G999G999') "MONTO TOTAL CREDITOS"
FROM CREDITO_CLIENTE cc LEFT JOIN CLIENTE c ON(cc.nro_cliente = c.nro_cliente)
WHERE EXTRACT(YEAR FROM cc.fecha_solic_cred) != EXTRACT(YEAR FROM SYSDATE)
GROUP BY c.numrun, c.dvrun, c.pnombre, c.snombre, c.appaterno, c.apmaterno
ORDER BY c.appaterno;

--Informe 2
CREATE OR REPLACE VIEW v_abonos_rescates_cliente
AS
SELECT TO_CHAR(c.numrun, '09G999G999') || '-' || UPPER(c.dvrun) "RUN CLIENTE",
INITCAP(c.pnombre || ' ' || c.snombre || ' ' || c.appaterno || ' ' || c.apmaterno) "NOMBRE CLIENTE",
COALESCE(TO_CHAR(SUM(CASE WHEN m.cod_tipo_mov = (SELECT tm2.cod_tipo_mov FROM TIPO_MOVIMIENTO tm2 WHERE tm2.nombre_tipo_mov = 'Abono')
    THEN m.monto_movimiento 
    END), '$9G999G999'), 'No realizó')  "ABONOS",
COALESCE(TO_CHAR(SUM(CASE WHEN m.cod_tipo_mov = (SELECT tm2.cod_tipo_mov FROM TIPO_MOVIMIENTO tm2 WHERE tm2.nombre_tipo_mov = 'Rescate')
    THEN m.monto_movimiento
    END), '$9G999G999'), 'No realizó') "RESCATES"    
FROM MOVIMIENTO m LEFT JOIN CLIENTE c ON(m.nro_cliente = c.nro_cliente)
    JOIN TIPO_MOVIMIENTO tm ON(tm.cod_tipo_mov = m.cod_tipo_mov)
WHERE EXTRACT(YEAR FROM m.fecha_movimiento) != EXTRACT(YEAR FROM SYSDATE)
GROUP BY c.numrun, c.dvrun, c.pnombre, c.snombre, c.appaterno, c.apmaterno
ORDER BY c.appaterno;


