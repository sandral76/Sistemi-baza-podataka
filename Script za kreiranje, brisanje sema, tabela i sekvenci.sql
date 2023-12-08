if object_id('Nagrade_sankcije_obuka.Zahtev_za_odsustvo') is not null
drop table Nagrade_sankcije_obuka.Zahtev_za_odsustvo
if object_id('Nagrade_sankcije_obuka.Obavlja') is not null
drop table Nagrade_sankcije_obuka.Obavlja
if object_id('Nagrade_sankcije_obuka.Sankcija') is not null
drop table Nagrade_sankcije_obuka.Sankcija
if object_id('Nagrade_sankcije_obuka.Nagrada') is not null
drop table Nagrade_sankcije_obuka.Nagrada
if object_id('Nagrade_sankcije_obuka.Obuka') is not null
drop table Nagrade_sankcije_obuka.Obuka
if object_id('Nagrade_sankcije_obuka.Hr_menadzer') is not null
drop table Nagrade_sankcije_obuka.Hr_menadzer
if object_id('Nagrade_sankcije_obuka.Projektni_menadzer') is not null
drop table Nagrade_sankcije_obuka.Projektni_menadzer
if object_id('Nagrade_sankcije_obuka.Radnik') is not null
drop table Nagrade_sankcije_obuka.Radnik
if object_id('Nagrade_sankcije_obuka.Tip_sankcije') is not null
drop table Nagrade_sankcije_obuka.Tip_sankcije
if object_id('Nagrade_sankcije_obuka.Tip_zahteva_za_odsustvo') is not null
drop table Nagrade_sankcije_obuka.Tip_zahteva_za_odsustvo
if object_id('Nagrade_sankcije_obuka.Tip_nagrade') is not null
drop table Nagrade_sankcije_obuka.Tip_nagrade
if object_id('Nagrade_sankcije_obuka.Status') is not null
drop table Nagrade_sankcije_obuka.Status
if object_id('Nagrade_sankcije_obuka.Tip_obuke') is not null
drop table Nagrade_sankcije_obuka.Tip_obuke
if object_id('Nagrade_sankcije_obuka.Zaposleni') is not null
drop table Nagrade_sankcije_obuka.Zaposleni

if object_id('Nagrade_sankcije_obuka.ZapId') is not null
drop sequence Nagrade_sankcije_obuka.ZapId;
if object_id('Nagrade_sankcije_obuka.SankcijaId') is not null
drop sequence Nagrade_sankcije_obuka.SankcijaId;
if object_id('Nagrade_sankcije_obuka.ObukaId') is not null
drop sequence Nagrade_sankcije_obuka.ObukaId;
if object_id('Nagrade_sankcije_obuka.ZahtevZaOdsustvoId') is not null
drop sequence Nagrade_sankcije_obuka.ZahtevZaOdsustvoId;
if object_id('Nagrade_sankcije_obuka.NagradaId') is not null
drop sequence Nagrade_sankcije_obuka.NagradaId;

if object_id('Nagrade_sankcije_obuka.BrojDanaOdsustva') is not null
drop function Nagrade_sankcije_obuka.BrojDanaOdsustva
go
if object_id('Nagrade_sankcije_obuka.Senioritet') is not null
drop function Nagrade_sankcije_obuka.Senioritet
go
if object_id('Nagrade_sankcije_obuka.MejlZaObuku') is not null
drop procedure Nagrade_sankcije_obuka.MejlZaObuku
go

if object_id('Nagrade_sankcije_obuka.OdobreniZahteviZaOdst') is not null
drop procedure Nagrade_sankcije_obuka.OdobreniZahteviZaOdst
go
if object_id('Nagrade_sankcije_obuka.PrioritetFunkcija')is not null
drop function Nagrade_sankcije_obuka.PrioritetFunkcija
go
if object_id('Nagrade_sankcije_obuka.PlataTriger') is not null
drop trigger Nagrade_sankcije_obuka.PlataTriger
go
if object_id('Nagrade_sankcije_obuka.ZahtevTriger') is not null
drop trigger Nagrade_sankcije_obuka.ZahtevTriger
go

if schema_id('Nagrade_sankcije_obuka') is not null
drop schema Nagrade_sankcije_obuka
go
create schema Nagrade_sankcije_obuka
go

