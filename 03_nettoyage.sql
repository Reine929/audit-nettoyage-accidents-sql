-- TP nettoyage de la base des accidents (réalisé en binôme).
-- À exécuter une seule fois sur une base fraîchement restaurée.

-- partie A : valeurs manquantes codées autrement que par NULL
 -- questions A1:
update usagers set sexe = nullif(sexe, '-1');

-- questionsA2: la reponse cest 10649.
select count(*) from usagers where sexe is null;

-- questionsA3:
update usagers set grav =  nullif(grav,'-1');
select count(*) from usagers where grav is null; -- ca donne bien 419

-- questions A4:
update lieux set v2= nullif(nullif(nullif(v2,'null'),'N/A'),'');

-- questions A5: et on a 22045 non null cest a dire renseigné
select count(*) from lieux where v2 is not null; -- ca me donne 230883 comme valeur null

-- PARTIE B : cohérence des écritures et des types
--questions B1:
update caracteristiques set adr = trim(adr);

update caracteristiques set adr = initcap(adr);
-- questions B2:
select adr from caracteristiques limit 10;
-- questions B3: 
select replace(id_usager,'','') from usagers limit 5; --ca change rien 

select ascii(substring(id_usager,4,1)) from usagers limit 1; -- ca donne 160 comme code

select replace(id_usager,chr(160),'') from usagers limit 5; -- la ca marche

--questionsB4:
alter table caracteristiques 
alter column lat type numeric using replace(trim(lat),',','.')::numeric;

alter table caracteristiques 
alter column long type numeric using replace(trim(long),',','.')::numeric;

-- pour voir le min et max 
select max(lat) from caracteristiques; -- on a 51.0787
select min (lat) from caracteristiques; -- ON A -23.3950
select max (long) from caracteristiques; -- ON A 168.1065
select min (long) from caracteristiques; -- on a -178.09438700

-- pour long: les coordonnees sont vraimment france
select long, lat from caracteristiques where long =168.1065490000; -- on a lat = -21.5814460000

select long, lat from caracteristiques where long =-178.09438700;-- on a lat= -14.29312100
-- pour lat
select long, lat from caracteristiques where lat =51.07874000; -- on a long= 2.51487700
select long, lat from caracteristiques where lat =-23.3950900000; -- on a long = -149.4722020000

-- PARTIE C : valeurs aberrantes (méthode IQR sur la vitesse maximale autorisée)
-- questionsC1: Q1 = 50 et Q3 = 80
with quartiles as(
SELECT percentile_cont(0.25) WITHIN GROUP (ORDER BY vma) AS q1,
       percentile_cont(0.75) WITHIN GROUP (ORDER BY vma) AS q3
FROM lieux
WHERE vma > 0)
-- questions C2: Q1 = 50 et Q3 = 80, donc IQR = 80 - 50 = 30
SELECT vma
FROM lieux
WHERE vma < (SELECT q1 - 1.5 * (q3 - q1) FROM quartiles)
OR vma > (SELECT q3 + 1.5 * (q3 - q1) FROM quartiles);

 -- questions C3: 
 WITH quartiles AS (
    SELECT percentile_cont(0.25) WITHIN GROUP (ORDER BY vma) AS q1,
       percentile_cont(0.75) WITHIN GROUP (ORDER BY vma) AS q3
	FROM lieux WHERE vma > 0
)
SELECT count(*) FROM lieux
WHERE vma > 0
  AND vma NOT BETWEEN (SELECT q1 - 1.5*(q3-q1) FROM quartiles)
                  AND (SELECT q3 + 1.5*(q3-q1) FROM quartiles);
-- on a 4367 en dehors des bornes
-- questions C4:
SELECT vma, count(*) FROM lieux
WHERE vma > 125
GROUP BY vma ORDER BY vma;-- elles ne sont pas toutes abberrantes

-- questionsC5:
 select COUNT(*) from lieux where vma > 130;-- il en a 64 quand on se base sur le code de la route
 select count(*) from lieux where vma <15; -- il ya 10628 inferieur a 15;

-- question C6: pour les outliers je decides de les signalez. c'est des valeurs qui necessite les connaissances metiers
--par contre pour une analyse statisques il faut faire une copie de la colonne de la colonne la modifier et travailler dessus
-- PARTIE D : transformer les codes en libellés
-- questionsD1:
SELECT CASE grav
         WHEN 1 THEN 'Indemne'
         WHEN 2 THEN 'Tué'
         when 3 then 'blesse hospitalise'
		 when 4 then 'blesse leger'
		 else null
       END AS gravite,
       count(*)
FROM usagers
GROUP BY gravite
ORDER BY count(*) DESC;
-- question D2:
select case agg
   when 1 then 'hors agglomeration'
   when 2 then 'en agglomeration'
   else null
   END AS agglomere,
   count(*)
   from caracteristiques group by agglomere order by  count(*) desc;


-- question D3: sa marche autre=404909 deux-roues=64954, pieton=38069
select case 
     when catu = 3 then 'pieton'
	 when catv between 30 AND 34  then 'deux-roues'
	 else 'autre'
	 end as type_usagers, count(*) from vehicules as u left join usagers as v on u.id_vehicule=v.id_vehicule 
	 group by type_usagers order by count(*) desc; 


-- PARTIE E : cohérence entre les tables (usagers rattachés à un accident inexistant)
-- question E1:
select * from usagers left join caracteristiques on caracteristiques.num_acc = usagers.num_acc
where caracteristiques.num_acc is null ; -- ca fait bien 300

DELETE FROM usagers u
WHERE NOT EXISTS (
    SELECT 1 FROM caracteristiques c WHERE c.num_acc = u.num_acc
); -- apres ca ca fait bien zero

 -- questionE2: jai verifier il ya zero
 select * from usagers left join caracteristiques on caracteristiques.num_acc = usagers.num_acc
where caracteristiques.num_acc is null ; -- ca fait bien bien zero
