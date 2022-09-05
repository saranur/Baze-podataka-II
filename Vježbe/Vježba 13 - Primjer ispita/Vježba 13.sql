--Vježba 13 :: Zadaci
--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.
CREATE DATABASE IB200067
GO 
USE IB200067
--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom:
--a) Proizvodi
--• ProizvodID,				  cjelobrojna vrijednost i primarni ključ
--• Naziv,					  40 UNICODE karaktera (obavezan unos)
--• Cijena,					  novčani tip (obavezan unos)
--• KoličinaNaSkladistu,	  smallint 
--• NazivKompanijeDobavljaca, 40 UNICODE (obavezan unos)
--• Raspolozivost,			  bit (obavezan unos)
CREATE TABLE Proizvodi
(
ProizvodID INT CONSTRAINT PK_Proizvodi PRIMARY KEY,				 
Naziv NVARCHAR(40) NOT NULL,					 
Cijena MONEY NOT NULL,					 
KoličinaNaSkladistu SMALLINT,	 
NazivKompanijeDobavljaca NVARCHAR(40) NOT NULL,
Raspolozivost BIT NOT NULL
)
--b) Narudzbe
--• NarudzbaID,			cjelobrojna vrijednost i primarni ključ,
--• DatumNarudzbe,		polje za unos datuma
--• DatumPrijema,		polje za unos datuma
--• DatumIsporuke,		polje za unos datuma
--• Drzava,				15 UNICODE znakova
--• Regija,				15 UNICODE znakova
--• Grad,				15 UNICODE znakova
--• Adresa,				60 UNICODE znakova
CREATE TABLE Narudzbe
(
NarudzbaID INT CONSTRAINT PK_Narudzbe PRIMARY KEY,		
DatumNarudzbe DATE,	
DatumPrijema DATE,	
DatumIsporuke DATE,	
Drzava NVARCHAR(15),			
Regija NVARCHAR(15),			
Grad NVARCHAR(15),			
Adresa NVARCHAR(60),			
)
--c) StavkeNarudzbe
--• NarudzbaID,		cjelobrojna vrijednost, strani ključ
--• ProizvodID,		cjelobrojna vrijednost, strani ključ
--• Cijena,			novčani tip (obavezan unos),
--• Količina,		smallint (obavezan unos),
--• Popust,			real vrijednost (obavezan unos)
--**Jedan proizvod se može naći na više narudžbi, dok jedna narudžba može imati više proizvoda. 
--U okviru jedne narudžbe jedan proizvod se ne može pojaviti više od jedanput.
CREATE TABLE StavkeNarudzbe
(
NarudzbaID INT CONSTRAINT FK_StavkeNarudzbe_Narudzba FOREIGN KEY REFERENCES Narudzbe(NarudzbaID),	
ProizvodID INT CONSTRAINT FK_StavkeNarudzbe_Proizvod FOREIGN KEY REFERENCES Proizvodi(ProizvodID),	
Cijena     MONEY NOT NULL,		
Količina   SMALLINT NOT NULL,	
Popust     REAL NOT NULL,		
CONSTRAINT PK_StavkeNarudzbe PRIMARY KEY(NarudzbaID,ProizvodID)
)

--3. Iz baze podataka Northwind u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Proizvodi dodati sve proizvode 
--• ProductID -> ProizvodID
--• ProductName -> Naziv 
--• UnitPrice -> Cijena 
--• UnitsInStock -> KolicinaNaSkladistu
--• CompanyName -> NazivKompanijeDobavljaca
--• Discontinued -> Raspolozivost 
INSERT INTO Proizvodi
SELECT P.ProductID, P.ProductName, P.UnitPrice, P.UnitsInStock, S.CompanyName, P.Discontinued
FROM Northwind.dbo.Products AS P
INNER JOIN Northwind.dbo.Suppliers AS S
ON P.SupplierID = S.SupplierID

SELECT*
FROM Proizvodi

--b) U tabelu Narudzbe dodati sve narudžbe, na mjestima gdje nema pohranjenih podataka o regiji 
--zamijeniti vrijednost sa nije naznaceno
--• OrderID -> NarudzbaID
--• OrderDate -> DatumNarudzbe
--• RequiredDate -> DatumPrijema
--• ShippedDate -> DatumIsporuke
--• ShipCountry -> Drzava
--• ShipRegion -> Regija
--• ShipCity -> Grad
--• ShipAddress -> Adresa
INSERT INTO Narudzbe
SELECT O.OrderID, O.OrderDate, O.RequiredDate, O.ShippedDate, O.ShipCountry, ISNULL(O.ShipRegion, 'nije naznaceno'), O.ShipCity, O.ShipAddress
FROM Northwind.dbo.Orders AS O

