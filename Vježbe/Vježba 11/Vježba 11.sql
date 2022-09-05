--Vježba 11 :: Zadaci
--1. Kreirati bazu Procedure_ i aktivirati je.
CREATE DATABASE Procedure_ 
GO 
USE Procedure_
--2. Kreirati tabelu Proizvodi te prilikom kreiranja uraditi insert podataka iz tabele 
--Products baze Northwind.
SELECT*
INTO Proizvodi
FROM Northwind.dbo.Products 

--3. Kreirati proceduru sp_Proizvod_Insert kojom će se u tabeli Proizvodi uraditi 
--insert novog zapisa.
SELECT*
FROM Proizvodi


--Prilikom Procedure trebamo pratiti da li je polje NULL i pratiti redoslijed 
GO 
CREATE PROCEDURE sp_Proizvod_Insert --sp je skracenica za stored procedure 
(
@ProductName	 NVARCHAR(40), 
@SupplierID		 INT=NULL,
@CategoryID		 INT=NULL,
@QuantityPerUnit NVARCHAR(20)=NULL,
@UnitPrice		 MONEY=NULL,
@UnitsInStock	 SMALLINT=NULL,
@UnitsOnOrder	 SMALLINT=NULL,
@ReorderLevel	 SMALLINT=NULL,
@Discontinued	 BIT
)
AS 
BEGIN 
INSERT INTO Proizvodi
VALUES(@ProductName,@SupplierID,@CategoryID, @QuantityPerUnit,@UnitPrice, @UnitsInStock, @UnitsOnOrder, @ReorderLevel, @Discontinued)
END 
GO
--4. Kreirati dva testna slučaja, u prvom poslati podatke u sva polja, u drugom samo 
--u ona koja su obavezna.
EXEC sp_Proizvod_Insert
@ProductName='Mlijeko',	
@SupplierID=1,
@CategoryID=2,
@QuantityPerUnit=4,
@UnitPrice=1.6,	
@UnitsInStock=16,
@UnitsOnOrder=1,	
@ReorderLevel=1,
@Discontinued=1


EXEC sp_Proizvod_Insert
@ProductName='Brasno',	
@Discontinued=1

SELECT*
FROM Proizvodi

--5. Kreirati proceduru sp_Proizvod_Update kojom će se u tabeli Proizvodi uraditi 
--update zapisa.
GO
CREATE OR ALTER PROCEDURE sp_Proizvod_Update
(
@ProductID       INT,
@ProductName	 NVARCHAR(40)=NULL,  
@SupplierID		 INT=NULL,
@CategoryID		 INT=NULL,
@QuantityPerUnit NVARCHAR(20)=NULL,
@UnitPrice		 MONEY=NULL,
@UnitsInStock	 SMALLINT=NULL,
@UnitsOnOrder	 SMALLINT=NULL,
@ReorderLevel	 SMALLINT=NULL,
@Discontinued	 BIT=NULL
)
AS 
BEGIN
UPDATE Proizvodi
SET
ProductName=	 ISNULL(@ProductName,ProductName),
SupplierID =	 ISNULL(@SupplierID,SupplierID),
CategoryID =     ISNULL(@CategoryID,CategoryID),
QuantityPerUnit= ISNULL(@QuantityPerUnit,QuantityPerUnit),
UnitPrice	=    ISNULL(@UnitPrice,UnitPrice),
UnitsInStock=    ISNULL(@UnitsInStock,UnitsInStock),
UnitsOnOrder=    ISNULL(@UnitsOnOrder,UnitsOnOrder),
ReorderLevel=    ISNULL(@ReorderLevel,ReorderLevel),
Discontinued=    ISNULL(@Discontinued,Discontinued)
WHERE ProductID=@ProductID
END

--6. Kreirati testni slučaj za update zapisa kroz proceduru.
EXEC sp_Proizvod_Update
@ProductID = 2,   
@ProductName = 'mnm',	
@Discontinued = 1	

SELECT*
FROM Proizvodi
--7. Kreirati proceduru sp_Proizvod_Delete kojom će se u tabeli Proizvodi uraditi 
--delete određenog zapisa.
GO
CREATE PROCEDURE sp_Proizvod_Delete
(
@ProductID INT
)
AS 
BEGIN
DELETE FROM Proizvodi
WHERE ProductID=@ProductID
END
--8. Kreirati testni slučaj za brisanje proizvoda sa id-om 78.
sp_Proizvod_Delete 78
sp_Proizvod_Delete 77

