### Baze podataka II - Vježbe 1

<hr>

**Postoje sistemske i korisniče baze podataka. **
<u>Sistemske baze su :</u> 

- master - glavna baza za SQL server, nalaze se podaci neophodan za server. Sve što server genereše i sva konfiguracija čuva se u master bazi.
- model - template baza, kada napišemo komandu "create database", SQL server napravi kopiju ove baze i da ime koje smo rekli
- msdb - nju koristi SQL agent, u nju se pohranjuju podaci o automatizaciji poslova na SQL serveru
- tempdb - baza koja ima privremeni karakter, generiše se kada se SQL upali, a briše se kada se SQL ugasi. 

<u>Imamo tri vrste komandi:</u> 

- **DDL** - koriste se za kreiranje šeme baze podataka i za definisanje tipa i strukture podataka. Imamo create, alter i drop. 
  	**create** - koristi se za kreiranje baze i njenih objekata
  	**alter** - koristi se za promjenu strukture postojeće baze podataka i njenih objekata
  	**drop** - koristi se za brisanje baze i njenih objekata
- **DML** - Imamo select, insert, update i delete
- **DCL** - koriste se za upravljanje pravima i dozvolama, imamo grant i revoke
  	**grant** - dozvoljava korisnicma pristup bazi
  	**revoke** - oduzima pravo pristupa 

<hr>

### Tipovi podataka

<hr>

| Exact Numbers | Appropriate numeric | Date/Time      | Characters | Unicode Characters | BInary    | Others           |
| :------------ | ------------------- | -------------- | ---------- | ------------------ | --------- | ---------------- |
| Bit           | Real                | Date           | Char       | Nchar              | Binary    | Cursor           |
| Tinyint       | Float               | Datetime       | Varchar    | Nvarchar           | Image     | Hierarchyid      |
| Smallint      |                     | Datetime2      | text       | Ntext              | Varbinary | Sql_variant      |
| Int           |                     | Datetimeoffset |            |                    |           | Table            |
| Bigint        |                     | Smalldatetime  |            |                    |           | Rowversion       |
| Decimal       |                     | Time           |            |                    |           | Uniqueidentifier |
| Numeric       |                     |                |            |                    |           | Xml              |
| Money         |                     |                |            |                    |           | Spatial          |
| Smallmoney    |                     |                |            |                    |           | geography        |

Unicode znakovi - npr. š,ć,đ,ž...
**Char** ćemo koristiti samo kada znamo da će kolona primiti fiksan broj znakova. Npr. ukoliko želimo da pohranimo spol jer nema potrebe koristiti varchar. **Varchar** ili **Nvarchar** će pohraniti i broj znakova (veličinu) i vrijednost. 

**SQL server nije case sensitive.**

