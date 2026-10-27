# Audit et nettoyage d'une base d'accidents de la route (SQL, PostgreSQL)

TP réalisé en binôme avec une camarade de classe, pendant mon Bachelor Business Intelligence & Data à Nexa Digital School.

## Contexte

Les accidents corporels de la circulation routière en France (2021 à 2024) étaient exploités dans des fichiers Excel devenus trop lourds. Les données ont été importées telles quelles dans PostgreSQL : l'objectif était de les **explorer, d'identifier les problèmes de qualité, puis de les corriger**.

La base contient 4 tables liées par `num_acc` (le numéro d'accident) :

| Table | Une ligne = | Nombre de lignes |
| --- | --- | --- |
| `caracteristiques` | un accident | 221 044 |
| `lieux` | le lieu de l'accident | 252 928 |
| `vehicules` | un véhicule impliqué | 378 071 |
| `usagers` | une personne impliquée | 508 162 |

## Fichiers

| Fichier | Contenu |
| --- | --- |
| `01_exploration.sql` | Exploration de la base : comptages, filtres, regroupements, jointures (sans rien corriger) |
| `02_doublons.sql` | Repérage des doublons dans la table `usagers` |
| `03_nettoyage.sql` | Nettoyage : valeurs manquantes, formats, valeurs aberrantes, lignes orphelines |
| `04_complement_doublons_et_types.sql` | Complément : identifiants, suppression des doublons, conversions de types |

## Fiche de diagnostic

Les problèmes sont classés selon les 4 piliers de la qualité des données : complétude, consistance, unicité, validité.

| Pilier | Table | Colonne | Problème constaté | Lignes | Décision |
| --- | --- | --- | --- | --- | --- |
| Complétude | usagers | sexe | Valeurs manquantes codées `-1`, invisibles avec `IS NULL` | 10 649 | corrigé : `-1` remplacé par `NULL` |
| Complétude | usagers | grav | Valeur `-1` absente de la nomenclature (1 à 4) | 419 | corrigé : `NULL` |
| Complétude | usagers | an_nais | Année de naissance non renseignée | 11 137 | signalé |
| Complétude | lieux | v2 | Manquants écrits `null`, `N/A` ou vides | 230 883 | corrigé : `NULL` (22 045 valeurs renseignées) |
| Complétude | vehicules | occutc | Colonne presque vide | 374 723 sur 378 071 | signalé |
| Consistance | caracteristiques | adr | Casse et espaces incohérents (24 755 résultats avec `LIKE '%RUE%'`, 48 061 avec `ILIKE`) | 221 044 | corrigé : `TRIM` et `INITCAP` |
| Consistance | caracteristiques | lat, long | Coordonnées stockées en texte avec une virgule décimale | 221 044 | corrigé : conversion en numérique |
| Consistance | usagers | id_usager | Espace insécable (code 160) au milieu de l'identifiant | 507 862 | corrigé dans `04_complement_doublons_et_types.sql` |
| Unicité | usagers | id_usager | Identifiants présents deux fois, lignes identiques | 976 | supprimé dans `04_complement_doublons_et_types.sql` (506 886 usagers restants) |
| Unicité | lieux | num_acc | Un accident apparaît sur plusieurs lignes quand il a lieu à un carrefour (deux voies) | 31 515 accidents | conservé, normal : compter les accidents avec `COUNT(DISTINCT num_acc)` |
| Validité | lieux | vma | Vitesse maximale autorisée de -1 à 901 km/h ; 4 367 valeurs hors des bornes IQR, 64 supérieures à 130 | 4 367 | signalé : décision métier |
| Validité | usagers | num_acc | Usagers rattachés à un accident qui n'existe pas | 300 | supprimé |

## Ce que j'ai retenu

- Les valeurs manquantes se cachent souvent derrière des codes (`-1`, `N/A`, `null`) : `IS NULL` ne suffit pas.
- Compter après une jointure peut gonfler les résultats : la table `lieux` compte 252 928 lignes pour 221 044 accidents.
- `MAX(grav)` ne donne pas le cas le plus grave : les codes sont des catégories, pas une échelle (4 = blessé léger, 2 = tué).
- Face à une valeur aberrante, on ne corrige que si on connaît la bonne valeur : sinon on la signale. Les coordonnées extrêmes ne sont d'ailleurs pas des erreurs : elles correspondent à l'outre-mer français.

## Limites et suite

- Les colonnes `com` (codes corses comme `2A004`), `actp` (codes `A` et `B`) et `pr` / `pr1` (valeur `(1)`) ne peuvent pas être converties en entier sans perdre de l'information : elles restent en texte, en attendant une décision métier. Cette conclusion remplace l'idée de départ du diagnostic, qui prévoyait de les convertir.
- La colonne `occutc` est signalée comme presque vide et n'est pas supprimée.
- Le complément (fichier 04) a été écrit après le TP et testé sur la base complète.

## Lancer le projet

1. Restaurer la base d'accidents dans PostgreSQL (fournie en cours, non incluse dans ce dépôt).
2. Exécuter dans l'ordre : `01_exploration.sql`, `02_doublons.sql`, `03_nettoyage.sql`, puis `04_complement_doublons_et_types.sql` (une seule fois).

## Outils

SQL, PostgreSQL : agrégations, jointures, quartiles avec `percentile_cont`, `CASE WHEN`, conversion de types.
