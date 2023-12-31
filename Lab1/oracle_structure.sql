CREATE TABLESPACE TS_UNIVERSITY
    DATAFILE 'tbs_university'
    SIZE 5M
    AUTOEXTEND ON NEXT 1M
    EXTENT MANAGEMENT LOCAL UNIFORM SIZE 64K;

CREATE TABLE POSITION (
    POSITION_NAME NVARCHAR2(50) PRIMARY KEY
)
TABLESPACE TS_UNIVERSITY;

INSERT INTO POSITION VALUES (N'Доцент');
INSERT INTO POSITION VALUES (N'Профессор');
INSERT INTO POSITION VALUES (N'Старший преподаватель');
INSERT INTO POSITION VALUES (N'Преподаватель-стажёр');
INSERT INTO POSITION VALUES (N'Ассистент');
INSERT INTO POSITION VALUES (N'Инженер');
COMMIT;

CREATE TABLE FACULTY (
    FACULTY NVARCHAR2(10) PRIMARY KEY,
    FACULTY_NAME NVARCHAR2(100)
)
TABLESPACE TS_UNIVERSITY;

INSERT INTO FACULTY VALUES (N'ФИТ', N'Факультет информационных технологий');
COMMIT;

CREATE TABLE PULPIT (
    PULPIT NVARCHAR2(10) PRIMARY KEY,
    FACULTY NVARCHAR2(10),
    PULPIT_NAME NVARCHAR2(150),
    CONSTRAINT FK_PULPIT_FACULTY
        FOREIGN KEY (FACULTY)
        REFERENCES FACULTY(FACULTY)
    ON DELETE CASCADE
)
TABLESPACE TS_UNIVERSITY;

INSERT INTO PULPIT VALUES (N'ИСиТ', N'ФИТ', N'Информационные системы и технологии');
COMMIT;

CREATE TABLE DISCIPLINE (
    DISCIPLINE NVARCHAR2(10) PRIMARY KEY,
    PULPIT NVARCHAR2(10),
    DISCIPLINE_NAME NVARCHAR2(150),
    CONSTRAINT FK_DISCIPLINE_PULPIT
        FOREIGN KEY (PULPIT)
        REFERENCES PULPIT(PULPIT)
    ON DELETE CASCADE
)
TABLESPACE TS_UNIVERSITY;

CREATE TABLE EMPLOYEE (
    EMPLOYEE_ID INT PRIMARY KEY,
    POSITION_NAME NVARCHAR2(50),
    PULPIT NVARCHAR2(10),
    NAME NVARCHAR2(150),
    PHONE NCHAR(12),
    CONSTRAINT FK_EMPLOYEE_POSITION
        FOREIGN KEY (POSITION_NAME)
        REFERENCES POSITION(POSITION_NAME)
    ON DELETE CASCADE,
    CONSTRAINT FK_EMPLOYEE_PULPIT
        FOREIGN KEY (PULPIT)
        REFERENCES PULPIT(PULPIT)
    ON DELETE CASCADE
)
TABLESPACE TS_UNIVERSITY;

SELECT * FROM EMPLOYEE;

CREATE TABLE PULPIT_MANAGER (
    MANAGER_ID INT PRIMARY KEY,
    EMPLOYEE_ID INT,
    PULPIT NVARCHAR2(10),
    CONSTRAINT FK_PULPIT_MANAGER_EMPLOYEE
        FOREIGN KEY (EMPLOYEE_ID)
        REFERENCES EMPLOYEE(EMPLOYEE_ID)
    ON DELETE CASCADE,
    CONSTRAINT FK_PULPIT_MANAGER_PULPIT
        FOREIGN KEY (PULPIT)
        REFERENCES PULPIT(PULPIT)
    ON DELETE CASCADE
)
TABLESPACE TS_UNIVERSITY;

