CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY, -- Automatically generated unique ID for each employee
    full_name VARCHAR(255) NOT NULL,            -- Employee's full name
    position VARCHAR(100),                      -- Job title or role
    hire_date DATE,                             -- Date when the employee was hired
    department VARCHAR(100),                    -- Department the employee belongs to
    status ENUM('active', 'left') DEFAULT 'active', -- Tracks if the employee is currently active or has left
    tax_number VARCHAR(50),                     -- Tax Identification Number
    nssf_number VARCHAR(50),                    -- NSSF number for social security contributions
    health_insurance_number VARCHAR(50)         -- Health insurance fund number
);
DROP TABLE employees;
CREATE DATABASE payroll_system;
USE payroll_system;
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    position VARCHAR(100),
    hire_date DATE,
    department VARCHAR(100),
    status ENUM('active', 'left') DEFAULT 'active',
    tax_number VARCHAR(50),
    nssf_number VARCHAR(50),
    health_insurance_number VARCHAR(50)
);
DROP TABLE employees;
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY, -- A unique ID automatically assigned to each employee.
    full_name VARCHAR(255) NOT NULL,            -- The employee's full name, up to 255 characters.
    position VARCHAR(100),                      -- The employee's job title or role (e.g., Manager, Analyst).
    hire_date DATE,                             -- The date the employee was hired, in YYYY-MM-DD format.
    department VARCHAR(100),                    -- The department the employee belongs to (e.g., HR, Finance).
    status ENUM('active', 'left') DEFAULT 'active', -- Indicates if the employee is still with the company ('active') or has left ('left').
    tax_number VARCHAR(50),                     -- The employee's unique tax identification number for income tax purposes.
    nssf_number VARCHAR(50),                    -- The employee's NSSF number for social security contributions.
    health_insurance_number VARCHAR(50)         -- The employee's health insurance fund number for medical contributions.
);
INSERT INTO employees (full_name, position, hire_date, department, status, tax_number, nssf_number, health_insurance_number)
VALUES
('John Doe', 'Accountant', '2022-01-15', 'Finance', 'active', 'TAX12345', 'NSSF12345', 'HEALTH12345'),
('Jane Smith', 'HR Manager', '2021-03-10', 'Human Resources', 'active', 'TAX23456', 'NSSF23456', 'HEALTH23456'),
('Paul Brown', 'IT Specialist', '2020-07-01', 'IT', 'left', 'TAX34567', 'NSSF34567', 'HEALTH34567');

select
*
From payroll_system.employees

CREATE TABLE salaries (
    salary_id INT AUTO_INCREMENT PRIMARY KEY,  -- Unique ID for each salary record.
    employee_id INT,                           -- Links to the employee's ID from the 'employees' table.
    base_salary DECIMAL(10,2) NOT NULL,        -- Fixed monthly or annual salary (e.g., 50000.00).
    bonus DECIMAL(10,2),                       -- Monetary reward for performance (e.g., 5000.00).
    allowance DECIMAL(10,2),                   -- Extra benefits like housing allowance (e.g., 3000.00).
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) -- Ensures the employee exists in the 'employees' table.
);

USE payroll_system;
SHOW TABLES;
CREATE TABLE salaries (
    salary_id INT AUTO_INCREMENT PRIMARY KEY, -- Unique ID for each salary record
    employee_id INT NOT NULL, -- Links to employee's ID from the 'employees' table
    base_salary DECIMAL(10,2) NOT NULL, -- Fixed salary (e.g., 50000.00)
    bonus DECIMAL(10,2) DEFAULT 0.00, -- Bonus amount (default is 0 if not provided)
    allowance DECIMAL(10,2) DEFAULT 0.00, -- Allowances (default is 0 if not provided)
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) -- Foreign key linking to 'employees'
);


INSERT INTO salaries (employee_id, base_salary, bonus, allowance)
VALUES
(1, 50000.00, 5000.00, 3000.00), -- Record for employee ID 1
(2, 70000.00, 7000.00, 5000.00), -- Record for employee ID 2
(3, 60000.00, 0.00, 2000.00);   -- Record for employee ID 3

