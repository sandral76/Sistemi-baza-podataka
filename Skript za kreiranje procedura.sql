/*1.Procedura koja na osnovu prosleðenog id-ja
zaposlenig kreira imejl koji se može koristiti za prijavu na sajt za prijavljivanje na neku obuku. 
Imejl se zasniva od id-ja, imena, prezimena, kao i lokacije gde je klijent prijavljen, te se na osnovu gradova mogu ubuduæe
grupisati mesta za odrzavanje obuka(do 10 mesta). Za 5 gradova koji su aktuelni u bazi, unapred su kreirane skraæenice, dok se
za ostale uzima puno ime grada (ukoliko se unese novi zaposleni koji je iz Niša, njegov imejl bi
imao ekstenziju @nisobuka.com). Unaped kreirane skraæenice po gradovima su: 
Beograd -bg, Novi Sad - ns, Trebinje - tb, Prijedor - pd, Kragujevac – kg.
*/
if object_id('Nagrade_sankcije_obuka.MejlZaObuku') is not null
drop procedure Nagrade_sankcije_obuka.MejlZaObuku
go
create procedure Nagrade_sankcije_obuka.MejlZaObuku
@idZap as numeric(5)
as 
begin 
declare @provera as numeric(5)=(select id_zaposlenog from Nagrade_sankcije_obuka.Zaposleni where id_zaposlenog=@idZap)
declare @ime as varchar(20)=(select z_ime from Nagrade_sankcije_obuka.Zaposleni where id_zaposlenog=@idZap)
declare @prez as varchar(20)=(select z_prezime from Nagrade_sankcije_obuka.Zaposleni where id_zaposlenog=@idZap)
declare @grad as varchar(20)=(select z_grad from Nagrade_sankcije_obuka.Zaposleni where id_zaposlenog=@idZap)
declare @mejl as varchar(100)
declare @ekstenzija as varchar(40)
if @provera is null
   begin
     print 'Zaposleni sa id-jem: '+convert(varchar,@idZap)+' ne postoji u bazi.'
   end
else
    begin
	  if(@grad='Beograd')
	    set @ekstenzija='@bgobuka.com'
	  else if(@grad='Novi Sad')
	   	set @ekstenzija='@nsobuka.com'
	  else if(@grad='Trebinje')
	   	set @ekstenzija='@tbobuka.com'
	  else if(@grad='Prijedor')
	   	set @ekstenzija='@pdobuka.com'
	  else if(@grad='Kragujevac')
	   	set @ekstenzija='@kgobuka.com'
	 else
	    begin
	   	 set @ekstenzija='@'+lower(replace(@grad,' ',''))+'obuka.com'
	     end
	 set @mejl=lower(@prez)+'_'+lower(@ime)+'_'+convert(varchar,@idZap)+convert(varchar,@ekstenzija)
	

	 update Nagrade_sankcije_obuka.Zaposleni
	 set z_email=@mejl
	 where id_zaposlenog=@idZap

	 print 'Imejl zaposlenog sa id-jem '+convert(varchar,@idZap)+' je postavljen na: '+ @mejl
 end
end
go
exec Nagrade_sankcije_obuka.MejlZaObuku 1
exec Nagrade_sankcije_obuka.MejlZaObuku 24

select * from Nagrade_sankcije_obuka.Zaposleni

/*2.Procedura koja na osnovu prosleðenog id-ja
hr menadzera generise spisak svih zahteva za odsustvo koji je hr menazder odobrio, uz izlistavanje osnovnih
informacija o zahtevu poput opisa i priorita zahteva. Takoðe, u okviru ispisa se i prilaže
datum pocetka odsustva kao i ime i prezime zaposlenog kom je odobreno odsustvo.
Ispisuje se i ukupan broj zahteva koji je hr menadzer odobrio.
Ako hr menadzer nije odobrio jos uvek ni jedan zahtev, ispisati poruku, kao i ako nema podataka o zahtevu.
*/