SELECT*
FROM Narudzbe
--c) U tabelu StavkeNarudzbe dodati sve stavke narudžbe gdje je količina veća od 4
--• OrderID -> NarudzbaID
--• ProductID -> ProizvodID
--• UnitPrice -> Cijena
--• Quantity -> Količina
--• Discount -> Popust
INSERT INTO StavkeNarudzbe
SELECT OD.OrderID, OD.ProductID, OD.UnitPrice, OD.Quantity, OD.Discount
FROM Northwind.dbo.[Order Details] AS OD
WHERE OD.Quantity>4

SELECT*
FROM StavkeNarudzbe
--4.
--a) Prikazati sve proizvode koji počinju sa slovom a ili c a trenutno nisu raspoloživi.
SELECT*
FROM Proizvodi AS P
WHERE (P.Naziv LIKE 'A%' OR P.Naziv LIKE 'C%') AND P.Raspolozivost=0

--b) Prikazati narudžbe koje su kreirane 1996 godine i čija je ukupna vrijednost bez popusta veća 
--od 500KM.
SELECT N.NarudzbaID, SUM(SN.Cijena*SN.Količina) AS 'Ukupna vrijednost'
FROM Narudzbe AS N
INNER JOIN StavkeNarudzbe AS SN
ON N.NarudzbaID=SN.NarudzbaID
WHERE YEAR(N.DatumNarudzbe)=1996 
GROUP BY N.NarudzbaID
HAVING SUM(SN.Cijena*SN.Količina)>500


--c) Prikazati ukupni promet (uzimajući u obzir i popust) od narudžbi po teritorijama. 
--(AdventureWorks2017)
SELECT ST.Name, SUM(SOD.LineTotal) AS 'Ukupni promet'
FROM AdventureWorks2019.Sales.SalesTerritory AS ST
INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH 
ON ST.TerritoryID=SOH.TerritoryID
INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
ON SOD.SalesOrderID=SOH.SalesOrderID
GROUP BY ST.Name

--d) Napisati upit koji će prebrojati stavke narudžbe za svaku narudžbu pojedinačno. U rezultatima 
--prikazati ID narudžbe i broj stavki, te uzeti u obzir samo one narudžbe čiji je broj stavki veći 
--od 1, te koje su napravljene između 1.6. i 10.6. bilo koje godine. Rezultate prikazati prema 
--ukupnom broju stavki obrnuto abecedno. (AdventureWorks2017)
SELECT SOH.SalesOrderID, (SELECT COUNT(*)
						  FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD
						  WHERE SOH.SalesOrderID=SOD.SalesOrderID) AS 'Ukupno stavki'
FROM AdventureWorks2019.Sales.SalesOrderHeader AS SOH
WHERE MONTH(SOH.OrderDate)=6 AND DAY(SOH.OrderDate) BETWEEN 1 AND 10 AND (SELECT COUNT(*)
						  FROM AdventureWorks2019.Sales.SalesOrderDetail AS SOD
						  WHERE SOH.SalesOrderID=SOD.SalesOrderID)>1
ORDER BY 2

--Drugi nacin 
SELECT SOH.SalesOrderID, COUNT(*) AS 'Ukupno stavki'
FROM AdventureWorks2019.Sales.SalesOrderHeader AS SOH 
INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD 
ON SOH.SalesOrderID=SOD.SalesOrderID
WHERE MONTH(SOH.OrderDate)=6 AND DAY(SOH.OrderDate) BETWEEN 1 AND 10
GROUP BY SOH.SalesOrderID
HAVING COUNT(*)>1
ORDER BY 2 

--e) Napisati upit koji će prikazati sljedeće podatke o proizvodima: ID proizvoda, naziv proizvoda, 
--šifru proizvoda, te novokreiranu šifru proizvoda. Nova šifra se sastoji od sljedećih vrijednosti: 
--(AdventureWorks2017)
--• Svi karakteri nakon prvog znaka - (crtica)
--• Karakter /
--• ID proizvoda
--Npr. Za proizvod sa ID-om 716 i šifrom LJ-0192-X, nova šifra će biti 0192-X/716.
SELECT PP.ProductID, PP.Name, 
SUBSTRING(PP.ProductNumber, CHARINDEX('-', PP.ProductNumber)+1, LEN(PP.ProductNumber)-CHARINDEX('-', PP.ProductNumber))+'/'+ CAST(PP.ProductID AS NVARCHAR)
FROM AdventureWorks2019.Production.Product AS PP

--5.
--a) Kreirati proceduru sp_search_proizvodi kojom će se u tabeli Proizvodi uraditi pretraga
--proizvoda prema nazivu prizvoda ili nazivu dobavljača. Pretraga treba da radi i prilikom 
--unosa bilo kojeg od slova, ne samo potpune riječi. Ukoliko korisnik ne unese ništa od 
--navedenog vratiti sve zapise. Proceduru obavezno pokrenuti.
GO
CREATE OR ALTER PROCEDURE dbo.sp_search_proizvodi
    @nazivProizvoda NVARCHAR(60)=NULL,
    @nazivDobavljaca NVARCHAR(60)=NULL  
