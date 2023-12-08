/*1.Aktivira se pri pokusaju unosa u tabelu Obavlja,
cija promena treba da rezultuje unosom/izmenom u tabelu Zaposleni.
Glavna svrha ovog trigera je da se zaposlenima, koji su uèestvovali u nekoj obuci i postigli
rezultate vece od 90 dodeli povecanje na platu (ili stavi nagradu) koja za zaposlene koji su projektni menadzeri iznosi 7000 NJ (novèanih jedinica),
za hr menadzere iznosi 5000NJ, a za obicne radnike 3000NJ. Tako se dalje u kodu deklariše kursor koji æe proæi kroz listu zaposlenih i uz odreðene uslove æe
dodeliti svakom zaposlenom koji je uèestvovao pomenutu sumu novca. Ispisuje se ime i prezime
zaposlenog, kao i zarada pre i posle uplate novca. Analogno ovom procesu, kreira se drugi kursor
koji æe na slièan naèin dodeliti i zaposlenima koji su uèestvovali u kupovini sumu novca koja je
propisana, a takoðe æe se na slièan naèin i njihova imena i prezimena ispisati, kao prethodna i
sadašnja zarada, nakon kupljene nekretnine*/

if object_id('Nagrade_sankcije_obuka.PlataTriger') is not null
drop trigger Nagrade_sankcije_obuka.PlataTriger
go
create trigger Nagrade_sankcije_obuka.PlataTriger
on Nagrade_sankcije_obuka.Obavlja
instead of insert 
as 
begin
if @@ROWCOUNT=0
return;
declare @postignutiRez as numeric(3)=(select postignuti_rez from inserted)
declare @idZap as numeric=(select id_zaposlenog from inserted)
declare @idTipO as numeric(5)=(select id_tip_obuke from inserted)
declare @rbObuke as numeric(5)=(select rb_obuke from inserted) 
declare @imeZ as varchar(20)
declare @prezZ as varchar(20)
declare @plata as numeric(30)
if @postignutiRez > =90
begin 
      declare curosor_plata cursor for
	  select zap.id_zaposlenog,z_ime,z_prezime,z_plt,postignuti_rez
	  from Nagrade_sankcije_obuka.Zaposleni zap join Nagrade_sankcije_obuka.Obavlja
	  obv on zap.id_zaposlenog=obv.id_zaposlenog 
	  where rb_obuke=1 and zap.id_zaposlenog=@idZap

	  open curosor_plata

	  fetch next from curosor_plata into @idZap,@imeZ,@prezZ,@plata,@postignutiRez

	  while @@FETCH_STATUS=0
	  begin
	   if (@idZap=(select projektni_menadzer from 
	   Nagrade_sankcije_obuka.Projektni_menadzer where projektni_menadzer=@idZap))
	    begin 
		  update Nagrade_sankcije_obuka.Zaposleni
		  set z_plt=z_plt+7000
		  where id_zaposlenog=@idZap
		 end 
		 else if (@idZap=(select hr_menadzer from 
	     Nagrade_sankcije_obuka.Hr_menadzer where hr_menadzer=@idZap))
	    begin 
		  update Nagrade_sankcije_obuka.Zaposleni
		  set z_plt=z_plt+5000
		  where id_zaposlenog=@idZap

		  insert into Nagrade_sankcije_obuka.Obavlja(postignuti_rez,id_zaposlenog,id_tip_obuke,rb_obuke)
          values(@postignutiRez,@idZap,@idTipO,@rbObuke);
		 end
		 else if (@idZap !=(select radnik from 
	     Nagrade_sankcije_obuka.Radnik where radnik=@idZap))
		 begin
		 update Nagrade_sankcije_obuka.Zaposleni
		  set z_plt=z_plt+3000
		  where id_zaposlenog=@idZap
		  insert into Nagrade_sankcije_obuka.Obavlja(postignuti_rez,id_zaposlenog,id_tip_obuke,rb_obuke)
          values(@postignutiRez, @idZap,@idTipO,@rbObuke);
		  end

		 declare @novaPltr as numeric(10) =(select z_plt from Nagrade_sankcije_obuka.Zaposleni
		 where id_zaposlenog=@idZap)
		 print (@imeZ+' '+@prezZ+', zarada pre izmene:'+try_cast(@plata as varchar)
		 +', zarada posle izmene:'+try_cast(@novaPltr as varchar))

		 fetch next from curosor_plata into @idZap,@imeZ,@prezZ,@plata,@postignutiRez

		 end