CREATE TABLE FACULTY_MANAGER (
    MANAGER_ID INT PRIMARY KEY,
    EMPLOYEE_ID INT,
    FACULTY NVARCHAR2(10),
    CONSTRAINT FK_FACULTY_MANAGER_EMPLOYEE
        FOREIGN KEY (EMPLOYEE_ID)
        REFERENCES EMPLOYEE(EMPLOYEE_ID)
    ON DELETE CASCADE,
    CONSTRAINT FK_FACULTY_MANAGER_FACULTY
        FOREIGN KEY (FACULTY)
        REFERENCES FACULTY(FACULTY)
    ON DELETE CASCADE
)
TABLESPACE TS_UNIVERSITY;

CREATE TABLE SPECIALITY (
    SPECIALITY_CODE NVARCHAR2(10) PRIMARY KEY,
    FACULTY NVARCHAR2(10),
    SPECIALITY_NAME NVARCHAR2(100),
    QUALIFICATION NVARCHAR2(100),
    CONSTRAINT FK_SPECIALITY_FACULTY
        FOREIGN KEY (FACULTY)
        REFERENCES FACULTY(FACULTY)
    ON DELETE CASCADE
)
TABLESPACE TS_UNIVERSITY;

CREATE TABLE "GROUP" (
    GROUP_ID INT PRIMARY KEY,
    SPECIALITY_CODE NVARCHAR2(10),
    START_YEAR INT,
    CONSTRAINT FK_GROUP_SPECIALITY
        FOREIGN KEY (SPECIALITY_CODE)
        REFERENCES SPECIALITY(SPECIALITY_CODE)
    ON DELETE CASCADE
)
TABLESPACE TS_UNIVERSITY;

CREATE TABLE STUDENT (
    STUDENT_ID INT PRIMARY KEY,
    GROUP_ID INT,
    NAME NVARCHAR2(100),
    BIRTH_DATE DATE,
    PHONE NCHAR(12),
    CONSTRAINT FK_STUDENT_GROUP
        FOREIGN KEY (GROUP_ID)
        REFERENCES "GROUP"(GROUP_ID)
    ON DELETE CASCADE
)
TABLESPACE TS_UNIVERSITY;

CREATE TABLE ADDRESS (
    ADDRESS_ID INT PRIMARY KEY,
    REGION NVARCHAR2(15),
    CITY NVARCHAR2(20),
    STREET NVARCHAR2(25),
    BUILDING_NUMBER NVARCHAR2(5)
)
TABLESPACE TS_UNIVERSITY;

CREATE TABLE BUILDING (
    BUILDING_ID NVARCHAR2(5) PRIMARY KEY,
    BUILDING_ADDRESS INT,
    CONSTRAINT FK_BUILDING_ADDRESS
        FOREIGN KEY (BUILDING_ADDRESS)
        REFERENCES ADDRESS(ADDRESS_ID)
    ON DELETE CASCADE
)
TABLESPACE TS_UNIVERSITY;

CREATE TABLE AUDITORIUM_TYPE (
    AUDITORIUM_TYPE NVARCHAR2(10) PRIMARY KEY,
    AUDITORIUM_NAME NVARCHAR2(30)
)
TABLESPACE TS_UNIVERSITY;

CREATE TABLE AUDITORIUM (
    AUDITORIUM NVARCHAR2(10) PRIMARY KEY,
    AUDITORIUM_TYPE NVARCHAR2(10),
    BUILDING_ID NVARCHAR2(5),
    CAPACITY INT,
    CONSTRAINT FK_AUDITORIUM_BUILDING
        FOREIGN KEY (BUILDING_ID)
        REFERENCES BUILDING(BUILDING_ID)
    ON DELETE CASCADE
)
TABLESPACE TS_UNIVERSITY;

