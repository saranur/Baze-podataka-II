--Vježba 8 :: Zadaci :: AdventureWorks2017
--1. Kreirati upit koji prikazuje kreditne kartice kojima je plaćeno više od 20 
--narudžbi. U listu uključiti ime i prezime vlasnika kartice, tip kartice, broj 
--kartice, ukupan iznos plaćen karticom. Rezultate sortirati prema ukupnom 
--iznosu u opadajućem redoslijedu zaokružene na dvije decimale.
USE AdventureWorks2019


SELECT PP.FirstName+' '+PP.LastName AS 'Ime i prezime', SCC.CardType AS 'Tip kartice', SCC.CardNumber AS 'Broj kartice', ROUND(SUM(SOH.TotalDue),2) 'Ukupan iznos'
FROM AdventureWorks2019.Person.Person AS PP
INNER JOIN AdventureWorks2019.Sales.PersonCreditCard AS PCC
ON PP.BusinessEntityID=PCC.BusinessEntityID
INNER JOIN AdventureWorks2019.Sales.CreditCard AS SCC
ON PCC.CreditCardID=SCC.CreditCardID
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON SCC.CreditCardID=SOH.CreditCardID
GROUP BY PP.FirstName, PP.LastName, SCC.CardType, SCC.CardNumber
HAVING COUNT(*)>20
ORDER BY 4 DESC


--2. Prikazati ime i prezime te vrijednost narudžbe (bez popusta) kupaca koji su 
--napravili narudžbu veću od prosječne vrijednosti svih narudžbi proizvoda sa idom 779.

SELECT PP.FirstName+' '+PP.LastName AS 'Ime i prezime' ,  (SELECT SUM(SOD.UnitPrice*SOD.OrderQty)
														   FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD
														   INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
														   ON SOD.SalesOrderID=SOH.SalesOrderID
														   WHERE SOH.CustomerID=SC.CustomerID) AS 'Vrijednost narudzbi'
FROM AdventureWorks2019.Person.Person AS PP
INNER JOIN AdventureWorks2019.Sales.Customer AS SC
ON PP.BusinessEntityID=SC.PersonID
WHERE (SELECT SUM(SOD.UnitPrice*SOD.OrderQty)
	   FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD
	   INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
	   ON SOD.SalesOrderID=SOH.SalesOrderID
	   WHERE SOH.CustomerID=SC.CustomerID)> (SELECT AVG(SOD.UnitPrice*SOD.OrderQty)
											  FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD
											  WHERE SOD.ProductID=779)
											 

--korelacijski podupit


SELECT* 
FROM AdventureWorks2019.Person.Person

SELECT* 
FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD

--3. Kreirati upit koji prikazuje kupce koji su u maju mjesecu 2014. godine naručili 
--proizvod „Front Brakes“ u količini većoj od 5 komada.
SELECT P.FirstName+' '+P.LastName AS 'Ime i prezime', PP.Name AS 'Ime prozivoda',  SOD.OrderQty AS 'Narucena kolicina',
CONVERT(NVARCHAR,SOH.OrderDate,104) 'Datum narudzbe'
FROM AdventureWorks2019.Person.Person AS P
INNER JOIN AdventureWorks2019.Sales.Customer AS SC
ON P.BusinessEntityID=SC.PersonID
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON SC.CustomerID=SOH.CustomerID
INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
ON SOH.SalesOrderID=SOD.SalesOrderID
INNER JOIN AdventureWorks2019.Production.Product AS PP
ON PP.ProductID=SOD.ProductID
WHERE YEAR(SOH.OrderDate)=2014 AND MONTH(SOH.OrderDate)=05 AND PP.Name LIKE '%Front Brakes%' AND SOD.OrderQty>5


--4. Kreirati upit koji prikazuje kupce koji su u 7. mjesecu utrošili više od 200.000 
--KM. U listu uključiti ime i prezime kupca te ukupni utrošak. Izlaz sortirati 
--prema utrošku opadajućim redoslijedom. 
SELECT CONCAT(P.FirstName,' ', P.LastName) AS 'Ime i prezime', SUM(SOH.TotalDue) AS 'Ukupni trosak'
FROM AdventureWorks2019.Person.Person AS P
INNER JOIN AdventureWorks2019.Sales.Customer AS SC
ON P.BusinessEntityID=SC.PersonID
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON SOH.CustomerID=SC.CustomerID
WHERE MONTH(SOH.OrderDate)=07
GROUP BY P.FirstName, P.LastName
HAVING SUM(SOH.TotalDue)>200000
ORDER BY 2 DESC