Select	
*
From salaries;

SELECT 
employee_id, 
base_salary + bonus + allowance AS total_compensation
FROM salaries;

CREATE TABLE deductions (
    deduction_id INT AUTO_INCREMENT PRIMARY KEY,  -- Unique ID for each deduction record
    employee_id INT NOT NULL,                     -- Links to the employee's ID from the 'employees' table
    tax DECIMAL(10,2) DEFAULT 0.00,               -- Income tax deduction (PAYE)
    nssf_deduction DECIMAL(10,2) DEFAULT 0.00,    -- National Social Security Fund deduction
    health_insurance_deduction DECIMAL(10,2) DEFAULT 0.00, -- Social health insurance deduction
    housing_levy_deduction DECIMAL(10,2) DEFAULT 0.00, -- Housing levy deduction
    insurance_relief DECIMAL(10,2) DEFAULT 0.00,  -- Relief provided for insurance payments
    payee_relief DECIMAL(10,2) DEFAULT 0.00,      -- PAYE (tax) relief for the employee
    employee_loan_deduction DECIMAL(10,2) DEFAULT 0.00, -- Deduction for employee loans
    other_deductions DECIMAL(10,2) DEFAULT 0.00,  -- Other deductions (e.g., penalties or miscellaneous)
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) -- Ensures the employee exists in the 'employees' table
);


CREATE VIEW employee_deductions AS
SELECT 
    e.employee_id,                                -- Employee's unique ID
    s.base_salary,                               -- Employee's base salary
    -- PAYE (Tax) calculation based on Finance Bill 2023 brackets:
    CASE
        WHEN s.base_salary <= 24000 THEN GREATEST((s.base_salary * 0.10) - 2400.00, 0.00)
        WHEN s.base_salary <= 40667 THEN GREATEST(((24000 * 0.10) + ((s.base_salary - 24000) * 0.25)) - 2400.00, 0.00)
        ELSE GREATEST(((24000 * 0.10) + (16667 * 0.25) + ((s.base_salary - 40667) * 0.30)) - 2400.00, 0.00)
    END AS tax,
    -- NSSF deduction capped at 4320 or 6% of base salary:
    LEAST(s.base_salary * 0.06, 4320.00) AS nssf_deduction,
    -- Health insurance deduction at 2.75% of gross salary:
    s.base_salary * 0.0275 AS health_insurance_deduction,
    -- Housing levy deduction at 1.5% of gross salary:
    s.base_salary * 0.015 AS housing_levy_deduction,
    -- Flat insurance relief:
    5000.00 AS insurance_relief,
    -- Flat PAYE relief:
    2400.00 AS payee_relief,
    -- Employee loan deduction (example placeholder):
    COALESCE(l.loan_installment, 0.00) AS employee_loan_deduction
FROM 
    employees e
JOIN 
    salaries s ON e.employee_id = s.employee_id
LEFT JOIN 
    loans l ON e.employee_id = l.employee_id; -- Optional: Include loan deductions if linked


CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,    -- Unique ID for each loan record
    employee_id INT NOT NULL,                 -- Links to the employee's ID from the 'employees' table
    loan_amount DECIMAL(10,2),                -- Total loan amount taken by the employee
    loan_installment DECIMAL(10,2),           -- Monthly repayment installment
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) -- Ensures the employee exists in the 'employees' table
);

