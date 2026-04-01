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
CASE
    WHEN dias_solicitados > (fecha_devolucion - fecha_ini_arriendo)
    THEN dias_solicitados - (fecha_devolucion - fecha_ini_arriendo)
    ELSE (fecha_devolucion - fecha_ini_arriendo) - dias_solicitados
END
"DIAS_ATRASO"
FROM arriendo_camion
WHERE CASE
    WHEN dias_solicitados > (fecha_devolucion - fecha_ini_arriendo)
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

SELECT * FROM empleado;

SELECT TO_NUMBER(numrun_emp, '00.000.000') 
FROM empleado;

