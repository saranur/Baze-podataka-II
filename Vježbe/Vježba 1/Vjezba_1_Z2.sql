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
NazivProjekta NVARCHAR(100) NOT NULL, 
AkronimProjekta NVARCHAR(50) NOT NULL,
SvrhaProjekta NVARCHAR(100) NOT NULL,
CiljProjekta NVARCHAR(100)
)

ALTER TABLE Projekat 
ADD sifraProjekta INT CONSTRAINT PK_Projekat PRIMARY KEY(sifraProjekta)

ALTER TABLE Aplikant 
ADD projekatID INT NOT NULL CONSTRAINT FK_Aplikant_Projekat FOREIGN KEY REFERENCES Projekat(sifraProjekta)

CREATE TABLE TematskaOblast
(
tematskaOblastID INT CONSTRAINT PK_TematskaOblast PRIMARY KEY(tematskaOblastID) IDENTITY(1,1),
naziv NVARCHAR(100) NOT NULL,
opseg NVARCHAR(100) NOT NULL
)

ALTER TABLE Aplikant 
ADD email NVARCHAR(30) 


ALTER TABLE Aplikant
DROP COLUMN MjestoRodjenja

ALTER TABLE Aplikant
ADD telefon NVARCHAR(11) NOT NULL, maticniBroj NVARCHAR(14) NOT NULL

DROP TABLE Aplikant, Projekat, TematskaOblast

USE baza1

DROP DATABASE ZadaciZaVjezbu
