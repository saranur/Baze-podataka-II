--Vje�ba 7 :: Zadaci

--1.	a) Upotrebom podupita iz tabele Customers baze Northwind 
--dati prikaz svih polja tabele pri �emu je kupac iz Berlina.
--b) Upotrebom podupita iz tabele Customers baze Northwind dati prikaz svih polja tabele pri �emu je kupac iz Londona ili Berlina.
--A
USE Northwind
SELECT*
FROM Customers AS C
WHERE C.City LIKE (SELECT C.City
				FROM Customers AS C
				WHERE C.City='Berlin')
--B
SELECT*
FROM Customers AS C
WHERE C.City IN (SELECT C.City
				FROM Customers AS C
				WHERE C.City='Berlin' OR C.City='London')
--2.	
USE AdventureWorks2017

SELECT AVG(PP.OrderQty) 'Srednja vrijednost naru�ene koli�ine'
FROM Purchasing.PurchaseOrderDetail AS PP
WHERE PP.UnitPrice BETWEEN 50 AND 100

SELECT AVG(PodQ.OrderQty) 'Srednja vrijednost naru�ene koli�ine'
FROM (SELECT PP.OrderQty
	  FROM Purchasing.PurchaseOrderDetail AS PP
	  WHERE PP.UnitPrice BETWEEN 50 AND 100) AS PodQ

--3.Prikazati ID narud�be(i) u kojima je naru�ena koli�ina jednaka minimalnoj, odnosno, maksimalnoj vrijednosti svih naru�enih koli�ina. (Northwind)	
USE Northwind

SELECT MIN(OD.Quantity) 'MIN', MAX(OD.Quantity)'MAX'
FROM [Order Details] AS OD
--MIN 1
--MAX 130
--NA�IN 1
SELECT DISTINCT OD.OrderID, OD.Quantity
FROM [Order Details] AS OD 
WHERE OD.Quantity=(SELECT MIN(OD.Quantity) 
					FROM [Order Details] AS OD) OR OD.Quantity=(SELECT MAX(OD.Quantity) 
																FROM [Order Details] AS OD)
--NA�IN 2
SELECT OD.OrderID, OD.Quantity
FROM [Order Details] AS OD 
WHERE OD.Quantity=(SELECT MIN(OD.Quantity) 
					FROM [Order Details] AS OD)
UNION
SELECT OD.OrderID, OD.Quantity
FROM [Order Details] AS OD 
WHERE OD.Quantity=(SELECT MAX(OD.Quantity) 
					FROM [Order Details] AS OD)

--4.	Prikazati  ID narud�be i ID kupca koji je kupio vi�e od 10 komada proizvoda �iji je ID 15. (Northwind)
SELECT O.OrderID,O.CustomerID
FROM Orders as O
WHERE (  SELECT Quantity 
		FROM [Order Details] AS OD        
		WHERE O.OrderID=OD.OrderID AND OD.ProductID=15)>10

USE Northwind
SELECT O.OrderID,O.CustomerID, OD.Quantity
FROM Orders AS O
INNER JOIN [Order Details] AS OD
ON O.OrderID=OD.OrderID
WHERE  OD.ProductID=15 AND OD.Quantity>10

--5.	Prikazati sve osobe koje nemaju prihode, vanredni i redovni. (Prihodi) 
USE prihodi
SELECT O.OsobaID, o.Ime
FROM Osoba AS O
WHERE NOT EXISTS  (SELECT VP.OsobaID
				   FROM VanredniPrihodi AS VP
					WHERE VP.OsobaID=O.OsobaID) AND NOT EXISTS (SELECT RP.OsobaID
																FROM RedovniPrihodi AS RP
																WHERE RP.OsobaID=O.OsobaID)

SELECT O.OsobaID
FROM Osoba AS O
LEFT JOIN VanredniPrihodi AS VP
ON VP.OsobaID=O.OsobaID
WHERE VP.OsobaID IS NULL
INTERSECT
SELECT O.OsobaID
FROM Osoba AS O
LEFT JOIN RedovniPrihodi AS RP
ON RP.OsobaID=O.OsobaID
WHERE RP.OsobaID IS NULL

--6.	Dati prikaz ID narud�be, ID proizvoda i jedini�ne cijene, te razliku cijene u odnosu na srednju vrijednost cijene za sve stavke. Rezultat sortirati prema vrijednosti razlike u rastu�em redoslijedu.  (Northwind)
SELECT OD.OrderID,OD.ProductID,OD.UnitPrice, (SELECT AVG(OD.UnitPrice)
												FROM [Order Details] AS OD) 'Srednja vrijednost', OD.UnitPrice-(SELECT AVG(OD.UnitPrice)
												FROM [Order Details] AS OD) 'Razlika'
