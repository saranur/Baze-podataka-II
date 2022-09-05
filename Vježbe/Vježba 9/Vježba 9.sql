--Vježba 9 :: Zadaci
--1. Prikazati ime i prezime, broj godina staža, opis posla uposlenika te broj knjiga 
--uposlenika koji su učestvovali u objavljivanju više od broja objavljenih naslova 
--izdavača sa id 0736 a koji imaju više od 30 godina staža. Rezultate upita sortirati 
--prema godinama staža rastućim i prema broju naslova u opadajućem
--redoslijedu. (Pubs)
SELECT CONCAT(E.fname,' ', E.lname) AS 'Ime i prezime', DATEDIFF(YEAR, E.hire_date, GETDATE()) AS 'Godine staza', 
J.job_desc AS 'Opis posla', (SELECT COUNT(*)
							 FROM pubs.dbo.titles AS T
							 INNER JOIN pubs.dbo.publishers AS P
							 ON T.pub_id=P.pub_id
							 WHERE E.pub_id=P.pub_id) AS 'Broj naslova'		
FROM pubs.dbo.employee AS E
INNER JOIN pubs.dbo.jobs AS J
ON E.job_id=J.job_id
INNER JOIN pubs.dbo.publishers AS P
ON P.pub_id=E.pub_id
WHERE DATEDIFF(YEAR, E.hire_date, GETDATE())>30 AND (SELECT COUNT(*)
													 FROM pubs.dbo.titles AS T
													 INNER JOIN pubs.dbo.publishers AS P
													 ON T.pub_id=P.pub_id
													 WHERE E.pub_id=P.pub_id)> (SELECT COUNT(*)
																				FROM pubs.dbo.titles AS T
																				WHERE T.pub_id=0736)
ORDER BY 2, 4 DESC															

--2. Napisati upit kojim će se prikazati ime i prezime uposlenika koji rade na poziciji 
--dizajnera, a koji su učestvovali u objavljivanju knjiga čija je prosječna prodata 
--količina veća od prosječne prodane količine izdavačke kuće sa id 0877. U 
--rezultatima upita prikazati i prosječnu prodanu vrijednost. (Pubs)
SELECT CONCAT(E.fname,' ', E.lname) AS 'Ime i prezime', J.job_desc AS 'Pozicija',
	(SELECT AVG(S.qty)
	FROM pubs.dbo.titles AS T
	INNER JOIN pubs.dbo.sales AS S
	ON T.title_id=S.title_id
	WHERE P.pub_id=T.pub_id) AS 'Prosjecna prodana vrijednost'
FROM pubs.dbo.employee AS E
INNER JOIN pubs.dbo.jobs AS J
ON J.job_id=E.job_id
INNER JOIN pubs.dbo.publishers AS P
ON E.pub_id=P.pub_id
WHERE J.job_desc LIKE '%Designer%' AND (SELECT AVG(S.qty)
										FROM pubs.dbo.titles AS T
										INNER JOIN pubs.dbo.sales AS S
										ON T.title_id=S.title_id
										WHERE P.pub_id=T.pub_id)>(SELECT AVG(S.qty)
																  FROM pubs.dbo.sales AS S
																  INNER JOIN pubs.dbo.titles AS T
																  ON S.title_id=T.title_id
																  WHERE T.pub_id=0877)


--3. Kreirati upit koji prikazuje sumaran iznos svih transakcija po godinama, 
--sortirano po godinama (uzeti u obzir i transakcije iz arhivske tabele). U rezultatu 
--upita prikazati samo dvije kolone: kalendarska godina i ukupan iznos 
--transakcija u godini. (AdventureWorks2017)
SELECT T1.[Kalendarska godina], SUM(T1.[Ukupna kolicina]) 'Ukupan iznos transakcija'
FROM (SELECT YEAR(PTH.TransactionDate) AS 'Kalendarska godina', SUM(PTH.ActualCost*PTH.Quantity) AS 'Ukupna kolicina'
FROM AdventureWorks2019.Production.TransactionHistory AS PTH
GROUP BY YEAR(PTH.TransactionDate)
UNION
SELECT YEAR(PTHA.TransactionDate) AS 'Kalendarska godina', SUM(PTHA.ActualCost*PTHA.Quantity) AS 'Ukupna kolicina'
FROM AdventureWorks2019.Production.TransactionHistoryArchive AS PTHA
GROUP BY YEAR(PTHA.TransactionDate)) AS T1
GROUP BY T1.[Kalendarska godina]
--Dodali smo u from dio tako da ako u obje tabele imamo recimo 2013. godinu, on ce ukupne iznose sabrati za obje godine

--4. Za potrebe menadžmenta neophodno je kreirati sljedeće upite: 
--(AdventureWorks2017)

