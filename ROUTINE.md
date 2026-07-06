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
PowerShell `scripts/run_loc_hunt.ps1` (rien à rendre « exécutable »).

1. **Testez d'abord à la main** (PowerShell, dans le dossier du dépôt) :
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\run_loc_hunt.ps1 matin
   Get-Content "$HOME\loc-hunt-cote-azur\loc-hunt.log" -Tail 40
   ```
2. **Créez les 2 tâches** (adaptez le chemin `C:\Users\...\Loc-Hunt`) :
   ```powershell
   schtasks /Create /TN "LocHunt-matin" /SC DAILY /ST 09:00 /TR "powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\plop\Loc-Hunt\scripts\run_loc_hunt.ps1 matin"
   schtasks /Create /TN "LocHunt-soir"  /SC DAILY /ST 18:00 /TR "powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\plop\Loc-Hunt\scripts\run_loc_hunt.ps1 soir"
   ```
3. **Vérifier / supprimer** une tâche :
   ```powershell
   schtasks /Query  /TN "LocHunt-matin"
   schtasks /Delete /TN "LocHunt-matin" /F
   ```

> Le PC doit être allumé à l'heure prévue. Pour un run même session verrouillée, ouvrez le Planificateur
> (interface) et cochez « Exécuter même si l'utilisateur n'est pas connecté ». Si Python n'est pas trouvé
> pendant le run, autorisez-le via `/permissions` (sous Windows la commande peut être `python` ou `py -3`).

### Option C — `/loop` (session ouverte)

Pour une exécution répétée tant qu'une session Claude Code reste ouverte :

```
/loop 6h /loc-hunt
```

Pratique pour tester, moins adapté qu'un cron pour une routine quotidienne de fond.

---

## Permissions pour l'exécution sans invite

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
