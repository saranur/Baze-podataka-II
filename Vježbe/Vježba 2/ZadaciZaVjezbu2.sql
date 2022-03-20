--1. Kroz SQL kod kreirati bazu podataka ZadaciZaVjezbu2
CREATE DATABASE ZadaciZaVjezbu2
GO 
USE ZadaciZaVjezbu2
--2. U pomenutoj bazi kreirati šemu Prodaja
GO 
CREATE SCHEMA Prodaja
GO
--3. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom:
--a) Proizvodi
-- ProizvodID, cjelobrojna vrijednost, autoinkrement i primarni ključ
-- Naziv, 40 UNICODE karaktera (obavezan unos)
-- Cijena, novčani tip
-- KolicinaNaSkladistu, skraćeni cjelobrojni tip
-- Raspolozivost, bit polje (obavezan unos)
CREATE TABLE Prodaja.Proizvodi
(
ProizvodID INT CONSTRAINT PK_Proizvod PRIMARY KEY IDENTITY(1,1),
Naziv NVARCHAR(40) NOT NULL,
Cijena MONEY,
KolicinaNaSkladistu SMALLINT, 
Raspolozivost BIT NOT NULL
)
--b) Kupci
-- KupciID, 5 UNICODE fiksna karaktera i primarni ključ
-- NazivKompanije, 40 UNICODE karaktera (obavezan unos)
-- Ime, 30 UNICODE karaktera
-- Telefon, 24 UNICODE karaktera
-- Faks, 24 UNICODE karaktera
CREATE TABLE Prodaja.Kupci
(
KupciID NCHAR(5) CONSTRAINT PK_Kupci PRIMARY KEY, 
NazivKompanije NVARCHAR(40) NOT NULL, 
Ime NVARCHAR(30),
Telefon NVARCHAR(24),
Faks NVARCHAR(24)
)
--c) Narudzbe
-- NarudzbaID, cjelobrojna vrijednost, autoinkrement i primarni ključ,
-- DatumNarudzbe, polje za unos datuma
-- DatumPrijema, polje za unos datuma
-- DatumIsporuke, polje za unos datuma
-- Drzava, 15 UNICODE karaktera
-- Regija, 15 UNICODE karaktera
-- Grad, 15 UNICODE karaktera
-- Adresa, 60 UNICODE karaktera
CREATE TABLE Prodaja.Narudzbe
(
NarudzbaID INT CONSTRAINT PK_Narudzbe PRIMARY KEY IDENTITY(1,1),
DatumNarudzbe DATE, 
DatumPrijema DATE, 
DatumIsporuke DATE, 
Drzava NVARCHAR(15), 
Regija NVARCHAR(15),
Grad NVARCHAR(15), 
Adresa NVARCHAR(60)
)
--d) StavkeNarudzbe
-- NarudzbaID, cjelobrojna vrijednost, strani ključ
-- ProizvodID, cjelobrojna vrijednost, strani ključ
-- Cijena, novčani tip (obavezan unos),
-- Kolicina, skraćeni cjelobrojni tip (obavezan unos) i defaultna vrijednost (1),
-- Popust, realna vrijednost (obavezan unos)
-- VrijednostStavki narudžbe (uzeti u obzir i popust)- calculated polje
--**Definisati primarni ključ tabele
CREATE TABLE Prodaja.StavkeNarudzbe
(
NarudzbaID INT CONSTRAINT FK_StavkeNarudzbe_Narudzba FOREIGN KEY REFERENCES Prodaja.Narudzbe(NarudzbaID),
ProizvodID INT CONSTRAINT FK_StavkeNarudzbe_Proizvod FOREIGN KEY REFERENCES Prodaja.Proizvodi(ProizvodID),
Cijena MONEY NOT NULL, 
Kolicina SMALLINT NOT NULL DEFAULT(1),
Popust REAL NOT NULL, 
VrijednostStavki AS (Cijena*Kolicina*(1-Popust)),
CONSTRAINT PK_StavkeNarudzbe PRIMARY KEY (NarudzbaID, ProizvodID)
)

--4. Iz baze podataka Northwind u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Proizvodi dodati sve proizvode 
-- ProductID -> ProizvodID
-- ProductName -> Naziv 
-- UnitPrice -> Cijena 
-- UnitsInStock -> KolicinaNaSkladistu
-- Discontinued -> Raspolozivost 

