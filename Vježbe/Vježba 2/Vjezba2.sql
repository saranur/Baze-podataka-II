--1. Kroz SQL kod kreirati bazu podataka Vjezba2
CREATE DATABASE Vjezba2
GO
USE Vjezba2
--2. U pomenutoj bazi kreirati šemu Prodaja
GO
CREATE SCHEMA Prodaja
GO
--3. U šemi prodaja kreirati tabele sa sljedećom strukturom:
CREATE TABLE Prodaja.Autori
(
AutorID VARCHAR(11) CONSTRAINT PK_Autor PRIMARY KEY,
Prezime VARCHAR(40) NOT NULL,
Ime VARCHAR(20) NOT NULL,
Telefon CHAR(12) DEFAULT 'nepoznato',
Adresa VARCHAR(40),
Drzava CHAR(2), --za polja fiksne duzine koristimo CHAR
PostanskiBroj CHAR(5),
Ugovor BIT NOT NULL
)
CREATE TABLE Prodaja.Knjige
(
KnjigaID VARCHAR(6) CONSTRAINT PK_Knjige PRIMARY KEY,
Naziv VARCHAR(80) NOT NULL,
Vrsta CHAR(12) NOT NULL,
IzdavacID CHAR(4),
Cijena MONEY,
Biljeska VARCHAR(200),
Datum DATETIME
)
--4. Upotrebom insert naredbe iz tabele Publishers baze Pubs izvršiti kreiranje
--i insertovanje podataka u tabelu Izdavaci šeme Prodaja
SELECT* --select* prikazuje sve zapise koje se nalaze u toj tabeli
INTO Prodaja.Izdavaci --sve iz pubs.dbo.pub_info se kopiralo u Prodaja.Izdavaci
FROM pubs.dbo.publishers
--5. U kreiranoj tabeli Izdavaci provjeriti koje polje je primarni ključ
ALTER TABLE Prodaja.Izdavaci
ADD CONSTRAINT PK_Izdavac PRIMARY KEY (pub_id)
--6. Povezati tabelu Izdavaci sa tabelom Knjige
ALTER TABLE Prodaja.Knjige
ADD CONSTRAINT FK_Knjiga_Izdavaci FOREIGN KEY(IzdavacID) REFERENCES Prodaja.Izdavaci(pub_id)
--7. U šemu prodaja dodati tabelu sa sljedećom strukturom
CREATE TABLE Prodaja.AutorNaslovi
(
AutorID VARCHAR(11) CONSTRAINT FK_AutorNaslov_Autori FOREIGN KEY REFERENCES Prodaja.Autori(AutorID),
KnjigaID VARCHAR(6) CONSTRAINT FK_AutorNaslov_Knjige FOREIGN KEY REFERENCES Prodaja.Knjige(KnjigaID),
AuOrd TINYINT,
CONSTRAINT PK_AutorNaslov PRIMARY KEY(AutorID, KnjigaID) --u medjutabelama treba biti kompozitni kljuc, samo dodamo oba FK kljuca
)
--8. U kreirane tabele izvršiti insert podataka iz baze Pubs (Za polje biljeska tabele knjige na mjestima gdje je vrijednost NULL pohraniti „nepoznata vrijednost“)
INSERT INTO Prodaja.Autori(AutorID,Prezime,Ime,Telefon,Adresa,Drzava,PostanskiBroj,Ugovor)
SELECT A.au_id,A.au_fname, A.au_lname, A.phone, A.address, A.state, A.zip, A.contract --kada je plavo radi se o rezervisanoj rijeci, mozemo dodati [address] kako nam ne bi predstavljalo problem
--Obzirom na to da smo u SELECT-u listali redom onako kako nam se nalazi u tabeli Autori nismo morali nista dodavati, u suprotnom bismo morali bismo navesti u zagradama kod INSERT INTO Prodaja.Autori
FROM pubs.dbo.authors AS A --AS kad stavimo A. izlistace sva polja u tabeliINSERT INTO Prodaja.Knjige(KnjigaID,Naziv,Vrsta,IzdavacID,Cijena,Biljeska,Datum)

INSERT INTO Prodaja.Knjige(KnjigaID,Naziv,Vrsta,IzdavacID,Cijena,Biljeska,Datum)
SELECT T.title_id, T.title, T.type, T.pub_id, T.price, ISNULL(T.notes, 'nepoznata vrijednost'), T.pubdate
FROM pubs.dbo.titles AS T

INSERT INTO Prodaja.AutorNaslovi(KnjigaID,AutorID,AuOrd)
SELECT TA.title_id, TA.au_id, TA.au_ord
FROM pubs.dbo.titleauthor AS TA

--DELETE 
--FROM Prodaja.AutorNaslovi

--9.	U tabeli autori nad kolonom Adresa promijeniti tip podatka na nvarchar (40)
ALTER TABLE Prodaja.Autori
ALTER COLUMN Adresa NVARCHAR(40) 

