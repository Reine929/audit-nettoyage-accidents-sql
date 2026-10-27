-- TP doublons : repérer les doublons dans la table usagers.

-- PARTIE A:
-- questions A1:
select count(*) from usagers; -- 508162 lignes
select count(distinct id_usager) from usagers; -- 507186 id_usager distincts
-- 508162 - 507186 = 976 lignes en trop
-- questions A2: sa m'afiche sa fait 976 au total
select id_usager, count( id_usager) as les_id_usager from usagers group by id_usager having count(id_usager) >1 ;

-- questions A3:
--il en 976 il apparaissent tous deux fois
select id_usager, count( id_usager) as les_id_usager from usagers group by id_usager having count(id_usager) >2 ;

-- quastions A4:
select * from usagers where id_usager ='203 713';
select * from usagers where id_usager = '206 365';
select * from usagers where id_usager = '202 316';
-- les deux lignes de chaque paire sont identiques dans toutes les colonnes

-- PARTIE B (suppression des doublons) : à faire