--a)Upit koji prikazuje zaradu po proizvodu u 5. mjesecu 2013. godine (sa 
--i bez popusta) 
SELECT PP.Name AS 'Proizvod', SUM(SOD.OrderQty*SOD.UnitPrice) AS 'Zarada bez popusta', 
SUM(SOD.LineTotal) AS 'Zarada s popustom' --LINE total je calculated polje koje racuna cijenu*kolicinu*discount, a mozemo i sami izracunati
FROM AdventureWorks2019.Production.Product AS PP
INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
ON PP.ProductID=SOD.ProductID
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE MONTH(SOH.OrderDate)=5 AND YEAR(SOH.OrderDate)=2013
GROUP BY PP.Name

--b)Upit koji prikazuje ukupnu zaradu po proizvodu u 2013. godini (sa i 
--bez popusta) 
SELECT PP.Name AS 'Proizvod', SUM(SOD.OrderQty*SOD.UnitPrice) AS 'Zarada bez popusta', 
SUM(SOD.LineTotal) AS 'Zarada s popustom' --LINE total je calculated polje koje racuna cijenu*kolicinu*discount, a mozemo i sami izracunati
FROM AdventureWorks2019.Production.Product AS PP
INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
ON PP.ProductID=SOD.ProductID
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE YEAR(SOH.OrderDate)=2013
GROUP BY PP.Name

--c)Upit koji prikazuje ukupnu zaradu po godinama (sa i bez popusta) 
SELECT YEAR(SOH.OrderDate) AS 'Godina',  SUM(SOD.OrderQty*SOD.UnitPrice) AS 'Zarada bez popusta', 
SUM(SOD.LineTotal) AS 'Zarada s popustom' --LINE total je calculated polje koje racuna cijenu*kolicinu*discount, a mozemo i sami izracunati
FROM AdventureWorks2019.Production.Product AS PP
INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
ON PP.ProductID=SOD.ProductID
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON SOD.SalesOrderID=SOH.SalesOrderID
GROUP BY YEAR(SOH.OrderDate)
ORDER BY 1
--d)Upit koji prikazuje zaradu po godinama i podkategorijama, ali samo 
--proizvoda koji pripadaju kategoriji „Bikes“ (Mountain Bikes, Road 
--Bikes, Touring Bikes). Rezultat upita prikazati kao na narednoj slici: 
--c)Upit koji prikazuje ukupnu zaradu po godinama (sa i bez popusta) 
SELECT YEAR(SOH.OrderDate) AS 'Godina',
	(SELECT CAST(SUM(SOD.LineTotal)AS DECIMAL(18,2))
	FROM AdventureWorks2019.Sales.SalesOrderHeader AS SOH1
	INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
	ON SOH1.SalesOrderID=SOD.SalesOrderID
	INNER JOIN AdventureWorks2019.Production.Product AS PP
	ON PP.ProductID=SOD.ProductID
	INNER JOIN AdventureWorks2019.Production.ProductSubcategory AS PPS
	ON PP.ProductSubcategoryID=PPS.ProductSubcategoryID
	WHERE PPS.Name LIKE 'Mountain Bikes' AND YEAR(SOH1.OrderDate)=YEAR(SOH.OrderDate)) AS 'Ukuno: Mountain Bikes',
		(SELECT CAST(SUM(SOD.LineTotal)AS DECIMAL(18,2))
		FROM AdventureWorks2019.Sales.SalesOrderHeader AS SOH1
		INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
		ON SOH1.SalesOrderID=SOD.SalesOrderID
		INNER JOIN AdventureWorks2019.Production.Product AS PP
		ON PP.ProductID=SOD.ProductID
		INNER JOIN AdventureWorks2019.Production.ProductSubcategory AS PPS
		ON PP.ProductSubcategoryID=PPS.ProductSubcategoryID
		WHERE PPS.Name LIKE 'Road Bikes' AND YEAR(SOH1.OrderDate)=YEAR(SOH.OrderDate)) AS 'Ukuno: Road Bikes', 
			(SELECT CAST(SUM(SOD.LineTotal)AS DECIMAL(18,2))
			 FROM AdventureWorks2019.Sales.SalesOrderHeader AS SOH1
			 INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
			 ON SOH1.SalesOrderID=SOD.SalesOrderID
			 INNER JOIN AdventureWorks2019.Production.Product AS PP
			 ON PP.ProductID=SOD.ProductID
			 INNER JOIN AdventureWorks2019.Production.ProductSubcategory AS PPS
			 ON PP.ProductSubcategoryID=PPS.ProductSubcategoryID
			 WHERE PPS.Name LIKE 'Touring Bikes' AND YEAR(SOH1.OrderDate)=YEAR(SOH.OrderDate)) AS 'Ukuno: Touring Bikes'
