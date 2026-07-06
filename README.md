# 🏠 Loc-Hunt — Recherche de location automatisée (Monaco / Côte d'Azur)

Un workflow piloté par l'IA qui **cherche des locations plusieurs fois par jour** sur les plateformes
françaises, **suit les annonces dans un tableur**, **rédige des messages de contact personnalisés**, et
**vous envoie un email récapitulatif** — le tout automatiquement.

> Adapté du projet [london-property-hunt-public](https://github.com/mikepapadim/london-property-hunt-public)
> pour le marché **français**, secteur **Monaco et communes limitrophes + Nice et littoral (Menton → La Trinité)**,
> **logement entier** (appartement ou maison, T2 / T3 / etc., 2 pièces et plus), **≤ 1 500 € charges comprises**.

---

## Ce que ça fait

1. **Parcourt les plateformes FR** — LeBonCoin, PAP, Bien'ici, SeLoger (+ Logic-Immo / Jinka en option) sur vos communes cibles
2. **Déduplique** avec votre tableur (recherche par URL, O(1)) — relançable sans doublon
3. **Priorise** chaque annonce en **HIGH / MEDIUM / LOW** selon vos critères (commune, budget, durée, disponibilité)
4. **Génère un message de contact** `.txt` prêt à envoyer pour chaque annonce HIGH (avec argumentaire dossier)
5. **Vous envoie un email récap** : cartes cliquables, messages prêts à envoyer, et backlog des annonces non contactées

Tourne sur planification (ex. 9 h et 18 h). Effort humain entre deux runs : zéro.

---

## Structure du dépôt

```
Loc-Hunt/
├── README.md              ← vous êtes ici
├── skill.md               ← la skill (le « cerveau » — instructions détaillées)
├── config.example.md      ← vos paramètres perso (à copier en config.md)
├── guide.md               ← méthode, spécificités Côte d'Azur, conseils
├── ROUTINE.md             ← lancer /loc-hunt et le planifier (cron / /schedule)
├── .claude/
│   └── commands/
│       └── loc-hunt.md    ← la commande /loc-hunt (prête à l'emploi)
├── tracker/
│   └── README.md          ← schéma des colonnes du tableur
├── scripts/
│   ├── creer_tracker.py   ← crée le fichier .xlsx (optionnel — la skill le fait sinon)
│   ├── update_tracker.py  ← ajoute/dédoublonne les annonces dans le tableur (script fixe)
│   ├── run_loc_hunt.sh    ← lance /loc-hunt en non-interactif (cron, Linux/macOS)
│   └── run_loc_hunt.ps1   ← idem sous Windows (Planificateur de tâches)
├── outreach/              ← messages de contact générés (ignoré par git)
└── .gitignore
```

---

## Pré-requis

- **Claude Code** (CLI ou app) — [claude.ai/code](https://claude.ai/code)
- **Connecteur Gmail MCP** — lecture des alertes des plateformes (mode `email`) + envoi du récapitulatif
- **Python 3 + openpyxl** — mise à jour du tableur (`pip install openpyxl`)
- Un compte Gmail auquel accorder l'accès MCP
- *(mode `navigateur` uniquement)* **Claude dans Chrome** *ou* **Playwright** — automatisation du navigateur

> **Deux modes de collecte** (voir `config.md` → `MODE_RECHERCHE`) :
> - **`email`** *(recommandé, sans Chrome)* — vous créez des alertes sur les plateformes, la skill les lit via Gmail.
> - **`navigateur`** — la skill ouvre les sites elle-même (plus complet, mais protections anti-bot).
>
> **Aucune clé API n'est nécessaire.** Jinka est optionnel (alertes email ou connexion — pas de clé).

---

## Installation

### 1. Cloner et configurer

**Sur votre ordinateur** (Terminal / Invite de commandes), récupérez le dépôt et entrez dans le dossier créé :

```bash
git clone https://github.com/bistiti/Loc-Hunt
cd Loc-Hunt
cp config.example.md config.md
```

Toutes les commandes suivantes se lancent **dans ce dossier `Loc-Hunt`** — c'est là que se trouvent
`config.example.md`, `skill.md`, `scripts/`, etc.

Éditez `config.md` — nom, dossier locataire (revenus/garant), communes, budget, email, et `MODE_RECHERCHE`.
Les valeurs sont déjà pré-remplies pour « logement entier T2+ ≤ 1 500 € CC, secteur Monaco » : ajustez surtout la section « Vous ».
En **mode `email`** (recommandé), créez aussi vos alertes sur les plateformes + un label Gmail (voir `config.md` / `guide.md`).

### 2. Créer votre tableur

```bash
mkdir -p ~/loc-hunt-cote-azur/outreach
pip install openpyxl
python3 scripts/creer_tracker.py        # crée ~/loc-hunt-cote-azur/loc_hunt.xlsx
```

La skill crée aussi le fichier automatiquement au premier run s'il n'existe pas.

### 3. Lancer la recherche

La commande `/loc-hunt` est **déjà prête** (fichier `.claude/commands/loc-hunt.md`). Ouvrez le dossier
`Loc-Hunt` dans Claude Code et tapez :

```
/loc-hunt
```

Elle lit `config.md`, suit `skill.md`, met à jour le tableur et envoie le récap. Détails dans `ROUTINE.md`.

### 4. Planifier (matin 9 h + soir 18 h)

Pour lancer `/loc-hunt` automatiquement — planificateur Claude Code, **cron système**, ou `/loop` :
voir **`ROUTINE.md`**. Exemple (cron, le plus robuste) :

```cron
0 9  * * * /chemin/vers/Loc-Hunt/scripts/run_loc_hunt.sh matin
0 18 * * * /chemin/vers/Loc-Hunt/scripts/run_loc_hunt.sh soir
```

> **Windows** : pas de `cron` — utilisez le **Planificateur de tâches** avec `scripts/run_loc_hunt.ps1`
> (commandes `schtasks` prêtes à copier dans **`ROUTINE.md`**).

---

## Comment fonctionne la recherche

- **Cible :** logement entier — **appartement ou maison**, T2 / T3 / etc. (2 pièces et plus), meublé **ou** non meublé, **longue durée** (location à l'année)
- **Exclusions strictes :** locations saisonnières / vacances / courte durée / meublé de tourisme
- **Budget :** ≤ 1 500 € charges comprises (léger dépassement toléré mais marqué LOW)
- **Plateformes :** LeBonCoin + PAP (particuliers, sans frais d'agence) + Bien'ici + SeLoger (+ Logic-Immo / Jinka en option)

### Logique de priorité

| Priorité | Règle |
|---|---|
| 🟢 **HIGH** | Commune **limitrophe de Monaco** (Beausoleil, Cap-d'Ail, Roquebrune-Cap-Martin, La Turbie, Monaco) + ≤ 1 500 € CC + longue durée + dispo rapide |
| 🟡 **MEDIUM** | Commune du **littoral** (Nice hors Ariane, Menton, Èze, Villefranche, Beaulieu, La Trinité) dans le budget, ou commune prioritaire avec un bémol (charges à confirmer, DPE F/G, dispo lointaine) |
| ⚪ **LOW** | Léger dépassement de budget, disponibilité lointaine, ou hors des communes listées |

Couleurs dans le tableur : HIGH = vert (`E2EFDA`), MEDIUM = jaune (`FFFFC7`), LOW = rouge (`FCE4D6`).

---

## Format de l'email

Chaque run envoie un email HTML (même si zéro nouvelle annonce) avec :

- **En-tête** — date, heure du run, plateformes, compteurs HIGH/MEDIUM/LOW
- **HIGH** — une carte par annonce avec un message vert prêt à envoyer (< 100 mots, personnalisé, argumentaire dossier)
- **MEDIUM** — cartes condensées + court message
- **LOW/IGNORÉ** — liste à puces
- **En attente** — jusqu'à 8 annonces HIGH des runs précédents non encore contactées
- **Stats** — répartition par commune, rappel « contactez au moins 5 annonces aujourd'hui »

---

## Adapter à une autre recherche

Le seul fichier à éditer est `config.md`. Tout le reste (communes, budget, logique de priorité, ton des
messages, format de l'email) se lit dedans. Pour changer de secteur, remplacez les communes et les URLs de
plateformes ; pour repasser en colocation, réactivez les filtres colocataires (voir le dépôt d'origine).

---

## Conseils pour être pris (secteur Monaco = très concurrentiel)

1. **Réactivité** — soyez dans les 5 premiers à répondre ; les biens partent en quelques heures
2. **Dossier complet d'avance** — pièce d'identité, 3 derniers bulletins, avis d'imposition, justif. domicile, garant/Visale, prêts à envoyer le jour même
3. **Revenus ≈ 3× le loyer** — sinon, garant solide ou dispositif **Visale**
4. **Téléphone > message** — si un numéro est affiché, appelez
5. **PAP en priorité** — pas de frais d'agence, contact direct propriétaire
6. **Attention au saisonnier** — sur la Côte d'Azur beaucoup d'annonces sont des locations vacances : la skill les exclut, restez vigilant aussi

---

*Construit avec Claude Code + Gmail MCP (+ Claude dans Chrome / Playwright en option) — adapté de london-property-hunt-public.*
