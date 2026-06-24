
VARIABLE v_run        NUMBER
VARIABLE v_porc_sim1  NUMBER
VARIABLE v_porc_sim2  NUMBER
VARIABLE v_sueldo_min NUMBER
VARIABLE v_sueldo_max NUMBER


EXEC :v_porc_sim1  := 8.5
EXEC :v_porc_sim2  := 20
EXEC :v_sueldo_min := 200000
EXEC :v_sueldo_max := 400000

---Ejecucion 1

EXEC :v_run := 12260812

DECLARE
    v_nombre      VARCHAR2(70);
    v_dvrut       empleado.dvrut_emp%TYPE;
    v_sueldo      empleado.sueldo_emp%TYPE;

    v_reajuste_s1      NUMBER;
    v_sueldo_nuevo_s1  NUMBER;

    v_reajuste_s2      NUMBER;
    v_sueldo_nuevo_s2  NUMBER;

    v_porc_s1_fmt  VARCHAR2(10);

    v_rango_fmt    VARCHAR2(50);

BEGIN
    SELECT e.nombre_emp || ' ' || e.appaterno_emp || ' ' || e.apmaterno_emp,
           e.dvrut_emp,
           e.sueldo_emp
    INTO   v_nombre,
           v_dvrut,
           v_sueldo
    FROM   empleado e
    WHERE  e.numrut_emp = :v_run;

    v_reajuste_s1     := ROUND(v_sueldo * :v_porc_sim1 / 100);
    v_sueldo_nuevo_s1 := v_sueldo + v_reajuste_s1;

    v_reajuste_s2     := ROUND(v_sueldo * :v_porc_sim2 / 100);
    v_sueldo_nuevo_s2 := v_sueldo + v_reajuste_s2;

    v_porc_s1_fmt := REPLACE(TO_CHAR(:v_porc_sim1), '.', ',');

    v_rango_fmt :=
        '$' || REPLACE(TO_CHAR(:v_sueldo_min, 'FM999,999'), ',', '.') ||
        ' y $' || REPLACE(TO_CHAR(:v_sueldo_max, 'FM999,999'), ',', '.');


    DBMS_OUTPUT.PUT_LINE('NOMBRE DEL EMPLEADO: ' || v_nombre);
    DBMS_OUTPUT.PUT_LINE('RUN: ' || TO_CHAR(:v_run) || '-' || v_dvrut);


    DBMS_OUTPUT.PUT_LINE('SIMULACIÓN 1: Aumentar en ' || v_porc_s1_fmt ||
                         '% el salario de todos los empleados');
    DBMS_OUTPUT.PUT_LINE('Sueldo actual: '     || TO_CHAR(v_sueldo));
    DBMS_OUTPUT.PUT_LINE('Sueldo reajustado: ' || TO_CHAR(v_sueldo_nuevo_s1));
    DBMS_OUTPUT.PUT_LINE('Reajuste: '          || TO_CHAR(v_reajuste_s1));

    IF v_sueldo >= :v_sueldo_min AND v_sueldo <= :v_sueldo_max THEN
        DBMS_OUTPUT.PUT_LINE('SIMULACIÓN 2: Aumentar en ' || TO_CHAR(:v_porc_sim2) ||
                             '% el salario de los empleados que poseen salarios entre ' ||
                             v_rango_fmt);
        DBMS_OUTPUT.PUT_LINE('Sueldo actual: '     || TO_CHAR(v_sueldo));
        DBMS_OUTPUT.PUT_LINE('Sueldo reajustado: ' || TO_CHAR(v_sueldo_nuevo_s2));
        DBMS_OUTPUT.PUT_LINE('Reajuste: '          || TO_CHAR(v_reajuste_s2));
    ELSE
        DBMS_OUTPUT.PUT_LINE('SIMULACIÓN 2: El empleado no se encuentra en el rango ' ||
                             v_rango_fmt);
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: No se encontró empleado con RUN ' || TO_CHAR(:v_run));
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/

---Ejecucion 2


EXEC :v_run := 11999100

DECLARE
    v_nombre      VARCHAR2(70);
    v_dvrut       empleado.dvrut_emp%TYPE;
    v_sueldo      empleado.sueldo_emp%TYPE;
    v_reajuste_s1      NUMBER;
    v_sueldo_nuevo_s1  NUMBER;
    v_reajuste_s2      NUMBER;
    v_sueldo_nuevo_s2  NUMBER;
    v_porc_s1_fmt  VARCHAR2(10);
    v_rango_fmt    VARCHAR2(50);

BEGIN
    SELECT e.nombre_emp || ' ' || e.appaterno_emp || ' ' || e.apmaterno_emp,
           e.dvrut_emp,
           e.sueldo_emp
    INTO   v_nombre,
           v_dvrut,
           v_sueldo
    FROM   empleado e
    WHERE  e.numrut_emp = :v_run;

    v_reajuste_s1     := ROUND(v_sueldo * :v_porc_sim1 / 100);
    v_sueldo_nuevo_s1 := v_sueldo + v_reajuste_s1;

    v_reajuste_s2     := ROUND(v_sueldo * :v_porc_sim2 / 100);
    v_sueldo_nuevo_s2 := v_sueldo + v_reajuste_s2;

    v_porc_s1_fmt := REPLACE(TO_CHAR(:v_porc_sim1), '.', ',');

    v_rango_fmt :=
        '$' || REPLACE(TO_CHAR(:v_sueldo_min, 'FM999,999'), ',', '.') ||
        ' y $' || REPLACE(TO_CHAR(:v_sueldo_max, 'FM999,999'), ',', '.');

    DBMS_OUTPUT.PUT_LINE('NOMBRE DEL EMPLEADO: ' || v_nombre);
    DBMS_OUTPUT.PUT_LINE('RUN: ' || TO_CHAR(:v_run) || '-' || v_dvrut);

    DBMS_OUTPUT.PUT_LINE('SIMULACIÓN 1: Aumentar en ' || v_porc_s1_fmt ||
                         '% el salario de todos los empleados');
    DBMS_OUTPUT.PUT_LINE('Sueldo actual: '     || TO_CHAR(v_sueldo));
    DBMS_OUTPUT.PUT_LINE('Sueldo reajustado: ' || TO_CHAR(v_sueldo_nuevo_s1));
    DBMS_OUTPUT.PUT_LINE('Reajuste: '          || TO_CHAR(v_reajuste_s1));

    IF v_sueldo >= :v_sueldo_min AND v_sueldo <= :v_sueldo_max THEN
        DBMS_OUTPUT.PUT_LINE('SIMULACIÓN 2: Aumentar en ' || TO_CHAR(:v_porc_sim2) ||
                             '% el salario de los empleados que poseen salarios entre ' ||
                             v_rango_fmt);
        DBMS_OUTPUT.PUT_LINE('Sueldo actual: '     || TO_CHAR(v_sueldo));
        DBMS_OUTPUT.PUT_LINE('Sueldo reajustado: ' || TO_CHAR(v_sueldo_nuevo_s2));
        DBMS_OUTPUT.PUT_LINE('Reajuste: '          || TO_CHAR(v_reajuste_s2));
    ELSE
        DBMS_OUTPUT.PUT_LINE('SIMULACIÓN 2: El empleado no se encuentra en el rango ' ||
                             v_rango_fmt);
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: No se encontró empleado con RUN ' || TO_CHAR(:v_run));
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/