--5. Kreirati upit koji prikazuje zaposlenike koji su uradili više od 200 narudžbi. U 
--listu uključiti ime i prezime zaposlenika te ukupan broj urađenih narudžbi. Izlaz 
--sortirati prema broju narudžbi opadajućim redoslijedom 
SELECT CONCAT(PP.FirstName,' ', PP.LastName) AS 'Ime i prezime', COUNT(*) AS 'Ukupan broj narudzbi'
FROM AdventureWorks2019.Person.Person AS PP
INNER JOIN AdventureWorks2019.Sales.SalesPerson AS SSP
ON PP.BusinessEntityID=SSP.BusinessEntityID
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON SOH.SalesPersonID = SSP.BusinessEntityID
GROUP BY PP.FirstName, PP.LastName
HAVING COUNT(*)>200
ORDER BY 2 DESC


--6. Kreirati upit koji prikazuje proizvode kojih na skladištu ima u količini manjoj 
--od 30 komada. Lista treba da sadrži naziv proizvoda, naziv skladišta (lokaciju), 
--stanje na skladištu i ukupnu prodanu količinu. U rezultate upita uključiti i one 
--proizvode koji nikad nisu prodavani. Ukoliko je ukupna prodana količina 
--prikazana kao NULL vrijednost, izlaz formatirati brojem 0. 
SELECT PP.Name 'Ime prozivoda', PL.Name 'Lokacija', PPI.Quantity 'Kolicina na skladistu', 
ISNULL((SELECT SUM(SOD.OrderQty)
	   FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD 
	   WHERE SOD.ProductID=PP.ProductID
	   ),0) AS 'Ukupna prodana kolicina'
FROM AdventureWorks2019.Production.Product AS PP
INNER JOIN AdventureWorks2019.Production.ProductInventory AS PPI
ON PP.ProductID=PPI.ProductID
INNER JOIN AdventureWorks2019.Production.Location AS PL 
ON PPI.LocationID=PL.LocationID
WHERE PPI.Quantity<30 OR PP.ProductID NOT IN(SELECT	DISTINCT SOD.ProductID	
											 FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD)
ORDER BY [Ukupna prodana kolicina] DESC 



--7. Prikazati ukupnu količinu prodaje i ukupnu zaradu (uključujući popust) od 
--prodaje svakog pojedinog proizvoda po teritoriji. Uzeti u obzir samo prodaju u 
--sklopu ponude pod nazivom “Volume Discount 11 to 14” i to samo gdje je 
--količina prodaje veća od 100 komada. Zaradu zaokružiti na dvije decimale, te 
--izlaz sortirati po zaradi u opadajućem redoslijedu.
SELECT PP.Name AS 'Ime proizvoda', SUM(SOD.OrderQty) AS 'Ukupna kolicina prodaje',
ROUND(SUM(SOD.UnitPrice*SOD.OrderQty*(1-SOD.UnitPriceDiscount)),2) AS 'Ukupna zarada s popustom', 
SST.Name AS 'Teritorija'
FROM AdventureWorks2019.Production.Product AS PP
INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
ON PP.ProductID=SOD.ProductID
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON SOH.SalesOrderID=SOD.SalesOrderID
INNER JOIN AdventureWorks2019.Sales.SalesTerritory AS SST
ON SOH.TerritoryID=SST.TerritoryID
INNER JOIN AdventureWorks2019.Sales.SpecialOffer AS SSO
ON SSO.SpecialOfferID=SOD.SpecialOfferID
WHERE SSO.Description LIKE 'Volume Discount 11 to 14'
GROUP BY PP.Name, SST.Name 
HAVING SUM(SOD.OrderQty)>100
ORDER BY 3 DESC


