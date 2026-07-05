---
description: Lance la routine Loc-Hunt (recherche de location Monaco / Côte d'Azur) — collecte les annonces, met à jour le tableur, rédige les messages de contact et envoie le récapitulatif par email.
argument-hint: "[matin|soir] (optionnel — sinon déduit de l'heure)"
---

Tu exécutes la routine **Loc-Hunt** de recherche de location (secteur Monaco / Côte d'Azur).
Aucun humain n'est présent : va au bout de TOUTES les étapes, sans poser de question.

## 1. Configuration
Lis d'abord le fichier `config.md` à la racine du projet (outil Read).
S'il est **absent ou vide**, ARRÊTE et affiche exactement :
« ⚠️ config.md manquant — copiez `config.example.md` vers `config.md` et remplissez-le, puis relancez /loc-hunt. »

## 2. Créneau & mode
- Créneau de ce run : `$ARGUMENTS` (matin ou soir). Si vide, déduis-le de l'heure locale (avant 14 h = matin, sinon soir).
- Applique le `MODE_RECHERCHE` défini dans `config.md` (`email` recommandé, ou `navigateur`).

## 3. Exécution
Suis **à la lettre** les instructions opérationnelles de la skill ci-dessous, en remplaçant chaque
`[PLACEHOLDER]` par la valeur correspondante lue dans `config.md` :

@skill.md

## 4. Critères de réussite (rappel)
- Tableur `Logements` mis à jour : aucun doublon d'URL, aucun studio/T1, aucun saisonnier, rien dans les zones à éviter (Ariane).
- Fichiers de contact `.txt` enregistrés pour chaque annonce HIGH.
- Email récapitulatif envoyé (TOUJOURS, même si zéro nouvelle annonce).
