-------------------------------------------------------
------------------------Caso 1-------------------------
-----------Obtenemos el rut, nombre completo-----------
------y fecha de nacimiento de todos los clientes------
-------que esten de cumpleaños el dia siguiente--------
--------al que se este ejecutando el script.-----------
-------------------------------------------------------

SELECT * FROM cliente;

SELECT numrun_cli||'-'||dvrun_cli 
"RUN CLIENTE", 
pnombre_cli||' '||snombre_cli||' '||appaterno_cli||' '||apmaterno_cli 
"NOMBRE COMPLETO CLIENTE",
fecha_nac_cli 
"FECHA NACIMIENTO"
FROM cliente
WHERE TO_CHAR(fecha_nac_cli, 'DD/MM') = TO_CHAR(SYSDATE + 1, 'DD/MM');

--Misma consulta, pero esta vez con la fecha que esta en el ejemplo de la guia.
SELECT numrun_cli||'-'||dvrun_cli 
"RUN CLIENTE", 
pnombre_cli||' '||snombre_cli||' '||appaterno_cli||' '||apmaterno_cli 
"NOMBRE COMPLETO CLIENTE",
fecha_nac_cli 
"FECHA NACIMIENTO"
FROM cliente
WHERE TO_CHAR(fecha_nac_cli, 'DD/MM') = 
TO_CHAR(TO_DATE('20/08/2026', 'DD/MM/YYYY')+1, 'DD/MM');
---

--------------------------------------------------------
------------------------Caso 2--------------------------
--Consultamos por el run, nombre completo, sueldo base--
--porcentaje de moviliacion y el valor de movilizcion---
-----------------de cada empleado.----------------------
--------------------------------------------------------

SELECT * FROM empleado;

SELECT numrun_emp||' '||dvrun_emp 
"RUN EMPLEADO",
pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp 
"NOMBRE COMPLETO EMPLEADO",
sueldo_base 
"SUELDO BASE",
TRUNC(sueldo_base/100000)
"PORCENTAJE MOVILIZACIÓN",
ROUND(sueldo_base*(TRUNC(sueldo_base/100000)/100))
"VALOR MOVILIZACIÓN"
FROM empleado
ORDER BY "PORCENTAJE MOVILIZACIÓN" DESC;
--

--------------------------------------------------------
------------------------Caso 3--------------------------
--Consultar por el run, nombre completo, sueldo base,---
--fecha de nacimiento, nombre de usuario y clave.-------
--------------------------------------------------------

SELECT numrun_emp||' '||dvrun_emp 
"RUN EMPLEADO",
pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp 
"NOMBRE COMPLETO EMPLEADO",
sueldo_base 
"SUELDO BASE", 
TO_CHAR(fecha_nac , 'DD/MM/YYYY')
"FECHA NACIMIENTO", 
SUBSTR(pnombre_emp, 1, 3)||LENGTH(pnombre_emp)||'*'||SUBSTR(sueldo_base,-1)||dvrun_emp||ROUND(MONTHS_BETWEEN(SYSDATE,fecha_contrato)/12) 
"NOMBRE USUARIO",
SUBSTR(numrun_emp, 3, 1)||EXTRACT(YEAR FROM fecha_contrato)+2||SUBSTR(sueldo_base, -3, 3)-1||SUBSTR(appaterno_emp, -2, 2)||TO_CHAR(EXTRACT(MONTH FROM SYSDATE))
"CLAVE"
FROM empleado
ORDER BY appaterno_emp ASC;
--

--------------------------------------------------------
------------------------Caso 4--------------------------
----Consultamos por el año de la consulta, la patente,--
----el valor de arriendo y garantia sin rebaja,---------
--------año de antiguedad, valor de arriendo y----------
----------------la garantia con rebaja.-----------------
--------------------------------------------------------

SELECT * FROM camion;

SELECT EXTRACT(YEAR FROM SYSDATE)
"ANNO_PROCESO",
nro_patente,
valor_arriendo_dia 
"VALOR_ARRIENDO_DIA_SR",
valor_garantia_dia
"VALOR_GARANTIA_DIA_SR",
EXTRACT(YEAR FROM SYSDATE) - anio
"ANNOS_ANTIGUEDAD",
valor_arriendo_dia * (1-(EXTRACT(YEAR FROM SYSDATE) - anio)/100)
"VALOR_ARRIENDO_DIA_CR",
valor_garantia_dia* (1-(EXTRACT(YEAR FROM SYSDATE) - anio)/100)
"VALOR_GARANTIA_DIA_CR"
FROM camion
ORDER BY "ANNOS_ANTIGUEDAD" DESC, nro_patente ASC;
--

-------------------------------------------------------------------
------------------------Caso 5-------------------------------------
----Consultamos el mes y año del proceso, el numero de patentem,---
--------la fecha de inicio del arriendo, dias solicitados,---------
------fecha de devolucion, dias de atraso y valor de la multa.-----
-------------------------------------------------------------------

SELECT * FROM camion;