SET IDENTITY_INSERT Prodaja.Proizvodi ON 
INSERT INTO Prodaja.Proizvodi(ProizvodID,Naziv,Cijena,KolicinaNaSkladistu,Raspolozivost)
SELECT P.ProductID, P.ProductName, P.UnitPrice, P.UnitsInStock, P.Discontinued
FROM Northwind.dbo.Products AS P
SET IDENTITY_INSERT Prodaja.Proizvodi OFF
--b) U tabelu Kupci dodati sve kupce
-- CustomerID -> KupciID
-- CompanyName -> NazivKompanije
-- ContactName -> Ime
-- Phone -> Telefon
-- Fax -> Faks
INSERT INTO Prodaja.Kupci(KupciID, NazivKompanije, Ime, Telefon,Faks)
SELECT C.CustomerID, C.CompanyName, C.ContactName, C.Phone, C.Fax
FROM Northwind.dbo.Customers AS C

--c) U tabelu Narudzbe dodati sve narudžbe, na mjestima gdje nema pohranjenih podataka o regiji 
--zamijeniti vrijednost sa nije naznaceno
-- OrderID -> NarudzbaID
-- OrderDate -> DatumNarudzbe
-- RequiredDate -> DatumPrijema
-- ShippedDate -> DatumIsporuke
-- ShipCountry -> Drzava
-- ShipRegion -> Regija
-- ShipCity -> Grad
-- ShipAddress -> Adresa
SET IDENTITY_INSERT Prodaja.Narudzbe ON
INSERT INTO Prodaja.Narudzbe(NarudzbaID,DatumNarudzbe,DatumPrijema,DatumIsporuke,Drzava,Regija,Grad,Adresa)
SELECT O.OrderID, O.OrderDate, O.RequiredDate, O.ShippedDate, O.ShipCountry, O.ShipRegion, O.ShipCity, O.ShipAddress
FROM Northwind.dbo.Orders AS O
SET IDENTITY_INSERT Prodaja.Narudzbe OFF

--d) U tabelu StavkeNarudzbe dodati sve stavke narudžbe gdje je količina veća od 4
-- OrderID -> NarudzbaID
-- ProductID -> ProizvodID
-- UnitPrice -> Cijena
-- Quantity -> Kolicina
-- Discount -> Popust
INSERT INTO Prodaja.StavkeNarudzbe(NarudzbaID,ProizvodID,Cijena,Kolicina,Popust)
SELECT OD.OrderID, OD.ProductID, OD.UnitPrice, OD.Quantity, OD.Discount
FROM Northwind.dbo.[Order Details] AS OD
WHERE OD.Quantity>4

SELECT* 
FROM Prodaja.StavkeNarudzbe

--5. Kreirati upit kojim će se prikazati svi proizvodi čija je cijena veća od 100
SELECT* 
FROM Prodaja.Proizvodi AS P
WHERE P.Cijena>100
--6. Insert komandom dodati novi proizvod 
INSERT INTO Prodaja.Proizvodi(Naziv, Raspolozivost)
VALUES('novi proizvod', 1)
SELECT*
FROM Prodaja.Proizvodi AS PP
WHERE PP.Naziv='novi proizvod'
--7. Dodati novu stavku narudzbe
INSERT INTO Prodaja.StavkeNarudzbe(NarudzbaID, ProizvodID, Cijena,Popust)
VALUES(10248,78,4,0)

SELECT*
FROM Prodaja.StavkeNarudzbe
--8. Izbrisati sve stavke narudzbe gdje je narudzbaID 10248
DELETE 
FROM Prodaja.StavkeNarudzbe
WHERE NarudzbaID=10248
--9. U tabeli Proizvodi kreirati ograničenje na koloni Cijena kojim će se onemogućiti unos vrijednosti manjih od 0,1
ALTER TABLE Prodaja.Proizvodi 
ADD CONSTRAINT CK_Cijena CHECK(Cijena>=0.1)
--10. U tabeli proizvodi dodati izračunatu kolonu pod nazivom potrebnoNaruciti za količinu 
--proizvoda na skladištu ispod 10 potrebno je pohraniti vrijednost „DA“ a u suptornom „NE“
ALTER TABLE Prodaja.Proizvodi 
ADD potrebnoNaruciti AS CASE WHEN(KolicinaNaSkladistu<10) THEN 'DA' ELSE 'NE' END

SELECT*
FROM Prodaja.Proizvodi