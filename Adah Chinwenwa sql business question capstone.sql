 -- Business Question 1: What are the full names, job titles, and current department names for all employees in the company?

SELECT 
    e.BusinessEntityID,
    CONCAT(p.FirstName, ' ', p.LastName) AS EmployeeName,
    e.JobTitle,
    mph.Rate
FROM HumanResources_Employee e
JOIN Person_Person p ON e.BusinessEntityID = p.BusinessEntityID
JOIN HumanResources_EmployeePayHistory mph ON e.BusinessEntityID = mph.BusinessEntityID
WHERE mph.Rate > (
    SELECT AVG(Rate) 
    FROM HumanResources_EmployeePayHistory
);

-- Business Question 2: Which products have a total order quantity greater than the average total quantity ordered across all products?

SELECT 
    p.ProductID,
    p.Name AS ProductName,
    SUM(sod.OrderQty) AS TotalQuantityOrdered
FROM Production_Product p
JOIN Sales_SalesOrderDetail sod ON p.ProductID = sod.ProductID
GROUP BY p.ProductID, p.Name
HAVING SUM(sod.OrderQty) > (
    SELECT AVG(ProductTotalQty)
    FROM (
        SELECT SUM(OrderQty) AS ProductTotalQty
        FROM Sales_SalesOrderDetail
        GROUP BY ProductID
    ) AS SubSummary
);


-- Business Question 3: Departments with more than 2 employees earning a pay rate > $40

SELECT 
    d.DepartmentID,
    d.Name AS DepartmentName,
    COUNT(edh.BusinessEntityID) AS HighEarnerCount
FROM
    HumanResources_Department d
        JOIN
    HumanResources_EmployeeDepartmentHistory edh ON d.DepartmentID = edh.DepartmentID
        JOIN
    HumanResources_EmployeePayHistory mph ON edh.BusinessEntityID = mph.BusinessEntityID
WHERE
    edh.EndDate IS NULL AND mph.Rate > 40.00
GROUP BY d.DepartmentID , d.Name
HAVING COUNT(edh.BusinessEntityID) > 2
ORDER BY HighEarnerCount 

--  Business Question 4: Employees who have never been assigned to a department
SELECT 
    e.BusinessEntityID,
    e.JobTitle,
    mph.Rate
FROM HumanResources.Employee e
JOIN HumanResources.EmployeePayHistory mph ON e.BusinessEntityID = mph.BusinessEntityID
WHERE mph.Rate > (
    SELECT AVG(Rate) 
    FROM HumanResources.EmployeePayHistory
);

-- Business Question 5: Which employees currently have a pay rate higher than the company average
SELECT 
    e.BusinessEntityID,
    e.JobTitle,
    mph.Rate
FROM HumanResources_Employee e
JOIN HumanResources_EmployeePayHistory mph ON e.BusinessEntityID = mph.BusinessEntityID
WHERE mph.Rate > (
    SELECT AVG(Rate) 
    FROM HumanResources_EmployeePayHistory
);

-- Business Question 6: Who is the highest-paid employee (by current pay rate) in each department?
SELECT 
        edh.DepartmentID,
        d.Name AS DepartmentName,
        e.BusinessEntityID,
        mph.Rate,
        ROW_NUMBER() OVER(PARTITION BY edh.DepartmentID ORDER BY mph.Rate DESC) as pay_rank
    FROM HumanResources_EmployeeDepartmentHistory edh
    JOIN HumanResources_Department d ON edh.DepartmentID = d.DepartmentID
    JOIN HumanResources_EmployeePayHistory mph ON edh.BusinessEntityID = mph.BusinessEntityID
    JOIN HumanResources_Employee e ON edh.BusinessEntityID = e.BusinessEntityID
    WHERE edh.EndDate IS NULL) 
SELECT DepartmentID, DepartmentName, BusinessEntityID, Rate
FROM RankedPay
WHERE pay_rank = 1;

-- Business Question 7: Which departments have more than 2 employees earning a pay rate greater than $40.00?
SELECT 
    d.DepartmentID,
    d.Name AS DepartmentName,
    COUNT(edh.BusinessEntityID) AS HighEarnerCount
FROM HumanResources_Department d
JOIN HumanResources_EmployeeDepartmentHistory edh ON d.DepartmentID = edh.DepartmentID
JOIN HumanResources_EmployeePayHistory mph ON edh.BusinessEntityID = mph.BusinessEntityID
WHERE edh.EndDate IS NULL
  AND mph.Rate > 40.00
GROUP BY d.DepartmentID, d.Name
HAVING COUNT(edh.BusinessEntityID) > 2;

-- Business Question 8: Which employees have a current pay rate higher than the average pay rate of their own specific department?
SELECT 
    e.BusinessEntityID,
    edh.DepartmentID,
    mph.Rate AS EmployeeRate
FROM HumanResources_EmployeePayHistory mph
JOIN HumanResources_Employee e ON mph.BusinessEntityID = e.BusinessEntityID
JOIN HumanResources_EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
WHERE edh.EndDate IS NULL
  AND mph.Rate > (
      SELECT AVG(mph_sub.Rate)
      FROM HumanResources_EmployeePayHistory mph_sub
      JOIN HumanResources_EmployeeDepartmentHistory edh_sub ON mph_sub.BusinessEntityID = edh_sub.BusinessEntityID
      WHERE edh_sub.DepartmentID = edh.DepartmentID
        AND edh_sub.EndDate IS NULL
  );
  
  -- Business Question 9: Which employees have worked in more than one department historically?
  SELECT 
    edh.BusinessEntityID,
    COUNT(DISTINCT edh.DepartmentID) AS TotalDepartmentsWorked
FROM HumanResources_EmployeeDepartmentHistory edh
GROUP BY edh.BusinessEntityID
HAVING COUNT(DISTINCT edh.DepartmentID) > 1;

-- Question 10: What are the Business Entity IDs and job titles of all employees?
SELECT BusinessEntityID, JobTitle
FROM HumanResources_Employee;

-- Business Question 11: What are the names and groups of all departments in the company?
SELECT DepartmentID, Name, GroupName
FROM HumanResources_Department
ORDER BY Name ASC;

-- Business Question 12: Which employees have accumulated 40 or more vacation hours?
SELECT BusinessEntityID, JobTitle, VacationHours
FROM HumanResources_Employee
WHERE VacationHours >= 40
ORDER BY VacationHours DESC;

--  Business Question 13: What are the current department names assigned to active employees?
SELECT 
    edh.BusinessEntityID,
    d.Name AS DepartmentName
FROM HumanResources_EmployeeDepartmentHistory edh
JOIN HumanResources_Department d ON edh.DepartmentID = d.DepartmentID
WHERE edh.EndDate IS NULL;

-- Business Question 14: Which employees currently have active department history records?
SELECT BusinessEntityID, DepartmentID, StartDate
FROM HumanResources_EmployeeDepartmentHistory
WHERE EndDate IS NULL;


-- Business Question 15: Job titles and department names for employees in Production

SELECT 
    e.BusinessEntityID,
    e.JobTitle,
    d.Name AS DepartmentName
FROM HumanResources_Employee e
JOIN HumanResources_EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources_Department d ON edh.DepartmentID = d.DepartmentID
WHERE edh.EndDate IS NULL 
  AND d.Name = 'Production';