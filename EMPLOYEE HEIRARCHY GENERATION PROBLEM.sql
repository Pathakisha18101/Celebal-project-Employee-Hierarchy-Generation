-- Create the database
CREATE DATABASE project;
GO

-- Use the newly created database
USE project;
GO

-- Function to extract the first name from email
CREATE FUNCTION dbo.FIRST_NAME (@Email NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN LEFT(@Email, CHARINDEX('.', @Email) - 1)
END
GO

-- Function to extract the last name from email
CREATE FUNCTION dbo.LAST_NAME (@Email NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN SUBSTRING(@Email, CHARINDEX('.', @Email) + 1, CHARINDEX('@', @Email) - CHARINDEX('.', @Email) - 1)
END
GO

-- Create the Employee_Hierarchy table
CREATE TABLE Employee_Hierarchy (
    EMPLOYEEID VARCHAR(20),
    REPORTING_TO NVARCHAR(MAX),
    EMAILID NVARCHAR(MAX),
    LEVEL INT,
    FIRSTNAME NVARCHAR(MAX),
    LASTNAME NVARCHAR(MAX)
);
GO

-- Create the EMPLOYEE_MASTER table
CREATE TABLE EMPLOYEE_MASTER (
    EMPLOYEEID VARCHAR(20),
    REPORTING_TO NVARCHAR(MAX),
    EMAILID NVARCHAR(MAX)
);
GO

-- Insert data into EMPLOYEE_MASTER
INSERT INTO EMPLOYEE_MASTER (EMPLOYEEID, REPORTING_TO, EMAILID)
VALUES 
('H1', NULL, 'JON.DOE@EXAMPLE.COM'),
('H2', NULL, 'JANNE.SMITH@EXAMPLE.COM'),
('H3', 'H1', 'ALICE.JONES@EXAMPLE.COM'),
('H4', 'H1', 'BOB.WHITE@EXAMPLE.COM'),
('H5', 'H3', 'CHARLIE.BROWN@EXAMPLE.COM'),
('H6', 'H3', 'DAVID.GREEN@EXAMPLE.COM'),
('H7', 'H4', 'EMILY.GRAY@EXAMPLE.COM'),
('H8', 'H4', 'FRANK.WILSON@EXAMPLE.COM'),
('H9', 'H5', 'GEROGE.HARRIS@EXAMPLE.COM'),
('H10', 'H5', 'HANNAH.TAYLOR@EXAMPLE.COM'),
('H11', 'H6', 'IRENE.MARTIN@EXAMPLE.COM'),
('H12', 'H6', 'JACK.ROBERTS@EXAMPLE.COM'),
('H13', 'H7', 'KATE.EVAN@EXAMPLE.COM'),
('H14', 'H7', 'LAURA.HALL@EXAMPLE.COM'),
('H15', NULL, 'MIKE.ANDERSON@EXAMPLE.COM'),
('H16', 'H8', 'NATALIE.CLARK@EXAMPLE.COM'),
('H17', 'H9', 'OLIVER.DAVIS@EXAMPLE.COM'),
('H18', 'H9', 'PETER.EDWARD@EXAMPLE.COM'),
('H19', 'H10', 'QUINN.FISHER@EXAMPLE.COM'),
('H20', 'H10', 'RACHEL.GARCIA@EXAMPLE.COM'),
('H21', 'H11', 'SARAH.HERNANDEZ@EXAMPLE.COM'),
('H22', 'H11', 'THOMAS.LEE@EXAMPLE.COM'),
('H23', 'H12', 'URSULA.LOPEZ@EXAMPLE.COM'),
('H24', 'H12', 'VICTOR.MARTINEZ@EXAMPLE.COM'),
('H25', 'H13', 'WILLIAM.NGUYEN@EXAMPLE.COM'),
('H26', 'H13', 'XAVIER.ORTIZ@EXAMPLE.COM'),
('H27', 'H14', 'YVONNE.PEREZ@EXAMPLE.COM'),
('H28', 'H14', 'ZOE.QUINN@EXAMPLE.COM'),
('H29', 'H15', 'ADAM.ROBINSON@EXAMPLE.COM'),
('H30', 'H15', 'BARBARA.SMITH@EXAMPLE.COM');
GO

-- Stored procedure to generate the employee hierarchy
CREATE PROCEDURE SP_hierarchy
AS
BEGIN
    -- Truncate the Employee_Hierarchy table
    TRUNCATE TABLE Employee_Hierarchy;
    
    -- Declare a table variable to store intermediate hierarchy data
    DECLARE @HierarchyTable TABLE (
        EMPLOYEEID VARCHAR(20),
        REPORTING_TO NVARCHAR(MAX),
        EMAILID NVARCHAR(MAX),
        LEVEL INT,
        FIRSTNAME NVARCHAR(MAX),
        LASTNAME NVARCHAR(MAX)
    );
    
    -- Insert root level employees (who do not report to anyone)
    INSERT INTO @HierarchyTable (EMPLOYEEID, REPORTING_TO, EMAILID, LEVEL, FIRSTNAME, LASTNAME)
    SELECT 
        EMPLOYEEID,
        REPORTING_TO,
        EMAILID,
        1 AS LEVEL,
        dbo.FIRST_NAME(EMAILID) AS FIRSTNAME,
        dbo.LAST_NAME(EMAILID) AS LASTNAME
    FROM EMPLOYEE_MASTER
    WHERE REPORTING_TO IS NULL;

    -- Recursive CTE to generate the hierarchy
    WITH EmployeeCTE (EMPLOYEEID, REPORTING_TO, EMAILID, LEVEL, FIRSTNAME, LASTNAME) AS
    (
        SELECT 
            EMPLOYEEID,
            REPORTING_TO,
            EMAILID,
            LEVEL,
            FIRSTNAME,
            LASTNAME
        FROM @HierarchyTable

        UNION ALL

        SELECT 
            em.EMPLOYEEID,
            em.REPORTING_TO,
            em.EMAILID,
            ecte.LEVEL + 1,
            dbo.FIRST_NAME(em.EMAILID),
            dbo.LAST_NAME(em.EMAILID)
        FROM EMPLOYEE_MASTER em
        INNER JOIN EmployeeCTE ecte ON em.REPORTING_TO = ecte.EMPLOYEEID
    )

    -- Insert the final hierarchy into the Employee_Hierarchy table
    INSERT INTO Employee_Hierarchy (EMPLOYEEID, REPORTING_TO, EMAILID, LEVEL, FIRSTNAME, LASTNAME)
    SELECT EMPLOYEEID, REPORTING_TO, EMAILID, LEVEL, FIRSTNAME, LASTNAME
    FROM EmployeeCTE;
END
GO

-- Execute the stored procedure to generate the hierarchy
EXEC SP_hierarchy;
GO

-- Query the Employee_Hierarchy table to verify the results
SELECT * FROM Employee_Hierarchy;
GO
