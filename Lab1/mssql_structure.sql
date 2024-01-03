USE MASTER;
GO;

IF DB_ID('UNIVERSITY') IS NOT NULL
    DROP DATABASE UNIVERSITY;
GO

CREATE DATABASE UNIVERSITY;
GO;

USE UNIVERSITY;
GO;

CREATE TABLE POSITION (
    POSITION_NAME NVARCHAR(50) PRIMARY KEY
);

INSERT INTO POSITION VALUES (N'Доцент'), (N'Профессор'), (N'Старший преподаватель'), (N'Преподаватель-стажёр'), (N'Ассистент'), (N'Инженер');

CREATE TABLE FACULTY (
    FACULTY NVARCHAR(10) PRIMARY KEY,
    FACULTY_NAME NVARCHAR(100)
);

INSERT INTO FACULTY VALUES (N'ФИТ', N'Факультет информационных технологий');

CREATE TABLE PULPIT (
    PULPIT NVARCHAR(10) PRIMARY KEY,
    FACULTY NVARCHAR(10),
    PULPIT_NAME NVARCHAR(150),
    CONSTRAINT FK_PULPIT_FACULTY
        FOREIGN KEY (FACULTY)
        REFERENCES FACULTY(FACULTY)
);

INSERT INTO PULPIT VALUES (N'ИСиТ', N'ФИТ', N'Информационные системы и технологии');

CREATE TABLE DISCIPLINE (
    DISCIPLINE NVARCHAR(10) PRIMARY KEY,
    PULPIT NVARCHAR(10),
    DISCIPLINE_NAME NVARCHAR(150),
    CONSTRAINT FK_DISCIPLINE_PULPIT
        FOREIGN KEY (PULPIT)
        REFERENCES PULPIT(PULPIT)
);

INSERT INTO DISCIPLINE (DISCIPLINE, PULPIT, DISCIPLINE_NAME)
VALUES (N'ПМС', N'ИСиТ', N'Проектирвоание мобильных систем'),
       (N'БД', N'ИСиТ', N'Базы данных'),
       (N'ОКГ', N'ИСиТ', N'Основы компьютерной геометрии'),
       (N'ПВИ', N'ИСиТ', N'Программирование в интернет');

CREATE TABLE EMPLOYEE (
    NODE HIERARCHYID PRIMARY KEY CLUSTERED,
    EMPLOYEE_ID INT UNIQUE,
    POSITION_NAME NVARCHAR(50),
    PULPIT NVARCHAR(10),
    NAME NVARCHAR(150),
    PHONE NCHAR(12),
    CONSTRAINT FK_EMPLOYEE_POSITION
        FOREIGN KEY (POSITION_NAME)
        REFERENCES POSITION(POSITION_NAME),
    CONSTRAINT FK_EMPLOYEE_PULPIT
        FOREIGN KEY (PULPIT)
        REFERENCES PULPIT(PULPIT)
);

INSERT INTO EMPLOYEE VALUES (
    HIERARCHYID::GetRoot(),
    1000,
    N'Доцент',
    N'ИСиТ',
    N'Квдратов Иосиф Алексеевич',
    N'375331112233'
);

DECLARE @ManagerNode HIERARCHYID;
SELECT @ManagerNode = NODE FROM EMPLOYEE WHERE EMPLOYEE_ID = 1000;

INSERT INTO EMPLOYEE VALUES (
    @ManagerNode.GetDescendant(NULL, NULL),
    1001,
    N'Старший преподаватель',
    N'ИСиТ',
    N'Круглов Добрыня Александрович',
    N'375331112233'
);

DECLARE @ManagerNode HIERARCHYID;
SELECT @ManagerNode = NODE FROM EMPLOYEE WHERE EMPLOYEE_ID = 1003;
DECLARE @SecondLevel HIERARCHYID;
SELECT @SecondLevel = NODE FROM EMPLOYEE WHERE EMPLOYEE_ID = 1007;

INSERT INTO EMPLOYEE VALUES (
    @ManagerNode.GetDescendant(NULL, NULL),
    1009,
    N'Преподаватель-стажёр',
    N'ИСиТ',
    N'Мирон Ян Артёмович',
    N'375331112233'
);

