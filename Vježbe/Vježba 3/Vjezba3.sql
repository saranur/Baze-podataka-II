--1.    Koristeći bazu Northwind izdvojiti godinu, mjesec i dan datuma isporuke narudžbe. 
SELECT YEAR(O.ShippedDate) AS Godina, MONTH(O.ShippedDate) AS Mjesec, DAY(O.ShippedDate) AS Dan
FROM Northwind.DBO.Orders AS O
--2.    Koristeći bazu Northwind izračunati koliko je vremena prošlo od datum narudžbe do danas. 
USE Northwind
SELECT DATEDIFF(YEAR, O.OrderDate,GETDATE()) AS 'Broj godina'
FROM Orders AS O
--3.    Koristeći bazu Northwind dohvatiti sve zapise u kojima ime zaposlenika počinje slovom A. 
SELECT*
FROM Employees AS E
WHERE E.FirstName LIKE 'A%'
--4.	Koristeći bazu Pubs dohvatiti sve zapise u kojima ime zaposlenika počinje slovom A ili M.
SELECT* 
FROM pubs.dbo.employee AS E
WHERE E.fname  LIKE '[A,M]%'
--5.	Koristeći bazu Northwind prikazati sve kupce koje u koloni ContactTitle sadrže pojam "manager".
SELECT*
FROM Customers AS C
WHERE C.ContactTitle LIKE '%manager%'
--6.	Koristeći bazu Northwind dohvatiti sve kupce kod kojih se poštanski broj sastoji samo od cifara. 
SELECT*
FROM Customers AS C
WHERE C.PostalCode LIKE '[O-9]%' AND C.PostalCode NOT LIKE '%-%'
--DRUGI NACIN
SELECT* 
FROM Customers AS C
WHERE C.PostalCode NOT LIKE '%[^0-9]%'
--TRECI NACIN
SELECT*
FROM Customers AS C
WHERE ISNUMERIC(C.PostalCode)=1  --ZNAK NEJEDNAKOSTI JE <>
--7.	Iz tabele Person.Person baze AdventureWorks2017 u bazu Vjezba2 u tabelu Osoba kopirati kolone FirstName, MiddleNamei LastName.
--Prikazati spojeno ime, srednje ime i prezime.Uslov je da se između pojedinih segmenata nalazi space. 
--Omogućiti prikaz podataka i ako neki od podataka nije unijet. Prikazati samo jedinstvene zapise (bez ponavljanja istih zapisa).

USE Vjezba2 
SELECT PP.FirstName,PP.MiddleName, PP.LastName
INTO Osoba
FROM AdventureWorks2019.Person.Person AS PP

SELECT O.FirstName +' '+ ISNULL(O.MiddleName, '') +' '+ O.LastName --samo jedna kolona i sve ce biti spojeno, ali ako ijedno polje ima null vrijednost, zato provjeravamo sa ISNUL na middle name
FROM Osoba AS O

UPDATE Osoba
SET MiddleName=' '
WHERE MiddleName IS NULL

SELECT DISTINCT O.FirstName +' '+ O.MiddleName +' '+ O.LastName --samo jedna kolona i sve ce biti spojeno, ali ako ijedno polje ima null vrijednost, zato provjeravamo sa ISNUL na middle name
FROM Osoba AS O 
--distinct nece vratiti duplikate, vec ce vratiti samo unikate 

SELECT DISTINCT CONCAT(PP.FirstName,' ',PP.MiddleName,' ',PP.LastName)
FROM AdventureWorks2019.Person.Person AS PP

