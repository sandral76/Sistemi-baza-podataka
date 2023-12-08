/*1.Izlistati proseèan iznos sankcija 
za zaposlene koji žive u Trebinju i Beogradu.*/
select avg(prosek) as 'Prosecan iznos sankcija' 
from (select id_zaposlenog, sum(try_cast(iznos_sankcije as int)) as prosek
from Nagrade_sankcije_obuka.Sankcija san join 
Nagrade_sankcije_obuka.Tip_sankcije tsan on san.id_tip_sankcije=tsan.id_tip_sankcije
group by id_zaposlenog) as NovaTab
where id_zaposlenog 
in(select id_zaposlenog from Nagrade_sankcije_obuka.Zaposleni where z_grad='Trebinje' or z_grad='Beograd')


/*2.Izlistati proseèan broj bodova postignutih rezultata po seminaru kao i celokupan rezultat jednog seminara,
prebrojati koliko zaposlenih je bilo na tim seminarima koji su trajali od 22-10-2021 do 15-11-2021.
Ispis sortirati po proseènoj oceni od najbolje do najlošije postignutih ukupnih proseènih rezultata.*/ 
select obv.rb_obuke as 'Redni broj obuke',BrojZap as 'Broj zaposlenih na seminaru',UkupniRez/BrojZap as 'Prosek ostvarenog rezultata',UkupniRez as 'Ukupan rezultat celog tima'
from Nagrade_sankcije_obuka.Obavlja obv join
((select ob.rb_obuke,count(id_zaposlenog) BrojZap,sum(postignuti_rez) UkupniRez  from Nagrade_sankcije_obuka.Obuka ob join Nagrade_sankcije_obuka.Obavlja obv
on ob.rb_obuke=obv.rb_obuke where datum_poc_obuke='2021-10-22' group by ob.rb_obuke)union
(select ob.rb_obuke,count(id_zaposlenog) BrojZap, sum(postignuti_rez) UkupniRez from  Nagrade_sankcije_obuka.Obuka ob join Nagrade_sankcije_obuka.Obavlja obv
on ob.rb_obuke=obv.rb_obuke where datum_zav_obuke='2021-11-15' 
group by ob.rb_obuke)) novaT on novaT.rb_obuke=obv.rb_obuke 
group by obv.rb_obuke,BrojZap,UkupniRez
order by UkupniRez/BrojZap desc

/*3.Za radnike iz Novog Sada koji imaju platu veæu od proseène plate svih radnika koji su podneli zahtev za odsustvo,
izdvojiti podatke o njihovom imenu, prezimenu, id-u,  
i ispisati opisno po prioritetima zahteva  kao i njihov status.
Opis prioriteta zahteva moze da ima vrednost:
- 'Hitno' – za zahtev èiji je prioritet 1
- 'Urgentno' – za zahtev èiji je prioritet izmeðu 2. i 4
- 'Redovno' – za zahtev èiji je prioritet izmeðu 5 i 7
- 'Nizak prioritet' – za zahtev èiji je prioritet izmeðu 8 i 10
- 'Nepoznato' – za zahtev èiji je prioritet nepoznat.*/
select z_ime as Ime, z_prezime as Prezime, zap.id_zaposlenog as "ID zaposlenog", opis_tipa_zahteva_ods as 
"Tip zahteva za odsustvo",opis_statusa as Status,
((select 'Urgentno' where prioritet=1)union (select 'Hitno' where prioritet between 2 and 4)
union (select 'Redovno' where prioritet between 5 and 7)union (select 'Nizak prioritet' where prioritet between 8 and 10)union (select 'Nepoznato' where prioritet is null)) as Prioritet
from Nagrade_sankcije_obuka.Zaposleni zap join Nagrade_sankcije_obuka.Zahtev_za_odsustvo zah 
on zap.id_zaposlenog=zah.id_zaposlenog join Nagrade_sankcije_obuka.Tip_zahteva_za_odsustvo tzah
on zah.id_tip_zahteva_ods=tzah.id_tip_zahteva_ods join Nagrade_sankcije_obuka.Status stat on zah.id_status=stat.id_status
where z_grad='Novi Sad' and z_plt>(select avg(z_plt) from Nagrade_sankcije_obuka.Zaposleni)
group by z_ime,z_prezime,zap.id_zaposlenog,opis_tipa_zahteva_ods,prioritet,opis_statusa,z_plt