FROM AdventureWorks2019.Sales.SalesOrderHeader AS SOH
GROUP BY YEAR(SOH.OrderDate)
ORDER BY 1


--5. Kreirati upit koji prikazuje četvrtu najveću platu u preduzeću (po visini 
--primanja), u rezultatima upita prikazati i ime i prezime zaposlenika. Tabela 
--EmployeePayHistory. (AdventureWorks2017)
SELECT TOP 1 T1.[Ime i prezime], T1.Plata
FROM (SELECT TOP 4 CONCAT(PP.FirstName,' ', PP.LastName) AS 'Ime i prezime', EPH.Rate 'Plata'
FROM AdventureWorks2019.HumanResources.EmployeePayHistory AS EPH
INNER JOIN AdventureWorks2019.HumanResources.Employee AS E
ON EPH.BusinessEntityID=E.BusinessEntityID
INNER JOIN AdventureWorks2019.Person.Person AS PP
ON PP.BusinessEntityID=E.BusinessEntityID
ORDER BY 2 DESC) AS T1
ORDER BY T1.Plata ASC

--Drugi nacin 
SELECT T1.[Ime i prezime], T1.Plata
FROM (SELECT TOP 4 CONCAT(PP.FirstName,' ', PP.LastName) AS 'Ime i prezime', EPH.Rate 'Plata', ROW_NUMBER() OVER(ORDER BY EPH.Rate DESC) 'Redoslijed'
FROM AdventureWorks2019.HumanResources.EmployeePayHistory AS EPH
INNER JOIN AdventureWorks2019.HumanResources.Employee AS E
ON EPH.BusinessEntityID=E.BusinessEntityID
INNER JOIN AdventureWorks2019.Person.Person AS PP
ON PP.BusinessEntityID=E.BusinessEntityID) AS T1
WHERE T1.Redoslijed=4


--6. Kreirati upit koji prikazuje ukupnu količinu utrošenog novca po kupcu. Izlaz 
--treba da sadrži sljedeće kolone: ime i prezime kupca, tip kreditne kartice, broj 
--kartice i ukupno utrošeno. Pri tome voditi računa da izlaz sadrži: 
--(AdventureWorks2017)

--a) Samo troškove koje su kupci napravili koristeći kredite kartice,    
SELECT CONCAT(PP.FirstName,' ', PP.LastName) AS 'Ime i prezime kupca', CC.CardType AS 'Tip kreditne kartice', 
CC.CardNumber AS 'Broj kartice', SUM(SOH.TotalDue) AS 'Ukupno utroseno'
FROM AdventureWorks2019.Sales.Customer AS SC
INNER JOIN AdventureWorks2019.Person.Person AS PP
ON PP.BusinessEntityID=SC.PersonID
INNER JOIN AdventureWorks2019.Sales.PersonCreditCard AS PCC
ON PP.BusinessEntityID=PCC.BusinessEntityID
INNER JOIN AdventureWorks2019.Sales.CreditCard AS CC
ON PCC.CreditCardID=CC.CreditCardID
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON CC.CreditCardID=SOH.CreditCardID
WHERE SOH.CreditCardID IS NOT NULL
GROUP BY CONCAT(PP.FirstName,' ', PP.LastName), CC.CardType ,CC.CardNumber 


--b) Samo one kupce koji imaju više od jedne kartice, 
SELECT CONCAT(PP.FirstName,' ', PP.LastName) AS 'Ime i prezime kupca', CC.CardType AS 'Tip kreditne kartice', 
CC.CardNumber AS 'Broj kartice', SUM(SOH.TotalDue) AS 'Ukupno utroseno'
FROM AdventureWorks2019.Sales.Customer AS SC
INNER JOIN AdventureWorks2019.Person.Person AS PP
ON PP.BusinessEntityID=SC.PersonID
INNER JOIN AdventureWorks2019.Sales.PersonCreditCard AS PCC
ON PP.BusinessEntityID=PCC.BusinessEntityID
INNER JOIN AdventureWorks2019.Sales.CreditCard AS CC
ON PCC.CreditCardID=CC.CreditCardID
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON CC.CreditCardID=SOH.CreditCardID
WHERE (SELECT COUNT(*)
	   FROM AdventureWorks2019.Sales.PersonCreditCard AS PCC
	   WHERE PCC.BusinessEntityID=PP.BusinessEntityID)>1
GROUP BY CONCAT(PP.FirstName,' ', PP.LastName), CC.CardType ,CC.CardNumber 