select NODE.ToString() as NodeAsString,
       NODE,
       NODE.GetLevel() as LEVEL,
       EMPLOYEE_ID,
       POSITION_NAME,
       NAME
FROM EMPLOYEE;

CREATE TABLE PULPIT_MANAGER (
    MANAGER_ID INT PRIMARY KEY,
    EMPLOYEE_ID INT,
    PULPIT NVARCHAR(10),
    CONSTRAINT FK_PULPIT_MANAGER_EMPLOYEE
        FOREIGN KEY (EMPLOYEE_ID)
        REFERENCES EMPLOYEE(EMPLOYEE_ID),
    CONSTRAINT FK_PULPIT_MANAGER_PULPIT
        FOREIGN KEY (PULPIT)
        REFERENCES PULPIT(PULPIT)
);

CREATE TABLE FACULTY_MANAGER (
    MANAGER_ID INT PRIMARY KEY,
    EMPLOYEE_ID INT,
    FACULTY NVARCHAR(10),
    CONSTRAINT FK_FACULTY_MANAGER_EMPLOYEE
        FOREIGN KEY (EMPLOYEE_ID)
        REFERENCES EMPLOYEE(EMPLOYEE_ID),
    CONSTRAINT FK_FACULTY_MANAGER_FACULTY
        FOREIGN KEY (FACULTY)
        REFERENCES FACULTY(FACULTY)
);

CREATE TABLE SPECIALITY (
    SPECIALITY_CODE NVARCHAR(10) PRIMARY KEY,
    FACULTY NVARCHAR(10),
    SPECIALITY_NAME NVARCHAR(100),
    QUALIFICATION NVARCHAR(100),
    CONSTRAINT FK_SPECIALITY_FACULTY
        FOREIGN KEY (FACULTY)
        REFERENCES FACULTY(FACULTY)
);

INSERT INTO SPECIALITY (SPECIALITY_CODE, FACULTY, SPECIALITY_NAME, QUALIFICATION)
VALUES (N'ПОИБИС', N'ФИТ', N'Программное обеспечение информационной безопасности мобильных систем', N'Инженер-программист');

CREATE TABLE "GROUP" (
    GROUP_ID INT PRIMARY KEY,
    SPECIALITY_CODE NVARCHAR(10),
    START_YEAR INT,
    CONSTRAINT FK_GROUP_SPECIALITY
        FOREIGN KEY (SPECIALITY_CODE)
        REFERENCES SPECIALITY(SPECIALITY_CODE)
);

INSERT INTO "GROUP" (GROUP_ID, SPECIALITY_CODE, START_YEAR)
VALUES (1, N'ПОИБМС', 2021),
       (2, N'ПОИБМС', 2021),
       (3, N'ПОИБМС', 2022),
       (4, N'ПОИБМС', 2022);

CREATE TABLE STUDENT (
    STUDENT_ID INT PRIMARY KEY,
    GROUP_ID INT,
    NAME NVARCHAR(100),
    BIRTH_DATE DATE,
    PHONE NCHAR(12),
    CONSTRAINT FK_STUDENT_GROUP
        FOREIGN KEY (GROUP_ID)
        REFERENCES "GROUP"(GROUP_ID)
);

INSERT INTO STUDENT (STUDENT_ID, GROUP_ID, NAME, BIRTH_DATE, PHONE)
VALUES (1, 1, N'Воликов Дмитрий Анатольевич', '02/17/2004', N'375291112233'),
       (2, 1, N'Парон Слава Андреевич', '02/19/2004', N'375291112233'),
       (3, 2, N'Слуга Алексей Петрович', '07/25/2003', N'375291112233'),
       (4, 2, N'Карто Эрик Валерьевич', '09/26/2004', N'375291112233'),
       (5, 3, N'Часы Никита Эдуардович', '08/02/2003', N'375291112233'),
       (6, 3, N'Топтына Честер Хайзенбергович', '01/21/2004', N'375291112233'),
       (7, 4, N'Лучина Лада Витальевна', '04/04/2003', N'375291112233'),
       (8, 4, N'Виковис Вика Викторовна', '06/22/2003', N'375291112233');