SELECT*
FROM Proizvodi
--9. Kreirati tabelu StavkeNarudzbe te prilikom kreiranja uraditi insert podataka iz 
--tabele Order Details baze Northwind.
SELECT*
INTO StavkeNarudzbe
FROM Northwind.dbo.[Order Details]
--10. Kreirati proceduru sp_StavkeNarudzbe_Proizvodi_InsertUpdate kojom će se u 
--tabeli StavkeNarudzbe dodati nova stavka narudžbe a u tabeli Proizvodi
--umanjiti stanje za zalihama.
GO
CREATE PROCEDURE sp_StavkeNarudzbe_Proizvodi_InsertUpdate
(
@OrderID    INT, 
@ProductID  INT,
@UnitPrice  MONEY,
@Quantity	SMALLINT,
@Discount	REAL
)
AS  
BEGIN
INSERT INTO StavkeNarudzbe
VALUES(@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount)

UPDATE Proizvodi
SET UnitsInStock=UnitsInStock-@Quantity
WHERE ProductID=@ProductID
END

--11. Kreirati testni slučaj za prethodno kreiranu proceduru.


EXEC sp_StavkeNarudzbe_Proizvodi_InsertUpdate 10248, 3, 2,3,0.1

SELECT*
FROM StavkeNarudzbe AS SN
WHERE OrderID=10248

SELECT*
FROM Proizvodi
--12. Kreirati proceduru sp_Proizvodi_SelectByProductNameOrCategoryID kojom 
--će se u tabeli Proizvodi uraditi select proizvoda prema nazivu proizvoda i ID 
--kategorije. Ukoliko korisnik ne unese ništa od navedenog prikazati sve 
--proizvode.
GO
CREATE OR ALTER PROCEDURE sp_Proizvodi_SelectByProductNameOrCategoryID
(
@ProductName NVARCHAR(40)=NULL,
@CategoryID INT=NULL
)
AS 
BEGIN
SELECT*
FROM Proizvodi AS P
WHERE (P.ProductName=@ProductName OR @ProductName IS NULL) AND (P.CategoryID=@CategoryID OR @CategoryID IS NULL)
END

EXEC sp_Proizvodi_SelectByProductNameOrCategoryID 'Pavlova'

--13. Prethodno kreiranu proceduru izvršiti sa sljedećim testnim slučajevima:
--• Ime proizvoda'Chai'
--• Id kategorije 7
--• Ime proizvoda'Tofu'i id kategorije=7
--• bez slanja bilo kakvih podataka
EXEC sp_Proizvodi_SelectByProductNameOrCategoryID @ProductName ='Chai'
EXEC sp_Proizvodi_SelectByProductNameOrCategoryID @CategoryID=7
EXEC sp_Proizvodi_SelectByProductNameOrCategoryID @ProductName= 'Tofu', @CategoryID=7
EXEC sp_Proizvodi_SelectByProductNameOrCategoryID 
EXEC sp_Proizvodi_SelectByProductNameOrCategoryID @ProductName=NULL,@CategoryID=NULL


--14. Kreirati proceduru u bazi Procedure_ naziva sp_uposlenici_selectAll nad 
--tabelama odgovarajućim tabelama baze AdventureWorks2017 kojom će se dati 
--prikaz polja BusinessEntityID, FirstName, LastName i JobTitle. Proceduru 
--podesiti da se rezultati sortiraju po BusinessEntityID.
GO 
CREATE PROCEDURE sp_uposlenici_selectAll
AS 
BEGIN
SELECT E.BusinessEntityID, PP.FirstName, PP.LastName, E.JobTitle
FROM AdventureWorks2019.HumanResources.Employee AS E
INNER JOIN AdventureWorks2019.Person.Person AS PP
ON E.BusinessEntityID=PP.BusinessEntityID
ORDER BY BusinessEntityID
END

EXEC sp_uposlenici_selectAll
GO

