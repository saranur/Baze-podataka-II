USE Northwind
SELECT P.SupplierID, P.UnitPrice, P.UnitsInStock
FROM Products AS P

SELECT P.SupplierID, P.UnitPrice*P.UnitsInStock 'Ukupna vrijednost'
FROM Products AS P

SELECT P.SupplierID, P.UnitPrice*P.UnitsInStock 'Ukupna vrijednost'
FROM Products AS P

SELECT P.SupplierID, SUM(P.UnitPrice*P.UnitsInStock) 'Ukupna vrijednost'
FROM Products AS P
WHERE P.SupplierID NOT IN(1,2)
GROUP BY P.SupplierID
HAVING SUM(P.UnitPrice*p.UnitsInStock)>2000
ORDER BY 2 DESC
--1.	Prikazati količinski najmanju i najveću vrijednost stavke narudžbe. (Northwind)
SELECT MIN(OD.Quantity) 'Najmanja', MAX(OD.Quantity) 'Najveca'
FROM [Order Details] AS OD
--2.	Prikazati količinski najmanju i najveću vrijednost stavke narudžbe za svaku od narudžbi pojedinačno. (Northwind)
SELECT OD.OrderID, MIN(OD.Quantity) 'Najmanja', MAX(OD.Quantity) 'Najveca'
FROM [Order Details] AS OD
GROUP BY OD.OrderID

--3.	Prikazati ukupnu zaradu od svih narudžbi. (Northwind)
SELECT SUM(OD.Quantity*OD.UnitPrice) 'Ukupna zarada'
FROM [Order Details] AS OD

--4.	Prikazati ukupnu vrijednost za svaku narudžbu pojedinačno uzimajući u obzir i popust. 
--Rezultate zaokružiti na dvije decimale i sortirati prema ukupnoj vrijednosti naružbe u opadajućem redoslijedu. (Northwind)
SELECT OD.OrderID, ROUND(SUM(OD.Quantity*OD.UnitPrice*1-OD.Discount),2) 'Zarada sa popustom'
FROM [Order Details] AS OD
GROUP BY OD.OrderID
ORDER BY 2 DESC

--5.	Prebrojati stavke narudžbe gdje su naručene količine veće od 50 (uključujući i graničnu vrijednost). 
--Uzeti u obzir samo one stavke narudžbe gdje je odobren popust. (Northwind)
SELECT COUNT(OD.Quantity)
FROM [Order Details] AS OD
WHERE OD.Quantity>=50 AND OD.Discount>0

--6.	Prikazati prosječnu cijenu stavki narudžbe za svaku narudžbu pojedinačno. 
--Sortirati po prosječnoj cijeni u opadajućem redoslijedu. (Northwind)
SELECT OD.OrderID, AVG(UnitPrice) 'Prosjecna cijena'
FROM [Order Details] AS OD
GROUP BY OD.OrderID
ORDER BY 2 DESC  

--7.	Prikazati broj narudžbi sa odobrenim popustom. (Northwind)
SELECT COUNT(*) 'Ukupan broj narudzbi sa odobrenim popustom'
FROM [Order Details] AS OD 
WHERE Discount>0

--8.	Prikazati broj narudžbi u kojima je unesena regija kupovine. (Northwind)
SELECT COUNT(*) 
FROM Orders AS O
WHERE O.ShipRegion IS NOT NULL

--DRUGI NACIN
SELECT COUNT(O.ShipRegion)  -- u ovom slucaju on ne gleda kada su zapisi null
FROM Orders AS O

--9.	Modificirati prethodni upit tako da se dobije broj narudžbi u kojima nije unesena regija kupovine. (Northwind)

SELECT COUNT(*)
FROM Orders AS O
WHERE O.ShipRegion IS NULL
--drugi nacin
SELECT COUNT(*)-COUNT(O.ShipRegion)
FROM Orders AS O

--10.	Prikazati ukupne troškove prevoza po uposlenicima.
--Uslov je da ukupni troškovi prevoza nisu prešli 7500 pri čemu se rezultat treba sortirati
--opadajućim redoslijedom po visini troškova prevoza. (Northwind)

SELECT O.EmployeeID, SUM(O.Freight) 'Ukupni trosak prevoza po uposelnicima'
FROM Northwind.dbo.Orders AS O
GROUP BY O.EmployeeID
HAVING SUM(O.Freight)<7500 
ORDER BY 2 DESC

--11.	Prikazati ukupnu vrijednost troškova prevoza po državama ali samo ukoliko je veća od 4000
--za robu koja se kupila u Francuskoj, Njemačkoj ili Švicarskoj. (Northwind)

SELECT O.ShipCountry, SUM(O.Freight) 'Ukupni trosak prevoza po drzavama'
FROM ORDERS AS O
WHERE  O.ShipCountry IN ('Germany','France','Switzerland')
GROUP BY O.ShipCountry
HAVING SUM(O.Freight)>4000 
--12.	Prikazati ukupan broj modela proizvoda. Lista treba da sadrži ID modela proizvoda i njihov ukupan broj. 
--Uslov je da proizvod pripada nekom modelu i da je ukupan broj proizvoda po modelu veći od 3. U listu uključiti 
--(prebrojati) samo one proizvode čiji naziv počinje slovom 'S'. (AdventureWorks2017)

USE AdventureWorks2019
SELECT P.ProductModelID,COUNT(*) AS 'Ukupan broj'
FROM Production.Product AS P
WHERE P.ProductModelID IS NOT NULL AND P.Name LIKE 'S%'
GROUP BY P.ProductModelID
HAVING COUNT(*)>3