CREATE TABLE MARK (
    MARK_ID INT PRIMARY KEY,
    STUDENT_ID INT,
    EMPLOYEE_ID INT,
    DISCIPLINE NVARCHAR2(10),
    MARK INT,
    MARK_DATE DATE,
    CONSTRAINT FK_MARK_STUDENT
        FOREIGN KEY (STUDENT_ID)
        REFERENCES STUDENT(STUDENT_ID)
    ON DELETE CASCADE,
    CONSTRAINT FK_MARK_EMPLOYEE
        FOREIGN KEY (EMPLOYEE_ID)
        REFERENCES EMPLOYEE(EMPLOYEE_ID)
    ON DELETE CASCADE,
    CONSTRAINT FK_MARK_DISCIPLINE
        FOREIGN KEY (DISCIPLINE)
        REFERENCES DISCIPLINE(DISCIPLINE)
    ON DELETE CASCADE
)
TABLESPACE TS_UNIVERSITY;

-- Indexes

CREATE INDEX STUDENT_NAME_INDEX ON STUDENT(NAME);
CREATE INDEX EMPLOYEE_NAME_INDEX ON EMPLOYEE(NAME);
CREATE INDEX DISCIPLINE_NAME_INDEX ON DISCIPLINE(DISCIPLINE_NAME);
CREATE INDEX PULPIT_NAME_INDEX ON PULPIT(PULPIT_NAME);
CREATE INDEX ADDRESS_INDEX ON ADDRESS(REGION, CITY, STREET, BUILDING_NUMBER);
CREATE INDEX AUDITORIUM_TYPE_CAPACITY_INDEX ON AUDITORIUM(AUDITORIUM_TYPE, CAPACITY);

-- Procedures

CREATE OR REPLACE PROCEDURE ENROLL_STUDENT_IN_GROUP(
    P_STUDENT_ID IN NUMBER,
    P_GROUP_ID IN NUMBER
)
AS
BEGIN
    UPDATE STUDENT
    SET GROUP_ID = P_GROUP_ID
    WHERE STUDENT_ID = P_STUDENT_ID;
END;

CREATE OR REPLACE PROCEDURE EXPEL_STUDENT_FROM_GROUP(
    P_STUDENT_ID IN NUMBER
)
AS
BEGIN
    UPDATE STUDENT
    SET GROUP_ID = NULL
    WHERE STUDENT_ID = P_STUDENT_ID;
END;

CREATE OR REPLACE PROCEDURE SET_NEW_FACULTY_DEAN(
    P_FACULTY IN NVARCHAR2,
    P_EMPLOYEE_ID IN NUMBER
)
AS
BEGIN
    UPDATE FACULTY_MANAGER
    SET EMPLOYEE_ID = P_EMPLOYEE_ID
    WHERE FACULTY = P_FACULTY;
END;

CREATE OR REPLACE PROCEDURE SET_NEW_PULPIT_MANAGER(
    P_PULPIT IN NVARCHAR2,
    P_EMPLOYEE_ID IN NUMBER
)
AS
BEGIN
    UPDATE PULPIT_MANAGER
    SET EMPLOYEE_ID = P_EMPLOYEE_ID
    WHERE PULPIT = P_PULPIT;
END;

-- EMPLOYEE_ID INT PRIMARY KEY,
--     POSITION_NAME NVARCHAR2(50),
--     PULPIT NVARCHAR2(10),
--     NAME NVARCHAR2(150),
--     PHONE NCHAR(12),
--     CONSTRAINT FK_EMPLOYEE_POSITION
--         FOREIGN KEY (POSITION_NAME)
--         REFERENCES POSITION(POSITION_NAME)
--     ON DELETE CASCADE,
--     CONSTRAINT FK_EMPLOYEE_PULPIT
--         FOREIGN KEY (PULPIT)
--         REFERENCES PULPIT(PULPIT)
--     ON DELETE CASCADE

