-- Complément : doublons, identifiants et conversions de types.
-- Termine les points restés ouverts dans le diagnostic.
-- À exécuter après 03_nettoyage.sql, une seule fois.

BEGIN;

-- 1) Identifiants : retirer l'espace insécable (code 160) caché dans les identifiants
UPDATE usagers   SET id_usager   = REPLACE(id_usager,   CHR(160), ''),
                     id_vehicule = REPLACE(id_vehicule, CHR(160), '');
UPDATE vehicules SET id_vehicule = REPLACE(id_vehicule, CHR(160), '');

-- 2) Doublons : les 976 paires d'usagers sont identiques dans toutes les colonnes.
--    On garde une ligne par id_usager. (Contrôle : COUNT(*) - COUNT(DISTINCT id_usager) = 0 après suppression.)
DELETE FROM usagers a
USING usagers b
WHERE a.ctid > b.ctid
  AND a.id_usager = b.id_usager;

-- 3) Types : les identifiants deviennent des entiers, puis des clés primaires
ALTER TABLE usagers   ALTER COLUMN id_usager   TYPE BIGINT USING id_usager::BIGINT;
ALTER TABLE usagers   ALTER COLUMN id_vehicule TYPE BIGINT USING id_vehicule::BIGINT;
ALTER TABLE vehicules ALTER COLUMN id_vehicule TYPE BIGINT USING id_vehicule::BIGINT;

ALTER TABLE usagers   ADD PRIMARY KEY (id_usager);
ALTER TABLE vehicules ADD PRIMARY KEY (id_vehicule);

-- 4) Largeur de la chaussée (larrout) : texte avec virgule décimale et valeur -1 pour "non renseigné"
ALTER TABLE lieux
ALTER COLUMN larrout TYPE NUMERIC
USING NULLIF(REPLACE(TRIM(larrout), ',', '.'), '-1')::NUMERIC;

-- 5) Colonnes qu'on NE convertit PAS en entier, et pourquoi :
--    caracteristiques.com : les codes corses (2A004, 2B080...) contiennent des lettres (2 354 lignes)
--    usagers.actp         : codes avec lettres A et B (1 773 lignes)
--    lieux.pr, lieux.pr1  : valeur "(1)" (non renseigné) et -1 écrits avec un espace
--    -> à garder en texte, ou à recoder après décision métier

COMMIT;

-- Contrôles
SELECT COUNT(*) AS usagers_restants FROM usagers;                       -- 506886
SELECT COUNT(*) - COUNT(DISTINCT id_usager) AS doublons FROM usagers;   -- 0
SELECT COUNT(*) AS usagers_sans_vehicule
FROM usagers u LEFT JOIN vehicules v ON v.id_vehicule = u.id_vehicule
WHERE v.id_vehicule IS NULL;
