-- TP 1 : explorer la base des accidents corporels de la circulation (2021-2024). On observe et on compte, on ne corrige rien.

--PARTIE A:
select * from lieux limit 10;
select * from caracteristiques limit 10;
select * from usagers limit 10;
select * from vehicules limit 10;
-- quetions1 :
select * from caracteristiques limit 10;

-- questions 2: nombres totale d'accidents = 221044
select count(distinct num_acc) from caracteristiques;
select count(distinct num_acc) from lieux;
-- questions 3:
select count(*) from caracteristiques;
select count(*) from lieux;
select count(*) from usagers;
select count(*) from vehicules;

-- questions 4:
select distinct an from caracteristiques; -- 4 années : 2021, 2022, 2023, 2024

-- questions 5: departement distinct =107 departements
select count(distinct dep ) from caracteristiques;

--PARTIE B:
--questions b1: en 2024 IL YA EU 34010 ACCIDENTS
select count(*) from caracteristiques where an = 2024 and agg =2;

--questions b2: il ya eu 30075 ENTRE CES HEURES
select count(*) from caracteristiques where  hrmn >= '22:00:00' or hrmn <=  '06:00:00';

-- question b3:
select * from caracteristiques where adr like'%RUE%'; -- il en a 24755
select count(*) from caracteristiques where adr ilike'%rue%'; -- il en 48061 il ya plusieurs personnes qui n'ont pas bien ecrit l addresse

--question b4:  il ya 11137 usagers qui n'ont pas renseigné annee de naissance
select count(*) from usagers where an_nais is null;

-- questions b5:
select distinct sexe from usagers; -- il ya 1 2  ET -1

select count(*) from usagers where sexe = -1; -- il ya 10649 QUI n'ont pas renseigné de sexe

-- PARTIE C:
--questions c1: 2021= 56518, 2022=55302, 2023= 54822, 2024=54402 une baisse
select an,count(num_acc) from caracteristiques group by an;
--questionc2:
select count(*) num_acc, grav from usagers group by grav order by grav asc;

--questions c3:
select count(*) from usagers; -- ca donne 508162
select count(an_nais) from usagers; -- 497025 tout le na pas renseigné son année de naissance

--questionc4:
select avg(vma)from lieux; -- j'ai 55,78
select max(vma) from lieux; -- c'est 901
select min(vma) from lieux; -- cest -1
-- question c5: Paris (75), Seine-Saint-Denis (93) et Hauts-de-Seine (92) sont les départements avec le plus d'accidents
select dep, count(num_acc) as nombre_accidents
from caracteristiques 
group by dep
order by nombre_accidents desc limit 10;
-- questions c6: il a 8 en requete imbriqués  
select count(num_acc), dep from caracteristiques group by dep having count(*) > 5000;
--question c7:
select max(grav) from usagers; -- donne 4, mais 4 = blessé léger : le code le plus grand n'est pas le cas le plus grave

select count(*) from usagers where grav=2; -- 13730 tués

-- PARTIE D:
--question D1:
select caracteristiques.an, count(caracteristiques.num_acc)
from caracteristiques inner join usagers on caracteristiques.num_acc = usagers.num_acc
where grav = 2 
group by an;

-- questions D2:
select count(*) from caracteristiques; -- 221044

select count(*) from lieux inner join caracteristiques on caracteristiques.num_acc = lieux.num_acc; -- c'est 252928

-- questions D3: il ya 31515
select num_acc, count( num_acc) as nombre_accident from lieux group by num_acc having count(num_acc) >1 ;
-- il ya deux fois la meme id car l'accidents c'est fait sur le croissement de 2 rue on renseigne les deux rues et sa fait deux linges
select * from lieux where num_acc = '202300012066';
-- questions D4:
select * from usagers left join caracteristiques on caracteristiques.num_acc = usagers.num_acc
where caracteristiques.num_acc is null ;

-- PARTIE E: DIAGNOTIC
-- Constats à consigner dans la fiche de diagnostic :
-- lat et long sont stockées en texte (virgule décimale) : à convertir en numérique
-- commune (com) en entier
-- pr et pr1, larrout dans lieux : à convertir en numérique
-- id_usager et id_vehicule : à convertir en entier (ils contiennent des espaces insécables)
-- actp en entier
-- occutc dans vehicules : la colonne est presque vide (3348 valeurs renseignées sur 378071) : à signaler plutôt qu'à supprimer