CREATE OR REPLACE TYPE EMPLOYEE_TYPE AS OBJECT (
    EMPLOYEE_ID INT,
    POSITION_NAME NVARCHAR2(50),
    PULPIT NVARCHAR2(10),
    NAME NVARCHAR2(150),
    PHONE NCHAR(12),
    MANAGER_ID INT,
    NODE_LEVEL INT
);

CREATE TYPE EMPLOYEE_TABLE_TAPE AS TABLE OF EMPLOYEE_TYPE;

CREATE OR REPLACE FUNCTION SHOW_NODES(P_NODE IN INT)
RETURN EMPLOYEE_TABLE_TAPE PIPELINED IS
BEGIN
     FOR rec IN (
        SELECT
            EMPLOYEE_ID,
            POSITION_NAME,
            PULPIT,
            NAME,
            PHONE,
            MANAGER_ID,
            LEVEL as node_level
        FROM
            EMPLOYEE
        START WITH EMPLOYEE_ID = P_NODE
        CONNECT BY PRIOR EMPLOYEE_ID = EMPLOYEE.MANAGER_ID
    ) LOOP
        PIPE ROW(EMPLOYEE_TYPE(rec.EMPLOYEE_ID, rec.POSITION_NAME, rec.PULPIT, rec.NAME, rec.PHONE, rec.MANAGER_ID, rec.node_level));
    END LOOP;
    RETURN;
END;

SELECT * FROM TABLE(SHOW_NODES(1000));

CREATE OR REPLACE PROCEDURE ADD_NODE(
    P_EMPLOYEE_ID INT,
    P_POSITION NVARCHAR2,
    P_PULPIT NVARCHAR2,
    P_NAME NVARCHAR2,
    P_PHONE NCHAR,
    P_MANAGER_ID INT
)
AS BEGIN
    INSERT INTO EMPLOYEE (EMPLOYEE_ID, POSITION_NAME, PULPIT, NAME, PHONE, MANAGER_ID)
    VALUES (P_EMPLOYEE_ID, P_POSITION, P_PULPIT, P_NAME, P_PHONE, P_MANAGER_ID);
    COMMIT;
END;

BEGIN
    ADD_NODE(1011, N'Ассистент', N'ИСиТ', N'Ковалёв Андрей Леонидович', N'375291112233', 1003);
END;

CREATE OR REPLACE PROCEDURE MOVE_NODE(
    P_OLD_PARENT IN INT,
    P_NEW_PARENT IN INT
)
AS BEGIN
    UPDATE EMPLOYEE
    SET MANAGER_ID = P_NEW_PARENT
    WHERE MANAGER_ID = P_OLD_PARENT;
    COMMIT;
END;

BEGIN
    MOVE_NODE(1003, 1001);
end;

-- Functions

CREATE OR REPLACE FUNCTION GET_FACULTY_BY_GROUP_ID(
    P_GROUP_ID IN NUMBER
)
RETURN NVARCHAR2
AS
BEGIN
    DECLARE
        P_FACULTY NVARCHAR2(10);
    BEGIN
        SELECT SPECIALITY.FACULTY
        INTO P_FACULTY
        FROM SPECIALITY
        JOIN "GROUP" ON "GROUP".SPECIALITY_CODE = SPECIALITY.SPECIALITY_CODE
        WHERE "GROUP".GROUP_ID = P_GROUP_ID;

        RETURN P_FACULTY;
    END;
END;

CREATE OR REPLACE FUNCTION GET_STUDENTS_AVERAGE_MARK
RETURN SYS_REFCURSOR
AS
BEGIN
    DECLARE
        L_CURSOR SYS_REFCURSOR;
    BEGIN
        OPEN L_CURSOR FOR
            SELECT SPECIALITY.FACULTY AS FACULTY,
                   STUDENT.NAME AS FULL_NAME,
                   AVG(MARK.MARK) AS AVERAGE_MARK
            FROM STUDENT
            JOIN "GROUP" ON STUDENT.GROUP_ID = "GROUP".GROUP_ID
            JOIN MARK ON MARK.STUDENT_ID = STUDENT.STUDENT_ID
            JOIN SPECIALITY ON "GROUP".SPECIALITY_CODE = SPECIALITY.SPECIALITY_CODE
            GROUP BY STUDENT.NAME, SPECIALITY.FACULTY;

        RETURN L_CURSOR;
    END;
