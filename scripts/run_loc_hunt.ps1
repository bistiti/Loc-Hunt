# run_loc_hunt.ps1 - routine Loc-Hunt sous Windows (Planificateur de taches)
#
# Usage (PowerShell) :
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\run_loc_hunt.ps1 matin
#
# Equivalent Windows de run_loc_hunt.sh. Pre-requis :
#   - le CLI 'claude' (Claude Code) accessible dans le PATH
#   - config.md rempli a la racine du depot
#   - permissions pre-accordees pour un run sans invite (voir ROUTINE.md)
#
# NB : fichier volontairement en ASCII pur (pas d'accents ni de tirets longs)
#      pour rester compatible Windows PowerShell 5.1 (lecture ANSI par defaut).
param([string]$Slot = "")

$ErrorActionPreference = "Continue"

# Racine du depot = dossier parent de scripts\
Set-Location (Split-Path -Parent $PSScriptRoot)

$LogDir = Join-Path $HOME "loc-hunt-cote-azur"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$Log = Join-Path $LogDir "loc-hunt.log"

$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content $Log "=== $now - debut run Loc-Hunt ($Slot) ==="

# --print = non-interactif ; acceptEdits = ecritures de fichiers auto-acceptees.
claude --print --permission-mode acceptEdits "/loc-hunt $Slot" *>> $Log

$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content $Log "=== $now - fin run Loc-Hunt ==="
