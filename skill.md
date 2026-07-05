# Loc-Hunt — Skill Claude Code (recherche de location Côte d'Azur / Monaco)

> **Utilisation :** copiez le contenu du bloc ci-dessous comme skill dans Claude Code, ou lancez-le directement.
> Avant de lancer, remplissez `config.md` (copié depuis `config.example.md`).
> Toutes les valeurs `[ENTRE_CROCHETS]` sont lues depuis votre fichier de config.

---

## Prompt de la skill (à coller dans Claude Code)

```
Tu exécutes la recherche de location de [VOTRE_NOM] sur le secteur Monaco / Côte d'Azur.
Fais tout automatiquement — aucun humain présent. Va au bout de chaque étape.

## QUI EST [VOTRE_NOM]
- [VOTRE_AGE] ans, [VOTRE_PROFESSION]
- Contrat : [TYPE_CONTRAT], revenus nets ~[REVENUS_MENSUELS_NET] €/mois, garant : [GARANT]
- Profil : [VOTRE_PROFIL]
- Emménagement : [EMMENAGEMENT]
- Téléphone : [VOTRE_TELEPHONE]

## CE QU'ON CHERCHE — LOGEMENT ENTIER UNIQUEMENT
- T2 / T3 / etc. — 2 pièces et plus. **Appartement ET maison entière** (les deux sont recherchés). PAS de studio ni T1, PAS de colocation.
- Loyer : jusqu'à [LOYER_MAX] € charges comprises (ou [LOYER_MAX_HORS_CHARGES] € hors charges).
- Meublé OU non meublé — les deux conviennent.
- **LONGUE DURÉE (location à l'année). EXCLURE impérativement** : locations saisonnières, vacances,
  courte durée, meublé de tourisme, « à la semaine », « juillet-août », baux mobilité < 6 mois.

### Zones
- PRIORITAIRES (→ HIGH) : [ZONES_PRIORITAIRES]
- SECONDAIRES (→ MEDIUM) : [ZONES_SECONDAIRES]
- À ÉVITER (→ IGNORER) : [ZONES_A_EVITER] — rejeter toute annonce dans ces quartiers/zones.
  ⚠️ Nice est inclus MAIS le quartier de l'Ariane (Nice Est) est EXCLU ; il jouxte La Trinité. Pour toute
  annonce à Nice Est ou « La Trinité », vérifier l'adresse/quartier exact avant de garder.

### Filtre budget (obligatoire avant d'ajouter une annonce)
- Loyer CC ≤ [LOYER_MAX] €  → GARDER ✅
- Loyer entre [LOYER_MAX] et [LOYER_MAX]+150 € → GARDER en notant « léger dépassement », priorité LOW
- Loyer > [LOYER_MAX]+150 € → IGNORER ❌
- Charges non précisées → GARDER, note « vérifier montant des charges »

### Filtre durée (obligatoire)
- Toute mention saisonnier / vacances / courte durée / meublé de tourisme → IGNORER ❌

## COLLECTE DES ANNONCES — selon [MODE_RECHERCHE]

### SI [MODE_RECHERCHE] = email  (recommandé, SANS navigateur)
Les plateformes envoient leurs nouvelles annonces par email ; on les lit via le connecteur Gmail.
1. Chercher les emails d'alerte récents dans Gmail :
   `label:[GMAIL_LABEL] newer_than:[GMAIL_FENETRE]`
   (à défaut de label : `from:([GMAIL_EXPEDITEURS reliés par OR]) newer_than:[GMAIL_FENETRE]`)
2. Pour chaque email, lire le corps COMPLET et en extraire CHAQUE annonce :
   titre, loyer, commune, surface/type si présents, et surtout l'URL de l'annonce.
3. On ne fait que LIRE les alertes — ne jamais répondre au site ni cliquer de lien de désinscription.

### SI [MODE_RECHERCHE] = navigateur
Pour chaque plateforme : ouvrir l'URL de config, appliquer les filtres (communes, loyer max [LOYER_MAX] €,
type appartement/maison, **2 pièces min → T2+**), TRIER PAR PLUS RÉCENT, relever la 1re page (et 2e si besoin).

1. LeBonCoin — [LBC_URL]
2. PAP — [PAP_URL]   (de particulier à particulier, sans frais d'agence — à privilégier)
3. Bien'ici — [BIENICI_URL]
4. SeLoger — [SELOGER_URL]   (protection anti-bot : naviguer doucement, filtrer à la main)
5. Logic-Immo — [LOGICIMMO_URL]   (optionnel)
6. Jinka — seulement si [JINKA_ACTIF]=oui

### Dans les deux cas — pour chaque annonce, relever puis filtrer :
Titre · Commune · Code postal · Loyer CC · Charges comprises (oui/non) · Surface m² · Type (T2/T3/…)
· Meublé (oui/non) · Disponible le · DPE si affiché · Contact (agence/particulier + tél si visible) · URL.

Filtres obligatoires avant d'ajouter : **2 pièces minimum** (rejeter studio/T1), **longue durée** (rejeter
saisonnier/vacances), **loyer ≤ [LOYER_MAX] €** (jusqu'à +150 € toléré → priorité LOW),
**hors zones à éviter** (rejeter [ZONES_A_EVITER]).

## TRACKER
Fichier : [DOSSIER_RECHERCHE]/loc_hunt.xlsx — feuille : `Logements`

Déduplication : charger toutes les URLs de la colonne URL dans un set Python au début.
Toute annonce dont l'URL existe déjà est ignorée silencieusement (idempotent — relançable sans doublon).
Nouvelles lignes : Statut = `NOUVEAU 🔴`, Trouvé le = date du jour.

Priorité :
- HIGH   : commune prioritaire [ZONES_PRIORITAIRES] + loyer ≤ [LOYER_MAX] € + longue durée + dispo rapide
- MEDIUM : commune secondaire [ZONES_SECONDAIRES] dans le budget, OU commune prioritaire avec un bémol
           (charges à confirmer, dispo un peu lointaine, DPE F/G)
- LOW    : léger dépassement de budget, dispo lointaine, ou hors des zones listées

Couleurs de ligne : HIGH = E2EFDA (vert), MEDIUM = FFFFC7 (jaune), LOW = FCE4D6 (rouge/orange).

## EMAIL — AUTONOME, LISIBLE SUR TÉLÉPHONE
[VOTRE_NOM] peut n'avoir que son téléphone. L'email doit être actionnable sans ouvrir aucun autre fichier.

Créer un brouillon via le connecteur Gmail (contentType: text/html), À : [VOTRE_EMAIL]
Objet : 🏠 Loc-Hunt Côte d'Azur — {DATE} ({matin/soir}) — {N} nouvelles annonces

Sections du corps HTML :

**A — En-tête :** Date, heure du run, plateformes parcourues.
Compteurs en gras : 🟢 HIGH : N | 🟡 MEDIUM : N | ⚪ LOW : N | 📋 TOTAL : N

**B — 🟢 HIGH du jour :** pour CHAQUE annonce HIGH, une carte avec :
- Titre = lien cliquable | Commune | Loyer € CC | Surface | Type | Meublé | Dispo | Plateforme
- Encadré vert avec un message de contact prêt à envoyer (< 100 mots, personnalisé) :
  « Bonjour, votre annonce [type] à [commune] ([loyer] € CC) m'intéresse beaucoup.
    Je suis [VOTRE_NOM], [VOTRE_AGE] ans, [VOTRE_PROFESSION] en [TYPE_CONTRAT], revenus
    ~[REVENUS_MENSUELS_NET] €/mois[, garant [GARANT]]. Dossier complet prêt à envoyer.
    Disponible pour une visite [EMMENAGEMENT]. Cordialement, [VOTRE_NOM] — [VOTRE_TELEPHONE] »

**C — 🟡 MEDIUM du jour :** Titre (lien) | Commune | Loyer | Dispo | court encadré de contact.

**D — ⚪ LOW/IGNORÉ :** simple liste à puces (titre + lien + raison).

**E — 🔁 En attente (HIGH non contactés, autres jours) :** jusqu'à 8 annonces du tracker où
Statut = NOUVEAU 🔴, Priorité = High, Trouvé le ≠ aujourd'hui. Communes prioritaires d'abord.
Chacune : carte avec URL cliquable + message prêt à envoyer.

**F — Stats :** totaux, répartition par commune, prochain run.
Fin : « ⚠️ Marché tendu : contactez au moins 5 annonces aujourd'hui, dossier complet en pièce jointe. »

Après création du brouillon : aller sur https://mail.google.com/mail/u/[GMAIL_ACCOUNT_INDEX]/#drafts,
ouvrir le brouillon, cliquer Envoyer.

## FICHIERS DE CONTACT
Enregistrer un .txt par annonce HIGH dans [DOSSIER_RECHERCHE]/outreach/
(nom : `AAAA-MM-JJ_commune_plateforme_prix.txt`, contenu = le message prêt à envoyer).

## CRITÈRES DE RÉUSSITE
- Feuille `Logements` mise à jour, aucune location saisonnière ajoutée, aucune > [LOYER_MAX]+150 €.
- Déduplication effective (aucun doublon d'URL).
- Fichiers de contact enregistrés pour les annonces HIGH.
- Email envoyé (toujours, même si zéro nouvelle annonce).
```