--c) Prikazati i one kartice sa kojima kupac nije obavljao narudžbe, 
--d) Ukoliko vrijedost kolone utrošeno bude nepoznata, zamijeniti je brojem 0 (nula),
--Izlaz treba biti sortiran po prezimenu kupca abecedno i količini 
--utrošenog novca opadajućim redoslijedom. 
SELECT CONCAT(PP.FirstName,' ', PP.LastName) AS 'Ime i prezime kupca', CC.CardType AS 'Tip kreditne kartice', 
CC.CardNumber AS 'Broj kartice', ISNULL(SUM(SOH.TotalDue),0) AS 'Ukupno utroseno'
FROM AdventureWorks2019.Sales.Customer AS SC
INNER JOIN AdventureWorks2019.Person.Person AS PP
ON PP.BusinessEntityID=SC.PersonID
INNER JOIN AdventureWorks2019.Sales.PersonCreditCard AS PCC
ON PP.BusinessEntityID=PCC.BusinessEntityID
INNER JOIN AdventureWorks2019.Sales.CreditCard AS CC
ON PCC.CreditCardID=CC.CreditCardID
LEFT OUTER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
ON CC.CreditCardID=SOH.CreditCardID
WHERE (SELECT COUNT(*)
	   FROM AdventureWorks2019.Sales.PersonCreditCard AS PCC
	   WHERE PCC.BusinessEntityID=PP.BusinessEntityID)>1
GROUP BY CONCAT(PP.FirstName,' ', PP.LastName), CC.CardType ,CC.CardNumber 
ORDER BY 2, 4 DESC


--7. Naći proizvode čijom je prodajom ostvaren najmanji i najveći ukupni promet 
--(uzimajući u obzir i popust), a zatim odrediti razliku između najmanjeg prometa 
--po proizvodu i prosječnog prometa prodaje proizvoda, te najvećeg prometa po 
--proizvodu i prosječnog prometa prodaje proizvoda. Rezultate prikazati 
--zaokružene na dvije decimale. Upit treba sadržavati nazive proizvoda sa 
--njihovim ukupnim prometom te izračunate razlike. Rezultate upita prikazati na 
--2 načina kao na slikama. (AdventureWorks2017)
SELECT P1.Proizvod, P1.[Najmanji promet],P2.Proizvod, P2.[Najveci promet],
P1.[Najmanji promet]-PAvg.Prosjek AS 'Razlika min avg', P2.[Najveci promet]-PAvg.Prosjek AS 'Razlika max avg'

FROM (SELECT TOP 1 PP.Name AS 'Proizvod', CAST(SUM(SOD.LineTotal) AS DECIMAL(18,2)) AS 'Najmanji promet'
FROM AdventureWorks2019.Production.Product AS PP
INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
ON PP.ProductID=SOD.ProductID
GROUP BY PP.Name
ORDER BY 2 ) AS P1,
(SELECT TOP 1 PP.Name AS 'Proizvod', CAST(SUM(SOD.LineTotal) AS DECIMAL(18,2)) AS 'Najveci promet'
FROM AdventureWorks2019.Production.Product AS PP
INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
ON PP.ProductID=SOD.ProductID
GROUP BY PP.Name
ORDER BY 2 DESC) AS P2,
(SELECT CAST(AVG(SOD.LineTotal) AS DECIMAL(18,2)) AS 'Prosjek'
FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD) AS PAvg
--Kartezijev proizvod

--Drugi nacin
SELECT*
FROM(SELECT TOP 1 PP.Name AS 'Proizvod', CAST(SUM(SOD.LineTotal) AS DECIMAL(18,2)) AS 'Min-max promet po proizvodu', 
CAST(SUM(SOD.LineTotal) AS DECIMAL(18,2))- (SELECT CAST(AVG(SOD.LineTotal) AS DECIMAL(18,2)) 'Prosjek'
											FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD) AS 'Razlike'
FROM AdventureWorks2019.Production.Product AS PP
INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
ON PP.ProductID=SOD.ProductID
GROUP BY PP.Name
ORDER BY 2 ) AS P1

UNION

SELECT*
FROM (SELECT TOP 1 PP.Name AS 'Proizvod', CAST(SUM(SOD.LineTotal) AS DECIMAL(18,2)) AS 'Min-max promet po proizvodu', 
CAST(SUM(SOD.LineTotal) AS DECIMAL(18,2))- (SELECT CAST(AVG(SOD.LineTotal) AS DECIMAL(18,2)) 'Prosjek'
											FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD) AS 'Razlike'
FROM AdventureWorks2019.Production.Product AS PP
INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
ON PP.ProductID=SOD.ProductID
GROUP BY PP.Name
ORDER BY 2 DESC) AS P2