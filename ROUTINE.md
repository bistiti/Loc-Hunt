# Routine `/loc-hunt`

Cette page explique comment **lancer** la recherche d'un simple `/loc-hunt`, et comment la **planifier**
(matin + soir automatiquement).

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

## Planifier la routine (matin + soir)

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

> Windows : utilisez le **Planificateur de tâches** en pointant sur `run_loc_hunt.sh` via WSL/Git-Bash,
> ou créez l'équivalent PowerShell qui appelle `claude --print "/loc-hunt"`.

### Option C — `/loop` (session ouverte)

Pour une exécution répétée tant qu'une session Claude Code reste ouverte :

```
/loop 6h /loc-hunt
```

Pratique pour tester, moins adapté qu'un cron pour une routine quotidienne de fond.

---

## Permissions pour l'exécution sans invite

En mode non-interactif (Options B/C), Claude Code ne doit pas s'arrêter pour demander l'autorisation d'un
outil. Accordez **vous-même**, après relecture, les permissions nécessaires — deux façons simples :

- Lancez `/loc-hunt` **une fois en interactif** et, à chaque demande, choisissez « toujours autoriser » :
  Claude Code mémorise vos choix pour les runs suivants.
- Ou utilisez la commande **`/permissions`** de Claude Code pour ajouter/relire les règles d'autorisation.

Outils que la routine doit pouvoir utiliser :
- lecture/écriture de fichiers (config, tableur, messages de contact) ;
- exécution de `python3` (mise à jour du tableur `.xlsx`) ;
- votre connecteur **Gmail** (lire les alertes + créer/envoyer le récap) ;
- en **mode `navigateur`** : votre extension *Claude dans Chrome* ou un serveur MCP Playwright.

> Ces réglages vivent dans `.claude/settings.json` (partageable) ou `.claude/settings.local.json` (personnel,
> ignoré par git). Passez par `/permissions` plutôt que d'éditer le JSON à la main.
>
> En dernier recours, le script `run_loc_hunt.sh` accepte une variable `CLAUDE_FLAGS` (mode « tout autoriser »)
> — à réserver à une machine personnelle et à vos risques.

---

## Arrêter la routine

- Option A : `/schedule list` puis `/schedule delete [id]`.
- Option B : `crontab -e` et supprimez les deux lignes.
- Option C : fermez la session ou arrêtez la boucle.

Une fois le logement trouvé, pensez à couper la routine 🎉
