# Routine `/loc-hunt`

Cette page explique comment **lancer** la recherche d'un simple `/loc-hunt`, et comment la **planifier**
(matin 9 h + soir 18 h).

---

## La commande `/loc-hunt`

Le fichier `.claude/commands/loc-hunt.md` définit une **commande Claude Code**. Dès que vous ouvrez le dossier
`Loc-Hunt` dans Claude Code, tapez :

```
/loc-hunt
```

ou en précisant le créneau :

```
/loc-hunt matin
/loc-hunt soir
```

La commande lit `config.md`, suit les instructions de `skill.md`, met à jour le tableur, rédige les messages
de contact et envoie le récapitulatif. Si `config.md` est manquant, elle vous le dit et s'arrête.

> Pré-requis : `config.md` rempli (voir `README.md`), et — en mode `email` — vos alertes plateformes/Jinka +
> le label Gmail configurés (voir `config.md` et `guide.md`).

### Modèle et effort de raisonnement

Les lanceurs planifiés (`run_loc_hunt.sh` et `run_loc_hunt.ps1`) appellent `claude` avec
**`--model sonnet --effort xhigh`** : modèle Sonnet, effort de raisonnement maximal. Un run non surveillé
(email + tableur + priorisation HIGH/MEDIUM/LOW) bénéficie de ce niveau d'effort pour rester fiable sans
intervention humaine. Si vous lancez `/loc-hunt` à la main dans une session Claude Code, appliquez le même
réglage avec `/model sonnet` puis `/effort xhigh` (ou lancez directement `claude --model sonnet --effort
xhigh --print "/loc-hunt"`).

---

## Planifier la routine (matin 9 h + soir 18 h)

Trois options, de la plus simple à la plus autonome.

### Option A — Planificateur intégré de Claude Code

Si votre Claude Code propose la planification, programmez deux runs par jour (9 h et 18 h) :

```
/schedule 0 9,18 * * * /loc-hunt
```

Pour lister / supprimer : `/schedule list` puis `/schedule delete [id]`.

### Option B — Cron système (Linux / macOS) — le plus robuste

Le script `scripts/run_loc_hunt.sh` lance la commande en mode non-interactif et journalise le tout.

1. Rendez-le exécutable (une fois) :
   ```bash
   chmod +x scripts/run_loc_hunt.sh
   ```
2. Éditez votre crontab :
   ```bash
   crontab -e
   ```
3. Ajoutez deux lignes (adaptez le chemin absolu vers votre dossier `Loc-Hunt`) :
   ```cron
   0 9  * * * /chemin/vers/Loc-Hunt/scripts/run_loc_hunt.sh matin
   0 18 * * * /chemin/vers/Loc-Hunt/scripts/run_loc_hunt.sh soir
   ```

Les logs de chaque run vont dans `~/loc-hunt-cote-azur/loc-hunt.log`.

### Option B (Windows) — Planificateur de tâches

Sous Windows, `cron`/`chmod` n'existent pas : utilisez le **Planificateur de tâches** avec le script
PowerShell `scripts/run_loc_hunt.ps1`, appelé via le wrapper **`scripts/run_loc_hunt.bat`** (certaines
configurations de tâches planifiées se comportent mieux en pointant vers un `.bat` plutôt que directement
vers un `.ps1` — guillemets/politique d'exécution plus prévisibles). Rien à rendre « exécutable ».

1. **Testez d'abord à la main** (PowerShell, dans le dossier du dépôt) :
   ```powershell
   .\scripts\run_loc_hunt.bat matin
   Get-Content "$HOME\loc-hunt-cote-azur\loc-hunt.log" -Tail 40
   ```
2. **Créez les 2 tâches** (adaptez le chemin `C:\Users\...\Loc-Hunt`) :
   ```powershell
   schtasks /Create /TN "LocHunt-matin" /SC DAILY /ST 09:00 /TR "C:\Users\plop\Loc-Hunt\scripts\run_loc_hunt.bat matin"
   schtasks /Create /TN "LocHunt-soir"  /SC DAILY /ST 18:00 /TR "C:\Users\plop\Loc-Hunt\scripts\run_loc_hunt.bat soir"
   ```
   Si vous aviez déjà créé les tâches en pointant directement sur le `.ps1`, supprimez-les et recréez-les
   avec les commandes ci-dessus (`schtasks` ne permet pas de modifier proprement l'action d'une tâche
   existante) :
   ```powershell
   schtasks /Delete /TN "LocHunt-matin" /F
   schtasks /Delete /TN "LocHunt-soir" /F
   ```
3. **Vérifier / supprimer** une tâche :
   ```powershell
   schtasks /Query  /TN "LocHunt-matin"
   schtasks /Delete /TN "LocHunt-matin" /F
   ```

> Le PC doit être allumé à l'heure prévue. Pour un run même session verrouillée, ouvrez le Planificateur
> (interface) et cochez « Exécuter même si l'utilisateur n'est pas connecté ». Si Python n'est pas trouvé
> pendant le run, autorisez-le via `/permissions` (sous Windows la commande peut être `python` ou `py -3`).

#### Ça marche en PowerShell mais pas via le Planificateur de tâches ?

C'est le symptôme classique : la tâche « s'exécute » (le journal affiche bien un début/fin de run) mais
**rien n'est mis à jour** (ni tableur, ni brouillon email). Le Planificateur de tâches n'utilise pas
toujours le même **PATH** qu'un terminal interactif : `claude` peut y être introuvable, et le script
avortait silencieusement.

`run_loc_hunt.ps1` détecte maintenant ce cas et écrit un diagnostic clair dans le journal :
```powershell
Get-Content "$HOME\loc-hunt-cote-azur\loc-hunt.log" -Tail 20
```
- S'il indique `claude resolu : ...` suivi du reste du run → ce n'était pas un problème de PATH,
  regardez la suite du journal (permissions manquantes, etc.).
- S'il indique `ERREUR : commande 'claude' introuvable` → réglez le PATH une bonne fois :
  1. Dans une session PowerShell où `/loc-hunt` fonctionne, lancez :
     ```powershell
     (Get-Command claude).Source
     ```
  2. Définissez ce chemin en **variable d'environnement permanente** `CLAUDE_EXE` (Panneau de
     configuration → Système → Paramètres système avancés → Variables d'environnement → Nouvelle,
     ou en une commande) :
     ```powershell
     setx CLAUDE_EXE "C:\chemin\vers\claude.cmd"
     ```
     Puis **fermez et rouvrez** toute session PowerShell/Planificateur pour que la variable soit prise
     en compte (`setx` ne s'applique qu'aux nouveaux processus).
  3. Relancez la tâche planifiée (ou testez avec `schtasks /Run /TN "LocHunt-matin"`) et revérifiez le log.

