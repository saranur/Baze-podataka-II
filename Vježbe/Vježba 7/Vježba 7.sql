--Vježba 7 :: Zadaci

--1.	a) Upotrebom podupita iz tabele Customers baze Northwind dati prikaz svih polja tabele pri čemu 
--je kupac iz Berlina. 
SELECT*
FROM Northwind.dbo.Customers AS C
WHERE C.City=(SELECT C.City 
			  FROM Northwind.dbo.Customers AS C
			  WHERE C.City LIKE 'Berlin')
--b) Upotrebom podupita iz tabele Customers baze Northwind dati prikaz svih polja tabele pri čemu je 
--kupac iz Londona ili Berlina. 
SELECT*
FROM Northwind.dbo.Customers AS C
WHERE C.City IN (SELECT C.City 
			   FROM Northwind.dbo.Customers AS C
			   WHERE C.City LIKE 'Berlin' OR C.City LIKE 'London')
--2.	Prikazati srednju vrijednost nabavljene količine, u obzir uzeti samo one zapise u kojima 
--je vrijednost UnitPrice između 50 i 100 (uključujući granične vrijednosti). (AdventureWorks2017)
SELECT AVG(POD.OrderQty) AS 'Srednja vrijednost'
FROM AdventureWorks2019.Purchasing.PurchaseOrderDetail AS POD
WHERE POD.UnitPrice BETWEEN 50 AND 100


--3.	Prikazati ID narudžbe(i) u kojima je naručena količina jednaka minimalnoj, 
--odnosno, maksimalnoj vrijednosti svih naručenih količina. (Northwind)
SELECT OD.OrderID
FROM Northwind.dbo.[Order Details] AS OD
WHERE OD.Quantity=(SELECT MIN(OD.Quantity) 
				   FROM Northwind.dbo.[Order Details] AS OD) OR OD.Quantity=(SELECT MAX(OD.Quantity)
																			 FROM Northwind.dbo.[Order Details] AS OD)
--4.	Prikazati  ID narudžbe i ID kupca koji je kupio više od 10 komada proizvoda čiji je ID 15.
--(Northwind)
SELECT O.OrderID, O.CustomerID, OD.Quantity
FROM Northwind.dbo.Orders AS O
INNER JOIN Northwind.dbo.[Order Details] AS OD
ON O.OrderID=OD.OrderID
WHERE OD.Quantity>10 AND OD.ProductID=15

--DRUGI NACIN
SELECT O.OrderID, O.CustomerID
FROM Northwind.dbo.Orders AS O
WHERE (SELECT OD.Quantity
	   FROM Northwind.dbo.[Order Details] AS OD
	   WHERE OD.OrderID=O.OrderID AND OD.ProductID=15)>10
	   --Ovo je korelacijski tip podupita 

--5.	Prikazati sve osobe koje nemaju prihode, vanredni i redovni. (Prihodi) 
SELECT*
FROM prihodi.dbo.Osoba AS O
WHERE NOT EXISTS (SELECT RP.OsobaID
				  FROM prihodi.dbo.RedovniPrihodi AS RP
				  WHERE RP.OsobaID=O.OsobaID) AND NOT EXISTS(SELECT VP.OsobaID
															 FROM prihodi.dbo.VanredniPrihodi AS VP
															 WHERE VP.OsobaID=O.OsobaID)

--6.	Dati prikaz ID narudžbe, ID proizvoda i jedinične cijene, te razliku cijene u odnosu 
--na srednju vrijednost cijene za sve stavke. Rezultat sortirati prema vrijednosti razlike u
--rastućem redoslijedu.  (Northwind)
SELECT OD.OrderID, OD.ProductID, OD.UnitPrice, (SELECT AVG(OD.UnitPrice)
												FROM Northwind.dbo.[Order Details] AS OD) AS 'Srednja vrijednost', 
												OD.UnitPrice-(SELECT AVG(OD.UnitPrice)
												FROM Northwind.dbo.[Order Details] AS OD) AS Razlika
FROM Northwind.dbo.[Order Details] AS OD
ORDER BY 5 ASC 

--7.	Za sve proizvode kojih ima na stanju dati prikaz ID proizvoda, naziv proizvoda i stanje zaliha,
--te razliku stanja zaliha proizvoda u odnosu na srednju vrijednost stanja za sve proizvode u tabeli. 
--Rezultat sortirati prema vrijednosti razlike u opadajućem redoslijedu. (Northwind)
SELECT P.ProductID, P.ProductName, P.UnitsInStock, (SELECT AVG(P.UnitsInStock)
												    FROM Northwind.dbo.Products AS P) AS 'Srednja vrijednost zaliha', 
													P.UnitsInStock- (SELECT AVG(P.UnitsInStock)
												    FROM Northwind.dbo.Products AS P) AS Razlika
