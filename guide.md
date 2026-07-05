# Guide — méthode, spécificités Côte d'Azur, et pistes d'amélioration

Ce guide explique **comment le système est construit**, les **particularités du secteur Monaco / Côte d'Azur**,
et **comment aller plus loin** (dont Jinka).

---

## La méthode en bref

Le système n'est **pas** un scraper classique. C'est une **skill** (un prompt) que Claude exécute lui-même.
Il peut collecter les annonces de **deux façons** (paramètre `MODE_RECHERCHE`) : en **lisant les alertes email**
des plateformes via Gmail (recommandé, **sans navigateur** — voir plus bas), ou en **pilotant un navigateur**
(*Claude dans Chrome* ou Playwright). Trois techniques reprises du projet d'origine :

1. **Extraction structurée** — pour chaque annonce, on relève toujours les mêmes champs (commune, loyer,
   surface, type, meublé, dispo, contact, URL), ce qui rend le tableur homogène et filtrable.
2. **Déduplication idempotente** — les URLs déjà vues sont chargées dans un `set` Python ; toute annonce
   déjà connue est ignorée. On peut relancer 10×/jour sans jamais créer de doublon.
3. **Priorisation par règles** — HIGH / MEDIUM / LOW calculés à partir de la commune, du budget, de la durée
   et de la disponibilité. Les couleurs du tableur reflètent la priorité.

Le tout est **planifiable** (`/schedule`) et **auto-suffisant** : chaque run met à jour le tableur, écrit les
messages de contact, et envoie un email récap actionnable depuis le téléphone.

---

## Spécificités du secteur Monaco / Côte d'Azur

- **Monaco (98000)** est une principauté : marché à part, loyers parmi les plus chers au monde. Un logement
  entier < 1 500 € y est quasi introuvable → l'essentiel des résultats vient des **communes françaises limitrophes**.
- **Communes limitrophes de Monaco** (idéales si vous y travaillez) : **Beausoleil, Cap-d'Ail,
  Roquebrune-Cap-Martin, La Turbie** → ce sont les zones **HIGH**.
- **Zone à éviter** : le **quartier de l'Ariane** (Nice Est) jouxte La Trinité. Il est **exclu**
  (`ZONES_A_EVITER`) ; attention, une annonce « La Trinité » ou « Nice Est » peut en réalité s'y trouver —
  vérifiez l'adresse exacte avant de valider.