SELECT TO_CHAR(SYSDATE, 'MM/YYYY')
"MES_ANNO_PROCESO",
nro_patente,
fecha_ini_arriendo,
dias_solicitados,
fecha_devolucion,
CASE WHEN dias_solicitados > (fecha_devolucion - fecha_ini_arriendo)
THEN dias_solicitados - (fecha_devolucion - fecha_ini_arriendo)
ELSE (fecha_devolucion - fecha_ini_arriendo) - dias_solicitados
END
"DIAS_ATRASO"
FROM arriendo_camion
WHERE CASE WHEN dias_solicitados > (fecha_devolucion - fecha_ini_arriendo)
THEN dias_solicitados - (fecha_devolucion - fecha_ini_arriendo)
ELSE (fecha_devolucion - fecha_ini_arriendo) - dias_solicitados
END != 0
AND EXTRACT(MONTH FROM fecha_ini_arriendo) = EXTRACT(MONTH FROM ADD_MONTHS(SYSDATE,-1))
AND EXTRACT(YEAR FROM fecha_ini_arriendo) = EXTRACT(YEAR FROM ADD_MONTHS(SYSDATE,-1))
AND EXTRACT(MONTH FROM fecha_devolucion) = EXTRACT(MONTH FROM ADD_MONTHS(SYSDATE,-1))
AND EXTRACT(YEAR FROM fecha_devolucion) = EXTRACT(YEAR FROM ADD_MONTHS(SYSDATE,-1))
ORDER BY fecha_ini_arriendo, nro_patente ASC;

-------------------------------------------------------------------
----------------------------CASO 6---------------------------------
-----Consultamos fecha de proceso, run, nombre completo,-----------
-----------sueldo base, bonificacion por utilidades..--------------
-------------------------------------------------------------------

SELECT TO_CHAR(SYSDATE, 'MM/YYYY') "FECHA PROCESO",
TO_CHAR(numrun_emp, '99G999G999')||'-'||dvrun_emp 
"RUN EMPLEADO",
pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp 
"NOMBRE EMPLEADO",
TO_CHAR(sueldo_base, '$9G999G999') 
"SUELDO BASE",
TO_CHAR(CASE WHEN sueldo_base BETWEEN 320000 AND 450000 
THEN (200000000 * 0.005)
WHEN sueldo_base BETWEEN 450001 AND 600000 
THEN (200000000 * 0.0035)
WHEN sueldo_base BETWEEN 600001 AND 900000 
THEN (200000000 * 0.0025)
WHEN sueldo_base BETWEEN 900001 AND 1800000 
THEN (200000000 * 0.0015)
WHEN sueldo_base > 1800000 
THEN (200000000 * 0.001)
END, '$9G999G999') 
"BONIFICACION POR UTILIDADES"
FROM empleado
ORDER BY appaterno_emp ASC;

-------------------------------------------------------------------
----------------------------CASO 7---------------------------------
-------Consultamos el run, nombre, años de contrato,--------------- 
---------valor movilizacion, bonif. extra de movilizacion----------
----------------y el valor de movilizacion total.------------------
-------------------------------------------------------------------
SELECT * FROM empleado;
SELECT * FROM comuna ORDER BY nombre_comuna ASC;

SELECT numrun_emp||'-'||dvrun_emp
"RUN EMPLEADO",
pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp 
"NOMBRE EMPLEADO",
ROUND(MONTHS_BETWEEN(SYSDATE, fecha_contrato)/12)
"AÑOS CONTRATADO",
TO_CHAR(sueldo_base, '$9G999G999') 
"SUELDO BASE",
TO_CHAR(ROUND(sueldo_base * (ROUND(MONTHS_BETWEEN(SYSDATE, fecha_contrato)/12)/100)), 
'$9G999G999')
"VALOR MOVILIZACION",
TO_CHAR(CASE WHEN sueldo_base >= 450000 
THEN ROUND(sueldo_base * TO_NUMBER(SUBSTR(sueldo_base, 1,1)) / 100)
WHEN sueldo_base < 450000 
THEN ROUND(sueldo_base * TO_NUMBER(SUBSTR(sueldo_base, 1,2)) / 100)
END, '$9G999G999')
"BONIF. EXTRA MOVILIZACION",
TO_CHAR(ROUND(sueldo_base * (ROUND(MONTHS_BETWEEN(SYSDATE, fecha_contrato)/12)/100))
+ CASE WHEN sueldo_base >= 450000 
THEN ROUND(sueldo_base * TO_NUMBER(SUBSTR(sueldo_base, 1,1)) / 100) 
WHEN sueldo_base < 450000 
THEN ROUND(sueldo_base * TO_NUMBER(SUBSTR(sueldo_base, 1,2)) / 100)
END, '$9G999G999')
"VALOR MOVILIZACION TOTAL"
FROM empleado
WHERE id_comuna in (117, 118, 120, 122, 126)
ORDER BY appaterno_emp ASC;

--117, 118, 120, 122, 126 -> codigos de las ciudades ('María Pinto', 'Curacaví', 'El Monte', 'Paine', 'Pirque').
