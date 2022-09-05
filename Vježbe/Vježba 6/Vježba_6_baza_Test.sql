CREATE DATABASE test
GO 
USE test
GO
CREATE TABLE TableA
(
ID INT,
Name VARCHAR(50),
Gender VARCHAR(50),
Department VARCHAR(50)
)
GO
INSERT INTO TableA VALUES(1, 'Pranaya', 'Male', 'IT')
INSERT INTO TableA VALUES(2, 'Priyanka', 'Female', 'IT')
INSERT INTO TableA VALUES(3, 'Preety', 'Female', 'HR')
INSERT INTO TableA VALUES(4, 'Preety', 'Female', 'HR')
GO 
CREATE TABLE TableB 
(
ID INT,
Name VARCHAR(50), 
Gender VARCHAR(10),
Department VARCHAR(50)
)
GO
INSERT INTO TableB VALUES(2, 'Priyanka', 'Female', 'IT')
INSERT INTO TableB VALUES(3, 'Preety', 'Female', 'HR')
INSERT INTO TableB VALUES(4, 'Anurag', 'Male', 'IT')
GO
SELECT A.ID, A.Name, A.Gender, A.Department
FROM TableA AS A
UNION -- Unija vraca unikatne redove zapisa iz dva querija, duplikate uklanja 
SELECT B.ID, B.Name, B.Gender, B.Department
FROM TableB AS B

SELECT A.ID, A.Name, A.Gender, A.Department
FROM TableA AS A
UNION ALL -- Sa dodatkom ALL vraca sve zapise, uključujući i duplikate 
SELECT B.ID, B.Name, B.Gender, B.Department
FROM TableB AS B

SELECT A.ID, A.Name, A.Gender, A.Department
FROM TableA AS A
INTERSECT -- dohvaća zajedničke jedinstvene redove iz lijevog i desnog upita (TabelaA i TabelaB)
-- INTERSECT eliminiše duplikate dok INNER JOIN vraća i duplikate 
SELECT B.ID, B.Name, B.Gender, B.Department
FROM TableB AS B

SELECT A.ID, A.Name, A.Gender, A.Department
FROM TableA AS A
EXCEPT --vraca unikatan zapis iz lijeve tabele (iz TabelaA)
SELECT B.ID, B.Name, B.Gender, B.Department
FROM TableB AS B