CREATE VIEW employee_deductions AS
SELECT 
    e.employee_id,                                -- Employee's unique ID
    s.base_salary,                               -- Employee's base salary
    -- PAYE (Tax) calculation based on Finance Bill 2023 brackets:
    CASE
        WHEN s.base_salary <= 24000 THEN GREATEST((s.base_salary * 0.10) - 2400.00, 0.00)
        WHEN s.base_salary <= 40667 THEN GREATEST(((24000 * 0.10) + ((s.base_salary - 24000) * 0.25)) - 2400.00, 0.00)
        ELSE GREATEST(((24000 * 0.10) + (16667 * 0.25) + ((s.base_salary - 40667) * 0.30)) - 2400.00, 0.00)
    END AS tax,
    -- NSSF deduction capped at 4320 or 6% of base salary:
    LEAST(s.base_salary * 0.06, 4320.00) AS nssf_deduction,
    -- Health insurance deduction at 2.75% of gross salary:
    s.base_salary * 0.0275 AS health_insurance_deduction,
    -- Housing levy deduction at 1.5% of gross salary:
    s.base_salary * 0.015 AS housing_levy_deduction,
    -- Flat insurance relief:
    5000.00 AS insurance_relief,
    -- Flat PAYE relief:
    2400.00 AS payee_relief,
    -- Employee loan deduction (example placeholder):
    COALESCE(l.loan_installment, 0.00) AS employee_loan_deduction
FROM 
    employees e
JOIN 
    salaries s ON e.employee_id = s.employee_id
LEFT JOIN 
    loans l ON e.employee_id = l.employee_id; -- Optional: Include loan deductions if linked
DROP VIEW IF EXISTS employee_deductions;
CREATE VIEW employee_deductions AS
SELECT 
    e.employee_id,                                -- Employee's unique ID
    s.base_salary,                               -- Employee's base salary
    -- PAYE (Tax) calculation with relief applied to the total tax:
    GREATEST(
        CASE
            WHEN s.base_salary <= 24000 THEN s.base_salary * 0.10
            WHEN s.base_salary <= 40667 THEN (24000 * 0.10) + ((s.base_salary - 24000) * 0.25)
            ELSE (24000 * 0.10) + (16667 * 0.25) + ((s.base_salary - 40667) * 0.30)
        END - 2400.00,  -- Subtract the PAYE relief from the total PAYE tax
        0.00            -- Ensure the final tax amount is not negative
    ) AS tax,
    -- NSSF deduction capped at 4320 or 6% of base salary:
    LEAST(s.base_salary * 0.06, 4320.00) AS nssf_deduction,
    -- Health insurance deduction at 2.75% of gross salary:
    s.base_salary * 0.0275 AS health_insurance_deduction,
    -- Housing levy deduction at 1.5% of gross salary:
    s.base_salary * 0.015 AS housing_levy_deduction,
    -- Flat insurance relief:
    5000.00 AS insurance_relief,
    -- Employee loan deduction (example placeholder):
    COALESCE(l.loan_installment, 0.00) AS employee_loan_deduction
FROM 
    employees e
JOIN 
    salaries s ON e.employee_id = s.employee_id
LEFT JOIN 
    loans l ON e.employee_id = l.employee_id; -- Optional: Include loan deductions if linked
SELECT * FROM employee_deductions;

CREATE VIEW employee_net_pay AS
SELECT 
    e.employee_id,                                  -- Employee ID
    s.base_salary,                                 -- Base salary
    s.bonus,                                       -- Bonus
    s.allowance,                                   -- Allowance
    -- Compute gross pay (base salary + bonus + allowance):
    (s.base_salary + s.bonus + s.allowance) AS gross_pay,
    -- Deductions (from the employee_deductions view):
    d.tax,                                         -- PAYE tax
    d.nssf_deduction,                              -- NSSF deduction
    d.health_insurance_deduction,                  -- Health insurance deduction
    d.housing_levy_deduction,                      -- Housing levy deduction
    d.employee_loan_deduction,                     -- Employee loan deduction
    -- Compute total deductions:
    (d.tax + d.nssf_deduction + d.health_insurance_deduction + d.housing_levy_deduction + d.employee_loan_deduction) AS total_deductions,
    -- Compute net pay (gross pay - total deductions):
    ((s.base_salary + s.bonus + s.allowance) - 
    (d.tax + d.nssf_deduction + d.health_insurance_deduction + d.housing_levy_deduction + d.employee_loan_deduction)) AS net_pay
