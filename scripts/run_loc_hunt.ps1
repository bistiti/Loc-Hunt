# run_loc_hunt.ps1 — routine Loc-Hunt sous Windows (Planificateur de tâches)
#
# Usage (PowerShell) :
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\run_loc_hunt.ps1 matin
#
# Équivalent Windows de run_loc_hunt.sh. Pré-requis :
#   - le CLI `claude` (Claude Code) accessible dans le PATH
#   - config.md rempli à la racine du dépôt
#   - permissions pré-accordées pour un run sans invite (voir ROUTINE.md)
param([string]$Slot = "")

$ErrorActionPreference = "Continue"

# Racine du dépôt = dossier parent de scripts\
Set-Location (Split-Path -Parent $PSScriptRoot)

$LogDir = Join-Path $HOME "loc-hunt-cote-azur"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$Log = Join-Path $LogDir "loc-hunt.log"

Add-Content $Log ("=== {0} — debut run Loc-Hunt ({1}) ===" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Slot)

# --print = non-interactif ; acceptEdits = écritures de fichiers auto-acceptées.
claude --print --permission-mode acceptEdits "/loc-hunt $Slot" *>> $Log

Add-Content $Log ("=== {0} — fin run Loc-Hunt ===" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