if object_id('Nagrade_sankcije_obuka.OdobreniZahteviZaOdst') is not null
drop procedure Nagrade_sankcije_obuka.OdobreniZahteviZaOdst
go
create procedure Nagrade_sankcije_obuka.OdobreniZahteviZaOdst
@idMen as numeric(5) 
as
begin
  declare @provera as numeric(5)=(select hr_menadzer from Nagrade_sankcije_obuka.Hr_menadzer where hr_menadzer=@idMen)
  declare @imeM as varchar(20)=(select z_ime from Nagrade_sankcije_obuka.Hr_menadzer hrm join Nagrade_sankcije_obuka.Zaposleni zap on hrm.hr_menadzer=zap.id_zaposlenog where hr_menadzer=@idMen)
  declare @brojZ as numeric(5)=(select count(rb_zahteva_ods) from  Nagrade_sankcije_obuka.Zahtev_za_odsustvo zah 
  where id_status=(select id_status from Nagrade_sankcije_obuka.Status where opis_statusa='Odobren')
  and hr_menadzer=@idMen)

  if @provera is null
      begin
    	   print 'Hr menadzer sa id-jem '+convert(varchar,@idMen) +' ne postoji u bazi.'
	  end
  else
    begin
  	 if @brojZ>0
	   begin
       print 'Hr menadzer sa id-jem '+convert(varchar,@idMen) +' je odobrio sledece zahteve za odsustvo:'
	   declare @rbZah as numeric(5)
	   declare @imeZap as varchar(20)
	   declare @prezZap as varchar(20)
	   declare @idZap as numeric(5)
	   declare @zahtev as varchar(50)
	   declare @prioritet as varchar(20)
	   declare @datumP as date
	   declare zahtev_kursor cursor for
	   select rb_zahteva_ods,zap.z_ime,zap.z_prezime,zap.id_zaposlenog,opis_tipa_zahteva_ods,Nagrade_sankcije_obuka.PrioritetFunkcija(rb_zahteva_ods),datum_poc_ods
	   from Nagrade_sankcije_obuka.Zaposleni zap join Nagrade_sankcije_obuka.Zahtev_za_odsustvo zah on zap.id_zaposlenog=zah.id_zaposlenog
       join Nagrade_sankcije_obuka.Tip_zahteva_za_odsustvo tn on zah.id_tip_zahteva_ods=tn.id_tip_zahteva_ods
       where hr_menadzer=@idMen and id_status=(select id_status from Nagrade_sankcije_obuka.Status where opis_statusa='Odobren')
	   open zahtev_kursor
	   fetch next from zahtev_kursor into @rbZah,@imeZap,@prezZap,@idZap,@zahtev,@prioritet,@datumP
	   while @@FETCH_STATUS=0
	   begin 

	     print 'Zaposlenom '+@imeZap+' '+@prezZap+' sa id-jem '+convert(varchar,@idZap)+
		 ' odobren je zahtev pod rednim brojem '+convert(varchar,@rbZah)+' ' +@zahtev+' prioriteta '+ 
		 @prioritet+' sa pocetkom od: '+convert(varchar,@datumP)

	     fetch next from zahtev_kursor into @rbZah,@imeZap,@prezZap,@idZap,@zahtev,@prioritet,@datumP
		 
		end
	   close zahtev_kursor
	   deallocate zahtev_kursor
	   print 'Hr menadzer sa id-jem '+convert(varchar,@idMen) +' je odobrio ukupno: '+convert(varchar,@brojZ)+' zahteva'
	 end
	else 
	begin
          print 'Hr menadzer sa id-jem '+convert(varchar,@idMen) +' jos uvek nije odobrio ni jedan zahtev.'
	end
  end
end	
go


exec Nagrade_sankcije_obuka.OdobreniZahteviZaOdst 12
exec Nagrade_sankcije_obuka.OdobreniZahteviZaOdst 13
exec Nagrade_sankcije_obuka.OdobreniZahteviZaOdst 125


if object_id('Nagrade_sankcije_obuka.PrioritetFunkcija')is not null
drop function Nagrade_sankcije_obuka.PrioritetFunkcija
go
create function Nagrade_sankcije_obuka.PrioritetFunkcija
(@rbzahtev as numeric(5))
returns varchar(20)
as
begin
 
declare @pr as varchar(20)
set @pr=(select
case 
when prioritet=1 then 'Urgentno'
when prioritet between 2 and 4 then 'Hitno'
when prioritet between 5 and 7 then 'Redovno'
when prioritet between 8 and 10 then 'Nizak prioritet'
when prioritet is null then  'Nepoznato' 
end as Prioritet
from Nagrade_sankcije_obuka.Zahtev_za_odsustvo 
where rb_zahteva_ods=@rbzahtev)
return @pr
end
go

 