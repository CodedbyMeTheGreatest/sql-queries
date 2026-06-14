--Caso 2

--
-- 
SAVEPOINT A;
--La tabla viene creada, asi que no es necesaria crearla aqui.

INSERT ALL 
INTO CLIENTES_ARRIENDOS_MENOS_PROM (anno_proceso, nombre_cliente, total_arriendos)
VALUES(anno_proceso, nombre_cliente, total_arriendos)
SELECT EXTRACT(YEAR FROM SYSDATE) ANNO_PROCESO, 
INITCAP(c.pnombre_cli || ' ' || c.snombre_cli || ' ' || c.appaterno_cli || ' ' || c.apmaterno_cli) NOMBRE_CLIENTE,
COALESCE(COUNT(ac.id_arriendo), 0) TOTAL_ARRIENDOS
FROM CLIENTE c LEFT JOIN ARRIENDO_CAMION ac ON(c.numrun_cli = ac.numrun_cli) AND(EXTRACT(YEAR FROM SYSDATE) = EXTRACT(YEAR FROM ac.fecha_ini_arriendo))
GROUP BY c.pnombre_cli, c.snombre_cli, c.appaterno_cli, c.apmaterno_cli
HAVING COUNT(ac.id_arriendo) <= (SELECT AVG(total) FROM (SELECT COUNT(id_arriendo) total FROM CLIENTE c2 LEFT JOIN ARRIENDO_CAMION ac2 ON(c2.numrun_cli = ac2.numrun_cli) AND(EXTRACT(YEAR FROM SYSDATE) = EXTRACT(YEAR FROM ac2.fecha_ini_arriendo))))
ORDER BY c.appaterno_cli;

SELECT * FROM CLIENTE;
UPDATE CLIENTE 
SET ID_CATEGORIA_CLI = 100
WHERE INITCAP(pnombre_cli || ' ' || snombre_cli || ' ' || appaterno_cli || ' ' || apmaterno_cli) IN (SELECT nombre_cliente FROM CLIENTES_ARRIENDOS_MENOS_PROM);

COMMIT;

ROLLBACK TO A;

--Caso 4

SELECT * FROM HIST_ARRIENDO_ANUAL_CAMION;
SELECT * FROM CAMION;

SAVEPOINT B;

INSERT ALL
INTO HIST_ARRIENDO_ANUAL_CAMION(anno_proceso, nro_patente, valor_arriendo_dia, valor_garactia_dia, total_veces_arrendado)
VALUES(anno_proceso, nro_patente, valor_arriendo_dia, valor_garactia_dia, total_veces_arrendado)
SELECT EXTRACT(YEAR FROM SYSDATE) ANNO_PROCESO,
c.nro_patente NRO_PATENTE,
c.valor_arriendo_dia VALOR_ARRIENDO_DIA,
c.valor_garantia_dia VALOR_GARACTIA_DIA,
COALESCE(COUNT(ac.id_arriendo), 0) TOTAL_VECES_ARRENDADO
FROM CAMION c LEFT JOIN ARRIENDO_CAMION ac ON(c.nro_patente = ac.nro_patente)
GROUP BY c.nro_patente, c.valor_arriendo_dia, c.valor_garantia_dia
ORDER BY c.nro_patente;

COMMIT;

ROLLBACK TO B;


--Caso 5--

--ciudadanos que, durante el año, 
--han obtenido ingresos por un monto superior a los $7.833.186 
--(13,5 Unidades Tributarias Anuales, UTA); 

--empleado -> valor mensual
SELECT *
FROM EMPLEADO;


SELECT numrun_emp,
dvrun_emp,
EXTRACT(YEAR FROM SYSDATE) ANNO_TRIBUTARIO,
UPPER(pnombre_emp || ' ' || snombre_emp || ' ' || appaterno_emp || ' ' || apmaterno_emp) NOMBRE_EMP,
CASE WHEN MONTHS_BETWEEN(TO_DATE(CONCAT('31/12/', (EXTRACT(YEAR FROM SYSDATE)-1)), 'DD/MM/YYYY'),fecha_contrato) > 12 THEN 12
    ELSE ROUND(MONTHS_BETWEEN(TO_DATE(CONCAT('31/12/', (EXTRACT(YEAR FROM SYSDATE)-1)), 'DD/MM/YYYY'),fecha_contrato), 1)
    END MESES_TRABAJADOS_ANNO,
