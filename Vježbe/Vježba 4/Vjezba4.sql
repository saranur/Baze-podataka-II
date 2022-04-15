SELECT LEFT('Softverski inzinjering', 2) -- REZULTAT So
SELECT RIGHT('Softverski inzinjering', 2) -- REZULTAT ng
SELECT CHARINDEX(' ', 'Softverski inzinjering') -- REZULTAT 11
SELECT PATINDEX('%[0-9]%', 'FITCC2022') -- REZULTAT 6, vraca lokaciju prve pronadjene zadane vrijednosti, patindeks s obje strane mora da ima %
SELECT SUBSTRING('Softverski inzinjering', 11+1, 11) -- REZULTAT Inzinjering
SELECT UPPER('Softverski inzinjering') -- REZULTAT 'SOFTVERSKI INZINJERING
SELECT LOWER('Softverski inzinjering') -- REZULTAT softverski inzinjering
SELECT LEN('Softverski inzinjering') -- REZULTAT 22
SELECT REPLACE('Softverski inzinjering', 'i','XY') -- REZULTAT SoftverskXY XYnzXYnjerXYng
SELECT STUFF('Softverski inzinjering',3,2,'XY') -- REZULATAT SoXYverski inzinjering, od pozicije 3 zamijeni naredna 2 sa XY
SELECT STR(123) +'.'
SELECT REVERSE('Softverski inzinjering') -- REZULTAT gnirejnizni iksrevtfoS


--1.	Iz tabele HumanResources.Employee baze AdventureWorks2017 iz kolone LoginID izvući ime uposlenika.
SELECT E.LoginID, SUBSTRING(E.LoginID, CHARINDEX('\', E.LoginID)+1, LEN(E.LoginID)-CHARINDEX('\', E.LoginID)-1)
FROM AdventureWorks2019.HumanResources.Employee AS E
 
--2.	Kreirati upit koji prikazuje podatke o zaposlenicima. Lista treba da sadrži sljedeće kolone: ID uposlenika, korisničko ime i novu lozinku:
--Uslovi su sljedeći: 
--•	Za korisničko ime potrebno je koristiti kolonu LoginID (tabela Employees). Npr. LoginID zaposlenika sa imenom i prezimenom 'Mary Gibson' 
--je adventureworks\mary0. Korisničko ime zaposlenika je sve što se nalazi iza znaka \ (backslash) što je u ovom primjeru mary0, 
--•	Nova lozinka se formira koristeći rowguid lozinku zaposlenika na sljedeći način: Rowguid je potrebno je okrenuti obrnuto 
--(npr. dbms2015 -> 5102smbd) o Nakon toga preskačemo prvih 5 i uzimamo narednih 8 karaktera 
--•	Sljedeći korak jeste da iz dobivenog stringa počevši od drugog karaktera naredna dva zamijenimo sa X#
--(npr. ako je dobiveni string dbms2015 izlaz će biti dX#s2015) 


SELECT*
FROM AdventureWorks2019.HumanResources.Employee


SELECT *, RIGHT(E.LoginID, CHARINDEX('\', REVERSE(E.LoginID))-1) AS 'Korisnicko ime', REPLACE(SUBSTRING(REVERSE
(E.rowguid),6,7),SUBSTRING(SUBSTRING(REVERSE (E.rowguid),6,7),2,3),'X#')
FROM AdventureWorks2019.HumanResources.Employee AS E

SELECT *, RIGHT(E.LoginID, CHARINDEX('\', REVERSE(E.LoginID))-1) AS 'Korisnicko ime', STUFF(SUBSTRING(REVERSE(E.rowguid),6,8),2,2,'X#') 'Nova lozinka'
FROM AdventureWorks2019.HumanResources.Employee AS E

--3.	Iz tabele Sales.Customer baze AdventureWorks2017 iz kolone AccountNumber izvući broj pri čemu je potrebno broj prikazati bez vodećih nula.
--a) dohvatiti sve zapise
--b) dohvatiti one zapise kojima je unijet podatak u kolonu PersonID
SELECT C.AccountNumber, CAST(RIGHT(C.AccountNumber, PATINDEX('%[A-Z]%',REVERSE(C.AccountNumber))-1) AS INT)
FROM AdventureWorks2019.Sales.Customer AS C
--mozemo korisiti cast ili convert
SELECT C.AccountNumber, CONVERT(INT,RIGHT(C.AccountNumber, PATINDEX('%[A-Z]%',REVERSE(C.AccountNumber))-1))
FROM AdventureWorks2019.Sales.Customer AS C
WHERE C.PersonID IS NOT NULL

--4.	Iz tabele Purchasing.Vendor baze AdventureWorks2017 dohvatiti zapise u kojima se podatak u koloni AccountNumber formirao iz prve riječi kolone Name.

SELECT PV.AccountNumber, PV.Name, LEFT(PV.AccountNumber, PATINDEX('%[0-9]%', PV.AccountNumber)-1), IIF(CHARINDEX(' ',PV.Name)=0,PV.Name, LEFT(PV.Name, CHARINDEX(' ',PV.Name)-1))
FROM AdventureWorks2019.Purchasing.Vendor AS PV
WHERE LEFT(PV.AccountNumber, PATINDEX('%[0-9]%', PV.AccountNumber)-1)=IIF(CHARINDEX(' ',PV.Name)=0,PV.Name, LEFT(PV.Name, CHARINDEX(' ',PV.Name)-1))

--5.	Koristeći bazu Northwind kreirati upit koji će prikazati odvojeno ime i prezime, naziv firme te državu i grad kupca ali samo onih čija adresa završava sa 2 
--ili više broja (uzeti u obzir samo one kupce koji u polju ContactName imaju dvije riječi).

SELECT C.ContactName, LEFT(C.ContactName, CHARINDEX(' ', C.ContactName)-1), RIGHT(C.ContactName, CHARINDEX(' ', REVERSE(C.ContactName))-1), 
C.CompanyName, C.City, C.Address, RIGHT(C.Address, CHARINDEX(' ', REVERSE(C.Address))-1) 
FROM Northwind.dbo.Customers AS C
WHERE IIF(ISNUMERIC(RIGHT(C.Address, CHARINDEX(' ', REVERSE(C.Address))-1))=1, RIGHT(C.Address, CHARINDEX(' ', REVERSE(C.Address))-1),0)>=10
AND LEN(C.ContactName)-LEN(REPLACE(C.ContactName, ' ', ''))=1

--6.	Koristeći bazu Northwind u tabeli Customers dodati izračunato polje Spol u koji će se upitom pohraniti vrijednost da li se radi o muškarcu 
--ili ženi (M ili F). Vrijednost na osnovu koje se određuje to o kojem se spolu radi nalazi se u koloni ContactName gdje zadnje slovo prve riječi
--određuje spol (riječi koje se završavaju slovom a predstavljaju osobe ženskog spola).

SELECT C.ContactName, IIF(RIGHT(LEFT(C.ContactName, CHARINDEX(' ', C.ContactName)-1),1)='a', 'F', 'M')
FROM Northwind.dbo.Customers AS C

ALTER TABLE Northwind.dbo.Customers
ADD Spol AS IIF(RIGHT(LEFT(ContactName, CHARINDEX(' ',ContactName)-1),1)='a', 'F', 'M')


SELECT* 
FROM Northwind.dbo.Customers

