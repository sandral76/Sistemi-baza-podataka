/*1.Na osnovu prosledjenog rednog broja zahteva, korisniku se vraæa odgovarajuæa poruka o zaposlenom 
koji je zatrazio odsustvo u trajanju zahtevanog odsustva izraženom u broju dana.
Ako je korisnik uneo nepostojeæi redni broj zahteva biæe obavešten o tome, u suprotnom
korisnik se obaveštava o broju dana trajanja odsustva samo za zahteve koji su odobreni.
*/

if object_id('Nagrade_sankcije_obuka.BrojDanaOdsustva') is not null
drop function Nagrade_sankcije_obuka.BrojDanaOdsustva
go
create function Nagrade_sankcije_obuka.BrojDanaOdsustva
(
 @rbZahteva as numeric(5)
)
returns varchar(500)
as 
begin
declare @trajanje as int
declare @poruka as varchar(500)
declare @datPoc as date
declare @datZav as date
declare @status as varchar(10)
declare @ime as varchar(20)
declare @prezime as varchar(20)
declare @idZap as numeric(5)
declare @provera as numeric(5)=(select rb_zahteva_ods from  Nagrade_sankcije_obuka.Zahtev_za_odsustvo where rb_zahteva_ods=@rbZahteva)

 if(@provera is null)
 begin
   
   set @poruka='Ne postoji zahtev za odsustvo sa unetim rednim brojem '+CONVERT(varchar,@rbZahteva)
   return @poruka
  end
 else
  begin 
   set @datPoc=(select datum_poc_ods from Nagrade_sankcije_obuka.Zahtev_za_odsustvo where rb_zahteva_ods=@rbZahteva)
   set @datZav=(select datum_zav_ods from Nagrade_sankcije_obuka.Zahtev_za_odsustvo where rb_zahteva_ods=@rbZahteva)
   set @status=(select opis_statusa from Nagrade_sankcije_obuka.Zahtev_za_odsustvo zah 
   join Nagrade_sankcije_obuka.Status stat on zah.id_status=stat.id_status where rb_zahteva_ods=@rbZahteva)
   set @ime=(select z_ime from Nagrade_sankcije_obuka.Zahtev_za_odsustvo zao join Nagrade_sankcije_obuka.Zaposleni zap on
   zao.id_zaposlenog=zap.id_zaposlenog where rb_zahteva_ods=@rbZahteva)
   set @prezime=(select z_prezime from Nagrade_sankcije_obuka.Zahtev_za_odsustvo zao join Nagrade_sankcije_obuka.Zaposleni zap on
   zao.id_zaposlenog=zap.id_zaposlenog where rb_zahteva_ods=@rbZahteva)
   set @idZap=(select id_zaposlenog from Nagrade_sankcije_obuka.Zahtev_za_odsustvo  where rb_zahteva_ods=@rbZahteva)
  
 if(@status != 'Odobren')
  begin
    set @poruka='Zahtev za odsustvo sa rednim brojem '+convert(varchar,@rbZahteva)+' jos uvek nije odobren zaposlenom '+
    concat(@ime,' ',@prezime)+' sa id-jem '+ convert(varchar,@idZap)
    return @poruka 
    
  end

  else
   begin
   set @trajanje=DATEDIFF(day,@datPoc,@datZav)
   set @poruka='Zahtev za odsustvo sa rednim brojem '+convert(varchar,@rbZahteva)+' je odobren zaposlenom '+
   concat(@ime,' ',@prezime)+' sa id-jem '+ convert(varchar,@idZap)
   +'. Odsustvo ce trajati '+ convert(varchar,@trajanje)+' dan/a.' 
   return @poruka 
  end
end
return @poruka
end 
go
select * from Nagrade_sankcije_obuka.Zahtev_za_odsustvo
select Nagrade_sankcije_obuka.BrojDanaOdsustva(5) 
select Nagrade_sankcije_obuka.BrojDanaOdsustva(17) 
select Nagrade_sankcije_obuka.BrojDanaOdsustva(60) 


/*2.Na osnovu unetog id_zaposlenog, vraæa se  senioritet zaposlenog na osnovu njegove plate i broja obuka koje je zaposleni prošao
Zaposleni je junior ako ima platu izmedju 50 000 i 70 000 i broj završenih obuka manji i jedak od 3,
zaposleni je medior ako ima platu izmedju 80 000 i 250 000 i broj završenih obuka izmeðu 5 i 7, 
zaposleni je senior ako ima platu izmedju 255 000 i 400 000 i broj završenih obuka veæi i jednak od 8.
*/
if object_id('Nagrade_sankcije_obuka.Senioritet') is not null
drop function Nagrade_sankcije_obuka.Senioritet
go
create function Nagrade_sankcije_obuka.Senioritet
(
 @idZap as numeric(5)
)
returns varchar(100)
as
begin 
declare @ispis as varchar(100)
declare @plata as numeric(10)
declare @brojObuka as numeric(5)
declare @ime as varchar(20)
declare @prezime as varchar(20)
declare @provera as numeric(5)=(select id_zaposlenog from Nagrade_sankcije_obuka.Zaposleni where id_zaposlenog=@idZap)
 if(@provera is null) 
  begin 
  set @ispis='Ne postoji zaposleni sa unetim id='+convert(varchar,@idZap)
  return @ispis
  end

 else 
  begin
  set @plata=(select z_plt from  Nagrade_sankcije_obuka.Zaposleni where id_zaposlenog=@idZap)
  set @brojObuka=(select count(id_zaposlenog) from Nagrade_sankcije_obuka.Obavlja where id_zaposlenog=14)
  set @ime=(select z_ime from  Nagrade_sankcije_obuka.Zaposleni where id_zaposlenog=@idZap)
  set @prezime=(select z_prezime from Nagrade_sankcije_obuka.Zaposleni where id_zaposlenog=@idZap)
      if(@plata between 50000 and 70000 and @brojObuka<=3)
      begin
      set @ispis='Zaposleni ' +concat(@ime,' ',@prezime)+' je junior.'
      return @ispis
      end

      else if (@plata between 80000 and 250000 and @brojObuka between 5 and 7)
      begin
      set @ispis='Zaposleni '+concat(@ime,' ',@prezime)+' je medior.'
      return @ispis
      end

      else if (@plata between 255000 and 400000 and @brojObuka>=8)
      begin
      set @ispis='Zaposleni '+concat(@ime,' ',@prezime)+' je senior.'
      return @ispis
      end

  end
    return @ispis
  end
go

select * from Nagrade_sankcije_obuka.Zaposleni
select Nagrade_sankcije_obuka.Senioritet(8)
select Nagrade_sankcije_obuka.Senioritet(14)
select Nagrade_sankcije_obuka.Senioritet(158)

--pazi ovde za proveru jer imas triger