--15. Iz baze AdventureWorks2017 u tabelu Vendor kopirati tabelu 
--Purchasing.Vendor.
SELECT*
INTO Vendor
FROM AdventureWorks2019.Purchasing.Vendor
--16. Kreirati proceduru sp_Vendor_deleteColumn kojom će se izvršiti brisanje 
--kolone PurchasingWebServiceURL.
GO
CREATE PROCEDURE sp_Vendor_deleteColumn
AS 
BEGIN
ALTER TABLE Vendor
DROP COLUMN PurchasingWebServiceURL
END 

EXEC sp_vendor_deleteColumn

SELECT * FROM Vendor
--17. Kreirati proceduru sp_Vendor_updateAccountNumber kojom će se izvršiti 
--update kolone AccountNumber tako da u svakom zapisu posljednji znak (cifra) 
--podatka isključivo bude 1.
GO 
CREATE PROCEDURE sp_Vendor_updateAccountNumber
AS 
BEGIN
UPDATE Vendor
SET AccountNumber = LEFT (AccountNumber, LEN(AccountNumber)-1)+ '1'
WHERE RIGHT (AccountNumber, 1) <> '1'
--WHERE CAST (RIGHT (AccountNumber,1) AS INT) != 1
--WHERE CONVERT (INT,RIGHT (AccountNumber,1)) <> 1
END

EXEC sp_Vendor_updateAccountNumber

SELECT*
FROM Vendor
--18. Kreirati proceduru u bazi Procedure_ naziva
--sp_Zaposlenici_SelectByFirstNameLastNameGender nad odgovarajućim 
--tabelama baze AdventureWorks2017 kojom će se definirati sljedeći ulazni 
--parametri: 
--- EmployeeID, 
--- FirstName,
--- LastName,
--- Gender. 
--Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj 
--parametara (možemo ostaviti bilo koje polje bez unijete vrijednosti parametra), 
--te da procedura daje rezultat ako je zadovoljena bilo koja od vrijednosti koje su 
--navedene kao vrijednosti parametara.
GO
CREATE PROCEDURE sp_Zaposlenici_SelectByFirstNameLastNameGender
(
@EmployeeID INT =NULL,
@FirstName	NVARCHAR(50)=NULL,
@LastName	NVARCHAR(50)=NULL,
@Gender		NCHAR(1)=NULL
)
AS 
BEGIN
SELECT E.BusinessEntityID, P.FirstName, P.LastName, E.Gender
FROM AdventureWorks2019.HumanResources.Employee AS E 
INNER JOIN AdventureWorks2019.Person.Person AS P
ON E.BusinessEntityID=P.BusinessEntityID
WHERE E.BusinessEntityID=@EmployeeID OR P.FirstName=@FirstName OR P.LastName=@LastName OR E.Gender=@Gender
END

--Nakon kreiranja pokrenuti proceduru sa 
--sljedećim testnim slučajevima:
--• EmployeeID = 20, 
--• FirstName = Miller,
--• LastName = Abercrombie 
--• Gender = M
EXEC sp_Zaposlenici_SelectByFirstNameLastNameGender 
@EmployeeID=20, 
@FirstName= 'Miller', 
@LastName= 'Abercrombie', 
@Gender	= 'M'

--19. Proceduru sp_Zaposlenici_SelectByFirstNameLastNameGender izmijeniti 
--tako da je prilikom izvršavanja moguće unijeti bilo koje vrijednosti za prva tri 
--parametra (možemo ostaviti bilo koje od tih polja bez unijete vrijednosti), a da 
--vrijednost četvrtog parametra bude F.
--Nakon izmjene pokrenuti proceduru sa sljedećim testnim slučajevima:
--• EmployeeID = 2, 
--• LastName = Miller
GO
ALTER PROCEDURE sp_Zaposlenici_SelectByFirstNameLastNameGender
(
@EmployeeID INT =NULL,
@FirstName	NVARCHAR(50)=NULL,
@LastName	NVARCHAR(50)=NULL,
@Gender		NCHAR(1) = 'F'
)
AS 
BEGIN
SELECT E.BusinessEntityID, P.FirstName, P.LastName, E.Gender
FROM AdventureWorks2019.HumanResources.Employee AS E 
INNER JOIN AdventureWorks2019.Person.Person AS P
ON E.BusinessEntityID=P.BusinessEntityID
WHERE (E.BusinessEntityID=@EmployeeID OR P.FirstName=@FirstName OR P.LastName=@LastName) AND E.Gender=@Gender
END