ROUND((MONTHS_BETWEEN(TO_DATE(CONCAT('31/12/', (EXTRACT(YEAR FROM SYSDATE)-1)), 'DD/MM/YYYY'), fecha_contrato) / 12)) ANNOS_TRABAJADOS,
sueldo_base SUELDO_BASE_MENSUAL,
ROUND(sueldo_base * 
    (CASE WHEN MONTHS_BETWEEN(TO_DATE(CONCAT('31/12/', (EXTRACT(YEAR FROM SYSDATE)-1)), 'DD/MM/YYYY'),fecha_contrato) > 12 THEN 12
    ELSE ROUND(MONTHS_BETWEEN(TO_DATE(CONCAT('31/12/', (EXTRACT(YEAR FROM SYSDATE)-1)), 'DD/MM/YYYY'),fecha_contrato), 1)
    END))  SUELDO_BASE_ANUAL,
ROUND((sueldo_base * (MONTHS_BETWEEN(TO_DATE(CONCAT('31/12/', (EXTRACT(YEAR FROM SYSDATE)-1)), 'DD/MM/YYYY'), fecha_contrato) / 12/ 100)) *  
    (CASE WHEN MONTHS_BETWEEN(TO_DATE(CONCAT('31/12/', (EXTRACT(YEAR FROM SYSDATE)-1)), 'DD/MM/YYYY'),fecha_contrato) > 12 THEN 12
    ELSE 0
    END)) BONO_POR_ANNOS_ANUAL,
ROUND((sueldo_base * 0.12) * 12) MOVILIZACIÓN_ANUAL,
ROUND((sueldo_base * 0.2) * 12) COLACIÓN_ANUAL,
ROUND((sueldo_base * 
    (CASE WHEN MONTHS_BETWEEN(TO_DATE(CONCAT('31/12/', (EXTRACT(YEAR FROM SYSDATE)-1)), 'DD/MM/YYYY'),fecha_contrato) > 12 THEN 12
    ELSE ROUND(MONTHS_BETWEEN(TO_DATE(CONCAT('31/12/', (EXTRACT(YEAR FROM SYSDATE)-1)), 'DD/MM/YYYY'),fecha_contrato), 1)
    END)) + (sueldo_base * (MONTHS_BETWEEN(TO_DATE(CONCAT('31/12/', (EXTRACT(YEAR FROM SYSDATE)-1)), 'DD/MM/YYYY'), fecha_contrato) / 12/ 100)) *  
    (CASE WHEN MONTHS_BETWEEN(TO_DATE(CONCAT('31/12/', (EXTRACT(YEAR FROM SYSDATE)-1)), 'DD/MM/YYYY'),fecha_contrato) > 12 THEN 12
    ELSE 0
    END) + ((sueldo_base * 0.12) * 12) + ((sueldo_base * 0.2) * 12)) SUELDO_BRUTO_ANUAL,
ROUND((sueldo_base * 
    (CASE WHEN MONTHS_BETWEEN(TO_DATE(CONCAT('31/12/', (EXTRACT(YEAR FROM SYSDATE)-1)), 'DD/MM/YYYY'),fecha_contrato) > 12 THEN 12
    ELSE ROUND(MONTHS_BETWEEN(TO_DATE(CONCAT('31/12/', (EXTRACT(YEAR FROM SYSDATE)-1)), 'DD/MM/YYYY'),fecha_contrato), 1)
    END)) + ((sueldo_base * (MONTHS_BETWEEN(TO_DATE(CONCAT('31/12/', (EXTRACT(YEAR FROM SYSDATE)-1)), 'DD/MM/YYYY'), fecha_contrato) / 12/ 100)) *  
    (CASE WHEN MONTHS_BETWEEN(TO_DATE(CONCAT('31/12/', (EXTRACT(YEAR FROM SYSDATE)-1)), 'DD/MM/YYYY'),fecha_contrato) > 12 THEN 12
    ELSE 0
    END))) RENTA_IMPONIBLE_ANUAL 
FROM EMPLEADO
ORDER BY numrun_emp;
--empleado -> valor anual