--Northwind
--8.	Prikazati listu zaposlenika sa sljedećim atributima: ID, ime, prezime, država i titula, gdje je ID = 9 ili dolaze iz USA. 
SELECT E.EmployeeID, E.FirstName, E.LastName, E.Country, E.Title
FROM Northwind.dbo.Employees AS E
WHERE E.EmployeeID=9 OR E.Country='USA'
--9.	 Prikazati podatke o narudžbama koje su napravljene prije 19.07.1996. godine. Izlaz treba da sadrži sljedeće kolone: 
--ID narudžbe, datum narudžbe, ID kupca, te grad. 
USE Northwind
SELECT O.OrderID, O.OrderDate, O.CustomerID, O.ShipCity
FROM Orders AS O
WHERE O.OrderDate<'1996-07-19'
--10.	Prikazati stavke narudžbe gdje je količina narudžbe bila veća od 100 komada uz odobreni popust.
USE Northwind
SELECT*
FROM [Order Details] AS OD
WHERE OD.Quantity>100 AND OD.Discount>0
--11.	 Prikazati ime kompanije kupca i kontakt telefon i to samo onih koji u svome imenu posjeduju riječ „Restaurant“. 
--Ukoliko naziv kompanije sadrži karakter (-), kupce izbaciti iz rezultata upita. 
SELECT C.CompanyName, C.Phone
FROM Customers AS C
WHERE C.CompanyName LIKE '%Restaurant%' AND C.CompanyName NOT LIKE '%-%'
--12.	 Prikazati proizvode čiji naziv počinje slovima „C“ ili „G“, drugo slovo može biti bilo koje, a treće slovo u nazivu je „A“ ili „O“. 
SELECT*
FROM Products AS P
WHERE P.ProductName LIKE  '[CG]_[AO]%'
--13.	Prikazati listu proizvoda čiji naziv počinje slovima „L“ ili „T“, ili je ID proizvoda = 46. 
--Lista treba da sadrži samo one proizvode čija se cijena po komadu kreće između 10 i 50. Upit napisati na dva načina. 
SELECT*
FROM Products AS P
WHERE (P.ProductName LIKE '[LT]%' OR P.ProductID=46) AND P.UnitPrice BETWEEN 10 AND 50
--Drugi nacin
SELECT*
FROM Products AS P
WHERE (P.ProductName LIKE '[LT]%' OR P.ProductID=46) AND P.UnitPrice>=10 and P.UnitPrice<=50
--14.	Prikazati naziv proizvoda i cijenu gdje je stanje na zalihama manje od naručene količine. 
--Također, u rezultate upita uključiti razliku između naručene količine i stanja zaliha. 
SELECT P.ProductName, P.UnitPrice, (P.UnitsInStock-P.UnitsOnOrder) AS Razlika --kada je jedna rijec kod as ne moramo korisiti ' ' ali kada imamo vise rijeci moramo koristiti navodnike
FROM Products AS P
WHERE P.UnitsInStock<P.UnitsOnOrder
--15.	Prikazati dobavljače koji dolaze iz Španije ili Njemačke a nemaju unesen broj faxa. Formatirati izlaz NULL vrijednosti. 
--Upit napisati na dva načina
SELECT S.SupplierID, S.CompanyName, S.ContactName, S.ContactTitle, S.Address, S.City, S.Region, S.PostalCode, S.Country, ISNULL(S.Fax,'nepoznata vrijednost'), S.HomePage
FROM Suppliers AS S
WHERE (S.Country='Spain' OR S.Country='Germany') AND S.Fax IS NULL
--Drugi nacin
SELECT S.SupplierID, S.CompanyName, S.ContactName, S.ContactTitle, S.Address, S.City, S.Region, S.PostalCode, S.Country, ISNULL(S.Fax,'nepoznata vrijednost'), S.HomePage
FROM Suppliers AS S
WHERE S.Country IN ('Spain', 'Germany') AND S.Fax IS NULL --IN je kao or, provjerice da li Spanija ili Njemacka

--Pubs
--16.	Prikazati listu autora sa sljedećim kolonama: ID, ime i prezime (spojeno), grad i to samo one autore čiji ID počinje brojem 8 
--ili dolaze iz grada „Salt Lake City“. Također autorima status ugovora treba biti 1. Koristiti aliase nad kolonama.
USE pubs
SELECT A.au_id, A.au_fname+' '+A.au_lname AS 'Ime i Prezime', A.city, A.contract
FROM authors AS A
WHERE (A.au_id LIKE '8%' OR A.city LIKE 'Salt Lake City') AND A.contract=1
--17.	Prikazati sve tipove knjiga bez duplikata. Listu sortirati po tipu. 
SELECT DISTINCT T.type
FROM titles AS T
ORDER BY 1 -- ko ne navedeno descending ici ce abecedbno 

--18.	Prikazati listu prodaje knjiga sa sljedećim kolonama: ID prodavnice, broj narudžbe i količinu, ali samo gdje je količina između 10 i 50,
--uključujući i granične vrijednosti. Rezultat upita sortirati po količini opadajućim redoslijedom. Upit napisati na dva načina.
SELECT S.stor_id, S.ord_num, S.qty
FROM sales AS S
WHERE S.qty BETWEEN 10 AND 50 
ORDER BY 3 DESC  --3 jer je qty na trecem mjestu u selectu 
--19.	Prikazati listu knjiga sa sljedećim kolonama: naslov, tip djela i cijenu. Kao novu kolonu dodati 20% od prikazane cijene 
--(npr. Ako je cijena 19.99 u novoj koloni treba da piše 3,998). Naziv kolone se treba zvati „20% od cijene“. 
--Listu sortirati abecedno po tipu djela i po cijeni opadajućim redoslijedom. Sa liste eliminisati one vrijednosti koje u polju cijena imaju nepoznatu vrijednost.
--Modifikovati upit tako da prikaže cijenu umanjenu za 20 %. Naziv kolone treba da se zove „Cijena umanjena za 20%“.
USE pubs
SELECT T.title, T.type, T.price-T.price*0.2 AS 'Cijena umanjena za 20%' , T.price*0.2 AS '20% od cijene'
FROM titles AS T
WHERE T.price IS NOT NULL
ORDER BY 3 DESC 

--20.	Prikazati 10 količinski najvećih stavki prodaje. Lista treba da sadrži broj narudžbe, datum narudžbe i količinu.
--Provjeriti da li ima više stavki sa količinom kao posljednja u listi
SELECT TOP 10 S.ord_num, S.ord_date, S.qty
FROM sales AS S
ORDER BY 3 DESC 