---

## Notes sur les paramètres

| Paramètre | Exemple | Où le définir |
|---|---|---|
| `[VOTRE_NOM]` | Alex Martin | config.md |
| `[VOTRE_AGE]` | 30 | config.md |
| `[VOTRE_PROFESSION]` | Croupier / Assistant(e) de direction | config.md |
| `[TYPE_CONTRAT]` | CDI | config.md |
| `[REVENUS_MENSUELS_NET]` | 3500 | config.md |
| `[GARANT]` | parent CDI / Visale | config.md |
| `[VOTRE_PROFIL]` | non-fumeur, sans animaux, calme | config.md |
| `[VOTRE_TELEPHONE]` | +33 6 … | config.md |
| `[ZONES_PRIORITAIRES]` | Beausoleil, Cap-d'Ail, Roquebrune-Cap-Martin, La Turbie, Monaco | config.md |
| `[ZONES_SECONDAIRES]` | Nice (hors Ariane), Menton, Èze, Villefranche-sur-Mer, Beaulieu-sur-Mer, La Trinité | config.md |
| `[ZONES_A_EVITER]` | quartier de l'Ariane (Nice Est) | config.md |
| `[LOYER_MAX]` | 1500 | config.md |
| `[EMMENAGEMENT]` | Dès que possible | config.md |
| `[VOTRE_EMAIL]` | jfds.cie@gmail.com | config.md |
| `[DOSSIER_RECHERCHE]` | ~/loc-hunt-cote-azur | config.md |
| `[GMAIL_ACCOUNT_INDEX]` | 0 (1er compte), 1 (2e) | config.md |
| `[MODE_RECHERCHE]` | email / navigateur | config.md |
| `[GMAIL_LABEL]` | Loc-Hunt | config.md |
| `[GMAIL_FENETRE]` | 3d | config.md |
| `[LBC_URL]` / `[PAP_URL]` / … | URLs de recherche (mode navigateur) | config.md |
| `[JINKA_ACTIF]` | non / oui | config.md |

---

## Pré-requis techniques (côté utilisateur)

- **Claude Code** (CLI ou app) — https://claude.ai/code
- **Connecteur Gmail MCP** — pour LIRE les alertes des plateformes (mode `email`) ET envoyer le récapitulatif
- **Python 3 + openpyxl** — pour le tableur (`pip install openpyxl`)
- Un compte Gmail auquel accorder l'accès MCP
- *(mode `navigateur` uniquement)* **Claude dans Chrome** *ou* **Playwright** — pour piloter le navigateur
