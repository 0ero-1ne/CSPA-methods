USE EARTH;
GO

-- 6.  Определите тип пространственных данных во всех таблицах
-- Эти данные описывают местоположение объектов в пространстве и могут быть использованы для моделирования и анализа географических и пространственных явлений.
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo';
--
-- 7.  Определите SRID - идентификатор системы координат
-- Примеры SRID включают SRID 4326, который обозначает систему координат WGS 84 (широта/долгота), который используется для веб-карт в проекции Web Mercator.
SELECT srid FROM dbo.geometry_columns;


-- 8.  Определите атрибутивные столбцы
-- содержат информацию об атрибутах (характеристиках) географических объектов
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo' AND DATA_TYPE != 'geometry';

-- 9.  Верните описания пространственных объектов в формате WKT
--  текстовый формат для представления геометрических объектов в пространстве
SELECT geom.STAsText() AS WKT_Description
FROM rivers;


-- 10.1.  Нахождение пересечения пространственных объектов;
-- Определение области, общей для двух или более пространственных объектов.
SELECT obj1.geom.STIntersection(obj2.geom) AS Intersection
FROM rivers obj1, rivers obj2
WHERE obj1.qgs_fid = 3 AND obj2.qgs_fid = 3;

SELECT obj1.geom.STIntersection(obj2.geom) AS Intersection
FROM rivers obj1, rivers obj2
WHERE obj1.qgs_fid = 29 AND obj2.qgs_fid = 29;

SELECT obj1.geom.STIntersection(obj2.geom) AS Intersection
FROM rivers obj1, rivers obj2
WHERE obj1.qgs_fid = 3 AND obj2.qgs_fid = 29;

-- 10.2.  Нахождение объединения пространственных объектов;
SELECT obj1.geom.STUnion(obj2.geom) AS [Union]
FROM rivers obj1, rivers obj2
WHERE obj1.qgs_fid = 13 AND obj2.qgs_fid = 12;

-- 10.3.  Нахождение вложенности пространственных объектов;

SELECT obj1.geom.STWithin(obj2.geom) AS [IsWithin]
FROM rivers obj1, rivers obj2
WHERE obj1.qgs_fid = 17 AND obj2.qgs_fid = 2;


SELECT obj1.qgs_fid, obj2.qgs_fid, obj1.geom.STWithin(obj2.geom) AS [IsWithin]
FROM rivers obj1, rivers obj2
WHERE obj1.qgs_fid != obj2.qgs_fid AND obj1.geom.STWithin(obj2.geom) = 1 ORDER BY obj1.qgs_fid;

-- 10.4.  Упрощение пространственного объекта;
-- Уменьшение сложности геометрии объекта с сохранением его основных характеристик
SELECT geom.Reduce(0.1) AS Simplified --насколько сильно должен быть упрощен геометрический объект
FROM rivers
WHERE qgs_fid = 6;

-- 10.5.  Нахождение координат вершин пространственного объектов
SELECT geom.STPointN(1).ToString() AS Coordinates
FROM rivers
WHERE qgs_fid = 6;

SELECT geom.STAsText() AS geom from rivers where qgs_fid = 6;

-- 10.6.  Нахождение размерности пространственных объектов
-- Выявление размерности геометрического объекта. Например, точка имеет размерность 0, линия - 1, а полигон - 2.
SELECT geom.STDimension() AS ObjectDimension
FROM rivers
WHERE qgs_fid = 3;

-- 10.7.  Нахождение длины и площади пространственных объектов;
-- Длина (Length): Измерение длины линейных объектов, таких как линии или полилинии.
-- Площадь (Area): Измерение площади замкнутых объектов, таких как полигоны.
SELECT geom.STLength() AS ObjectLength, geom.STArea() AS ObjectArea
FROM rivers
WHERE qgs_fid = 5;


-- 10.8.  Нахождение расстояния между пространственными объектами;

SELECT obj1.geom.STDistance(obj2.geom) AS Distance
FROM rivers obj1, rivers obj2
WHERE obj1.qgs_fid = 6 AND obj2.qgs_fid = 4


-- 11.  Создайте пространственный объект в виде точки (1) /линии (2) /полигона (3).
-- точка
DECLARE @pointGeometry GEOMETRY;
SET @pointGeometry = GEOMETRY::STGeomFromText('POINT(25 25)', 4326);

SELECT @pointGeometry AS PointGeometry;

-- линия
DECLARE @lineGeometry GEOMETRY;
SET @lineGeometry = GEOMETRY::STGeomFromText('LINESTRING(20 5, 5 20, 25 25)', 4326);

SELECT @lineGeometry AS LineGeometry;


-- полигон
DECLARE @polygonGeometry GEOMETRY;
SET @polygonGeometry = GEOMETRY::STGeomFromText('POLYGON((15 10, 55 55, 9 20, 12 2, 15 10))', 4326);

SELECT @polygonGeometry AS PolygonGeometry;


-- 12.  Найдите, в какие пространственные объекты попадают созданные вами объекты

-- точка и полигон

DECLARE @point GEOMETRY = GEOMETRY::STGeomFromText('POINT(25 25)', 0);
DECLARE @polygon GEOMETRY = GEOMETRY::STGeomFromText('POLYGON((20 20, 20 40, 40 40, 40 20, 20 20))', 0);

SELECT @polygon AS PolygonGeometry;
SELECT @point.STWithin(@polygon) AS PointWithinPolygon;

-- прямая и полигон
DECLARE @line GEOMETRY = GEOMETRY::STGeomFromText('LINESTRING(20 5, 5 20, 25 25)', 0);
DECLARE @polygonn GEOMETRY = GEOMETRY::STGeomFromText('POLYGON((20 20, 20 40, 40 40, 40 20, 20 20))', 0);

SELECT @line.STIntersects(@polygonn) AS LineIntersectsPolygon;

USE UNIVERSITY;
GO

SELECT * FROM MARK;


DECLARE @page int = 2, @per int = 10;
SELECT *
FROM (
	SELECT 
		ROW_NUMBER() OVER (ORDER BY MARK_ID) AS ROW_NUM,
		MARK.*
	FROM 
		MARK
) AS PARTITION_MARKS
WHERE ROW_NUM BETWEEN @page * @per + 1 AND @page * @per + @per;