Autres réglages de la tâche à vérifier si le problème persiste (onglet **Général** de la tâche dans
`taskschd.msc`) :
- **Exécuter avec les autorisations maximales** : décochez, sauf besoin explicite (une session élevée
  peut charger un environnement différent).
- Sécurité : préférez **« Exécuter uniquement si l'utilisateur est connecté »** à « que l'utilisateur soit
  connecté ou non » si le PC reste ouvert sur votre session — c'est le contexte le plus proche d'un run
  interactif, donc le plus fiable pour retrouver le même comportement.
- Onglet **Actions** → **Commencer dans (optionnel)** : renseignez le dossier `Loc-Hunt` (ex.
  `C:\Users\plop\Loc-Hunt`), en plus du chemin déjà passé en argument.

#### Le log affiche « You've hit your session limit »

Ce n'est **ni un bug du script ni un problème Windows** : c'est le **quota d'usage de votre compte Claude**
qui était atteint au moment du run (le message indique l'heure de reset, ex. « resets 8pm »). Le run a bien
tenté de s'exécuter — `claude` a été trouvé et lancé — mais l'appel a été refusé faute de quota disponible.

Cause fréquente : enchaîner plusieurs tests manuels (`schtasks /Run`, runs interactifs) en peu de temps
consomme le même quota que les runs planifiés. Si vous testez beaucoup pendant la mise en place, il est
normal de voir ce message de temps en temps — les runs planifiés (9 h / 18 h) sont en général assez espacés
pour laisser le quota se reconstituer entre deux. Si le message apparaît systématiquement aux heures
planifiées, vérifiez votre quota/plan dans les réglages de votre compte Claude.

### Option C — `/loop` (session ouverte)

Pour une exécution répétée tant qu'une session Claude Code reste ouverte :

```
/loop 6h /loc-hunt
```

Pratique pour tester, moins adapté qu'un cron pour une routine quotidienne de fond.

---

## Permissions pour l'exécution sans invite

> ⚠️ **Prérequis indispensable — « truster » le dossier.** Claude Code **ignore** `.claude/settings.json`
> tant que le dossier n'a pas été approuvé (message « this workspace has not been trusted »). Lancez **une
> fois** `claude` en interactif dans `Loc-Hunt` et acceptez le dialogue de confiance (ou passez
> `projects["…/Loc-Hunt"].hasTrustDialogAccepted: true` dans `~/.claude.json`). Sans ça, un run planifié
> démarre mais **saute tout** : ni mise à jour du tableur, ni email.
>
> Les noms d'outils MCP Gmail dépendent de votre connecteur : ici `mcp__claude_ai_Gmail__*`. La commande
> Python est `python` sous Windows (`python3` sous Linux/macOS) — les deux sont déjà couverts.

Un fichier **`.claude/settings.json` est fourni** dans le dépôt : il pré-autorise (relisez-le !) uniquement
les outils dont la routine a besoin en mode `email` — votre connecteur **Gmail**, les deux **scripts fixes**
`scripts/creer_tracker.py` et `scripts/update_tracker.py`, et la création de dossiers. **Aucune exécution de
Python arbitraire** n'est autorisée : par sécurité, toutes les écritures du tableur passent par
`update_tracker.py`.

- Le lanceur `run_loc_hunt.sh` ajoute `--permission-mode acceptEdits` : les écritures de fichiers (tableur,
  messages de contact) sont acceptées automatiquement, sans élargir la liste d'outils autorisés.
- Les **noms des outils MCP** listés dans `settings.json` sont ceux du connecteur Gmail de la session de départ ;
  **ajustez-les** s'ils diffèrent chez vous (la commande **`/permissions`** affiche les noms exacts).
- En **mode `navigateur`**, ajoutez les outils de votre extension *Claude dans Chrome* ou serveur MCP Playwright.

> `.claude/settings.json` est partagé (versionné) ; `.claude/settings.local.json` reste personnel (ignoré par
> git). En dernier recours, `run_loc_hunt.sh` accepte `CLAUDE_FLAGS="--dangerously-skip-permissions"` — à
> réserver à une machine personnelle et à vos risques.

---

## Arrêter la routine

- Option A : `/schedule list` puis `/schedule delete [id]`.
- Option B (cron, Linux/macOS) : `crontab -e` et supprimez les deux lignes.
- Option B (Windows) : `schtasks /Delete /TN "LocHunt-matin" /F` (idem pour `-soir`).
- Option C : fermez la session ou arrêtez la boucle.

Une fois le logement trouvé, pensez à couper la routine 🎉
