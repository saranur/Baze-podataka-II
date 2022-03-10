CREATE DATABASE baza1 --kreira bazu
GO  --da bi mogli koristiti bazu, prije nego unesemo USE, moramo unijeti GO
USE baza1 --koristimo bazu

CREATE TABLE Studenti
(
brojIndeksa NVARCHAR(10),
 /*kada stavimo samo NVARCHAR to ce znaciti da ce biti samo jedan karakter, u zagrade mozemo dodati velicinu ()*/
 ime NVARCHAR(10),-- NOT NULL -ako zelimo da nije nullable
 prezime NVARCHAR(10) 
 /*sva ova polja su trenutno NULLABLE, ako ne zelimo da budu onda dodamo NOT NULL */

)

ALTER TABLE Studenti 
ADD CONSTRAINT PK_Student PRIMARY KEY(brojIndeksa) --ovim mozemo imenovati ogranicenja, nije neophodno, ali ce nam olaksati rad
/*dodali smo primarni kljuc, obrirom da kolona brojIneksa je nullable, nece raditi na ovaj nacin */

ALTER TABLE Studenti 
DROP COLUMN brojIndeksa
--Nakon dropanja kolone, nije moguce vratiti podatke ili ih oporaviti ukoliko nemamo backup (teoretski)

ALTER TABLE Studenti
ADD brojIndeksa NVARCHAR(10) CONSTRAINT PK_Student PRIMARY KEY(brojIndeksa)
--svaki primarni kljuc je unikatan i bice not null

ALTER TABLE Studenti   
ADD email NVARCHAR(50) NOT NULL CONSTRAINT UQ_Student_email UNIQUE, 
Telefon NVARCHAR(15) 


--pri imenjovanje tabela, imenuju se u mnozini, a ostale stvari u jednini mozemo

CREATE TABLE Fakulteti
(
FakultetID INT CONSTRAINT PK_Fakulteti PRIMARY KEY IDENTITY(1,1),
Naziv NVARCHAR(50)
)


--Povezivanje tabela
ALTER TABLE Studenti
ADD FakultetID INT NOT NULL CONSTRAINT FK_Student_Fakultet FOREIGN KEY REFERENCES Fakulteti(FakultetID)
--Konvencija imenovanja: FK_NazivTabelaUKOjuPrelazi_NazivTabeleIzKojePrelazi 
