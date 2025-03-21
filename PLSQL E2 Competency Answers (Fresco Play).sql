--1. Problem 1: Employees under terminated Manager | Hackerrank Solution
SET NULL "NULL";
SET FEEDBACK OFF;
SET ECHO OFF;
SET HEADING OFF;
SET WRAP OFF;
SET LINESIZE 10000;
SET TAB OFF;
SET PAGES 0;
SET DEFINE OFF;
/*
Enter your query below.
Please append a semicolon ";" at the end of the query
*/
SET SERVEROUTPUT ON;
DECLARE
v_active_count NUMBER;
v_terminated_count NUMBER;
BEGIN
-- Counting Active and Terminated Employees
SELECT COUNT(*) INTO v_active_count
FROM EMP
WHERE EMP_STATUS = 'Active';
SELECT COUNT(*) INTO v_terminated_count
FROM EMP
WHERE EMP_STATUS = 'Terminated';
DBMS_OUTPUT.PUT_LINE('**Status Count**');
DBMS_OUTPUT.PUT_LINE('Active' ||' ' || v_active_count);
DBMS_OUTPUT.PUT_LINE('Terminated' ||' ' || v_terminated_count);
DBMS_OUTPUT.PUT_LINE('**Employees under Terminated Manager**');
DBMS_OUTPUT.PUT_LINE('emp_id emp_name Mgr_name Mgr_Status Mgr_Supervisor');
FOR r IN (
SELECT E.EMP_ID, E.EMP_FNAME || ' ' || E.EMP_LNAME AS EMP_NAME,
M.MGR_FNAME || ' ' || M.MGR_LNAME AS MGR_NAME,
M.MGR_STATUS, M.MGR_SUPERVISOR
FROM EMP E
JOIN MGR M ON E.MGR_ID = M.MGR_ID
WHERE E.EMP_STATUS = 'Active' AND M.MGR_STATUS = 'Terminated'
) LOOP
DBMS_OUTPUT.PUT_LINE(r.EMP_ID || ' ' || r.EMP_NAME || ' ' || r.MGR_NAME || ' ' || r.MGR_STATUS || ' ' || r.MGR_SUPERVISOR);
END LOOP;
END;
/
--2. Problem 2: Employees with yearly incentive Amounts | Hackerrank Solution
--The second problem focuses on creating a PLSQL function that calculates a specific value based on input parameters. This function must be called within a PLSQL block to demonstrate its use.
--Solution:
SET NULL "NULL";
SET FEEDBACK OFF;
SET ECHO OFF;
SET HEADING OFF;
SET WRAP OFF;
SET LINESIZE 10000;
SET TAB OFF;
SET PAGES 0;
SET DEFINE OFF;
/*
Enter your query below.
Please append a semicolon ";" at the end of the query
*/
set serveroutput on;
declare
incentive number;
work_exp number;
cursor curr is
select emp_id,
concat(emp_fname,concat(' ',emp_lname)) as empname,
emp_hiredate
from emp
where emp_status='Active'
and extract(month from to_date(emp_hiredate, 'yyyy-mm-dd'))=12;
c curr%rowtype;
begin
open curr;
dbms_output.put_line('Employees with yearly incentive amounts:');
dbms_output.put_line('**********');
dbms_output.put_line('Employee ID Name of the Employee Hire Date Incentive Amount');
dbms_output.put_line('**********');
loop
fetch curr into c;
exit when curr%notfound;
work_exp:=MONTHS_BETWEEN(to_date('31/12/2020', 'dd/mm/yyyy'),c.emp_hiredate)/12;
case
when work_exp>13 then incentive:=8000;
when work_exp>11 then incentive:=5000;
when work_exp>9 then incentive:=3000;
when work_exp>7 then incentive:=2000;
when work_exp>4 then incentive:=1000;
when work_exp>0 then incentive:=400;
else incentive:='null';
end case;
dbms_output.put_line(c.emp_id||' '||c.empname||' '||c.emp_hiredate||' '|| incentive);
end loop;
dbms_output.put_line('**********');
dbms_output.put_line('The number of rows fetched is '||curr%rowcount);
dbms_output.put_line('**********');
end;
/
--3. Problem 3: Employees not assigned to any department | Hackerrank Solution
--Solution:
SET NULL "NULL";
SET FEEDBACK OFF;
SET ECHO OFF;
SET HEADING OFF;
SET WRAP OFF;
SET LINESIZE 10000;
SET TAB OFF;
SET PAGES 0;
SET DEFINE OFF;
/*
Enter your query below.
Please append a semicolon ";" at the end of the query
*/
SET SERVEROUTPUT ON;
DECLARE
v_dept_id dept.dept_id%TYPE;
v_dept_name dept.dept_name%TYPE;
v_dept_head dept.dept_head%TYPE;
v_mgr_name VARCHAR2(100);
CURSOR emp_cursor IS
SELECT emp_id, emp_fname || ' ' || emp_lname AS emp_name, emp_status
FROM emp
WHERE emp_status = 'Active' AND dept_id IS NULL;
CURSOR dept_cursor IS
SELECT dept_id, dept_name, dept_head
FROM dept
WHERE dept_id NOT IN (SELECT dept_id FROM emp WHERE dept_id IS NOT NULL);
BEGIN
OPEN dept_cursor;
FETCH dept_cursor INTO v_dept_id, v_dept_name, v_dept_head;
CLOSE dept_cursor;
IF v_dept_id IS NULL THEN
DBMS_OUTPUT.PUT_LINE('No available department without employees.');
RETURN;
END IF;
SELECT mgr_fname || ' ' || mgr_lname INTO v_mgr_name FROM mgr WHERE dept_head = v_dept_head;
DBMS_OUTPUT.PUT_LINE('Emp_id Emp_name Emp_status Dept_id Dept_name Mgr_name');
FOR emp_rec IN emp_cursor LOOP
UPDATE emp SET dept_id = v_dept_id, mgr_id = v_dept_head WHERE emp_id = emp_rec.emp_id;
DBMS_OUTPUT.PUT_LINE(emp_rec.emp_id || ' ' || emp_rec.emp_name || ' ' || emp_rec.emp_status || ' ' || v_dept_id || ' ' || v_dept_name || ' ' || v_mgr_name);
END LOOP;
COMMIT;
/*DBMS_OUTPUT.PUT_LINE('Employees have been assigned to the department.');*/
END;
/
--4. Problem 4: Total Amount of Salary of each department | Hackerrank Solution
--Solution:
SET NULL "NULL";
SET SERVEROUTPUT ON;
SET FEEDBACK OFF;
SET ECHO OFF;
SET HEADING OFF;
SET WRAP OFF;
SET LINESIZE 10000;
SET TAB OFF;
SET PAGES 0;
SET DEFINE OFF;
SET SERVEROUTPUT ON;
DECLARE
-- Variables to hold total salaries and employee counts
v_total_salary_active NUMBER := 0;
v_total_employees_active NUMBER := 0;
v_total_salary_terminated NUMBER := 0;
v_total_employees_terminated NUMBER := 0;
-- Cursor for active employees
CURSOR active_emp_cursor IS
SELECT NVL(dept_id, 0) AS dept_id, SUM(emp_sal) AS total_salary, COUNT(*) AS total_employees
FROM emp
WHERE emp_status = 'Active'
GROUP BY NVL(dept_id, 0)
ORDER BY NVL(dept_id, 0);
-- Cursor for terminated employees
CURSOR terminated_emp_cursor IS
SELECT NVL(dept_id, 0) AS dept_id, SUM(emp_sal) AS total_salary, COUNT(*) AS total_employees
FROM emp
WHERE emp_status = 'Terminated'
GROUP BY NVL(dept_id, 0)
ORDER BY NVL(dept_id, 0);
-- Variables to hold cursor data
v_dept_id NUMBER;
v_total_salary NUMBER;
v_total_employees NUMBER;
BEGIN
-- Display details for active employees
DBMS_OUTPUT.PUT_LINE('Details of Active employees');
DBMS_OUTPUT.PUT_LINE('-----------------------------------');
DBMS_OUTPUT.PUT_LINE('Department_id Total_employees Total_salary');
OPEN active_emp_cursor;
LOOP
FETCH active_emp_cursor INTO v_dept_id, v_total_salary, v_total_employees;
EXIT WHEN active_emp_cursor%NOTFOUND;
DBMS_OUTPUT.PUT_LINE(v_dept_id || ' ' || v_total_employees || ' ' || v_total_salary);
-- Accumulate totals
v_total_salary_active := v_total_salary_active + v_total_salary;
v_total_employees_active := v_total_employees_active + v_total_employees;
END LOOP;
CLOSE active_emp_cursor;
DBMS_OUTPUT.PUT_LINE('-----------------------------------');
-- Display accumulated totals for active employees
DBMS_OUTPUT.PUT_LINE('Total_employees ' || v_total_employees_active);
DBMS_OUTPUT.PUT_LINE('Total_salary ' || v_total_salary_active);
DBMS_OUTPUT.PUT_LINE('-----------------------------------');
-- Display details for terminated employees
DBMS_OUTPUT.PUT_LINE('Details of Terminated employees');
DBMS_OUTPUT.PUT_LINE('-----------------------------------');
DBMS_OUTPUT.PUT_LINE('Department_id Total_employees Total_salary');
OPEN terminated_emp_cursor;
LOOP
FETCH terminated_emp_cursor INTO v_dept_id, v_total_salary, v_total_employees;
EXIT WHEN terminated_emp_cursor%NOTFOUND;
DBMS_OUTPUT.PUT_LINE(v_dept_id || ' ' || v_total_employees || ' ' || v_total_salary);
-- Accumulate totals
v_total_salary_terminated := v_total_salary_terminated + v_total_salary;
v_total_employees_terminated := v_total_employees_terminated + v_total_employees;
END LOOP;
CLOSE terminated_emp_cursor;
DBMS_OUTPUT.PUT_LINE('-----------------------------------');
-- Display accumulated totals for terminated employees
DBMS_OUTPUT.PUT_LINE('Total_employees ' || v_total_employees_terminated);
DBMS_OUTPUT.PUT_LINE('Total_salary ' || v_total_salary_terminated);
DBMS_OUTPUT.PUT_LINE('-----------------------------------');
END;
/