create sequence Nagrade_sankcije_obuka.ZapId as numeric 
start with 1 
minvalue 1 
increment by 1 
no cycle 
create table Nagrade_sankcije_obuka.Zaposleni
(id_zaposlenog numeric(5) not null default(next value for Nagrade_sankcije_obuka.ZapId),
z_jbmg numeric(13) not null unique,
z_ime varchar(20) not null,
z_prezime varchar(20) not null,
z_pol varchar(20) check(z_pol='m' or z_pol='z'), 
z_dat_rodj date,
z_adresa varchar(20) not null,
z_grad varchar(20),
z_drzv varchar(20),
z_broj_tel varchar(20) not null,
z_email varchar(40) not null,
z_datum_zap date not null,
z_plt numeric(20) not null,
constraint PK_Zaposleni primary key(id_zaposlenog),
)
 
create table Nagrade_sankcije_obuka.Tip_sankcije
(id_tip_sankcije numeric(5) not null,
opis_tipa_sankcije varchar(30) not null,
iznos_sankcije varchar(10) default(0),
constraint PK_Tip_sankcije primary key(id_tip_sankcije)
)
 
create table  Nagrade_sankcije_obuka.Tip_obuke
(id_tip_obuke numeric(5) not null,
opis_tipa_obuke varchar(300) not null,
constraint PK_Tip_obuke primary key(id_tip_obuke)
)

create table Nagrade_sankcije_obuka.Tip_zahteva_za_odsustvo
(id_tip_zahteva_ods numeric(5) not null,
opis_tipa_zahteva_ods varchar(45) not null,
constraint PK_Tip_zahteva_za_odsustvo primary key(id_tip_zahteva_ods)
)

create table Nagrade_sankcije_obuka.Tip_nagrade
(id_tip_nagrade numeric(5) not null,
opis_tipa_nagrade varchar(300) not null,
vrsta varchar not null check(vrsta in('i','o','g')),
oznaka varchar(10) not null check(oznaka='direktna' or oznaka='indirektna'),
constraint PK_Tip_nagrade primary key(id_tip_nagrade)
)


create table Nagrade_sankcije_obuka.Hr_menadzer
(hr_menadzer numeric(5) not null,
constraint PK_Hr_menadzer primary key(hr_menadzer),
constraint FK_Hr_menadzer_Zaposleni foreign key(hr_menadzer) references Nagrade_sankcije_obuka.Zaposleni(id_zaposlenog)
)
create table Nagrade_sankcije_obuka.Projektni_menadzer
(projektni_menadzer numeric(5) not null,
constraint PK_Projektni_menadzer primary key(projektni_menadzer),
constraint FK_Projektni_menadzer_Zaposleni foreign key(projektni_menadzer) references Nagrade_sankcije_obuka.Zaposleni(id_zaposlenog)
)
create table Nagrade_sankcije_obuka.Radnik
(radnik numeric(5) not null,
constraint PK_Radnik primary key(radnik),
constraint FK_Radnik_Zaposleni foreign key(radnik) references Nagrade_sankcije_obuka.Zaposleni(id_zaposlenog)
)
create table Nagrade_sankcije_obuka.Status
(id_status numeric(5) not null,
opis_statusa varchar(40) not null,
constraint PK_Status primary key(id_status)
)

create sequence Nagrade_sankcije_obuka.SankcijaId as numeric 
start with 1 
minvalue 1 
increment by 1 
no cycle
create table Nagrade_sankcije_obuka.Sankcija
(rb_sankcije numeric(5) not null default (next value for Nagrade_sankcije_obuka.SankcijaId),
datum_od_sprovodjenja datetime default(null),
datum_do_sprovodjenja datetime default(null),
id_zaposlenog numeric(5) not null,
id_tip_sankcije numeric(5) not null,
constraint PK_Sankcija primary key(id_zaposlenog,rb_sankcije),
constraint FK_Sankcija_Zaposleni foreign key(id_zaposlenog) references Nagrade_sankcije_obuka.Zaposleni(id_zaposlenog),
constraint FK_Sankcija_Tip_sanckije foreign key(id_tip_sankcije) references Nagrade_sankcije_obuka.Tip_sankcije(id_tip_sankcije),
constraint CHK_Sankcija_datum_do_sprovodjenja check(datum_do_sprovodjenja>=datum_od_sprovodjenja)
)