CREATE TABLE ADDRESS (
    ADDRESS_ID INT PRIMARY KEY,
    REGION NVARCHAR(15),
    CITY NVARCHAR(20),
    STREET NVARCHAR(25),
    BUILDING_NUMBER NVARCHAR(5)
);

CREATE TABLE BUILDING (
    BUILDING_ID NVARCHAR(5) PRIMARY KEY,
    BUILDING_ADDRESS INT,
    CONSTRAINT FK_BUILDING_ADDRESS
        FOREIGN KEY (BUILDING_ADDRESS)
        REFERENCES ADDRESS(ADDRESS_ID)
);

CREATE TABLE AUDITORIUM_TYPE (
    AUDITORIUM_TYPE NVARCHAR(10) PRIMARY KEY,
    AUDITORIUM_NAME NVARCHAR(30)
);

CREATE TABLE AUDITORIUM (
    AUDITORIUM NVARCHAR(10) PRIMARY KEY,
    AUDITORIUM_TYPE NVARCHAR(10),
    BUILDING_ID NVARCHAR(5),
    CAPACITY INT,
    CONSTRAINT FK_AUDITORIUM_BUILDING
        FOREIGN KEY (BUILDING_ID)
        REFERENCES BUILDING(BUILDING_ID)
);

DECLARE @startDate DATE = '2022-09-01';
DECLARE @endDate DATE = '2023-05-31';

DECLARE @disciplines TABLE (discipline NVARCHAR(50), employee_id INT);
INSERT INTO @disciplines VALUES (N'ПМС', 1004), (N'БД', 1001), (N'ОКГ', 1002), (N'ПВИ', 1008);

DECLARE @marks TABLE (student_id INT, employee_id INT, discipline NVARCHAR(50), mark INT, mark_date DATE);

WHILE @startDate <= @endDate
BEGIN
    INSERT INTO @marks (student_id, employee_id, discipline, mark, mark_date)
    SELECT 8, employee_id, discipline, FLOOR(RAND()*(10-4+1)+4), DATEADD(DAY, (ROW_NUMBER() OVER (PARTITION BY discipline ORDER BY (SELECT NULL)) - 1) * 7, @startDate)
    FROM @disciplines
    CROSS JOIN (VALUES (1),(2),(3),(4)) AS months(month);

    SET @startDate = DATEADD(MONTH, 1, @startDate);
END

INSERT INTO MARK (STUDENT_ID, EMPLOYEE_ID, DISCIPLINE, MARK, MARK_DATE)
SELECT student_id, employee_id, discipline, mark, mark_date
FROM @marks;

-- exam marks

INSERT INTO MARK (STUDENT_ID, EMPLOYEE_ID, DISCIPLINE, MARK, MARK_DATE)
VALUES (8, 1001, N'БД', 4, '06/03/2023'),
       (8, 1002, N'ОКГ', 4, '06/09/2023'),
       (8, 1008, N'ПВИ', 10, '06/16/2023'),
       (8, 1004, N'ПМС', 3, '06/20/2023'),
       (8, 1004, N'ПМС', 8, '06/21/2023');

-- exam marks

CREATE TABLE MARK (
    MARK_ID INT IDENTITY(1, 1) PRIMARY KEY,
    STUDENT_ID INT,
    EMPLOYEE_ID INT,
    DISCIPLINE NVARCHAR(10),
    MARK INT,
    MARK_DATE DATE,
    CONSTRAINT FK_MARK_STUDENT
        FOREIGN KEY (STUDENT_ID)
        REFERENCES STUDENT(STUDENT_ID),
    CONSTRAINT FK_MARK_EMPLOYEE
        FOREIGN KEY (EMPLOYEE_ID)
        REFERENCES EMPLOYEE(EMPLOYEE_ID),
    CONSTRAINT FK_MARK_DISCIPLINE
        FOREIGN KEY (DISCIPLINE)
        REFERENCES DISCIPLINE(DISCIPLINE)
);
GO;

-- Procedures

CREATE OR ALTER PROCEDURE ENROLL_STUDENT_IN_GROUP @STUDENT_ID INT, @GROUP_ID INT
AS BEGIN
    UPDATE STUDENT
    SET STUDENT.GROUP_ID = @GROUP_ID
    WHERE STUDENT.STUDENT_ID = @STUDENT_ID;