/* 4.Prikazati zaposlene kojima ime poèinje karakterima ’A’, ’S’ ili ’M’, sa mestom
stanovanja u Novom Sadu ili Beogradu. Podaci koji su prikazani su: ime, kontakt telefon, mesto i adresa
zaposlenog. Takoðe, u okviru kolone Nagrade je prikazano da li je zaposleni dobio nagradu u poslednjih 6 godina,
i ako jeste prikazaæe se tip i vrsta nagrade i datum kada je dobijena nagrada, 
a ukoliko nije ispisati poruku "Nema nagrade". Vrsta nagrade treba da bude ispisana kao:
- 'INDIVIUDALNA' – za nagrade èija je vrsta oznaèena sa i
- 'GRUPNA ' – za nagrade èija je vrsta oznaèena sa g
- 'ORGANIZACIONA' – za nagrade èija je vrsta oznaèena sa o
Izlistati samo one zaposlene koji zaraðuju manje od nekog drugog zaposlenog koji je hr menadžer.
*/

select z_ime as Ime, z_broj_tel as 'Kontakt telefon',z_grad as Grad, z_adresa as Adresa,
iif(opis_tipa_nagrade is not null,
replace(LEFT(opis_tipa_nagrade, CHARINDEX('-', opis_tipa_nagrade)),'-',' '),'Nema nagrade') 
as Nagrade ,datum_dobijanja_nagrade as 'Datum dobijanja nagrade',
case 
when vrsta='i' then 'INDIVIDUALNA'
when vrsta='o' then 'ORGANIZACIONA'
when vrsta='g' then 'GRUPNA'
end as Vrsta
from  Nagrade_sankcije_obuka.Zaposleni zap join Nagrade_sankcije_obuka.Nagrada nag on zap.id_zaposlenog=nag.id_zaposlenog 
join Nagrade_sankcije_obuka.Tip_nagrade tn on nag.id_tip_nagrade=tn.id_tip_nagrade 
where z_grad in('Novi Sad','Beograd') and (z_ime like 'A%' or z_ime like'S%' or z_ime like'M%')
and (year(datum_dobijanja_nagrade) between year(getDate())-6 and year(getDate())) and (z_plt<any(select z_plt
from Nagrade_sankcije_obuka.Zaposleni zap 
join Nagrade_sankcije_obuka.Hr_menadzer hrm on zap.id_zaposlenog=hrm.hr_menadzer))


/*5.Izlistati id zaposlenog,ime, godinu zaposlenja, radni staž za 
najbolje plaæene radnike medju hr menadžerima i projektnim menadžerima 
koji su osvojili neku od indirektnih nagrada, kao i podatke o tim nagradama, srazmerno rastuæuj plati.*/
select zap.id_zaposlenog as 'Id zaposlenog',z_ime as Ime, year(zap.z_datum_zap) as 'Godina zaposlenja', concat(DATEDIFF(year,z_datum_zap,getDate()),'g.')  as 'Radni staz',
replace(LEFT(opis_tipa_nagrade, CHARINDEX('-', opis_tipa_nagrade)),'-',' ') as Nagrada,oznaka as 'Oznaka nagrade',maxPlt as 'Najveca plata'
from Nagrade_sankcije_obuka.Zaposleni zap join  Nagrade_sankcije_obuka.Nagrada nag on zap.id_zaposlenog=nag.id_zaposlenog join Nagrade_sankcije_obuka.Tip_nagrade tn on
nag.id_tip_nagrade=tn.id_tip_nagrade join
((select nag.id_tip_nagrade,max(zap.z_plt) as maxplt
from Nagrade_sankcije_obuka.Nagrada nag join 
 Nagrade_sankcije_obuka.Hr_menadzer hrm on nag.id_zaposlenog=hrm.hr_menadzer join Nagrade_sankcije_obuka.Zaposleni zap on zap.id_zaposlenog=hrm.hr_menadzer
 join  Nagrade_sankcije_obuka.Tip_nagrade tn on nag.id_tip_nagrade=tn.id_tip_nagrade
where oznaka='indirektna'
group by nag.id_tip_nagrade
)
union
(select nag.id_tip_nagrade,max(zap.z_plt) as maxPlt
from Nagrade_sankcije_obuka.Nagrada nag join 
 Nagrade_sankcije_obuka.Projektni_menadzer prm on nag.id_zaposlenog=prm.projektni_menadzer join Nagrade_sankcije_obuka.Zaposleni zap on zap.id_zaposlenog=prm.projektni_menadzer
 join  Nagrade_sankcije_obuka.Tip_nagrade tn on nag.id_tip_nagrade=tn.id_tip_nagrade
 where oznaka='indirektna'
group by nag.id_tip_nagrade
)) maxPlata on nag.id_tip_nagrade=maxplata.id_tip_nagrade
where zap.z_plt=maxPlt
order by z_plt
