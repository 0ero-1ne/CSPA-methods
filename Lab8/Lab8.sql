-- 2.	Создать объектные типы данных по своему варианту, реализовав:
--      a.	Дополнительный конструктор;
--      b.	Метод сравнения типа MAP или ORDER;
--      c.	Метод экземпляра функцию;
--      d.	Метод экземпляра процедуру.

-- Student type --
CREATE OR REPLACE TYPE StudentType AS OBJECT
(
    student_id number,
    group_id number,
    name NVARCHAR2(100),
    birth_date DATE,
    phone NCHAR(12),
    CONSTRUCTOR FUNCTION StudentType(p_student_id number, p_group_id number, p_name NVARCHAR2, p_birth_date DATE, p_phone NCHAR) RETURN SELF AS RESULT,
    MAP MEMBER FUNCTION get_id RETURN NUMBER DETERMINISTIC,
    MEMBER FUNCTION get_details RETURN VARCHAR2,
    MEMBER PROCEDURE print_details
);

CREATE OR REPLACE TYPE BODY StudentType
AS
    CONSTRUCTOR FUNCTION StudentType(
        p_student_id number,
        p_group_id number,
        p_name NVARCHAR2,
        p_birth_date DATE,
        p_phone NCHAR
    ) RETURN SELF AS RESULT
    IS
    BEGIN
        SELF.student_id := p_student_id;
        SELF.group_id := p_group_id;
        SELF.name := p_name;
        SELF.birth_date := p_birth_date;
        SELF.phone := p_phone;
        RETURN;
    END;

    MAP MEMBER FUNCTION get_id RETURN number IS
    BEGIN
        RETURN student_id;
    END;

    MEMBER FUNCTION get_details RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Student ID: ' || SELF.student_id || ', Group ID: ' || SELF.group_id || ', Name: ' || SELF.name || ', Birth Date: ' || TO_CHAR(SELF.birth_date, 'DD-MON-YYYY') || ', Phone: ' || SELF.phone;
    END;

    MEMBER PROCEDURE print_details IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('-----------------');
        DBMS_OUTPUT.PUT_LINE('Student ID: ' || student_id);
        DBMS_OUTPUT.PUT_LINE('Group ID: ' || group_id);
        DBMS_OUTPUT.PUT_LINE('Name: ' || name);
        DBMS_OUTPUT.PUT_LINE('Birth Date: ' || TO_CHAR(birth_date, 'DD-MON-YYYY'));
        DBMS_OUTPUT.PUT_LINE('Phone: ' || phone);
        DBMS_OUTPUT.PUT_LINE('-----------------');
    END;
END;



-- Group type --
CREATE OR REPLACE TYPE GroupType AS OBJECT
(
    group_id NUMBER,
    speciality_code NVARCHAR2(10),
    start_year NUMBER,
    CONSTRUCTOR FUNCTION GroupType(p_group_id number, p_speciality_code NVARCHAR2, p_start_year NUMBER) RETURN SELF AS RESULT,
    MAP MEMBER FUNCTION get_id RETURN NUMBER,
    MEMBER FUNCTION get_details RETURN VARCHAR2,
    MEMBER PROCEDURE print_details
);

CREATE OR REPLACE TYPE BODY GroupType
AS
    CONSTRUCTOR FUNCTION GroupType(
        p_group_id number,
        p_speciality_code NVARCHAR2,
        p_start_year number
    ) RETURN SELF AS RESULT
    IS
    BEGIN
        SELF.group_id := p_group_id;
        SELF.SPECIALITY_CODE := p_speciality_code;
        SELF.START_YEAR := p_start_year;
        RETURN;
    END;

    MAP MEMBER FUNCTION get_id RETURN number IS
    BEGIN
        RETURN group_id;
    END;

    MEMBER FUNCTION get_details RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Group ID: ' || SELF.group_id || ', Speciality code: ' || SELF.SPECIALITY_CODE || ', Start year: ' || SELF.START_YEAR;
    END;

    MEMBER PROCEDURE print_details IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('-----------------');
        DBMS_OUTPUT.PUT_LINE('Group ID: ' || group_id);
        DBMS_OUTPUT.PUT_LINE('Speciality code: ' || speciality_code);
        DBMS_OUTPUT.PUT_LINE('Start year: ' || start_year);
        DBMS_OUTPUT.PUT_LINE('-----------------');
    END;
END;


-- 3.	Скопировать данные из реляционных таблиц в объектные. --
CREATE TABLE StudentTypeTable OF STUDENTTYPE;
CREATE TABLE GroupTypeTable OF GROUPTYPE;

DROP TABLE StudentTypeTable;
DROP TABLE GroupTypeTable;

INSERT INTO StudentTypeTable SELECT * FROM STUDENT;
INSERT INTO GroupTypeTable SELECT * FROM "GROUP";

SELECT * FROM GroupTypeTable;
SELECT * FROM StudentTypeTable;

DECLARE
  student_obj StudentType;
BEGIN
  student_obj := NEW StudentType(
      student_id => 5,
      group_id => 1,
      name => 'John Doe',
      birth_date => TO_DATE('2000-01-01', 'YYYY-MM-DD'),
      phone => '375332902929'
  );
  student_obj.PRINT_DETAILS();
END;

-- 4.	Продемонстрировать применение объектных представлений --
CREATE VIEW StudentView OF StudentType
WITH OBJECT IDENTIFIER (student_id)
AS
    SELECT * FROM StudentTypeTable;

SELECT * FROM StudentView;

CREATE VIEW GroupView OF GroupType
WITH OBJECT IDENTIFIER (group_id)
AS
    SELECT * FROM GroupTypeTable;

SELECT * FROM GroupView;

DROP VIEW StudentView;
DROP VIEW GroupView;

-- 5.	Продемонстрировать применение индексов для индексирования по атрибуту и по методу в объектной таблице --

-- По атрибуту --
CREATE INDEX idx_student_name ON StudentTypeTable (NAME);
CREATE INDEX idx_group_speciality_code ON GroupTypeTable(SPECIALITY_CODE);

-- По методу в объекте --
CREATE TABLE StudentObjTable(
    student STUDENTTYPE
);

INSERT INTO StudentObjTable (student)
    SELECT VALUE(s) FROM StudentView s;

CREATE TABLE GroupObjTable(
    "group" GROUPTYPE
);

INSERT INTO GroupObjTable ("group")
    SELECT VALUE(g) FROM GroupView g;

DROP TABLE StudentObjTable;
DROP TABLE GroupObjTable;

CREATE INDEX idx_student_getID ON StudentObjTable(student.GET_ID());