END;
GO;

CREATE OR ALTER PROCEDURE EXPEL_STUDENT_FROM_GROUP @STUDENT_ID INT AS
BEGIN
    UPDATE STUDENT
    SET GROUP_ID = NULL
    WHERE STUDENT_ID = @STUDENT_ID;
END;
GO;

CREATE OR ALTER PROCEDURE SET_NEW_FACULTY_DEAN @FACULTY NVARCHAR(10), @EMPLOYEE_ID INT
AS BEGIN
    UPDATE FACULTY_MANAGER
    SET EMPLOYEE_ID = @EMPLOYEE_ID
    WHERE FACULTY = @FACULTY;
END;
GO;

CREATE OR ALTER PROCEDURE SET_NEW_PULPIT_MANAGER @PULPIT NVARCHAR(10), @EMPLOYEE_ID INT
AS BEGIN
    UPDATE PULPIT_MANAGER
    SET EMPLOYEE_ID = @EMPLOYEE_ID
    WHERE PULPIT = @PULPIT;
END;
GO;

CREATE OR ALTER PROCEDURE SHOW_NODES @NODE HIERARCHYID
AS
    SELECT NODE.ToString() as NodeAsString,
       NODE,
       NODE.GetLevel() as LEVEL,
       EMPLOYEE_ID,
       POSITION_NAME,
       NAME
    FROM EMPLOYEE
    WHERE NODE.ToString() LIKE CONCAT(SUBSTRING(@NODE.ToString(), 0, 3), '/%')
    ORDER BY NodeAsString
    OFFSET 1 ROW;
GO;

DECLARE @node HIERARCHYID;
SELECT @node = NODE FROM EMPLOYEE WHERE EMPLOYEE_ID = 1001;
exec SHOW_NODES @NODE = @node;

CREATE OR ALTER PROCEDURE ADD_NODE @NODE HIERARCHYID, @LastDesc HIERARCHYID, @POSITION NVARCHAR(50), @PULPIT NVARCHAR(10), @NAME NVARCHAR(150), @PHONE NCHAR(12)
AS BEGIN
    DECLARE @NewID INT;
    SELECT @NewID = MAX(EMPLOYEE_ID) + 1 FROM EMPLOYEE;

    INSERT INTO EMPLOYEE VALUES (
        @NODE.GetDescendant(@LastDesc, NULL),
        (SELECT MAX(EMPLOYEE_ID) + 1 FROM EMPLOYEE),
        @POSITION,
        @PULPIT,
        @NAME,
        @PHONE
    );
END;
GO;

select NODE.ToString() as NodeAsString,
       NODE,
       NODE.GetLevel() as LEVEL,
       EMPLOYEE_ID,
       POSITION_NAME,
       NAME
FROM EMPLOYEE;

DECLARE @node HIERARCHYID, @LastDesc HIERARCHYID;
SELECT @node = NODE FROM EMPLOYEE WHERE EMPLOYEE_ID = 1004;
SELECT @lastDesc = NODE FROM EMPLOYEE WHERE EMPLOYEE_ID = 1009;
exec ADD_NODE @NODE = @node, @LastDesc = NULL, @POSITION = N'Преподаватель-стажёр', @PULPIT = N'ИСиТ', @NAME = N'Куделевич Мария Сергеевна', @PHONE = N'3752911122233';

CREATE OR ALTER PROCEDURE MOVE_NODE @NodeToMove HIERARCHYID, @ParentNode HIERARCHYID, @LastDescendant HIERARCHYID
AS BEGIN
    DECLARE @POS NVARCHAR(50), @PUL NVARCHAR(10), @NAME NVARCHAR(150), @TEL NCHAR(12), @ID INT;
    SELECT @POS = POSITION_NAME FROM EMPLOYEE WHERE NODE = @NodeToMove;
    SELECT @PUL = PULPIT FROM EMPLOYEE WHERE NODE = @NodeToMove;
    SELECT @NAME = NAME FROM EMPLOYEE WHERE NODE = @NodeToMove;
    SELECT @TEL = PHONE FROM EMPLOYEE WHERE NODE = @NodeToMove;
    SELECT @ID = MAX(EMPLOYEE_ID) + 1 FROM EMPLOYEE;

    INSERT INTO EMPLOYEE
    VALUES (@ParentNode.GetDescendant(@LastDescendant, NULL), @ID, @POS, @PUL, @NAME, @TEL);

    DELETE FROM EMPLOYEE WHERE NODE = @NodeToMove;