--20. Kreirati proceduru u bazi Procedure_ naziva 
--sp_Narudzbe_SelectByCustomerID nad odgovarajućim tabelama baze 
--Northwind, sa parametrom CustomerID kojom će se dati pregled ukupno 
--naručenih koločina svakog od proizvoda za unijeti ID Customera. Proceduru 
--pokrenuti za ID Customera BOLID
GO
CREATE PROCEDURE sp_Narudzbe_SelectByCustomerID 
@CustomerID NCHAR(5)
AS 
BEGIN
SELECT P.ProductName, SUM(OD.Quantity) AS 'Ukupno naruceno'
FROM Northwind.dbo.Customers AS C
INNER JOIN Northwind.dbo.Orders AS O
ON C.CustomerID=O.CustomerID
INNER JOIN Northwind.dbo.[Order Details] AS OD
ON O.OrderID=OD.OrderID
INNER JOIN Northwind.dbo.Products AS P
ON P.ProductID=OD.ProductID
WHERE C.CustomerID=@CustomerID
GROUP BY P.ProductName
ORDER BY 2 DESC
END

EXEC sp_Narudzbe_SelectByCustomerID	@CustomerID =  BOLID
--21. Koristeći bazu Northwind kreirati pogled v_Narudzbe strukture:
--- OrderID
--- ShippedDate
--- Ukupno (predstavlja sumu vrijednosti stavki po narudžbi).
USE Northwind


GO
CREATE VIEW v_Narudzbe
AS
SELECT O.OrderID, O.ShippedDate, SUM(OD.Quantity*OD.UnitPrice) AS 'Ukupno'
FROM Northwind.dbo.Orders AS O
INNER JOIN Northwind.dbo.[Order Details] AS OD
ON OD.OrderID=O.OrderID
GROUP BY O.OrderID, O.ShippedDate
GO


--22. Koristeći pogled v_Narudzbe kreirati proceduru sp_Prodavci_Zemlje sa 
--paramterima:
--- startDate, datumski tip
--- endDate, datumski tip
--startDate i endDate su datumi između kojih se izračunava suma prometa po 
--narudžbi i obavezno je unijeti oba datuma.
--Procedura ima sljedeću strukturu, odnosno vraća sljedeće podatke:
--- OrderID
--- Ukupno
--pri čemu će kolona ukupno biti tipa money.
--Omogućiti sortiranje u opadajućem redoslijedu po Ukupno.

--Nakon kreiranja procedure pokrenuti za vrijednosti
--• startDate = 1997-01-01, endDate= 1997-12-31
GO 
CREATE PROCEDURE sp_Prodavci_Zemlje
(
@startDate DATE,
@endDate DATE
)
AS 
BEGIN
SELECT VN.OrderID, CAST(VN.Ukupno AS MONEY) AS Ukupno
FROM v_Narudzbe AS VN
WHERE VN.ShippedDate BETWEEN @startDate AND @endDate
ORDER BY 2 DESC
END
GO

EXEC sp_Prodavci_Zemlje @startDate= '1997-01-01', @endDate= '1997-12-31'

EXEC sp_Prodavci_Zemlje @startDate = '19970101', @endDate = '19971231'

--23. Iz baze AdventureWorks2017 u bazu Procedure_ kopirati tabelu zaglavlje i 
--tabelu stavke narudžbe za nabavke. Novokreirane tabele imenovati kao 
--zaglavlje i detalji. U kreiranim tabelama definirati PK kao u tabelama u Bazi 
--AdventureWorks2017. Definirati realtionships između tabela zaglavlje i stavke 
--narudzbe.

SELECT*
INTO Zaglavlje
FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader

SELECT*
FROM Zaglavlje

ALTER TABLE Zaglavlje
ADD CONSTRAINT PK_Zaglavlje PRIMARY KEY(PurchaseOrderID)

SELECT*
INTO Detalji
FROM AdventureWorks2019.Purchasing.PurchaseOrderDetail  

