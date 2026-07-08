#!/usr/bin/env bash
# Routine Loc-Hunt en mode non-interactif (pour cron / tâche planifiée).
#
# Usage :
#   scripts/run_loc_hunt.sh [matin|soir]
#
# Pré-requis :
#   - le CLI `claude` (Claude Code) dans le PATH
#   - config.md rempli à la racine du dépôt
#   - les permissions pré-accordées pour un run sans invite (voir ROUTINE.md § Permissions)
set -euo pipefail

# Se placer à la racine du dépôt (dossier parent de scripts/)
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SLOT="${1:-}"
LOGDIR="${LOC_HUNT_LOG_DIR:-$HOME/loc-hunt-cote-azur}"
mkdir -p "$LOGDIR"
LOG="$LOGDIR/loc-hunt.log"

echo "=== $(date '+%F %T') — début run Loc-Hunt (${SLOT:-auto}) ===" >> "$LOG"

# --print : mode non-interactif (pas de TUI).
# --model/--effort : Sonnet avec effort de raisonnement maximal (xhigh), pour une
# recherche/priorisation aussi fiable que possible sur un run non surveillé.
# La gestion des permissions dépend de votre setup — voir ROUTINE.md :
#   - option recommandée : allow-list dans .claude/settings.json (aucune invite)
#   - sinon, décommentez l'option ci-dessous (à vos risques) :
#     CLAUDE_FLAGS="--dangerously-skip-permissions"
CLAUDE_FLAGS="${CLAUDE_FLAGS:-}"

# shellcheck disable=SC2086
claude --print --model sonnet --effort xhigh --permission-mode acceptEdits $CLAUDE_FLAGS "/loc-hunt ${SLOT}" >> "$LOG" 2>&1

echo "=== $(date '+%F %T') — fin run Loc-Hunt ===" >> "$LOG"
