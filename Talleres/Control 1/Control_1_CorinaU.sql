--ITEM 1--
---Obtener la lista de empleados que tienen 
--un salario superior al promedio de su departamento, 
--incluyendo nombre del empleado, salario, nombre del departamento y
--gerente.

SELECT * FROM EMPLOYEES;

--Considerando a los managers
SELECT e.first_name || ' ' || e.last_name "Nombre Empleado",
TO_CHAR(e.salary, '$9G999') "Salario",
d.department_id "Departamento ID",
CONCAT('Departamento de ', d.department_name) "Nombre Departamento",
m.first_name || ' ' || m.last_name "Nombre Manager"
FROM EMPLOYEES e JOIN DEPARTMENTS d 
ON(e.department_id = d.department_id)
JOIN EMPLOYEES m 
ON(d.manager_id = m.employee_id)
WHERE e.salary > (SELECT AVG(salary) FROM EMPLOYEES WHERE department_id = d.department_id);

--Sin considerar a los managers
SELECT e.first_name || ' ' || e.last_name "Nombre Empleado",
TO_CHAR(e.salary, '$9G999') "Salario",
d.department_id "Departamento ID",
CONCAT('Departamento de ', d.department_name) "Nombre Departamento",
m.first_name || ' ' || m.last_name "Nombre Manager"
FROM EMPLOYEES e JOIN DEPARTMENTS d 
ON(e.department_id = d.department_id)
JOIN EMPLOYEES m 
ON(d.manager_id = m.employee_id)
WHERE e.employee_id != m.employee_id
AND e.salary > (SELECT AVG(e2.salary) FROM EMPLOYEES e2 WHERE e2.department_id = d.department_id AND e2.employee_id != d.manager_id);


--ITEM 2
--Obtener la lista de productos más vendidos por cada categoría, mostrando el nombre del
--producto, total vendido, nombre de la categoría y su posición dentro de su categoría (ranking
--por ventas).

--con ranking (1 y 2)
SELECT p.product_name "Nombre Producto", 
SUM(oi.quantity) "Total Vendido", 
pc.category_name "Nombre Categoria",
CASE WHEN SUM(oi.quantity) > MAX(OI.QUANTITY) THEN 1
ELSE 2 END "Ranking"
FROM ORDER_ITEMS oi JOIN PRODUCTS p 
ON(oi.product_id = p.product_id) 
JOIN PRODUCT_CATEGORIES pc ON(p.category_id = pc.category_id)
GROUP BY  p.product_name,  pc.category_name
ORDER BY pc.category_name DESC, SUM(oi.quantity) DESC;

--sin ranking
SELECT p.product_name "Nombre Producto", 
SUM(oi.quantity) "Total Vendido", 
pc.category_name "Nombre Categoria"
FROM ORDER_ITEMS oi JOIN PRODUCTS p 
ON(oi.product_id = p.product_id)
JOIN PRODUCT_CATEGORIES pc ON(p.category_id = pc.category_id)
GROUP BY  p.product_name,  pc.category_name
ORDER BY pc.category_name DESC, SUM(oi.quantity) DESC;

