--1. Prikazati tip popusta, naziv prodavnice i njen id. (Pubs)

--2. Prikazati ime uposlenika, njegov id, te naziv posla koji obavlja. (Pubs)
USE pubs
SELECT E.fname, E.emp_id, J.job_desc
FROM employee AS E
INNER JOIN jobs AS J 
ON E.job_id=J.job_id

--3. Prikazati spojeno ime i prezime uposlenika, teritoriju i regiju koju pokriva. 
-- Uslov je da su zaposlenici mlađi od 60 godina. (Northwind)
USE Northwind
SELECT E.FirstName+' ' +E.LastName,T.TerritoryDescription,R.RegionDescription
FROM Employees AS E
INNER JOIN EmployeeTerritories AS ET
ON E.EmployeeID=ET.EmployeeID
INNER JOIN Territories AS T
ON T.TerritoryID=ET.TerritoryID
INNER JOIN Region AS R
ON R.RegionID=T.RegionID
WHERE DATEDIFF(YEAR,E.BirthDate,GETDATE())<60
--4.	Prikazati ime uposlenika i ukupnu vrijednost svih narudžbi koju je taj uposlenik napravio u 1996. godini. 
--U obzir uzeti samo one uposlenike čija je ukupna napravljena vrijednost veća od 20000. 
--Podatke sortirati prema ukupnoj vrijednosti (zaokruženoj na dvije decimale) u rastućem redoslijedu. (Northwind)
SELECT E.FirstName, SUM(OD.Quantity*OD.UnitPrice) 'Ukupna vrijednost'
FROM Employees AS E
INNER JOIN Orders AS O
ON E.EmployeeID=O.EmployeeID
INNER JOIN [Order Details] AS OD
ON OD.OrderID=O.OrderID
WHERE YEAR(O.OrderDate)=1996
GROUP BY E.FirstName
HAVING SUM(OD.Quantity*OD.UnitPrice)>20000
ORDER BY 2

exec sp_changedbowner 'sa'
--5.	Prikazati naziv dobavljača, adresu i državu dobavljača i nazive proizvoda koji pripadaju
--kategoriji pića i ima ih na stanju više od 30 komada. Rezultate upita sortirati po državama. (Northwind)
SELECT S.ContactTitle, S.Address, S.Country, P.ProductName
FROM Suppliers AS S 
INNER JOIN Products AS P
ON S.SupplierID=P.SupplierID
INNER JOIN Categories AS C
ON C.CategoryID=P.CategoryID
WHERE C.Description LIKE '%drinks%' AND P.UnitsInStock>30
ORDER BY 3


--6.	Prikazati kontakt ime kupca, njegov id, broj narudžbe, datum kreiranja narudžbe 
--(prikazan na način npr 24.07.2021) te ukupnu vrijednost narudžbe sa i bez popusta.
--Prikazati samo one narudžbe koje su kreirane u 1997. godini. Izračunate vrijednosti zaokružiti na dvije decimale, 
--te podatke sortirati prema ukupnoj vrijednosti narudžbe sa popustom. (Northwind)
SELECT C.ContactName, C.CustomerID, O.OrderID, O.OrderDate, ROUND(SUM(OD.UnitPrice*OD.Quantity),2) AS bezPopusta, ROUND(SUM(OD.UnitPrice*OD.Discount*(1-OD.Discount)),2) AS saPopustom
FROM Customers AS C 
INNER JOIN Orders AS O
ON C.CustomerID=O.CustomerID
INNER JOIN [Order Details] AS OD
ON OD.OrderID=O.OrderID
WHERE YEAR(O.OrderDate)=1997
ORDER BY 5
--7.	U tabeli Customers baze Northwind ID kupca je primarni ključ. 
--U tabeli Orders baze Northwind ID kupca je vanjski ključ.
--Prikazati:
--a)	Koliko je kupaca evidentirano u obje tabele
--b)	Da li su svi kupci obavili narudžbu 
--c)	Ukoliko postoje neki da nisu prikazati koji su to
-- Da bi mogli korisiti ove operatore UNION, EXCEPT... moramo pratiti neka pravila: 
	--1) Broj i redoslijed kolona moraju biti jednaki u oba querija
	--2) Tipovi podataka moraju da budu kompatibilni 
	--3) Ako hocemo da radimo Order By, njega radimo ispod querija skroz/na dnu
SELECT C.CustomerID
FROM Customers AS C
UNION
SELECT O.CustomerID
FROM Orders AS O

SELECT C.CustomerID
FROM Customers AS C
INTERSECT
SELECT O.CustomerID
FROM Orders AS O

SELECT C.CustomerID
FROM Customers AS C
INNER JOIN Orders AS O
ON O.CustomerID=C.CustomerID
--B
SELECT C.CustomerID
FROM Customers AS C
INTERSECT
SELECT O.CustomerID
FROM Orders AS O
--C
SELECT C.CustomerID
FROM Customers AS C
EXCEPT -- Prikazuje one koje se nalaze u Customers, a ne nalaze se u Orders 
SELECT O.CustomerID
FROM Orders AS O

--Drugi nacin ne koriscenjem EXCEPT
SELECT C.CustomerID
FROM Customers AS C
LEFT OUTER JOIN Orders AS O
ON O.CustomerID=C.CustomerID
WHERE O.OrderID IS NULL