--8. Kreirati upit koji prikazuje naziv proizvoda, naziv lokacije, stanje zaliha na 
--lokaciji, ukupno stanje zaliha na svim lokacijama i ukupnu prodanu količinu. 
--Uzeti u obzir prodaju samo u 2013. godini. 
SELECT PP.Name AS 'Ime prozivoda', PL.Name AS 'Lokacija', PPI.Quantity AS 'Stanje zaliha',
(SELECT SUM(PPI.Quantity)
FROM AdventureWorks2019.Production.ProductInventory AS PPI
WHERE PPI.ProductID=PP.ProductID) 'Stanje zaliha na lokaciji',
(SELECT SUM(SOD.OrderQty)
FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE PP.ProductID=SOD.ProductID AND YEAR(SOH.OrderDate)=2013) 'Ukupna prodana kolicina'
FROM AdventureWorks2019.Production.Product AS PP
INNER JOIN AdventureWorks2019.Production.ProductInventory AS PPI
ON PP.ProductID=PPI.ProductID
INNER JOIN AdventureWorks2019.Production.Location AS PL
ON PPI.LocationID=PL.LocationID
ORDER BY [Ukupna prodana kolicina] DESC


--9. Kreirati upit kojim će se prikazati narudžbe kojima je na osnovu popusta kupac 
--uštedio 100KM i više. Upit treba da sadrži broj narudžbe, naziv kupca i stvarnu 
--ukupnu vrijednost narudžbe zaokruženu na 2 decimale. Podatke je potrebno 
--sortirati rastućim redosljedom od najmanjeg do najvećeg.
SELECT SOH.SalesOrderID AS 'Broj narudzbe', CONCAT(PP.FirstName,' ', PP.LastName) AS 'Ime i prezime',
ROUND(SUM(SOD.LineTotal),2) AS 'Ukupna vrijednost'
FROM AdventureWorks2019.Person.Person AS PP
INNER JOIN AdventureWorks2019.Sales.Customer AS SC
ON PP.BusinessEntityID=SC.PersonID
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON SOH.CustomerID=SC.CustomerID
INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
ON SOD.SalesOrderID=SOH.SalesOrderID
GROUP BY SOH.SalesOrderID, PP.FirstName, PP.LastName
HAVING SUM (SOD.UnitPriceDiscount*SOD.UnitPrice*SOD.OrderQty)>=100
ORDER BY 3 


--10. Kreirati upit kojim se prikazuje da li su muškarci ili žene napravili veći broj 
--narudžbi. Način provjere spola jeste da osobe čije ime završava slovom „a“ 
--predstavljaju ženski spol. U rezultatima upita prikazati spol (samo jedan), 
--ukupan broj narudžbi koje su napravile osobe datog spola i ukupnu potrošenu 
--vrijednost zaokruženu na dvije decimale.
SELECT TOP 1 COUNT(*) AS 'Broj narudzbi', IIF(RIGHT(PP.FirstName,1)='a', 'F', 'M') AS Spol, 
ROUND(SUM(SOH.TotalDue),2) AS 'Ukupna potrosena vrijednost'
FROM AdventureWorks2019.Person.Person AS PP
INNER JOIN AdventureWorks2019.Sales.Customer AS SC
ON PP.BusinessEntityID=SC.PersonID
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON SC.CustomerID=SOH.CustomerID
GROUP BY IIF(RIGHT(PP.FirstName,1)='a', 'F', 'M')
ORDER BY 1 DESC


--11. Kreirati upit koji prikazuje ukupan broj proizvoda, ukupnu količinu proizvoda 
--na lageru, te ukupnu vrijednost proizvoda na lageru (skladištu). Rezultate 
--prikazati grupisane po nazivu dobavljača te uzeti u obzir samo one zapise gdje 
--je sumarna količina na lageru veća od 100 i vrijednost cijene proizvoda veća od 
--od 100 i vrijednost cijene proizvoda veæa od 0.
SELECT PV.Name, COUNT(*) AS 'Ukupan broj proizvoda', SUM(PPI.Quantity) AS 'Ukupan broj proizvoda na lageru',
SUM(PP.ListPrice*PPI.Quantity) AS 'Ukupna vrijednost na lageru'
FROM AdventureWorks2019.Production.Product AS PP
INNER JOIN AdventureWorks2019.Production.ProductInventory AS PPI
ON PP.ProductID=PPI.ProductID
INNER JOIN AdventureWorks2019.Purchasing.ProductVendor AS PPV
ON PP.ProductID= PPV.ProductID
INNER JOIN AdventureWorks2019.Purchasing.Vendor AS PV
ON PV.BusinessEntityID=PPV.BusinessEntityID
WHERE PP.ListPrice>0
GROUP BY PV.Name
HAVING SUM(PPI.Quantity)>100