END;

CREATE OR REPLACE FUNCTION GET_EXCELLENT_STUDENTS
RETURN SYS_REFCURSOR
AS
BEGIN
    DECLARE
        L_CURSOR SYS_REFCURSOR;
    BEGIN
        OPEN L_CURSOR FOR
            SELECT STUDENT.NAME AS FULL_NAME,
                   AVG(MARK.MARK) AS AVERAGE_MARK
            FROM STUDENT
            JOIN MARK ON MARK.STUDENT_ID = STUDENT.STUDENT_ID
            GROUP BY STUDENT.NAME
            HAVING AVG(MARK.MARK) > 4.5;

        RETURN L_CURSOR;
    END;
END;

-- Views

CREATE OR REPLACE VIEW FACULTIES_DEAN AS
SELECT FACULTY.FACULTY, FACULTY.FACULTY_NAME, EMPLOYEE.NAME
FROM FACULTY
JOIN FACULTY_MANAGER ON FACULTY_MANAGER.FACULTY = FACULTY.FACULTY
JOIN EMPLOYEE ON FACULTY_MANAGER.EMPLOYEE_ID = EMPLOYEE.EMPLOYEE_ID;

CREATE OR REPLACE VIEW PULPITS_MANAGER AS
SELECT PULPIT.FACULTY, PULPIT.PULPIT, PULPIT.PULPIT_NAME, EMPLOYEE.NAME
FROM PULPIT
JOIN PULPIT_MANAGER ON PULPIT.PULPIT = PULPIT_MANAGER.PULPIT
JOIN EMPLOYEE ON PULPIT_MANAGER.EMPLOYEE_ID = EMPLOYEE.EMPLOYEE_ID;

CREATE OR REPLACE VIEW PULPITS_EMPLOYEES AS
SELECT PULPIT.PULPIT AS "Pulpit short name",
       PULPIT.PULPIT_NAME AS "Pulpit full name",
       EMPLOYEE.NAME AS "Full name"
FROM PULPIT
JOIN EMPLOYEE ON PULPIT.PULPIT = EMPLOYEE.PULPIT;

-- Triggers

-- CREATE OR REPLACE TRIGGER TR_STUDENT_DELETE
-- AFTER DELETE ON STUDENT
-- FOR EACH ROW
-- BEGIN
--     DELETE FROM MARK WHERE STUDENT_ID = :OLD.STUDENT_ID;
-- END;
--
-- CREATE OR REPLACE TRIGGER TR_DELETE_EMPLOYEE
-- AFTER DELETE ON EMPLOYEE
-- FOR EACH ROW
-- BEGIN
--     DELETE FROM FACULTY_MANAGER WHERE EMPLOYEE_ID = :OLD.EMPLOYEE_ID;
--     DELETE FROM PULPIT_MANAGER WHERE EMPLOYEE_ID = :OLD.EMPLOYEE_ID;
-- END;

SELECT *
FROM
(
    SELECT
        ROW_NUMBER() OVER (ORDER BY MARK_DATE) AS row_num,
        Mark.*
    FROM
        Mark
)
WHERE row_num BETWEEN 9 and 16;

DELETE
FROM MARK
where row_number() OVER ( PARTITION BY Mark order by MARK_DATE) = (
    SELECT
        ROW_NUMBER() OVER (PARTITION BY Mark ORDER BY MARK_DATE) AS row_num,
        Mark.*
    FROM
        Mark
    WHERE
        MARK_DATE BETWEEN date '2023-01-01' AND date '2024-01-01'
);