END;
GO;

DECLARE @nodeToMove HIERARCHYID, @destinationNode HIERARCHYID, @parentNode HIERARCHYID;
SELECT @nodeToMove = NODE FROM EMPLOYEE WHERE EMPLOYEE_ID = 1010;
SELECT @destinationNode = NODE FROM EMPLOYEE WHERE EMPLOYEE_ID = 1009;
SELECT @parentNode = NODE FROM EMPLOYEE WHERE EMPLOYEE_ID = 1003;
EXEC MOVE_NODE @nodeToMove, @parentNode, @destinationNode;

-- Functions

CREATE OR ALTER FUNCTION GET_FACULTY_BY_GROUP_ID(@ID INT) RETURNS NVARCHAR(10)
AS BEGIN
    declare @faculty NVARCHAR(10) = '';
    SET @faculty = (SELECT SPECIALITY.FACULTY
    FROM SPECIALITY
    JOIN "GROUP" ON "GROUP".SPECIALITY_CODE = SPECIALITY.SPECIALITY_CODE
    WHERE "GROUP".GROUP_ID = @ID);
    RETURN @faculty;
END;
GO;

CREATE OR ALTER FUNCTION GET_STUDENTS_AVERAGE_MARK() RETURNS TABLE
AS RETURN
    SELECT SPECIALITY.FACULTY AS 'Faculty',
           STUDENT.NAME AS 'Full name',
           AVG(MARK.MARK) AS 'Average mark'
    FROM STUDENT
    JOIN [GROUP] ON STUDENT.GROUP_ID = [GROUP].GROUP_ID
    JOIN MARK ON MARK.STUDENT_ID = STUDENT.STUDENT_ID
    JOIN SPECIALITY ON [GROUP].SPECIALITY_CODE = SPECIALITY.SPECIALITY_CODE
    GROUP BY STUDENT.NAME, SPECIALITY.FACULTY;
GO;

CREATE OR ALTER FUNCTION GET_EXCELLENT_STUDENTS() RETURNS TABLE
AS RETURN
    SELECT STUDENT.NAME AS 'Full name',
           AVG(MARK.MARK) AS 'Average mark'
    FROM STUDENT
    JOIN MARK ON MARK.STUDENT_ID = STUDENT.STUDENT_ID
    GROUP BY STUDENT.NAME
    HAVING AVG(MARK.MARK) > 4.5;
GO;

-- Views

CREATE OR ALTER VIEW FACULTIES_DEAN AS
SELECT FACULTY.FACULTY, FACULTY.FACULTY_NAME, EMPLOYEE.NAME
FROM FACULTY
JOIN FACULTY_MANAGER ON FACULTY_MANAGER.FACULTY = FACULTY.FACULTY
JOIN EMPLOYEE ON FACULTY_MANAGER.EMPLOYEE_ID = EMPLOYEE.EMPLOYEE_ID;
GO;

CREATE OR ALTER VIEW PULPITS_MANAGER AS
SELECT PULPIT.FACULTY, PULPIT.PULPIT, PULPIT.PULPIT_NAME, EMPLOYEE.NAME
FROM PULPIT
JOIN PULPIT_MANAGER ON PULPIT.PULPIT = PULPIT_MANAGER.PULPIT
JOIN EMPLOYEE ON PULPIT_MANAGER.EMPLOYEE_ID = EMPLOYEE.EMPLOYEE_ID;
GO;

CREATE OR ALTER VIEW PULPITS_EMPLOYEES AS
SELECT PULPIT.PULPIT AS 'Pulpit short name',
       PULPIT.PULPIT_NAME AS 'Pulpit full name',
       EMPLOYEE.NAME AS 'Full name'
FROM PULPIT
JOIN EMPLOYEE ON PULPIT.PULPIT = EMPLOYEE.PULPIT;
GO;

-- Indexes