FROM 
    salaries s
JOIN 
    employee_deductions d ON s.employee_id = d.employee_id
JOIN 
    employees e ON s.employee_id = e.employee_id;

SELECT 
* 
FROM employee_net_pay;

DROP VIEW IF EXISTS employee_net_pay;

CREATE VIEW employee_net_pay AS
SELECT 
    e.employee_id,                                  -- Employee ID
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name, -- Full name (first and last name combined)
    s.base_salary,                                 -- Base salary
    s.bonus,                                       -- Bonus
    s.allowance,                                   -- Allowance
    -- Compute gross pay (base salary + bonus + allowance):
    (s.base_salary + s.bonus + s.allowance) AS gross_pay,
    -- Deductions (from the employee_deductions view):
    d.tax,                                         -- PAYE tax
    d.nssf_deduction,                              -- NSSF deduction
    d.health_insurance_deduction,                  -- Health insurance deduction
    d.housing_levy_deduction,                      -- Housing levy deduction
    d.employee_loan_deduction,                     -- Employee loan deduction
    -- Compute total deductions:
    (d.tax + d.nssf_deduction + d.health_insurance_deduction + d.housing_levy_deduction + d.employee_loan_deduction) AS total_deductions,
    -- Compute net pay (gross pay - total deductions):
    ((s.base_salary + s.bonus + s.allowance) - 
    (d.tax + d.nssf_deduction + d.health_insurance_deduction + d.housing_levy_deduction + d.employee_loan_deduction)) AS net_pay
FROM 
    salaries s
JOIN 
    employee_deductions d ON s.employee_id = d.employee_id
JOIN 
    employees e ON s.employee_id = e.employee_id;
    
DESCRIBE employees;

DROP VIEW IF EXISTS employee_net_pay;

CREATE VIEW employee_net_pay AS
SELECT 
    e.employee_id,                                  -- Employee ID
    e.full_name AS employee_name,                  -- Full name of the employee
    s.base_salary,                                 -- Base salary
    s.bonus,                                       -- Bonus
    s.allowance,                                   -- Allowance
    -- Compute gross pay (base salary + bonus + allowance):
    (s.base_salary + s.bonus + s.allowance) AS gross_pay,
    -- Deductions (from the employee_deductions view):
    d.tax,                                         -- PAYE tax
    d.nssf_deduction,                              -- NSSF deduction
    d.health_insurance_deduction,                  -- Health insurance deduction
    d.housing_levy_deduction,                      -- Housing levy deduction
    d.employee_loan_deduction,                     -- Employee loan deduction
    -- Compute total deductions:
    (d.tax + d.nssf_deduction + d.health_insurance_deduction + d.housing_levy_deduction + d.employee_loan_deduction) AS total_deductions,
    -- Compute net pay (gross pay - total deductions):
    ((s.base_salary + s.bonus + s.allowance) - 
    (d.tax + d.nssf_deduction + d.health_insurance_deduction + d.housing_levy_deduction + d.employee_loan_deduction)) AS net_pay
FROM 
    salaries s
JOIN 
    employee_deductions d ON s.employee_id = d.employee_id
JOIN 
    employees e ON s.employee_id = e.employee_id;
    
    SELECT 
    * 
    FROM employee_net_pay;
    
    SELECT * FROM employee_net_pay;
    SELECT * FROM employee_net_pay WHERE employee_id = 1;
    SELECT * FROM employee_net_pay WHERE base_salary < 24000;
    SELECT * FROM employee_net_pay WHERE base_salary > 40667;
    
    ALTER TABLE salaries 
ADD COLUMN hourly_rate DECIMAL(10,2),
ADD COLUMN overtime_hours INT DEFAULT 0; -- Overtime hours worked by the employee

ALTER TABLE salaries 
ADD COLUMN penalties DECIMAL(10,2) DEFAULT 0.00; -- Penalty deductions