ALTER TABLE Detalji
ADD CONSTRAINT PK_Detalji PRIMARY KEY(PurchaseOrderID, PurchaseOrderDetailID)

ALTER TABLE Detalji 
ADD CONSTRAINT FK_Detalji_Zaglavlje FOREIGN KEY(PurchaseOrderID) REFERENCES Detalji(PurchaseOrderID)

--24. Kreirati proceduru sp_Narudzbe_Stavke sa paramterima:
--- status, kratki cjelobrojni tip
--- mjesecNarudzbe, cjelobrojni tip
--- kvartalIsporuke, cjelobrojni tip
--- vrijednostStavke, realni tip
--Procedura je sljedeće strukture:
--- status
--- mjesec datuma narudžbe
--- kvartal datuma isporuke
--- naručena količina
--- cijena
--- vrijednost stavke kao proizvod količine i cijene
GO 
CREATE PROCEDURE sp_Narudzbe_Stavke
@status			   TINYINT=NULL, 
@mjesecNarudzbe	   INT=NULL, 
@kvartalIsporuke   INT=NULL,
@vrijednostStavke  REAL=NULL
AS
BEGIN
SELECT Z.Status, MONTH(Z.OrderDate) AS 'Mjesec', DATEPART(QUARTER, Z.ShipDate) AS 'Kvartal',
	   D.OrderQty, D.UnitPrice, (D.OrderQty*D.UnitPrice) AS 'Vrijednost stavke'
FROM Zaglavlje AS Z 
INNER JOIN Detalji AS D
ON Z.PurchaseOrderID=D.PurchaseOrderID
WHERE (Z.Status=@status OR MONTH(Z.OrderDate)=@mjesecNarudzbe OR  DATEPART(QUARTER, Z.ShipDate) = @kvartalIsporuke
OR (D.OrderQty*D.UnitPrice)= @vrijednostStavke) 
AND (D.OrderQty*D.UnitPrice) BETWEEN 100 AND 500
ORDER BY 6 DESC
END
GO
--Uslov je da procedura dohvata samo one zapise u kojima je vrijednost kolone 
--vrijednost stavki između 100 i 500, pri čemu će prilikom pokretanja procedure 
--rezultati biti sortirani u opadajućem redoslijedu. Proceduru kreirati tako da je 
--prilikom izvršavanja moguće unijeti bilo koji broj parametara (možemo ostaviti 
--bilo koje polje bez unijetog parametra), te da procedura daje rezultat ako je 
--zadovoljena bilo koja od vrijednosti koje su navedene kao vrijednosti 
--parametara.
--Nakon kreiranja procedure pokrenuti za sljedeće testne slučajeve:
--• status = 3
EXEC sp_Narudzbe_Stavke @status=3
--• kvartal_isporuke = 4
EXEC sp_Narudzbe_Stavke @kvartalIsporuke=4
--• mjesec_narudzbe = 3, status = 1
EXEC sp_Narudzbe_Stavke @mjesecNarudzbe=3, @status=1

--25. Kreirati proceduru sp_Narudzbe_Stavke_sum sa paramterima:
--- status,				kratki cjelobrojni tip
--- mjesecNarudzbe,		cjelobrojni tip
--- kvartalIsporuke,	cjelobrojni tip
--Procedura je sljedeće strukture:
--- Status
--- mjesec datuma narudžbe
--- kvartal datuma isporuke
--- ukupnu vrijednost narudžbe
GO
CREATE PROCEDURE sp_Narudzbe_Stavke_sum
@status TINYINT =NULL,			
@mjesecNarudzbe INT=NULL,	
@kvartalIsporuke INT=NULL
AS 
BEGIN
SELECT Z.Status, MONTH(Z.OrderDate) AS 'Mjesec', DATEPART(QUARTER, Z.ShipDate) AS Kvartal, 
	   SUM(D.OrderQty*D.UnitPrice) AS 'Vrijednost narudzbe'
FROM Zaglavlje AS Z
INNER JOIN Detalji AS D
ON Z.PurchaseOrderID=D.PurchaseOrderID
WHERE Z.Status=@status OR MONTH(Z.OrderDate)= @mjesecNarudzbe OR DATEPART(QUARTER, Z.ShipDate) = @kvartalIsporuke
GROUP BY Z.Status,  MONTH(Z.OrderDate), DATEPART(QUARTER, Z.ShipDate)
HAVING SUM(D.OrderQty*D.UnitPrice) BETWEEN 10000 AND 5000000
ORDER BY 4 DESC
END
GO

