-- 0. Разработайте локальные процедуру и функцию для своей БД по варианту

DECLARE
PROCEDURE ADD_ADDRESS_LOCAL
(
    p_id IN NUMBER,
    p_region IN NVARCHAR2,
    p_city IN NVARCHAR2,
    p_street IN NVARCHAR2,
    p_building_number IN NVARCHAR2
)
IS
    empty_parameter_ex EXCEPTION;
BEGIN
    IF p_id IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_region IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_city IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_street IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_building_number IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    INSERT INTO ADDRESS (ADDRESS_ID, REGION, CITY, STREET, BUILDING_NUMBER)
    VALUES (p_id, p_region, p_city, p_street, p_building_number);
    COMMIT;
EXCEPTION
    WHEN empty_parameter_ex THEN
        dbms_output.put_line('Empty parameter');
    WHEN OTHERS THEN
        dbms_output.put_line('Procedure error! Check you parameters');
END;
BEGIN
    ADD_ADDRESS_LOCAL(4, 'Minsk', 'Minsk', 'Bobruiskaya', '25');
END;

select * from ADDRESS;

DECLARE
FUNCTION GET_FACULTY_BY_GROUP_ID_LOCAL(
    p_group_id IN NUMBER
) RETURN NVARCHAR2
AS
BEGIN
    IF p_group_id IS NULL THEN
        RETURN 'There is no group with ID = NULL';
    END IF;

    DECLARE
        P_FACULTY NVARCHAR2(10);
    BEGIN
        SELECT SPECIALITY.FACULTY
        INTO P_FACULTY
        FROM SPECIALITY
        JOIN "GROUP" ON "GROUP".SPECIALITY_CODE = SPECIALITY.SPECIALITY_CODE
        WHERE "GROUP".GROUP_ID = p_group_id;

        IF P_FACULTY LIKE '' THEN
            RETURN 'There is no group with ID = ' || p_group_id;
        end if;

        RETURN P_FACULTY;
    END;
END;
BEGIN
    SELECT GET_FACULTY_BY_GROUP_ID_LOCAL(1) FROM DUAL;
END;

-- 1. Для пакета
CREATE OR REPLACE PROCEDURE SYSTEM.ADD_ADDRESS
(
    p_id IN NUMBER,
    p_region IN NVARCHAR2,
    p_city IN NVARCHAR2,
    p_street IN NVARCHAR2,
    p_building_number IN NVARCHAR2
)
IS
    empty_parameter_ex EXCEPTION;
BEGIN
    IF p_id IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_region IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_city IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_street IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_building_number IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    INSERT INTO ADDRESS (ADDRESS_ID, REGION, CITY, STREET, BUILDING_NUMBER)
    VALUES (p_id, p_region, p_city, p_street, p_building_number);
    COMMIT;
EXCEPTION
    WHEN empty_parameter_ex THEN
        dbms_output.put_line('Empty parameter');
    WHEN OTHERS THEN
        dbms_output.put_line('Procedure error! Check you parameters');
END;

CREATE OR REPLACE FUNCTION SYSTEM.GET_FACULTY_BY_GROUP_ID(
    p_group_id IN NUMBER
)
RETURN NVARCHAR2
AS
BEGIN
    IF p_group_id IS NULL THEN
        RETURN 'There is no group with ID = NULL';
    END IF;

    DECLARE
        P_FACULTY NVARCHAR2(10);
    BEGIN
        SELECT SPECIALITY.FACULTY
        INTO P_FACULTY
        FROM SPECIALITY
        JOIN "GROUP" ON "GROUP".SPECIALITY_CODE = SPECIALITY.SPECIALITY_CODE
        WHERE "GROUP".GROUP_ID = p_group_id;

        IF P_FACULTY LIKE '' THEN
            RETURN 'There is no group with ID = ' || p_group_id;
        end if;

        RETURN P_FACULTY;
    END;
END;

BEGIN
    ADD_ADDRESS(1, 'Minsk', 'Minsk', 'Sverdlova', '13a');
end;

SELECT * FROM ADDRESS;

SELECT GET_FACULTY_BY_GROUP_ID(4) FROM DUAL;
COMMIT;