- **Piège n°1 : les locations saisonnières.** La Côte d'Azur est saturée d'annonces vacances / courte durée /
  meublé de tourisme. La skill les **exclut explicitement** (on cherche de la **longue durée, à l'année**).
- **Piège n°2 : les charges.** Beaucoup d'annonces affichent le loyer **hors charges**. La skill note quand
  les charges ne sont pas précisées et tolère un léger dépassement (marqué LOW) plutôt que d'écarter à tort.
- **Marché tendu = réactivité.** Les bons biens partent en quelques heures. D'où l'email récap plusieurs fois par jour avec
  message de contact prêt à envoyer, et l'accent mis sur le **dossier complet d'avance**.

---

## Le dossier locataire (le nerf de la guerre)

Sur ce secteur, ce qui fait la différence n'est pas de « trouver » l'annonce mais d'**être choisi**. Préparez :

- Pièce d'identité, 3 derniers bulletins de salaire, contrat de travail / attestation employeur
- Dernier avis d'imposition, 3 dernières quittances de loyer ou justificatif de domicile
- **Garant** (revenus ≈ 3× le loyer) ou dispositif **Visale** (garantie gratuite Action Logement)

Ces éléments sont renseignés dans `config.md` et **cités dans chaque message de contact** pour rassurer d'emblée.

---

## Éviter le navigateur : le mode « alertes email » (recommandé)

**Oui, on peut se passer totalement de Chrome.** Beaucoup de plateformes protègent leurs pages contre le
scraping (DataDome sur LeBonCoin / SeLoger…), ce qui rend l'automatisation navigateur fragile. Le mode
`email` contourne ça élégamment : on laisse les plateformes **pousser** leurs nouveautés par email, et la
skill les **lit** via le connecteur Gmail (le même qui envoie déjà le récap). Aucun navigateur, aucun
scraping, et on reste dans les conditions d'utilisation des sites.

### Démarches (une seule fois)
1. **Créer les alertes** sur chaque plateforme, avec vos critères (communes, loyer ≤ 1 500 €, **T2 et plus**) :
   - LeBonCoin : lancez la recherche filtrée → « 🔔 Recevoir les nouveautés » (compte gratuit requis).
   - SeLoger / Logic-Immo / Bien'ici : « Enregistrer la recherche » → alerte email.
   - PAP : « Créer une alerte email » depuis les résultats.
   - **Jinka** (agrégateur) : une seule alerte couvre LeBonCoin + PAP + SeLoger + Logic-Immo… → le plus efficace.

   Faites arriver toutes ces alertes sur `VOTRE_EMAIL`.
2. **Trier dans Gmail** : créez un **filtre** qui applique un label (ex. `Loc-Hunt`) à tout email provenant de
   ces expéditeurs (`leboncoin.fr`, `seloger.com`, `pap.fr`, `bienici.com`, `jinka.fr`…). Renseignez
   `GMAIL_LABEL`, `GMAIL_EXPEDITEURS` et `GMAIL_FENETRE` dans `config.md`.
3. **Lancer la skill** avec `MODE_RECHERCHE=email` : elle cherche `label:Loc-Hunt newer_than:3d`, ouvre chaque
   email, en extrait les annonces (titre, loyer, commune, URL), déduplique, met à jour le tableur, rédige les
   messages de contact, et envoie le récap. Planifiable comme d'habitude via `/schedule`.

### Limites et parades
- On dépend de la **couverture des alertes** : créez-en sur plusieurs plateformes (ou une bonne alerte Jinka)
  pour ne rien rater. Réglez-les au plus **sensible** (rayon large, seuil de prix un peu au-dessus).
- Les emails d'alerte donnent parfois peu de détails (surface, DPE) : la skill note « à vérifier » ; vous
  confirmez au moment de contacter.

### Alternative technique : Playwright (navigateur *headless*)
Pour parcourir les sites sans l'extension Chrome, **Playwright** (Chromium sans interface) peut être piloté
par la skill. Plus puissant, mais : (a) ça reste du scraping soumis aux protections anti-bot, (b) ça demande
une installation (`pip install playwright` puis `playwright install chromium`). À réserver si le mode `email`
ne suffit pas. Le mode `navigateur` de la skill marche indifféremment avec *Claude dans Chrome* ou un MCP Playwright.

> À éviter : les simples requêtes HTTP (WebFetch/curl) sur LeBonCoin ou SeLoger — bloquées par l'anti-bot, peu fiables.

---

## Aller plus loin

### Jinka (agrégateur) — ACTIVÉ (source principale en mode email)
Jinka regroupe LeBonCoin, PAP, SeLoger, Logic-Immo… en un seul flux avec alertes. Pas d'API publique.
Deux intégrations possibles (voir `config.md`, `JINKA_METHODE`) :
- **Alertes email → Gmail** *(recommandé, `JINKA_METHODE=email`)* : créez une alerte Jinka, la skill lit les
  emails d'alerte et en extrait les annonces. Le plus simple, **sans identifiants à partager**. Étapes
  détaillées dans `config.md` (section Jinka).
- **Connexion navigateur** *(`JINKA_METHODE=connexion`)* : la skill se connecte à votre compte Jinka.
  Nécessite vos identifiants (à fournir en local uniquement, jamais dans un fichier committé).

Avec une seule alerte Jinka bien réglée (communes + T2+ + ≤ 1 500 €, l'Ariane exclue), vous couvrez déjà
l'essentiel des plateformes.

### Autres pistes
- **Filtre transport** : prioriser les communes bien reliées à Monaco (bus Lignes d'Azur / TER Menton–Monaco–Nice).
- **Seuil de surface** : ajouter une surface minimale (ex. ≥ 20 m²) dans la config si besoin.
- **Alerte SMS/Telegram** en plus de l'email pour les annonces HIGH (via un connecteur dédié).

---

## Rappel sécurité

- Ne committez **jamais** `config.md`, un `.xlsx`, ou des identifiants (Jinka, Gmail) — c'est déjà couvert
  par le `.gitignore`.
- Les clés/mots de passe éventuels vont dans `config.md` (ignoré) ou un `.env` local.
