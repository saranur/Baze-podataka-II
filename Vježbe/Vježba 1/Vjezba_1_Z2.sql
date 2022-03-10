CREATE DATABASE ZadaciZaVjezbu
GO
USE ZadaciZaVjezbu


CREATE TABLE Aplikant
(
Ime NVARCHAR(20),
Prezime NVARCHAR(20),
MjestoRodjenja NVARCHAR(50)
)

ALTER TABLE Aplikant 
ADD aplikantID INT CONSTRAINT PK_Aplikant PRIMARY KEY(aplikantID) IDENTITY(1,1) 


CREATE TABLE Projekat
(
NazivProjekta NVARCHAR(100), 
AkronimProjekta NVARCHAR(50),
SvrhaProjekta NVARCHAR(100),
CiljProjekta NVARCHAR
)

ALTER TABLE Projekat 
ADD sifraProjekta INT CONSTRAINT PK_Projekat PRIMARY KEY(sifraProjekta)

ALTER TABLE Aplikant 
ADD projekatID INT NOT NULL CONSTRAINT FK_Aplikant_Projekat FOREIGN KEY REFERENCES Projekat(sifraProjekta)

CREATE TABLE TematskaOblast
(
tematskaOblastID INT CONSTRAINT PK_TematskaOblast PRIMARY KEY(tematskaOblastID) IDENTITY(1,1),
naziv NVARCHAR(100),
opseg NVARCHAR(100)
)

ALTER TABLE Aplikant 
ADD email NVARCHAR 


ALTER TABLE Aplikant
DROP COLUMN MjestoRodjenja

ALTER TABLE Aplikant
ADD telefon NVARCHAR(11), maticniBroj NVARCHAR(14)

DROP TABLE Aplikant, Projekat, TematskaOblast

USE baza1

DROP DATABASE ZadaciZaVjezbu