CREATE INDEX STUDENT_NAME_INDEX ON STUDENT(NAME);
CREATE INDEX EMPLOYEE_NAME_INDEX ON EMPLOYEE(NAME);
CREATE INDEX DISCIPLINE_NAME_INDEX ON DISCIPLINE(DISCIPLINE_NAME);
CREATE INDEX PULPIT_NAME_INDEX ON PULPIT(PULPIT_NAME);
CREATE INDEX ADDRESS_INDEX ON ADDRESS(REGION, CITY, STREET, BUILDING_NUMBER);
CREATE INDEX AUDITORIUM_TYPE_CAPACITY_INDEX ON AUDITORIUM(AUDITORIUM_TYPE, CAPACITY);
GO;

-- Triggers

CREATE OR ALTER TRIGGER TR_STUDENT_DELETE ON STUDENT AFTER DELETE
AS BEGIN
    DELETE FROM MARK WHERE STUDENT_ID = (SELECT STUDENT_ID FROM DELETED);
END;
GO;

CREATE OR ALTER TRIGGER TR_DELETE_EMPLOYEE ON EMPLOYEE AFTER DELETE
AS BEGIN
    DELETE FROM FACULTY_MANAGER WHERE EMPLOYEE_ID = (SELECT EMPLOYEE_ID FROM DELETED);
    DELETE FROM PULPIT_MANAGER WHERE EMPLOYEE_ID = (SELECT EMPLOYEE_ID FROM DELETED);
END;
GO;

-- Lab 4

-- 1)

SELECT
    STUDENT.NAME,
    YEAR(MARK.MARK_DATE) AS Year,
    MONTH(MARK.MARK_DATE) AS Month,
    AVG(MARK.MARK) AS 'Month mark'
FROM MARK
JOIN STUDENT on MARK.STUDENT_ID = STUDENT.STUDENT_ID
WHERE MARK.MARK_DATE BETWEEN '2021-09-01' AND '2022-05-31'
GROUP BY
    STUDENT.NAME, YEAR(MARK.MARK_DATE), MONTH(MARK.MARK_DATE);

SELECT
    STUDENT.NAME,
    YEAR(MARK.MARK_DATE) AS Year,
    CASE
        WHEN MONTH(MARK.MARK_DATE) IN (9, 10, 11) THEN 'Sep-Nov'
        WHEN MONTH(MARK.MARK_DATE) IN (12, 1, 2) THEN 'Dec-Feb'
        ELSE 'Mar-May'
    END AS Quarter,
    AVG(MARK.MARK) AS [Quarter mark]
FROM MARK
JOIN STUDENT on MARK.STUDENT_ID = STUDENT.STUDENT_ID
WHERE MARK.MARK_DATE BETWEEN '2021-09-01' AND '2022-05-31'
GROUP BY
    STUDENT.NAME, YEAR(MARK.MARK_DATE),
    CASE
        WHEN MONTH(MARK.MARK_DATE) IN (9, 10, 11) THEN 'Sep-Nov'
        WHEN MONTH(MARK.MARK_DATE) IN (12, 1, 2) THEN 'Dec-Feb'
        ELSE 'Mar-May'
    END;

SELECT
    STUDENT.NAME,
    YEAR(MARK.MARK_DATE) AS Year,
    AVG(MARK.MARK) AS [Year mark]
FROM MARK
JOIN STUDENT on MARK.STUDENT_ID = STUDENT.STUDENT_ID
WHERE MARK.MARK_DATE BETWEEN '2021-09-01' AND '2022-05-31'
GROUP BY
    STUDENT.NAME, YEAR(MARK.MARK_DATE);

SELECT
    STUDENT.NAME,
    YEAR(MARK.MARK_DATE) AS Year,
    MONTH(MARK.MARK_DATE) AS Month,
    CASE
        WHEN MONTH(MARK.MARK_DATE) IN (9, 10, 11) THEN 'Sep-Nov'
        WHEN MONTH(MARK.MARK_DATE) IN (12, 1, 2) THEN 'Dec-Feb'
        ELSE 'Mar-May'
    END AS Quarter,
    AVG(MARK.MARK) AS AverageMark
FROM
    MARK
    JOIN STUDENT ON MARK.STUDENT_ID = STUDENT.STUDENT_ID