close curosor_plata
deallocate curosor_plata
end
else
print 'Postignuti rezultati su manji od 90, nema promene plate.'
insert into Nagrade_sankcije_obuka.Obavlja(postignuti_rez,id_zaposlenog,id_tip_obuke,rb_obuke)
values(@postignutiRez,@idZap,@idTipO,@rbObuke);
end
go

insert into Nagrade_sankcije_obuka.Obavlja(postignuti_rez,id_zaposlenog,id_tip_obuke,rb_obuke)
values(90,20,1,13);

insert into Nagrade_sankcije_obuka.Obavlja(postignuti_rez,id_zaposlenog,id_tip_obuke,rb_obuke)
values(70,20,1,14);

select * from Nagrade_sankcije_obuka.obavlja



/*2.Triger signalizira gresku (i time sprecava insert) ukoliko je ukupan broj evidentranih 
zahteva za odsustvo jednog zaposlenog veæi od 5.*/

 if object_id('Nagrade_sankcije_obuka.ZahtevTriger') is not null
 drop trigger Nagrade_sankcije_obuka.ZahtevTriger
 go
 create trigger Nagrade_sankcije_obuka.ZahtevTriger
 on Nagrade_sankcije_obuka.Zahtev_za_odsustvo
 instead of insert
 as
 begin
 if @@ROWCOUNT=0
 return;
 declare @idZap as numeric(5)=(select id_zaposlenog from inserted)
 declare @datumP as date=(select datum_poc_ods from inserted)
 declare @datumZ as date=(select datum_zav_ods from inserted)
 declare @prioritet as numeric(2)=(select prioritet from inserted)
 declare @status as numeric(5)=(select id_status from inserted)
 declare @tipZ as numeric(5)=(select id_tip_zahteva_ods from inserted)
 declare @hrM as numeric(5)=(select hr_menadzer from inserted)

 
 declare @brZahteva as numeric(5)=(select count(rb_zahteva_ods) from Nagrade_sankcije_obuka.Zahtev_za_odsustvo
 where id_zaposlenog=@idZap)
 if @brZahteva >5
 begin
    declare @msg as varchar(100)
	set @msg=formatmessage('Zaposleni sa id-jem  '+convert(varchar,@idZap)
	+' ima vise od 5 zahteva za odsustvo, ne moze mu se dodeliti novo.')
	raiserror(@msg,16,0)
 end
 else
 begin
 print 'Zaposleni sa id-jem '+convert(varchar,@idZap)+' ima manje od 5 zahteva za odsustvo moze mu se uneti novi.'
insert into Nagrade_sankcije_obuka.Zahtev_za_odsustvo(datum_poc_ods,datum_zav_ods,prioritet,id_zaposlenog,id_status,id_tip_zahteva_ods,hr_menadzer)
values(@datumP,@datumZ,@prioritet,@idZap,@status,@tipZ,@hrM)
end
 end
go

 select * from Nagrade_sankcije_obuka.Zahtev_za_odsustvo
  insert into Nagrade_sankcije_obuka.Zahtev_za_odsustvo(datum_poc_ods,datum_zav_ods,prioritet,id_zaposlenog,id_status,id_tip_zahteva_ods,hr_menadzer)
values('2022-1-25',dateadd(week,3, '2022-12-25'),1,2,1,1,13);
  insert into Nagrade_sankcije_obuka.Zahtev_za_odsustvo(datum_poc_ods,datum_zav_ods,prioritet,id_zaposlenog,id_status,id_tip_zahteva_ods,hr_menadzer)
values('2022-12-25',dateadd(week,3, '2022-12-25'),1,1,1,1,13);