AS
BEGIN
    SELECT*
	FROM Proizvodi AS PP
	WHERE (PP.Naziv LIKE @nazivProizvoda+'%' OR @nazivProizvoda IS NULL) AND (PP.NazivKompanijeDobavljaca LIKE @nazivDobavljaca+'%' OR @nazivDobavljaca IS NULL)
END
GO

EXEC dbo.sp_search_proizvodi @nazivProizvoda='c'

SELECT*
FROM Proizvodi

--b) Kreirati proceduru sp_insert_stavkeNarudzbe koje će vršiti insert nove stavke narudžbe u 
--tabelu stavkeNarudzbe. Proceduru obavezno pokrenuti.
GO 
CREATE OR ALTER PROCEDURE sp_insert_stavkeNarudzbe(
@NarudzbaID INT, 
@ProizvodID INT, 
@Cijena MONEY, 
@Kolicina SMALLINT, 
@Popust REAL
)
AS 
BEGIN 
	INSERT INTO StavkeNarudzbe 
	VALUES(@NarudzbaID, @ProizvodID, @Cijena, @Kolicina, @Popust)
END
GO

EXEC sp_insert_stavkeNarudzbe @NarudzbaID=10248, @ProizvodID=23, @Cijena=12.5, @Kolicina=2, @Popust=2
EXEC sp_insert_stavkeNarudzbe 10248, 1, 2, 2, 0.02

SELECT*
FROM StavkeNarudzbe AS SN
WHERE SN.NarudzbaID=10248
--c) Kreirati view koji prikazuje sljedeće kolone: ID narudžbe, datum narudžbe, spojeno ime i 
--prezime kupca i ukupnu vrijednost narudžbe bez popusta. Podatke sortirati prema ukupnoj 
--vrijednosti u opadajućem redoslijedu. (AdventureWorks2017)
GO
CREATE VIEW V_Narudzbe_Ukupno 
AS 
	SELECT SOD.SalesOrderID 'ID narudzbe', SOH.OrderDate 'Datum narudzbe', CONCAT(PP.FirstName,' ',PP.LastName) AS 'Ime i prezime', 
	SUM(SOD.OrderQty*SOD.UnitPrice) AS Ukupno
	FROM AdventureWorks2019.Person.Person AS PP
	INNER JOIN AdventureWorks2019.Sales.Customer AS SC
	ON PP.BusinessEntityID=SC.PersonID
	INNER JOIN AdventureWorks2019.Sales.SalesOrderHeader AS SOH
	ON SC.CustomerID= SOH.CustomerID
	INNER JOIN AdventureWorks2019.Sales.SalesOrderDetail AS SOD
	ON SOH.SalesOrderID=SOD.SalesOrderID
	GROUP BY SOD.SalesOrderID, SOH.OrderDate, CONCAT(PP.FirstName,' ',PP.LastName)
GO

SELECT *
FROM V_Narudzbe_Ukupno AS VU
ORDER BY VU.Ukupno DESC

--d) Kreirati okidač kojim će se onemogućiti brisanje zapisa iz tabele StavkeNarudzbe. 
--Korisnicima je potrebno ispisati poruku Arhivske zapise nije moguće izbrisati.
GO
CREATE TRIGGER t_onem_delete_StavkeNarudzbe
ON StavkeNarudzbe
INSTEAD OF DELETE 
AS
BEGIN 
	PRINT( 'Arhivske zapise nije moguće izbrisati')
END
GO

DELETE FROM StavkeNarudzbe

SELECT*
FROM StavkeNarudzbe

--e) Kreirati index kojim će se ubrzati pretraga po nazivu proizvoda.

CREATE INDEX IX_pretraga_po_nazivu
ON Proizvodi (Naziv)

SELECT Naziv
FROM Proizvodi
WHERE Naziv LIKE 'A%'

--f) U tabeli StavkeNarudzbe kreirati polje ModifiedDate u kojem će se nakon kreiranja okidača 
--za izmjenu podataka spremati datum modifikacije podataka za konkretan red na kojem je 
--izvršena modifikacija

ALTER TABLE StavkeNarudzbe
ADD ModifiedDate DATETIME
GO
CREATE TRIGGER t_update_StavkeNarudzbe
ON StavkeNarudzbe
AFTER UPDATE 
AS
BEGIN 
	 UPDATE StavkeNarudzbe
     SET ModifiedDate=GETDATE()
	 WHERE NarudzbaID IN(SELECT DISTINCT NarudzbaID FROM inserted) AND ProizvodID IN(SELECT DISTINCT ProizvodID FROM inserted)
END

UPDATE StavkeNarudzbe
SET Cijena=1
WHERE NarudzbaID=10248 AND ProizvodID=1

SELECT*
FROM StavkeNarudzbe