FROM Northwind.dbo.Products AS P
WHERE P.UnitsInStock>0
ORDER BY 5 DESC
--8.	Prikazati po 5 najstarijih zaposlenika muškog, odnosno, ženskog pola uz navođenje sljedećih
--podataka: radno mjesto na kojem se nalazi, datum rođenja, korisnicko ime i godine starosti.
--Korisničko ime je dio podatka u LoginID. Rezultate sortirati prema polu rastućim, 
--a zatim prema godinama starosti opadajućim redoslijedom. (AdventureWorks2017)
SELECT F.JobTitle, F.BirthDate, F.Gender, F.[Korisnicko ime], F.[Godine starosti]
FROM(SELECT TOP 5 E.JobTitle, E.BirthDate, E.Gender,
SUBSTRING(E.LoginID, CHARINDEX('\', E.LoginID)+1, (LEN(E.LoginID)-CHARINDEX('\', E.LoginID))-1) AS 'Korisnicko ime',
DATEDIFF(YEAR, E.BirthDate, GETDATE()) AS 'Godine starosti'
FROM AdventureWorks2019.HumanResources.Employee AS E
WHERE E.Gender='F'
ORDER BY 5 DESC) AS F
UNION
SELECT M.JobTitle, M.BirthDate, M.Gender,  M.[Korisnicko ime], M.[Godine starosti]
FROM(SELECT TOP 5 E.JobTitle, E.BirthDate, E.Gender,
SUBSTRING(E.LoginID, CHARINDEX('\', E.LoginID)+1, (LEN(E.LoginID)-CHARINDEX('\', E.LoginID))-1) AS 'Korisnicko ime',
DATEDIFF(YEAR, E.BirthDate, GETDATE()) AS 'Godine starosti'
FROM AdventureWorks2019.HumanResources.Employee AS E
WHERE E.Gender='M'
ORDER BY 5 DESC) AS M
ORDER BY F.Gender, [Godine starosti] DESC
--s obzirom na to da kada koristimo UNION mozemo imati samo jedan order BY, a mi trebamo da sortiramo i imamo ORDER BY
--i za muskarce i za zene, stavimo sve u podupit 

--Kada nam jedan upit postaje izvor podataka drugom podupitu, moramo mu dati neki alias

--9.	Prikazati po 3 zaposlenika koji obavljaju poslove managera uz navođenje sljedećih podataka: 
--radno mjesto na kojem se nalazi, datum zaposlenja, bračni status i staž. 
--Ako osoba nije u braku plaća dodatni porez (upitom naglasiti to), inače ne plaća.
--Rezultate sortirati prema bračnom statusu rastućim, a zatim prema stažu opadajućim redoslijedom.(AdventureWorks2017)
SELECT TOP 3 E.JobTitle, E.HireDate, E.MaritalStatus, DATEDIFF(YEAR, E.HireDate, GETDATE()) AS 'Staz', 'Placa dodatni porez' Porez
FROM AdventureWorks2019.HumanResources.Employee AS E
WHERE E.JobTitle LIKE '%manager%' AND E.MaritalStatus='S'
UNION 
SELECT TOP 3 E.JobTitle, E.HireDate, E.MaritalStatus, DATEDIFF(YEAR, E.HireDate, GETDATE()) AS 'Staz', '' Porez
FROM AdventureWorks2019.HumanResources.Employee AS E
WHERE E.JobTitle LIKE '%manager%' AND E.MaritalStatus='M'
ORDER BY 3, 4 DESC

--10.	Prikazati po 5 osoba koje se nalaze na 1, odnosno, 4.  organizacionom nivou, 
--uposlenici su i žele primati email ponude od AdventureWorksa uz navođenje sljedećih polja:
--ime i prezime osobe kao jedinstveno polje, organizacijski nivo na kojem se nalazi i da 
--li prima email promocije. Pored ovih uvesti i polje koje će sadržavati poruke: 
--Ne prima (0), Prima selektirane (1) i Prima (2). 
--Sadržaj novog polja ovisi o vrijednosti polja EmailPromotion. 
--Rezultat sortirati prema organizacijskom nivou i dodatno uvedenom polju. (AdventureWorks2017)

SELECT TOP 5 CONCAT(PP.FirstName,' ', PP.MiddleName, ' ', PP.LastName) AS 'Ime i prezime', E.OrganizationLevel, PP.EmailPromotion, 'Ne prima' 'Email promocije'
FROM AdventureWorks2019.Person.Person AS PP
INNER JOIN AdventureWorks2019.HumanResources.Employee AS E
ON PP.BusinessEntityID=E.BusinessEntityID
WHERE(E.OrganizationLevel=1 OR E.OrganizationLevel=4) AND PP.EmailPromotion=0
UNION
SELECT TOP 5 CONCAT(PP.FirstName,' ', PP.MiddleName, ' ', PP.LastName) AS 'Ime i prezime', E.OrganizationLevel, PP.EmailPromotion, 'Prima selektirane' 'Email promocije'
FROM AdventureWorks2019.Person.Person AS PP
INNER JOIN AdventureWorks2019.HumanResources.Employee AS E
ON PP.BusinessEntityID=E.BusinessEntityID
WHERE(E.OrganizationLevel=1 OR E.OrganizationLevel=4) AND PP.EmailPromotion=1
UNION
SELECT TOP 5 CONCAT(PP.FirstName,' ', PP.MiddleName, ' ', PP.LastName) AS 'Ime i prezime', E.OrganizationLevel,PP.EmailPromotion,  'Prima' 'Email promocije'
FROM AdventureWorks2019.Person.Person AS PP
INNER JOIN AdventureWorks2019.HumanResources.Employee AS E
ON PP.BusinessEntityID=E.BusinessEntityID
WHERE(E.OrganizationLevel=1 OR E.OrganizationLevel=4) AND PP.EmailPromotion=2
ORDER BY 2,4
--11.	Prikazati broj narudžbe, datum narudžbe i datum isporuke za narudžbe koje su isporučene u
--Kanadu u 7. mjesecu 2014. godine. Uzeti u obzir samo narudžbe koje nisu plaćene kreditnom karticom. 
--Datume formatirati u sljedećem obliku: dd.mm.yyyy. (AdventureWorks2017)
SELECT SOH.SalesOrderID, FORMAT(SOH.OrderDate, 'dd.mm.yyyy') 'Datum narudzbe', FORMAT(SOH.ShipDate, 'dd.mm.yyyy') 'Datum isporuke'
FROM AdventureWorks2019.Sales.SalesOrderHeader AS SOH
INNER JOIN AdventureWorks2019.Sales.SalesTerritory AS SST
ON SOH.TerritoryID=SST.TerritoryID
WHERE SOH.CreditCardID IS NULL AND YEAR(SOH.ShipDate)=2014 AND MONTH(SOH.ShipDate)=7 AND SST.CountryRegionCode='CA'
--12.	Kreirati upit koji prikazuje minimalnu, maksimalnu, prosječnu te ukupnu zaradu po mjesecima
--u 2013. godini. (AdventureWorks2017)
SELECT MONTH(SOH.OrderDate)'Mjesec', MIN(SOD.LineTotal) 'Minimalna zarada', MAX(SOD.LineTotal) 'Maksimalna zarada',
AVG(SOD.LineTotal) 'Prosjecna zarada'
FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE YEAR(SOH.OrderDate)=2013
GROUP BY MONTH(SOH.OrderDate) 
ORDER BY 1

--13.	Kreirati upit koji prikazuje ime i prezime, korisničko ime (sve iza znaka „\“ u koloni
--LoginID), dužinu korisničkog imena, titulu, datum zaposlenja (dd.mm.yyyy), starost i staž zaposlenika.
--Uslov je da se prikaže 10 najstarijih zaposlenika koji obavljaju bilo koju ulogu menadžera.
--(AdventureWorks2017)
SELECT TOP 10 CONCAT(PP.FirstName,' ', PP.MiddleName,' ', PP.LastName) 'Ime i prezime', 
SUBSTRING(E.LoginID, CHARINDEX('\', E.LoginID)+1, LEN(E.LoginID)-CHARINDEX('\', E.LoginID)) 'Korisnicko ime', 
LEN(SUBSTRING(E.LoginID, CHARINDEX('\', E.LoginID)+1, LEN(E.LoginID)-CHARINDEX('\', E.LoginID))) 'Duzina korisnickog imena', 
E.JobTitle, FORMAT(E.HireDate, 'dd.mm.yyyy') 'Datum zaposlenja', DATEDIFF(YEAR, E.BirthDate, GETDATE())	Startost, 
DATEDIFF(YEAR, E.HireDate, GETDATE()) Staz
FROM AdventureWorks2019.HumanResources.Employee AS E
INNER JOIN AdventureWorks2019.Person.Person AS PP
ON E.BusinessEntityID=PP.BusinessEntityID
WHERE E.JobTitle LIKE '%manager%'
ORDER BY 5 DESC


--14.	Kreirati upit koji prikazuje 10 najskupljih stavki prodaje (detalji narudžbe) i to
--sljedeće kolone: naziv proizvoda, količina, cijena, iznos. Cijenu i iznos zaokružiti na dvije decimale.
--Također, količinu prikazati u formatu „10 kom.“, a cijenu i iznos u formatu „1000 KM“.(AdventureWorks2017)

SELECT TOP 10 PP.Name AS 'Naziv proizvoda', CAST(SOD.OrderQty AS NVARCHAR)+' kom' AS Kolicina, CAST(ROUND(SOD.UnitPrice,2)AS NVARCHAR)+' KM' AS Cijena, CAST(ROUND(SOD.UnitPrice*SOD.OrderQty,2)AS NVARCHAR)+' KM' AS Iznos
FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD
INNER JOIN AdventureWorks2019.Production.Product AS PP
ON SOD.ProductID=PP.ProductID
ORDER BY 4 DESC

--15.	Kreirati upit koji prikazuje naziv modela i opis modela proizvoda. 
--Uslov je da naziv modela sadrži riječ „Mountain“, dok je opis potrebno prikazati samo na
--engleskom jeziku. (AdventureWorks2017)
SELECT PPM.Name, PD.Description
FROM AdventureWorks2019.Production.ProductModel AS PPM
INNER JOIN AdventureWorks2019.Production.ProductModelProductDescriptionCulture AS PMPDC
ON PMPDC.ProductModelID=PPM.ProductModelID
INNER JOIN AdventureWorks2019.Production.ProductDescription AS PD
ON PD.ProductDescriptionID=PMPDC.ProductDescriptionID
INNER JOIN AdventureWorks2019.Production.Culture AS C
ON PMPDC.CultureID=C.CultureID
WHERE C.Name LIKE 'English' AND PPM.Name LIKE '%Mountain%'

--16.	Kreirati upit koji prikazuje broj, naziv i cijenu proizvoda, te stanje zaliha po lokacijama. 
--Uzeti u obzir samo proizvode koji pripadaju kategoriji „Bikes“. Izlaz sortirati po stanju zaliha u
--opadajućem redoslijedu. (AdventureWorks2017)
SELECT PP.ProductNumber, PP.Name, PP.ListPrice, PL.Name AS Lokacija,  SUM(PPI.Quantity) AS 'Stanje zaliha'
FROM AdventureWorks2019.Production.Product AS PP
INNER JOIN AdventureWorks2019.Production.ProductSubcategory AS PPS
ON PPS.ProductSubcategoryID=PP.ProductSubcategoryID	
INNER JOIN AdventureWorks2019.Production.ProductCategory AS PC
ON PPS.ProductCategoryID=PC.ProductCategoryID
INNER JOIN AdventureWorks2019.Production.ProductInventory AS PPI
ON PP.ProductID=PPI.ProductID
INNER JOIN AdventureWorks2019.Production.Location AS PL
ON PPI.LocationID=PL.LocationID
WHERE PC.Name LIKE '%bikes%'
GROUP BY PP.ProductNumber, PP.Name, PP.ListPrice, PL.Name
ORDER BY 5 DESC

--17.	Kreirati upit koji prikazuje ukupno ostvarenu zaradu po zaposleniku, na području Evrope,
--u januaru mjesecu 2014. godine. Lista treba da sadrži ime i prezime zaposlenika, datum zaposlenja 
--(dd.mm.yyyy), mail adresu, te ukupnu ostvarenu zaradu zaokruženu na dvije decimale.
--Izlaz sortirati po zaradi u opadajućem redoslijedu. (AdventureWorks2017)  
SELECT CONCAT(PP.FirstName,' ', PP.MiddleName, ' ', PP.LastName) AS 'Ime i prezime',
FORMAT(E.HireDate, 'dd.mm.yyyy') AS 'Datum zaposlenja', PEA.EmailAddress, ROUND(SUM(SOD.UnitPrice*SOD.OrderQty),2) AS Zarada
FROM AdventureWorks2019.HumanResources.Employee AS E
INNER JOIN AdventureWorks2019.Person.Person AS PP
ON E.BusinessEntityID=PP.BusinessEntityID
INNER JOIN AdventureWorks2019.Person.EmailAddress AS PEA
ON PEA.BusinessEntityID=PP.BusinessEntityID
INNER JOIN AdventureWorks2019.Sales.SalesPerson AS SSP
ON E.BusinessEntityID=SSP.BusinessEntityID
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON SSP.BusinessEntityID= SOH.SalesPersonID
INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
ON SOH.SalesOrderID=SOD.SalesOrderID
INNER JOIN AdventureWorks2019.Sales.SalesTerritory AS SST
ON SST.TerritoryID=SOH.TerritoryID
WHERE SST.[Group] LIKE '%Europe%' AND YEAR(SOH.OrderDate)=2014 AND MONTH(SOH.OrderDate)=1
GROUP BY CONCAT(PP.FirstName,' ', PP.MiddleName, ' ', PP.LastName), E.HireDate, PEA.EmailAddress
ORDER BY 4 DESC
