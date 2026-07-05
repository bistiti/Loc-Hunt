# Guide — méthode, spécificités Côte d'Azur, et pistes d'amélioration

Ce guide explique **comment le système est construit**, les **particularités du secteur Monaco / Côte d'Azur**,
et **comment aller plus loin** (dont Jinka).

---

## La méthode en bref

Le système n'est **pas** un scraper classique. C'est une **skill** (un prompt) que Claude exécute lui-même
en pilotant un navigateur via l'extension *Claude dans Chrome*. Trois techniques reprises du projet d'origine :

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
- **Piège n°1 : les locations saisonnières.** La Côte d'Azur est saturée d'annonces vacances / courte durée /
  meublé de tourisme. La skill les **exclut explicitement** (on cherche de la **longue durée, à l'année**).
- **Piège n°2 : les charges.** Beaucoup d'annonces affichent le loyer **hors charges**. La skill note quand
  les charges ne sont pas précisées et tolère un léger dépassement (marqué LOW) plutôt que d'écarter à tort.
- **Marché tendu = réactivité.** Les bons biens partent en quelques heures. D'où l'email récap 2×/jour avec
  message de contact prêt à envoyer, et l'accent mis sur le **dossier complet d'avance**.

---

## Le dossier locataire (le nerf de la guerre)

Sur ce secteur, ce qui fait la différence n'est pas de « trouver » l'annonce mais d'**être choisi**. Préparez :

- Pièce d'identité, 3 derniers bulletins de salaire, contrat de travail / attestation employeur
- Dernier avis d'imposition, 3 dernières quittances de loyer ou justificatif de domicile
- **Garant** (revenus ≈ 3× le loyer) ou dispositif **Visale** (garantie gratuite Action Logement)

Ces éléments sont renseignés dans `config.md` et **cités dans chaque message de contact** pour rassurer d'emblée.

---

## Aller plus loin

### Jinka (agrégateur) — optionnel
Jinka regroupe LeBonCoin, PAP, SeLoger, Logic-Immo… en un seul flux avec alertes. Pas d'API publique.
Deux intégrations possibles (voir `config.md`) :
- **Alertes email → Gmail** : créez une alerte Jinka, la skill lit les emails d'alerte et en extrait les annonces.
  C'est l'option la plus simple et sans identifiants à partager.
- **Connexion navigateur** : la skill se connecte à votre compte Jinka. Nécessite vos identifiants
  (à fournir en local uniquement, jamais dans un fichier committé).

Dites-moi si vous voulez l'activer, et par quelle méthode.

### Autres pistes
- **Filtre transport** : prioriser les communes bien reliées à Monaco (bus Lignes d'Azur / TER Menton–Monaco–Nice).
- **Seuil de surface** : ajouter une surface minimale (ex. ≥ 20 m²) dans la config si besoin.
- **Alerte SMS/Telegram** en plus de l'email pour les annonces HIGH (via un connecteur dédié).

---

## Rappel sécurité

- Ne committez **jamais** `config.md`, un `.xlsx`, ou des identifiants (Jinka, Gmail) — c'est déjà couvert
  par le `.gitignore`.
- Les clés/mots de passe éventuels vont dans `config.md` (ignoré) ou un `.env` local.