FROM [Order Details] AS OD
ORDER BY 5 

--7.	Za sve proizvode kojih ima na stanju dati prikaz ID proizvoda, naziv proizvoda i stanje zaliha, te razliku stanja zaliha proizvoda u odnosu na srednju vrijednost stanja za sve proizvode u tabeli. Rezultat sortirati prema vrijednosti razlike u opadaju�em redoslijedu. (Northwind)
SELECT P.ProductID,P.ProductName,P.UnitsInStock, P.UnitsInStock -(SELECT AVG(P.UnitsInStock)
																	FROM Products AS P)
FROM Products AS P
WHERE P.UnitsInStock>0

--8.	Prikazati po 5 najstarijih zaposlenika mu�kog, odnosno, �enskog spola uz navo�enje sljede�ih podataka: radno mjesto na kojem se nalazi, datum ro�enja, korisnicko ime i godine starosti. Korisni�ko ime je dio podatka u LoginID. Rezultate sortirati prema polu rastu�im, a zatim prema godinama starosti opadaju�im redoslijedom. (AdventureWorks2017)
USE AdventureWorks2017
SELECT F.JobTitle,F.BirthDate,F.Gender,F.[Korisnicko ime],F.[Godine starosti]
FROM(SELECT TOP 5 E.JobTitle,E.BirthDate,E.Gender,SUBSTRING(LoginID, CHARINDEX('\',LoginID) + 1, 
			LEN(LoginID) - CHARINDEX('\',LoginID) - 1)'Korisnicko ime',DATEDIFF(YEAR,E.BirthDate,GETDATE()) 'Godine starosti'
FROM HumanResources.Employee AS E
WHERE E.Gender='F'
ORDER BY 5 DESC
) AS F
UNION
SELECT M.JobTitle,M.BirthDate,M.Gender,M.[Korisnicko ime],M.[Godine starosti]
FROM(SELECT TOP 5 E.JobTitle,E.BirthDate,E.Gender,SUBSTRING(LoginID, CHARINDEX('\',LoginID) + 1, 
			LEN(LoginID) - CHARINDEX('\',LoginID) - 1)'Korisnicko ime',DATEDIFF(YEAR,E.BirthDate,GETDATE()) 'Godine starosti'
FROM HumanResources.Employee AS E
WHERE E.Gender='M'
ORDER BY 5 DESC
) AS M
ORDER BY F.Gender,[Godine starosti] DESC

--9.	Prikazati po 3 zaposlenika koji obavljaju poslove managera uz navo�enje sljede�ih podataka: radno mjesto na kojem se nalazi, datum zaposlenja, bra�ni status i sta�. Ako osoba nije u braku pla�a dodatni porez (upitom naglasiti to), ina�e ne pla�a. Rezultate sortirati prema bra�nom statusu rastu�im, a zatim prema sta�u opadaju�im redoslijedom. (AdventureWorks2017)
SELECT TOP 3 E.JobTitle,E.HireDate,E.MaritalStatus,DATEDIFF(YEAR, E.HireDate,GETDATE()) 'Godine staza', 'Placa dodatni porez' Porez
FROM HumanResources.Employee AS E
WHERE E.JobTitle LIKE '%manager%' AND E.MaritalStatus ='S'
UNION
SELECT TOP 3 E.JobTitle,E.HireDate,E.MaritalStatus,DATEDIFF(YEAR, E.HireDate,GETDATE()) 'Godine staza', ' ' Porez
FROM HumanResources.Employee AS E
WHERE E.JobTitle LIKE '%manager%' AND E.MaritalStatus ='M'
ORDER BY 3, [Godine staza] DESC


--10.	Prikazati po 5 osoba koje se nalaze na 1, odnosno, 4.  organizacionom nivou, uposlenici su i �ele primati email ponude od AdventureWorksa uz navo�enje sljede�ih polja: ime i prezime osobe kao jedinstveno polje, organizacijski nivo na kojem se nalazi i da li prima email promocije. Pored ovih uvesti i polje koje �e sadr�avati poruke: Ne prima (0), Prima selektirane (1) i Prima (2). Sadr�aj novog polja ovisi o vrijednosti polja EmailPromotion. Rezultat sortirati prema organizacijskom nivou i dodatno uvedenom polju. (AdventureWorks2017)
SELECT TOP 5 PP.FirstName +' ' +PP.LastName 'Ime i prezime', E.OrganizationLevel,PP.EmailPromotion, 'Ne prima' Prima
FROM HumanResources.Employee AS E
INNER JOIN Person.Person AS PP
ON E.BusinessEntityID=PP.BusinessEntityID
WHERE (E.OrganizationLevel=1 OR E.OrganizationLevel=4) AND PP.EmailPromotion=0
UNION 
SELECT TOP 5 PP.FirstName +' ' +PP.LastName 'Ime i prezime', E.OrganizationLevel,PP.EmailPromotion, 'Prima selektirane' Prima
FROM HumanResources.Employee AS E
INNER JOIN Person.Person AS PP
ON E.BusinessEntityID=PP.BusinessEntityID
WHERE (E.OrganizationLevel=1 OR E.OrganizationLevel=4) AND PP.EmailPromotion=1
UNION 
SELECT TOP 5 PP.FirstName +' ' +PP.LastName 'Ime i prezime', E.OrganizationLevel,PP.EmailPromotion, 'Prima email promocije' Prima
FROM HumanResources.Employee AS E
INNER JOIN Person.Person AS PP
ON E.BusinessEntityID=PP.BusinessEntityID
WHERE (E.OrganizationLevel=1 OR E.OrganizationLevel=4) AND PP.EmailPromotion=2
ORDER BY 2 ,4 

--11.	Prikazati broj narud�be, datum narud�be i datum isporuke za narud�be koje su isporu�ene u Kanadu u 7. mjesecu 2014. godine. Uzeti u obzir samo narud�be koje nisu pla�ene kreditnom karticom. Datume formatirati u sljede�em obliku: dd.mm.yyyy. (AdventureWorks2017)
SELECT SOH.SalesOrderID, FORMAT(SOH.OrderDate,'dd.MM.yyyy') 'Order date', SOH.ShipDate
FROM Sales.SalesOrderHeader AS SOH
INNER JOIN Sales.SalesOrderDetail AS SOD
ON SOH.SalesOrderID=SOD.SalesOrderID
INNER JOIN Sales.SalesTerritory AS ST
ON ST.TerritoryID=SOH.TerritoryID
WHERE ST.Name LIKE 'Canada' AND YEAR(SOH.ShipDate)=2014 AND MONTH(SOH.ShipDate)=7 AND SOH.CreditCardID IS NULL

--12.	Kreirati upit koji prikazuje minimalnu, maksimalnu, prosje�nu te ukupnu zaradu po mjesecima u 2013. godini. (AdventureWorks2017)
SELECT MONTH(SOH.OrderDate) 'Mjesec',AVG(SOD.LineTotal) 'Prosjek', MIN(SOD.LineTotal) 'Minimalna', MAX(SOD.LineTotal) 'Maksimalna'
FROM Sales.SalesOrderDetail AS SOD
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE YEAR(SOH.OrderDate)=2013
GROUP BY MONTH(SOH.OrderDate)
ORDER BY 1

SELECT MONTH(SOH.OrderDate) 'Mjesec',AVG(SOD.UnitPrice*SOD.OrderQty) 'Prosjek', MIN(SOD.UnitPrice*SOD.OrderQty) 'Minimalna', MAX(SOD.UnitPrice*SOD.OrderQty) 'Maksimalna'
FROM Sales.SalesOrderDetail AS SOD
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE YEAR(SOH.OrderDate)=2013
GROUP BY MONTH(SOH.OrderDate)
ORDER BY 1

--13.	Kreirati upit koji prikazuje ime i prezime, korisni�ko ime (sve iza znaka �\� u koloni LoginID), du�inu korisni�kog imena, titulu, datum zaposlenja (dd.mm.yyyy), starost i sta� zaposlenika. Uslov je da se prika�e 10 najstarijih zaposlenika koji obavljaju bilo koju ulogu menad�era. (AdventureWorks2017)
SELECT TOP 10 PP.FirstName+ ' '+PP.LastName 'Ime i prezime', RIGHT(E.LoginID, CHARINDEX('\',REVERSE(E.LoginID))-1) 'Korisni�ko ime', LEN(RIGHT(E.LoginID, CHARINDEX('\',REVERSE(E.LoginID))-1)) 'Du�ina korisni�kog imena', E.JobTitle, FORMAT(E.HireDate,'dd.MM.yyyy') 'Datum zaposlenja', DATEDIFF(YEAR,E.BirthDate,GETDATE()) 'Starost', DATEDIFF(YEAR, E.HireDate,GETDATE()) 'Sta�'
FROM Person.Person AS PP
INNER JOIN HumanResources.Employee AS E
ON E.BusinessEntityID=PP.BusinessEntityID
WHERE E.JobTitle LIKE '%Manager%'
ORDER BY Starost DESC

--14.	Kreirati upit koji prikazuje 10 najskupljih stavki prodaje (detalji narud�be) i to sljede�e kolone: naziv proizvoda, koli�ina, cijena, iznos. Cijenu i iznos zaokru�iti na dvije decimale. Tako�er, koli�inu prikazati u formatu �10 kom.�, a cijenu i iznos u formatu �1000 KM�. (AdventureWorks2017)
SELECT PP.Name,SOD.OrderQty,CAST(SOD.UnitPrice AS VARCHAR) +' kom' 'Kolicina',CAST(SUM(SOD.UnitPrice*SOD.OrderQty) AS VARCHAR) +' KM' 'Iznos'
FROM Sales.SalesOrderDetail AS SOD
INNER JOIN Production.Product AS PP
ON SOD.ProductID=PP.ProductID
GROUP BY PP.Name,SOD.OrderQty,SOD.UnitPrice
ORDER BY 4 DESC

--15.	Kreirati upit koji prikazuje naziv modela i opis modela proizvoda. Uslov je da naziv modela sadr�i rije� �Mountain�, dok je opis potrebno prikazati samo na engleskom jeziku. (AdventureWorks2017)
SELECT PM.Name,PD.Description
FROM Production.ProductModel AS PM
INNER JOIN Production.ProductModelProductDescriptionCulture AS PMPDC
ON PM.ProductModelID=PMPDC.ProductModelID
INNER JOIN Production.ProductDescription AS PD
ON PD.ProductDescriptionID=PMPDC.ProductDescriptionID
INNER JOIN Production.Culture AS C
ON C.CultureID=PMPDC.CultureID
WHERE C.Name LIKE 'English' AND PM.Name LIKE '%Mountain%'

--16.	Kreirati upit koji prikazuje broj, naziv i cijenu proizvoda, te stanje zaliha po lokacijama. Uzeti u obzir samo proizvode koji pripadaju kategoriji �Bikes�. Izlaz sortirati po stanju zaliha u opadaju�em redoslijedu. (AdventureWorks2017)
SELECT PP.ProductNumber,PP.Name,PP.ListPrice,PL.Name,SUM(PI.Quantity) 'Stanje zaliha'
FROM Production.Product AS PP
INNER JOIN Production.ProductInventory AS PI
ON PP.ProductID=PI.ProductID
INNER JOIN Production.Location AS PL
ON PI.LocationID=PL.LocationID
GROUP BY PP.ProductNumber,PP.Name,PP.ListPrice,PL.Name
ORDER BY 5 DESC

--17.	Kreirati upit koji prikazuje ukupno ostvarenu zaradu po zaposleniku, za robu isporu�enu na podru�je Evrope, u januaru mjesecu 2014. godine. Lista treba da sadr�i ime i prezime zaposlenika, datum zaposlenja (dd.mm.yyyy), mail adresu, te ukupnu ostvarenu zaradu zaokru�enu na dvije decimale. Izlaz sortirati po zaradi u opadaju�em redoslijedu. (AdventureWorks2017)   
SELECT PP.FirstName + ' '+ PP.LastName 'Ime i prezime zaposlenika', FORMAT(E.HireDate,'dd.MM.yyyy') 'Datum zaposlenja',E.HireDate,EA.EmailAddress,SUM(SOD.UnitPrice*SOD.OrderQty)'Ukupna zarada'
FROM HumanResources.Employee AS E
INNER JOIN Person.Person AS PP
ON E.BusinessEntityID=PP.BusinessEntityID
INNER JOIN Person.EmailAddress AS EA
ON PP.BusinessEntityID=EA.BusinessEntityID
INNER JOIN Sales.SalesPerson AS SP
ON E.BusinessEntityID=SP.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader AS SOH
ON SOH.SalesPersonID=SP.BusinessEntityID
INNER JOIN Sales.SalesOrderDetail AS SOD
ON SOD.SalesOrderID=SOH.SalesOrderID
INNER JOIN Sales.SalesTerritory AS ST
ON SOH.TerritoryID=ST.TerritoryID
WHERE ST.[Group]='Europe' AND YEAR(SOH.OrderDate)=2014 AND MONTH(SOH.OrderDate)=1
GROUP BY PP.FirstName + ' '+ PP.LastName,FORMAT(E.HireDate,'dd.MM.yyyy'),E.HireDate,EA.EmailAddress
ORDER BY [Ukupna zarada] DESC
