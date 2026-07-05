# Tableur de suivi — Schéma

La skill lit et écrit un unique fichier `.xlsx` avec une feuille.

## Emplacement

```
[DOSSIER_RECHERCHE]/loc_hunt.xlsx
```

Définissez `DOSSIER_RECHERCHE` dans `config.md`. La skill crée le fichier au premier run s'il n'existe pas
(ou utilisez `scripts/creer_tracker.py`).

---

## Feuille : `Logements`

| Colonne | Type | Notes |
|---|---|---|
| Titre | Texte | Titre de l'annonce |
| Plateforme | Texte | LeBonCoin / PAP / SeLoger / Bien'ici / Logic-Immo / Jinka |
| URL | Lien | URL complète — sert à la déduplication |
| Commune | Texte | Beausoleil, Menton, Cap-d'Ail… |
| Code postal | Texte | ex. 06240 |
| Loyer CC (€) | Nombre | Loyer mensuel charges comprises |
| Charges comprises | Oui/Non/Inconnu | |
| Surface (m²) | Nombre | |
| Type | Texte | T2 / T3 / etc. (2 pièces et plus) |
| Meublé | Oui/Non/Inconnu | |
| Disponible le | Date | Date de disponibilité |
| DPE | Texte | A–G si affiché |
| Contact | Texte | Agence / particulier + téléphone si visible |
| Notes | Texte | Détails divers (ex. « vérifier montant des charges ») |
| Statut | Texte | Voir valeurs ci-dessous |
| Priorité | Texte | High / Medium / Low |
| Trouvé le | Date | Date d'ajout de la ligne |

### Valeurs de statut

| Statut | Signification |
|---|---|
| `NOUVEAU 🔴` | Vient d'être trouvé, pas encore contacté |
| `À contacter` | Présélectionné, prêt à contacter |
| `Contacté` | Message envoyé |
| `Visite prévue` | Visite confirmée |
| `Visité` | Visite effectuée |
| `Dossier envoyé` | Dossier de candidature transmis |
| `Refusé` | Non retenu / déjà loué |
| `Signé ✅` | Bail signé — terminé |

### Couleurs de ligne

| Priorité | Couleur | Hex |
|---|---|---|
| High | Vert | `E2EFDA` |
| Medium | Jaune | `FFFFC7` |
| Low | Rouge/orange | `FCE4D6` |

---

## Mise en forme appliquée par la skill

- Ligne d'en-tête : fond bleu foncé (`1F3864`), texte blanc gras
- Ligne 1 figée (l'en-tête reste visible au défilement)
- Filtre automatique activé sur toutes les colonnes
- URLs écrites comme liens cliquables
- Largeurs de colonnes ajustées (Titre large, URL large, etc.)

---

## Déduplication

Au début de chaque run, la skill charge toutes les valeurs de la colonne `URL` dans un `set` Python.
Toute nouvelle annonce dont l'URL existe déjà est ignorée silencieusement. Chaque run est ainsi **idempotent** —
relançable autant de fois que voulu sans créer de doublon.

---

## Création manuelle (optionnel)

```bash
pip install openpyxl
python3 scripts/creer_tracker.py
```

Voir `scripts/creer_tracker.py` pour le détail (colonnes, en-tête, feuille figée, filtre auto).