WHERE
    MARK.MARK_DATE BETWEEN '2021-09-01' AND '2022-05-31'
GROUP BY
    STUDENT.NAME,
    YEAR(MARK.MARK_DATE),
    MONTH(MARK.MARK_DATE),
    CASE
        WHEN MONTH(MARK.MARK_DATE) IN (9, 10, 11) THEN 'Sep-Nov'
        WHEN MONTH(MARK.MARK_DATE) IN (12, 1, 2) THEN 'Dec-Feb'
        ELSE 'Mar-May'
    END;


-- 2)
DECLARE @AverageByFaculty float = (
    SELECT CAST(AVG(MARK.MARK) AS float)
    FROM MARK
    JOIN STUDENT ON MARK.STUDENT_ID = STUDENT.STUDENT_ID
    JOIN [GROUP] ON STUDENT.GROUP_ID = [GROUP].GROUP_ID
    JOIN SPECIALITY ON [GROUP].SPECIALITY_CODE = SPECIALITY.SPECIALITY_CODE
    JOIN FACULTY ON SPECIALITY.FACULTY = FACULTY.FACULTY
    WHERE FACULTY.FACULTY like N'ФИТ'
);

DECLARE @BestFacultyMark float = (
    SELECT CAST(MAX(MARK.MARK) AS float)
    FROM MARK
    JOIN STUDENT ON MARK.STUDENT_ID = STUDENT.STUDENT_ID
    JOIN [GROUP] ON STUDENT.GROUP_ID = [GROUP].GROUP_ID
    JOIN SPECIALITY ON [GROUP].SPECIALITY_CODE = SPECIALITY.SPECIALITY_CODE
    JOIN FACULTY ON SPECIALITY.FACULTY = FACULTY.FACULTY
    WHERE FACULTY.FACULTY like N'ФИТ'
);

SELECT
    STUDENT.NAME,
    AVG(MARK) AS AverageMark,
    CAST(AVG(MARK) AS FLOAT) / @AverageByFaculty * 100 AS FacultyComparison,
    CAST(AVG(MARK) AS FLOAT) / @BestFacultyMark * 100 AS BestMarkComparison
FROM
    MARK
    JOIN STUDENT ON MARK.STUDENT_ID = STUDENT.STUDENT_ID
    JOIN [GROUP] ON STUDENT.GROUP_ID = [GROUP].GROUP_ID
    JOIN SPECIALITY ON [GROUP].SPECIALITY_CODE = SPECIALITY.SPECIALITY_CODE
    JOIN FACULTY ON SPECIALITY.FACULTY = FACULTY.FACULTY
WHERE
    MARK_DATE BETWEEN '2021-09-01' AND '2022-05-31'
    AND
    FACULTY.FACULTY = N'ФИТ'
GROUP BY STUDENT.NAME;


-- 3)

SELECT
    STUDENT.NAME,
    MARK.DISCIPLINE,
    AVG(MARK.MARK) AS AverageMark
FROM
    MARK
    JOIN STUDENT ON MARK.STUDENT_ID = STUDENT.STUDENT_ID
WHERE
    MARK.DISCIPLINE IN (
        SELECT TOP 3 DISCIPLINE
        FROM MARK
        GROUP BY DISCIPLINE
        ORDER BY MAX(MARK_DATE) DESC
    )
GROUP BY
    STUDENT.NAME, MARK.DISCIPLINE;

select * from MARK
WHERE MARK_DATE BETWEEN '06/01/2022' AND '06/25/2022';

-- 4)
WITH RankedMarks AS (
    SELECT
        MARK.DISCIPLINE AS Discipline,
        MARK.STUDENT_ID AS Student,
        COUNT(MARK.DISCIPLINE) AS Attempts
    FROM
        MARK
    WHERE
        MARK_DATE BETWEEN '2022-06-01' AND '2022-06-25'
    GROUP BY
        MARK.DISCIPLINE,
        MARK.STUDENT_ID
)
SELECT
    RankedMarks.Discipline AS Discipline,
    RankedMarks.Student AS Student,
    RankedMarks.Attempts AS Attempts
FROM RankedMarks
WHERE
    RankedMarks.Attempts = 2;