--8.	Dati pregled vanrednih prihoda osobe. Pregled treba da sadrži sljedeće kolone:
--OsobaID, Ime, VanredniPrihodID, IznosPrihoda (Prihodi)
USE Prihodi
SELECT *
FROM Osoba AS O 

--9.	Dati pregled redovnih prihoda svih osoba. Pregled treba da sadrži sljedeæe kolone: OsobaID, Ime, RedovniPrihodID, Neto (Prihodi)
SELECT O.OsobaID,O.Ime,RP.RedovniPrihodiID,RP.Neto
FROM Osoba AS O
LEFT OUTER JOIN RedovniPrihodi AS RP
ON O.OsobaID=RP.OsobaID

--10.	Prikazati ukupnu vrijednost prihoda osobe (i redovne i vanredne). Rezultat sortirati u rastuæem redoslijedu prema ID osobe. (Prihodi)
SELECT O.OsobaID,O.Ime,SUM(ISNULL(RP.Neto,0)+ISNULL(VP.IznosVanrednogPrihoda,0)) 'Ukupan iznos prihoda'
FROM Osoba AS O
LEFT OUTER JOIN RedovniPrihodi AS RP
ON O.OsobaID=RP.OsobaID
LEFT OUTER JOIN VanredniPrihodi AS VP
ON O.OsobaID=VP.OsobaID
GROUP BY O.OsobaID,O.Ime
ORDER BY 1

--11.	Odrediti da li je svaki autor napisao bar po jedan naslov. (Pubs)
--a) ako ima autora koji nisu napisali ni jedan naslov navesti njihov ID.
--b) dati pregled autora koji su napisali bar po jedan naslov.
USE pubs
SELECT A.au_id
FROM authors AS A
INTERSECT 
SELECT TA.au_id
FROM titleauthor AS TA

SELECT*
FROM authors

-- OVIM VIDIMO DA SVI AUTORI NISU NAPISALI PO JEDAN NASLOV
--A
SELECT A.au_id 'Autori bez naslova'
FROM authors AS A
LEFT OUTER JOIN titleauthor AS TA
ON A.au_id=TA.au_id
WHERE TA.title_id IS NULL

--ILI

SELECT A.au_id 
FROM authors AS A
EXCEPT
SELECT TA.au_id 
FROM titleauthor AS TA

--B 
-- DISTINCT UKOLIKO ŽELIMO DA SE JEDAN AUTOR NE PONAVLJA VIŠE PUTA
SELECT DISTINCT A.au_id 'Autori s naslovima'
FROM authors AS A
INNER JOIN titleauthor AS TA
ON A.au_id=TA.au_id

--ILI

SELECT A.au_id
FROM authors AS A
INTERSECT
SELECT TA.au_id
FROM titleauthor AS TA

--12.	Prikazati 10 najskupljih stavki prodaje. Upit treba da sadrži naziv proizvoda, kolièinu, cijenu i vrijednost stavke prodaje. Cijenu i vrijednost stavke prodaje zaokružiti na dvije decimale. Izlaz formatirati na naèin da uz kolièinu stoji 'kom' (npr 50kom) a uz cijenu KM (npr 50KM). (AdventureWorks2017)
USE AdventureWorks2019
SELECT TOP 10 PP.Name,CAST(SOD.OrderQty AS NVARCHAR)+' kom' 'Kolicina',CAST(ROUND(SOD.UnitPrice,2) AS NVARCHAR) +' KM' 'Cijena',ROUND((SOD.OrderQty*SOD.UnitPrice),2) 'Stavka prodaje'
FROM Sales.SalesOrderDetail AS SOD
INNER JOIN Production.Product AS PP
ON SOD.ProductID=PP.ProductID
ORDER BY 4 DESC

--13.	Kreirati upit koji prikazuje ukupan broj kupaca po teritoriji. Lista treba da sadrži sljedeæe kolone: naziv teritorije, ukupan broj kupaca. Uzeti u obzir samo teritorije gdje ima više od 1000 kupaca. (AdventureWorks2017)
SELECT ST.Name, COUNT(*) 'Broj kupaca'
FROM Sales.Customer AS SC
INNER JOIN SALES.SalesTerritory AS ST
ON SC.TerritoryID=ST.TerritoryID
GROUP BY St.Name
HAVING COUNT(*)>1000

--14.	Kreirati upit koji prikazuje zaradu od prodaje proizvoda. Lista treba da sadrži naziv proizvoda, ukupnu zaradu bez uraèunatog popusta i ukupnu zaradu sa uraèunatim popustom. Iznos zarade zaokružiti na dvije decimale. Uslov je da se prikaže zarada samo za stavke gdje je bilo popusta. Listu sortirati po zaradi opadajuæim redoslijedom. (AdventureWorks2017)
SELECT PP.Name,ROUND(SUM(SOD.UnitPrice*SOD.OrderQty),2) 'Ukupna zarada bez popusta', ROUND(SUM(SOD.UnitPrice*SOD.OrderQty*(1-SOD.UnitPriceDiscount)),2) 'Ukupna zarada sa popustom'
FROM Sales.SalesOrderDetail AS SOD
INNER JOIN Production.Product AS PP
ON PP.ProductID=SOD.ProductID
WHERE SOD.UnitPriceDiscount>0
GROUP BY PP.Name
ORDER BY 3 DESC