CREATE TABLE custom_deductions (
    deduction_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,                  -- Links to the employee
    deduction_name VARCHAR(255),              -- Description of the deduction
    deduction_amount DECIMAL(10,2),           -- Deduction amount
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE VIEW employee_net_pay AS
SELECT 
    e.employee_id,
    e.full_name AS employee_name,
    s.base_salary,
    s.bonus,
    s.allowance,
    -- Compute overtime pay:
    (s.hourly_rate * s.overtime_hours * 1.5) AS overtime_pay,
    -- Compute gross pay (base salary + bonus + allowance + overtime pay):
    (s.base_salary + s.bonus + s.allowance + (s.hourly_rate * s.overtime_hours * 1.5)) AS gross_pay,
    -- Deductions (from the employee_deductions view):
    d.tax,
    d.nssf_deduction,
    d.health_insurance_deduction,
    d.housing_levy_deduction,
    d.employee_loan_deduction,
    COALESCE(s.penalties, 0.00) AS penalties_deduction,
    COALESCE((SELECT SUM(deduction_amount) 
              FROM custom_deductions cd 
              WHERE cd.employee_id = e.employee_id), 0.00) AS custom_deductions,
    -- Compute total deductions:
    (d.tax + d.nssf_deduction + d.health_insurance_deduction + d.housing_levy_deduction + 
     d.employee_loan_deduction + COALESCE(s.penalties, 0.00) + 
     COALESCE((SELECT SUM(deduction_amount) FROM custom_deductions cd WHERE cd.employee_id = e.employee_id), 0.00)) AS total_deductions,
    -- Compute net pay (gross pay - total deductions):
    ((s.base_salary + s.bonus + s.allowance + (s.hourly_rate * s.overtime_hours * 1.5)) - 
     (d.tax + d.nssf_deduction + d.health_insurance_deduction + d.housing_levy_deduction + 
      d.employee_loan_deduction + COALESCE(s.penalties, 0.00) + 
      COALESCE((SELECT SUM(deduction_amount) FROM custom_deductions cd WHERE cd.employee_id = e.employee_id), 0.00))) AS net_pay
FROM 
    salaries s
JOIN 
    employee_deductions d ON s.employee_id = d.employee_id
JOIN 
    employees e ON s.employee_id = e.employee_id;
    
    DROP VIEW IF EXISTS employee_net_pay;
    CREATE VIEW employee_net_pay AS
SELECT 
    e.employee_id,
    e.full_name AS employee_name,
    s.base_salary,
    s.bonus,
    s.allowance,
    -- Compute overtime pay:
    (s.hourly_rate * s.overtime_hours * 1.5) AS overtime_pay,
    -- Compute gross pay (base salary + bonus + allowance + overtime pay):
    (s.base_salary + s.bonus + s.allowance + (s.hourly_rate * s.overtime_hours * 1.5)) AS gross_pay,
    -- Deductions (from the employee_deductions view):
    d.tax,
    d.nssf_deduction,
    d.health_insurance_deduction,
    d.housing_levy_deduction,
    d.employee_loan_deduction,
    COALESCE(s.penalties, 0.00) AS penalties_deduction,
    COALESCE((SELECT SUM(deduction_amount) 
              FROM custom_deductions cd 
              WHERE cd.employee_id = e.employee_id), 0.00) AS custom_deductions,
    -- Compute total deductions:
    (d.tax + d.nssf_deduction + d.health_insurance_deduction + d.housing_levy_deduction + 
     d.employee_loan_deduction + COALESCE(s.penalties, 0.00) + 
     COALESCE((SELECT SUM(deduction_amount) FROM custom_deductions cd WHERE cd.employee_id = e.employee_id), 0.00)) AS total_deductions,
    -- Compute net pay (gross pay - total deductions):
    ((s.base_salary + s.bonus + s.allowance + (s.hourly_rate * s.overtime_hours * 1.5)) - 
     (d.tax + d.nssf_deduction + d.health_insurance_deduction + d.housing_levy_deduction + 
      d.employee_loan_deduction + COALESCE(s.penalties, 0.00) + 
      COALESCE((SELECT SUM(deduction_amount) FROM custom_deductions cd WHERE cd.employee_id = e.employee_id), 0.00))) AS net_pay
FROM 
    salaries s
JOIN 
    employee_deductions d ON s.employee_id = d.employee_id
JOIN 
    employees e ON s.employee_id = e.employee_id;
    
    SELECT * FROM employee_net_pay;
    DROP VIEW IF EXISTS employee_net_pay;
    
    CREATE VIEW employee_net_pay AS
SELECT 
    e.employee_id,
    e.full_name AS employee_name,
    COALESCE(s.base_salary, 0.00) AS base_salary,
    COALESCE(s.bonus, 0.00) AS bonus,
    COALESCE(s.allowance, 0.00) AS allowance,
    -- Compute overtime pay (defaults to 0.00 if null):
    COALESCE(s.hourly_rate, 0.00) * COALESCE(s.overtime_hours, 0) * 1.5 AS overtime_pay,
    -- Compute gross pay (base salary + bonus + allowance + overtime pay):
    (COALESCE(s.base_salary, 0.00) + COALESCE(s.bonus, 0.00) + COALESCE(s.allowance, 0.00) + 
     (COALESCE(s.hourly_rate, 0.00) * COALESCE(s.overtime_hours, 0) * 1.5)) AS gross_pay,
    -- Deductions (from the employee_deductions view):
    d.tax,
    d.nssf_deduction,
    d.health_insurance_deduction,
    d.housing_levy_deduction,
    d.employee_loan_deduction,
    COALESCE(s.penalties, 0.00) AS penalties_deduction,
    COALESCE((SELECT SUM(deduction_amount) 
              FROM custom_deductions cd 
              WHERE cd.employee_id = e.employee_id), 0.00) AS custom_deductions,
    -- Compute total deductions:
    (d.tax + d.nssf_deduction + d.health_insurance_deduction + d.housing_levy_deduction + 
     d.employee_loan_deduction + COALESCE(s.penalties, 0.00) + 
     COALESCE((SELECT SUM(deduction_amount) FROM custom_deductions cd WHERE cd.employee_id = e.employee_id), 0.00)) AS total_deductions,
    -- Compute net pay (gross pay - total deductions):
    ((COALESCE(s.base_salary, 0.00) + COALESCE(s.bonus, 0.00) + COALESCE(s.allowance, 0.00) + 
      (COALESCE(s.hourly_rate, 0.00) * COALESCE(s.overtime_hours, 0) * 1.5)) - 
     (d.tax + d.nssf_deduction + d.health_insurance_deduction + d.housing_levy_deduction + 
      d.employee_loan_deduction + COALESCE(s.penalties, 0.00) + 
      COALESCE((SELECT SUM(deduction_amount) FROM custom_deductions cd WHERE cd.employee_id = e.employee_id), 0.00))) AS net_pay
FROM 
    salaries s
JOIN 
    employee_deductions d ON s.employee_id = d.employee_id
JOIN 
    employees e ON s.employee_id = e.employee_id;
    SELECT * FROM employee_net_pay WHERE overtime_pay = 0.00;
    
    SELECT * FROM employee_net_pay WHERE bonus > 0 OR allowance > 0;	
    
    CREATE VIEW payroll_summary AS
SELECT 
    DATE_FORMAT(payment_date, '%Y-%m') AS pay_month, -- Group by month
    COUNT(employee_id) AS total_employees,          -- Total number of employees
    SUM(gross_pay) AS total_gross_pay,              -- Total gross pay for the month
    SUM(total_deductions) AS total_deductions,      -- Total deductions for the month
    SUM(net_pay) AS total_net_pay                   -- Total net pay for the month
FROM 
    employee_net_pay
GROUP BY 
    pay_month;


ALTER TABLE salaries ADD COLUMN payment_date DATE;


CREATE OR REPLACE VIEW employee_net_pay AS
SELECT 
    e.employee_id,
    e.full_name AS employee_name,
    COALESCE(s.base_salary, 0.00) AS base_salary,
    COALESCE(s.bonus, 0.00) AS bonus,
    COALESCE(s.allowance, 0.00) AS allowance,
    COALESCE(s.hourly_rate, 0.00) * COALESCE(s.overtime_hours, 0) * 1.5 AS overtime_pay,
    (COALESCE(s.base_salary, 0.00) + COALESCE(s.bonus, 0.00) + COALESCE(s.allowance, 0.00) + 
     (COALESCE(s.hourly_rate, 0.00) * COALESCE(s.overtime_hours, 0) * 1.5)) AS gross_pay,
    d.tax,
    d.nssf_deduction,
    d.health_insurance_deduction,
    d.housing_levy_deduction,
    d.employee_loan_deduction,
    COALESCE(s.penalties, 0.00) AS penalties_deduction,
    COALESCE((SELECT SUM(deduction_amount) 
              FROM custom_deductions cd 
              WHERE cd.employee_id = e.employee_id), 0.00) AS custom_deductions,
    (d.tax + d.nssf_deduction + d.health_insurance_deduction + d.housing_levy_deduction + 
     d.employee_loan_deduction + COALESCE(s.penalties, 0.00) + 
     COALESCE((SELECT SUM(deduction_amount) FROM custom_deductions cd WHERE cd.employee_id = e.employee_id), 0.00)) AS total_deductions,
    ((COALESCE(s.base_salary, 0.00) + COALESCE(s.bonus, 0.00) + COALESCE(s.allowance, 0.00) + 
      (COALESCE(s.hourly_rate, 0.00) * COALESCE(s.overtime_hours, 0) * 1.5)) - 
     (d.tax + d.nssf_deduction + d.health_insurance_deduction + d.housing_levy_deduction + 
      d.employee_loan_deduction + COALESCE(s.penalties, 0.00) + 
      COALESCE((SELECT SUM(deduction_amount) FROM custom_deductions cd WHERE cd.employee_id = e.employee_id), 0.00))) AS net_pay,
    s.payment_date                                -- Include payment_date in the view
FROM 
    salaries s
JOIN 
    employee_deductions d ON s.employee_id = d.employee_id
JOIN 
    employees e ON s.employee_id = e.employee_id;
    
   
SELECT 
    DATE_FORMAT(payment_date, '%Y-%m') AS pay_month, -- Group by month
    COUNT(employee_id) AS total_employees,          -- Total number of employees
    SUM(gross_pay) AS total_gross_pay,              -- Total gross pay for the month
    SUM(total_deductions) AS total_deductions,      -- Total deductions for the month
    SUM(net_pay) AS total_net_pay                   -- Total net pay for the month
FROM 
    employee_net_pay
GROUP BY 
    pay_month;

    
    SELECT * FROM payroll_summary;
    
    CREATE VIEW year_to_date_data AS
SELECT 
    employee_id,
    employee_name,
    SUM(gross_pay) AS year_to_date_gross,        -- Cumulative gross pay
    SUM(total_deductions) AS year_to_date_deductions, -- Cumulative deductions
    SUM(net_pay) AS year_to_date_net             -- Cumulative net pay
FROM 
    employee_net_pay
WHERE 
    YEAR(payment_date) = YEAR(CURDATE())         -- Automatically fetches the current year
GROUP BY 
    employee_id, employee_name;
    
    SELECT * FROM year_to_date_data;
    
    CREATE VIEW individual_employee_breakdown AS
SELECT 
    payment_date,
    employee_id,
    employee_name,
    gross_pay,
    tax AS paye_tax,
    nssf_deduction,
    health_insurance_deduction,
    housing_levy_deduction,
    penalties_deduction,
    custom_deductions,
    total_deductions,
    net_pay
FROM 
    employee_net_pay
ORDER BY 
    payment_date DESC;
    
    SELECT * FROM individual_employee_breakdown;
    
    SELECT USER();
mysqldump -u root -p payroll_system > payroll_system_backup.sql

    
    
