--10.	Prikazati sve Autore čije ime počinje sa slovom A ili S
SELECT*
FROM Prodaja.Autori AS A	
WHERE A.Ime LIKE 'A%' OR A.Ime LIKE 'S%'
--11.	Prikazati knjige gdje cijena nije unesena

SELECT* 
FROM Prodaja.Knjige AS K
WHERE K.Cijena IS NULL

--12.	U bazi Vjezba2 kreirati šemu narudzbe
GO 
CREATE SCHEMA Narudzbe
GO

--13.	Upotrebom insert naredbe iz tabele Region baze Northwind izvršiti kreiranje i insertovanje podataka u tabelu Regije šeme narudžbe
SELECT* 
INTO Narudzbe.Regije
FROM Northwind.dbo.Region
--14.	Prikazati sve podatke koji se nalaze u tabeli Regije
SELECT* 
FROM Narudzbe.Regije
--15.	U tabelu Regije insertovati zapis:
--5    SE
INSERT INTO Narudzbe.Regije
VALUES (5,'SE')
--16.	U tabelu Regije insertovati zapise:
--6   NE
--7   NW
INSERT INTO Narudzbe.Regije
VALUES (6, 'NE'),(7,'NW')
--17.	Upotrebom insert naredbe iz tabele OrderDetails baze Northwind izvršiti kreiranje i insertovanje podataka u tabelu StavkeNarudzbe šeme Narudzbe
SELECT*
INTO Narudzbe.StavkeNarudzbe
FROM Northwind.dbo.[Order Details]
--18.	U tabeli StavkeNarudzbe dodati standardnu kolonu ukupno tipa decimalni broj (8,2).
ALTER TABLE Narudzbe.StavkeNarudzbe
ADD Ukupno DECIMAL (8,2) 
--19.	Izvršiti update kreirane kolone kao umnožak kolona Quantity i UnitPrice.
UPDATE Narudzbe.StavkeNarudzbe
SET Ukupno=Quantity*UnitPrice

SELECT* 
FROM Narudzbe.StavkeNarudzbe
--20.	U tabeli StavkeNarduzbe dodati izračunatu (stalno pohranjenu) kolonu CijeliDio u kojoj će biti cijeli dio iz kolone UnitPrice
ALTER TABLE Narudzbe.StavkeNarudzbe
ADD CijeliDio AS FLOOR(UnitPrice)
--21.	U tabeli StavkeNarduzbe kreirati ograničenje na koloni Discount kojim će se onemogućiti unos vrijednosti manjih od 0.
ALTER TABLE Narudzbe.StavkeNarudzbe
ADD CONSTRAINT CK_Discount CHECK(Discount>=0)
--22.	U tabelu StavkeNarudzbe insertovati novi zapis (potrebno je )
INSERT INTO Narudzbe.StavkeNarudzbe(OrderID, ProductID, UnitPrice,Quantity,Discount)
VALUES(11,222,22,66,0)

SELECT*
FROM Narudzbe.StavkeNarudzbe AS SN
WHERE SN.OrderID=11
--23.	U šemu narudzbe dodati tabelu sa sljedećom strukturom:
--Kategorije
--•	KategorijaID ,  cjelobrojna vrijednost, primarni ključ i autoinkrement
--•	ImeKategorije, 15 UNICODE znakova (obavezan unos)
--•	Opis, tekstualan UNICODE tip podatka 
CREATE TABLE Narudzbe.Kategorije
(
KategorijaID INT CONSTRAINT PK_Narudzba PRIMARY KEY IDENTITY(1,1),
ImeKategorije NVARCHAR(15) NOT NULL,
Opis NTEXT 
)
--24.	U kreiranu tabelu izvršiti insertovanje podataka iz tabele Categories baze Northwind
SET IDENTITY_INSERT Narudzbe.Kategorije ON --Iskljuci nas Identity dok mi ne insertujemo podatke 
INSERT INTO Narudzbe.Kategorije(KategorijaID,ImeKategorije,Opis)
SELECT C.CategoryID, C.CategoryName, C.Description
FROM Northwind.dbo.Categories AS C
SET IDENTITY_INSERT Narudzbe.Kategorije OFF -- ovjde ga opet aktiviramo i on ce nastaviti od zadnjeg unijetog podatka 
--25.	U tabelu Kategorije insertovati novu kategoriju pod nazivom „Ncategory“
INSERT INTO Narudzbe.Kategorije(ImeKategorije)
VALUES('Ncategory')
--26.	Kreirati upit kojim će se prikazati sve kategorije
SELECT*
FROM Narudzbe.Kategorije
--27.	Izvršiti update zapisa u tabeli Kategorija na mjestima gdje Opis kategorije nije dodan pohraniti vrijednost „bez opisa“
UPDATE Narudzbe.Kategorije 
SET Opis='bez opisa'
WHERE Opis IS NULL
--28.	Izvršiti brisanje svih kategorija
DELETE FROM Narudzbe.Kategorije