-- 3. Разработайте 2 хранимые процедуры:
-- одну для выполнения какого-либо DML-оператора для своей БД по варианту,
-- а вторую – для получения какого-либо результирующего набора для своей БД по варианту.
-- Предусмотрите обработку ошибок.

CREATE OR REPLACE PROCEDURE ADD_ADDRESS_2
(
    p_id IN NUMBER,
    p_region IN NVARCHAR2,
    p_city IN NVARCHAR2,
    p_street IN NVARCHAR2,
    p_building_number IN NVARCHAR2
)
IS
    empty_parameter_ex EXCEPTION;
BEGIN
    IF p_id IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_region IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_city IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_street IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_building_number IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    INSERT INTO ADDRESS (ADDRESS_ID, REGION, CITY, STREET, BUILDING_NUMBER)
    VALUES (p_id, p_region, p_city, p_street, p_building_number);
    COMMIT;
EXCEPTION
    WHEN empty_parameter_ex THEN
        dbms_output.put_line('Empty parameter');
    WHEN OTHERS THEN
        dbms_output.put_line('Procedure error! Check you parameters');
END;

CREATE OR REPLACE PROCEDURE GET_ADDRESSES
(
    c_addresses OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN c_addresses FOR
    SELECT * FROM ADDRESS;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Procedure error! Check you parameters');
END;

DECLARE
 c_address SYS_REFCURSOR;
 temp_addresses ADDRESS%ROWTYPE;
BEGIN
 GET_ADDRESSES(c_address);

 LOOP
       FETCH c_address INTO temp_addresses;
       EXIT WHEN c_address%NOTFOUND;
       dbms_output.put_line(temp_addresses.ADDRESS_ID || ' :: ' || temp_addresses.REGION || ' :: ' || temp_addresses.CITY || ' :: ' || temp_addresses.STREET || ' :: ' || temp_addresses.BUILDING_NUMBER);
 END LOOP;

 CLOSE c_address;
END;

-- 5. Разработайте 2 функции, определенные пользователем:
-- одну для вычисления какого-либо агрегатного значения над набором строк для своей БД по варианту (например, суммы или среднего),
-- а вторую – для обработки дат для своей БД по варианту (например, получения разницы дат).

CREATE OR REPLACE FUNCTION SYSTEM.GET_FACULTIES_COUNT
RETURN NUMBER
AS
BEGIN
    DECLARE
        P_FACULTY NUMBER;
    BEGIN
        SELECT COUNT(FACULTY.FACULTY) INTO P_FACULTY FROM FACULTY;
        RETURN P_FACULTY;
    END;
END;

CREATE OR REPLACE FUNCTION SYSTEM.GET_STUDENTS_BIRTHDATE_MAX
(
    p_stud1 IN NUMBER,
    p_stud2 IN NUMBER
)
RETURN DATE
AS
BEGIN
    IF p_stud1 IS NULL THEN
        RETURN TO_DATE('00.00.0000', 'DD.MM.YYYY');
    end if;
    IF p_stud2 IS NULL THEN
        RETURN TO_DATE('00.00.0000', 'DD.MM.YYYY');
    end if;
    DECLARE
        result DATE;
    BEGIN
        SELECT MAX(BIRTH_DATE) INTO result FROM STUDENT WHERE STUDENT_ID IN (p_stud1, p_stud2);
        RETURN result;
    END;
END;

SELECT GET_FACULTIES_COUNT() AS Faculties_Count FROM DUAL;
SELECT GET_STUDENTS_BIRTHDATE_MAX(1, 2) FROM DUAL;

-- 8. Разработайте пакет, содержащий данные процедуры и функции


create or replace package CoolPackage
as
PROCEDURE ADD_ADDRESS
(
    p_id IN NUMBER,
    p_region IN NVARCHAR2,
    p_city IN NVARCHAR2,
    p_street IN NVARCHAR2,
    p_building_number IN NVARCHAR2
);

FUNCTION GET_FACULTY_BY_GROUP_ID(
    p_group_id IN NUMBER
) RETURN NVARCHAR2;

PROCEDURE ADD_ADDRESS_2
(
    p_id IN NUMBER,
    p_region IN NVARCHAR2,
    p_city IN NVARCHAR2,
    p_street IN NVARCHAR2,
    p_building_number IN NVARCHAR2
);

PROCEDURE GET_ADDRESSES
(
    c_addresses OUT SYS_REFCURSOR
);

FUNCTION GET_FACULTIES_COUNT
RETURN NUMBER;

FUNCTION GET_STUDENTS_BIRTHDATE_MAX
(
    p_stud1 IN NUMBER,
    p_stud2 IN NUMBER
)
RETURN DATE;

END;

CREATE OR REPLACE PACKAGE BODY CoolPackage
IS
PROCEDURE ADD_ADDRESS
(
    p_id IN NUMBER,
    p_region IN NVARCHAR2,
    p_city IN NVARCHAR2,
    p_street IN NVARCHAR2,
    p_building_number IN NVARCHAR2
)
IS
    empty_parameter_ex EXCEPTION;
BEGIN
    IF p_id IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_region IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_city IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_street IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_building_number IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    INSERT INTO ADDRESS (ADDRESS_ID, REGION, CITY, STREET, BUILDING_NUMBER)
    VALUES (p_id, p_region, p_city, p_street, p_building_number);
    COMMIT;
EXCEPTION
    WHEN empty_parameter_ex THEN
        dbms_output.put_line('Empty parameter');
    WHEN OTHERS THEN
        dbms_output.put_line('Procedure error! Check you parameters');
END;

FUNCTION GET_FACULTY_BY_GROUP_ID(
    p_group_id IN NUMBER
)
RETURN NVARCHAR2
AS
BEGIN
    IF p_group_id IS NULL THEN
        RETURN 'There is no group with ID = NULL';
    END IF;

    DECLARE
        P_FACULTY NVARCHAR2(10);
    BEGIN
        SELECT SPECIALITY.FACULTY
        INTO P_FACULTY
        FROM SPECIALITY
        JOIN "GROUP" ON "GROUP".SPECIALITY_CODE = SPECIALITY.SPECIALITY_CODE
        WHERE "GROUP".GROUP_ID = p_group_id;

        IF P_FACULTY LIKE '' THEN
            RETURN 'There is no group with ID = ' || p_group_id;
        end if;

        RETURN P_FACULTY;
    END;
END;

PROCEDURE ADD_ADDRESS_2
(
    p_id IN NUMBER,
    p_region IN NVARCHAR2,
    p_city IN NVARCHAR2,
    p_street IN NVARCHAR2,
    p_building_number IN NVARCHAR2
)
IS
    empty_parameter_ex EXCEPTION;
BEGIN
    IF p_id IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_region IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_city IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_street IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    IF p_building_number IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    INSERT INTO ADDRESS (ADDRESS_ID, REGION, CITY, STREET, BUILDING_NUMBER)
    VALUES (p_id, p_region, p_city, p_street, p_building_number);
    COMMIT;
EXCEPTION
    WHEN empty_parameter_ex THEN
        dbms_output.put_line('Empty parameter');
    WHEN OTHERS THEN
        dbms_output.put_line('Procedure error! Check you parameters');
END;

PROCEDURE GET_ADDRESSES
(
    c_addresses OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN c_addresses FOR
    SELECT * FROM ADDRESS;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Procedure error! Check you parameters');
END;

FUNCTION GET_FACULTIES_COUNT
RETURN NUMBER
AS
BEGIN
    DECLARE
        P_FACULTY NUMBER;
    BEGIN
        SELECT COUNT(FACULTY.FACULTY) INTO P_FACULTY FROM FACULTY;
        RETURN P_FACULTY;
    END;
END;

FUNCTION GET_STUDENTS_BIRTHDATE_MAX
(
    p_stud1 IN NUMBER,
    p_stud2 IN NUMBER
)
RETURN DATE
AS
BEGIN
    IF p_stud1 IS NULL THEN
        RETURN TO_DATE('00.00.0000', 'DD.MM.YYYY');
    end if;
    IF p_stud2 IS NULL THEN
        RETURN TO_DATE('00.00.0000', 'DD.MM.YYYY');
    end if;
    DECLARE
        result DATE;
    BEGIN
        SELECT MAX(BIRTH_DATE) INTO result FROM STUDENT WHERE STUDENT_ID IN (p_stud1, p_stud2);
        RETURN result;
    END;
END;

END;

select CoolPackage.GET_STUDENTS_BIRTHDATE_MAX(1, 2) FROM DUAL;