create sequence Nagrade_sankcije_obuka.NagradaId as numeric 
start with 1 
minvalue 1 
increment by 1
cycle
create table Nagrade_sankcije_obuka.Nagrada
(rb_nagrade numeric(5) not null default(next value for Nagrade_sankcije_obuka.NagradaId),
iznos_nagrade varchar(30) not null,
datum_dobijanja_nagrade date,
id_zaposlenog numeric(5) not null,
id_tip_nagrade numeric(5) not null,
constraint PK_Nagrada primary key(id_zaposlenog,rb_nagrade),
constraint FK_Nagrada_Zaposleni foreign key(id_zaposlenog) references Nagrade_sankcije_obuka.Zaposleni(id_zaposlenog),
constraint FK_Nagrada_Tip_nagrade foreign key(id_tip_nagrade) references Nagrade_sankcije_obuka.Tip_nagrade(id_tip_nagrade),
)

create sequence Nagrade_sankcije_obuka.ObukaId as numeric 
start with 1 
minvalue 1 
increment by 1
no cycle
create table Nagrade_sankcije_obuka.Obuka
(rb_obuke numeric(5) not null default(next value for Nagrade_sankcije_obuka.ObukaId),
datum_poc_obuke date not null,
datum_zav_obuke date not null,
broj_casova numeric(3) check(len(broj_casova)>0 and len(broj_casova)<=100),
id_tip_obuke numeric(5) not null,
constraint PK_Obuka primary key(id_tip_obuke,rb_obuke),
constraint FK_Obuka_Tip_obuke foreign key(id_tip_obuke) references Nagrade_sankcije_obuka.Tip_obuke(id_tip_obuke),
constraint CHK_Obuka_datum_zav_obuke check(datum_zav_obuke>datum_poc_obuke)
)

create sequence Nagrade_sankcije_obuka.ZahtevZaOdsustvoId as numeric 
start with 1 
minvalue 1 
increment by 2
cycle
create table Nagrade_sankcije_obuka.Zahtev_za_odsustvo
(rb_zahteva_ods numeric(5) not null default(next value for Nagrade_sankcije_obuka.ZahtevZaOdsustvoId),
datum_poc_ods date not null,
datum_zav_ods date  not null,
prioritet numeric(2),
id_zaposlenog numeric(5) not null,
id_status numeric(5) not null,
id_tip_zahteva_ods numeric(5) not null,
hr_menadzer numeric(5) not null,
constraint PK_Zahtev_za_odsustvo primary key(id_zaposlenog,rb_zahteva_ods),
constraint FK_Zahtev_za_odsustvo_Zaposleni foreign key(id_zaposlenog) references Nagrade_sankcije_obuka.Zaposleni(id_zaposlenog),
constraint FK_Zahtev_za_odsustvo_Hr_menadzer foreign key(hr_menadzer) references Nagrade_sankcije_obuka.Hr_menadzer(hr_menadzer),
constraint FK_Zahtev_za_odsustvo_Tip_zahteva_za_odsustvo foreign key(id_tip_zahteva_ods) references Nagrade_sankcije_obuka.Tip_zahteva_za_odsustvo(id_tip_zahteva_ods),
constraint FK_Zahtev_za_odsustvo_Status foreign key(id_status) references Nagrade_sankcije_obuka.Status(id_status),
constraint CHK_Zahtev_za_odsustvo_datum_zav_ods check(datum_zav_ods>datum_poc_ods)
)

create table Nagrade_sankcije_obuka.Obavlja
(postignuti_rez numeric(3) not null check(len(postignuti_rez)>=0 and len(postignuti_rez)<=100),
id_zaposlenog numeric(5) not null,
id_tip_obuke numeric(5) not null,
rb_obuke numeric(5) not null,
constraint PK_Obavlja primary key(id_zaposlenog,id_tip_obuke,rb_obuke),
constraint FK_Obavlja_Zaposleni foreign key(id_zaposlenog) references Nagrade_sankcije_obuka.Zaposleni(id_zaposlenog),
constraint FK_Obavlja_Obuka foreign key(id_tip_obuke,rb_obuke) references Nagrade_sankcije_obuka.Obuka(id_tip_obuke,rb_obuke)
)
