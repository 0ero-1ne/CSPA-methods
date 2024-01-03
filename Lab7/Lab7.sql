SELECT * FROM MARK;
SELECT * FROM DISCIPLINE;
SELECT * FROM EMPLOYEE;
select * from STUDENT;

INSERT INTO MARK (MARK_ID, STUDENT_ID, EMPLOYEE_ID, DISCIPLINE, MARK, MARK_DATE)
VALUES (16, 4, 1008, N'ПВИ', 5, TO_DATE('25.12.2023', 'DD.MM.YYYY'));

-- 1.	Постройте при помощи конструкции MODEL запросы, которые разрабатывают план:
-- успеваемости для каждого студента на следующий год с учетом успеваемости за предыдущие годы (предложить варианты зависимостей).

SELECT *
FROM MARK
MODEL
    RETURN UPDATED ROWS
    PARTITION BY (MARK_ID)
    DIMENSION BY (STUDENT_ID, MARK_DATE)
    MEASURES (MARK)
RULES
(
    MARK[FOR STUDENT_ID FROM 1 TO 2 INCREMENT 1, MARK_DATE] = ROUND(MARK[CV(), CV()]*1.1),
    MARK[FOR STUDENT_ID FROM 3 TO 4 INCREMENT 1, MARK_DATE] = ROUND(MARK[CV(), CV()]*0.9)
)
ORDER BY MARK_ID DESC;


-- 2.	Найдите при помощи конструкции MATCH_RECOGNIZE() данные, которые соответствуют шаблону
-- Падение, рост, падение успеваемости для каждой группы
SELECT * FROM MARK;

SELECT *
FROM mark
MATCH_RECOGNIZE
(
    PARTITION BY student_id
    ORDER BY mark_date
    MEASURES STRT.mark_date AS start_mark,
             LAST(DOWN.mark_date) AS bottom_mark,
             LAST(UP.mark_date) AS end_mark
    ONE ROW PER MATCH
    AFTER MATCH SKIP TO LAST UP
    PATTERN (STRT DOWN+ UP+ DOWN+)
    DEFINE
        DOWN AS DOWN.mark < PREV(DOWN.mark),
        UP AS UP.mark > PREV(UP.mark)
    ) MR
ORDER BY MR.STUDENT_ID, MR.start_mark;