--Uslov je da procedura dohvata samo one zapise u kojima je vrijednost kolone 
--ukupno između 10000 i 5 000 000, pri čemu će prilikom pokretanja procedure 
--rezultati biti sortirani u opadajućem redoslijedu.

--Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj 
--parametara (možemo ostaviti bilo koje polje bez unijetog parametra), te da 
--procedura daje rezultat ako je zadovoljena bilo koja od vrijednosti koje su 
--navedene kao vrijednosti parametara.

--Nakon kreiranja procedure pokrenuti za sljedeće testne slučajeve:
--• status = 1
EXEC sp_Narudzbe_Stavke_sum @status=1
--• kvartal_isporuke = 4, mjesec_narudzbe = 3
EXEC sp_Narudzbe_Stavke_sum @kvartalIsporuke=4, @mjesecNarudzbe=3


--26. Kreirati bazu Indeksi i aktivirati je.

CREATE DATABASE Indeksi 
GO 
USE Indeksi
--27. Kreirati tabelu ProizvodiOsobe koja će nastati spajanjem tabela Product i 
--Person baze AdventureWorks2017 i prilikom kreiranja importovati 10 miliona 
--zapisa.
SELECT TOP 100000000 P.ProductID,P.Name,P.ProductNumber,P.Color,P.ListPrice,PP.BusinessEntityID,PP.FirstName,PP.LastName,PP.MiddleName
INTO ProizvodiOsobe
FROM AdventureWorks2019.Production.Product AS P
CROSS JOIN AdventureWorks2019.Person.Person AS PP
--28. Kreirati nonclustered index kojim će se ubrzati pretraga po imenu i prezimenu. 
--Kreirati testni slučaj i pogledati aktualni plan izvršenja. Izbrisati kreirani index.
CREATE INDEX IX_proizvodiOsobe_FirstName_LastName
ON ProizvodiOsobe(FirstName, LastName)

SELECT PO.FirstName,PO.LastName
FROM ProizvodiOsobe AS PO
WHERE PO.FirstName LIKE 'A%' AND PO.LastName LIKE 'S%'

DROP INDEX IX_proizvodiOsobe_FirstName_LastName
ON ProizvodiOsobe
--29. Kreirati nonclustered indeks koji će omogućiti bržu pretragu prema imenu i 
--prezimenu a također pretraga će biti ubrzana iako se prikaže srednje ime. 
--Kreirati testni slučaj i pogledati plan izvršenja. Izbrisati kreirani index.

CREATE INDEX IX_proizvodiOsobe_FirstName_LastName_INC_MiddleName
ON ProizvodiOsobe(FirstName, LastName) INCLUDE (MiddleName)

SELECT PO.FirstName,PO.LastName
FROM ProizvodiOsobe AS PO
WHERE PO.FirstName LIKE 'A%' AND PO.LastName LIKE 'S%' AND PO.MiddleName LIKE 'L'

DROP INDEX IX_proizvodiOsobe_FirstName_LastName_INC_MiddleName
ON ProizvodiOsobe

--30. Kreirati kompozitni primarni ključ nad kolonama ProductId i 
--BusindessEntityId. Kreirati testni slučaj za upotrebu primarnog ključa.

SELECT*
FROM ProizvodiOsobe

ALTER TABLE ProizvodiOsobe
ADD CONSTRAINT PK_ProizvodiOsobe PRIMARY KEY(ProductId, BusinessEntityID)

SELECT *
FROM ProizvodiOsobe AS PO
WHERE PO.ProductId = 1 AND PO.BusinessEntityID=14951



--31. Kreirati clustered index nad kolonom ProductNumber. Kreirati testni slučaj za 
--upotrebu indexa i pogledati plan izvršenja. Izbrisati kreirani index
CREATE CLUSTERED INDEX IX_proizvodiOsobe_ProductNumber
ON ProizvodiOsobe(ProductNumber)

SELECT *
FROM ProizvodiOsobe AS PO
WHERE PO.ProductNumber LIKE 'A%'