# Loc-Hunt — Configuration personnelle

> Copiez ce fichier vers `config.md` et remplissez vos informations.
> `config.md` est ignoré par git — vos données personnelles restent en local.
>
> Les valeurs ci-dessous sont **pré-remplies pour une recherche « logement entier, ≤ 1 500 € CC,
> secteur Monaco / Côte d'Azur »**. Ajustez ce qui doit l'être (surtout la section « Vous »).

---

## Vous

```
VOTRE_NOM=Prénom NOM
VOTRE_AGE=30
VOTRE_PROFESSION=votre métier
VOTRE_PROFIL=sérieux(se), non-fumeur, sans animaux, dossier complet
VOTRE_TELEPHONE=+33 6 00 00 00 00
```

## Votre dossier locataire (essentiel sur la Côte d'Azur — marché très tendu)

Ces éléments servent à rédiger des messages de contact qui rassurent tout de suite le bailleur/l'agence.

```
TYPE_CONTRAT=CDI
REVENUS_MENSUELS_NET=3500
GARANT=oui (parent, CDI) / Visale / aucun
DOSSIER_PRET=oui — pièces d'identité, 3 derniers bulletins, avis d'imposition, justif. domicile
```

> Règle usuelle des bailleurs : revenus ≈ 3× le loyer. Pour 1 500 € de loyer → ~4 500 € de revenus
> (garant ou dispositif **Visale** si en dessous). Le message de contact mentionnera ces points.

## Zones cibles

Les zones **prioritaires** = communes limitrophes de Monaco (idéal si vous travaillez à Monaco).
Les zones **secondaires** = le reste du littoral demandé. Réordonnez selon vos besoins.

```
ZONES_PRIORITAIRES=Beausoleil (06240), Cap-d'Ail (06320), Roquebrune-Cap-Martin (06190), La Turbie (06320), Monaco (98000)
ZONES_SECONDAIRES=Menton (06500), Èze (06360), Villefranche-sur-Mer (06230), Beaulieu-sur-Mer (06310), La Trinité (06340)
```

> ⚠️ **Monaco (98000)** : loyers très élevés — un logement entier < 1 500 € y est quasi introuvable.
> Il reste dans la liste au cas où, mais l'essentiel des résultats viendra des communes françaises limitrophes.

## Budget

```
LOYER_MAX=1500          # charges comprises (CC)
LOYER_MAX_HORS_CHARGES=1400   # si le loyer est affiché hors charges
```

## Type de logement

```
TYPE_LOGEMENT=entier                 # logement entier (pas de colocation)
TYPES_BIEN=studio, T1, T2            # appartement entier ; ajoutez « maison » si voulu
MEUBLE=indifférent                   # meublé ET non meublé
DUREE=longue durée (location à l'année)   # EXCLURE saisonnier / vacances / courte durée
```

## Dates

```
EMMENAGEMENT=Dès que possible
```

## Email (récapitulatif)

```
VOTRE_EMAIL=jfds.cie@gmail.com
GMAIL_ACCOUNT_INDEX=0
```

`GMAIL_ACCOUNT_INDEX` : index du compte utilisé par le connecteur Gmail MCP.
- `0` = premier compte Google connecté
- `1` = deuxième compte (si votre email de recherche diffère du compte principal)

## Dossier de travail (chemins)

```
DOSSIER_RECHERCHE=~/loc-hunt-cote-azur
```

La skill va :
- lire/écrire `$DOSSIER_RECHERCHE/loc_hunt.xlsx`
- enregistrer les messages de contact dans `$DOSSIER_RECHERCHE/outreach/`

Créez le dossier avant le premier lancement :
```bash
mkdir -p ~/loc-hunt-cote-azur/outreach
```

---

## URLs de recherche par plateforme

> Ce sont des **points de départ**. Au lancement, la skill (via l'automatisation navigateur)
> ouvre chaque plateforme, applique les filtres, trie par **date (plus récent d'abord)**, puis relève les annonces.
> Vous pouvez régénérer une URL en la construisant depuis le site puis en la collant ici.

### LeBonCoin (leboncoin.fr) — la plus complète, particuliers + agences

`category=10` = Locations · `real_estate_type=1,2` = maison+appartement · `price=min-1500` · `locations=Commune_CodePostal`

```
LBC_URL=https://www.leboncoin.fr/recherche?category=10&real_estate_type=1,2&price=min-1500&locations=Beausoleil_06240,Cap-d'Ail_06320,La-Turbie_06320,Roquebrune-Cap-Martin_06190,Villefranche-sur-Mer_06230,Beaulieu-sur-Mer_06310,Èze_06360,Menton_06500,La-Trinité_06340
```

### PAP (pap.fr) — de particulier à particulier (sans frais d'agence)

Base : `https://www.pap.fr/annonce/locations` → filtrer par communes + loyer max 1 500 €.
```
PAP_URL=https://www.pap.fr/annonce/locations-menton-06500-g43769-1500?geo_objets_ids=... (à finaliser depuis le site : saisir chaque commune, prix max 1500)
```

### SeLoger (seloger.com) — agences

Base : `https://www.seloger.com/immobilier/locations/` → communes + budget 1 500 € + type appartement.
```
SELOGER_URL=https://www.seloger.com/immobilier/locations/nice/  # ⚠️ protection anti-bot forte : la skill navigue lentement, filtre à la main
```

### Bien'ici (bienici.com) — agences + particuliers, bonne carte

Base : `https://www.bienici.com/recherche/location/` → dessiner la zone Monaco + littoral, loyer max 1 500 €.
```
BIENICI_URL=https://www.bienici.com/recherche/location/beausoleil-06240?prix-max=1500
```

### Logic-Immo (logic-immo.com) — optionnel

```
LOGICIMMO_URL=https://www.logic-immo.com/location-immobilier-alpes-maritimes-06,00_1/options/groupprptypesids=1,2/pricemax=1500
```

### Jinka (jinka.fr) — OPTIONNEL, agrégateur (LBC + PAP + SeLoger + Logic-Immo…)

Jinka n'a **pas d'API publique**. Deux façons de l'intégrer :
1. **Alertes email** (recommandé) : créez une alerte Jinka sur ces communes/budget, faites-la arriver
   sur `VOTRE_EMAIL`, et la skill lira ces emails via Gmail pour en extraire les annonces.
2. **Connexion navigateur** : la skill se connecte à votre compte Jinka en session.

```
JINKA_ACTIF=non
JINKA_EMAIL_EXPEDITEUR=alertes@jinka.fr   # si vous activez le mode « alertes email »
# JINKA_LOGIN / JINKA_MDP → à me communiquer séparément SEULEMENT si vous choisissez le mode connexion
```

---

## Notes

- Vous pouvez modifier ce fichier à tout moment — relancez la skill, elle reprend les nouveaux paramètres.
- Pour arrêter les lancements planifiés une fois le logement trouvé : `/schedule list` puis `/schedule delete [id]`.
- **Ne mettez aucun mot de passe / clé dans un fichier committé.** Utilisez `config.md` (ignoré par git) ou un `.env`.
