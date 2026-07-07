# run_loc_hunt.ps1 - routine Loc-Hunt sous Windows (Planificateur de taches)
#
# Usage (PowerShell) :
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\run_loc_hunt.ps1 matin
#
# Equivalent Windows de run_loc_hunt.sh. Pre-requis :
#   - le CLI 'claude' (Claude Code) accessible dans le PATH, OU variable d'environnement
#     CLAUDE_EXE pointant vers son chemin complet (voir ROUTINE.md, section Windows)
#   - config.md rempli a la racine du depot
#   - permissions pre-accordees pour un run sans invite (voir ROUTINE.md)
#   - le dossier du depot doit avoir ete "trusted" au moins une fois en session interactive
#
# NB : fichier volontairement en ASCII pur (pas d'accents ni de tirets longs)
#      pour rester compatible Windows PowerShell 5.1 (lecture ANSI par defaut).
param([string]$Slot = "")

$ErrorActionPreference = "Continue"

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

$LogDir = Join-Path $HOME "loc-hunt-cote-azur"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$Log = Join-Path $LogDir "loc-hunt.log"

function Write-Log([string]$Message) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content $Log "$ts - $Message"
}

Write-Log "=== debut run Loc-Hunt ($Slot) ==="
Write-Log "utilisateur : $env:USERNAME | dossier : $RepoRoot | PSVersion : $($PSVersionTable.PSVersion)"

# Resolution de l'executable claude : le Planificateur de taches Windows n'a pas toujours
# le meme PATH qu'un terminal interactif - c'est la cause la plus frequente d'echec silencieux
# (le script se termine "normalement" mais claude n'a jamais tourne, donc rien n'est mis a jour).
$ClaudeExe = $null
if ($env:CLAUDE_EXE -and (Test-Path $env:CLAUDE_EXE)) {
    $ClaudeExe = $env:CLAUDE_EXE
} else {
    $found = Get-Command claude -ErrorAction SilentlyContinue
    if ($found) { $ClaudeExe = $found.Source }
}
if (-not $ClaudeExe) {
    foreach ($candidate in @(
        (Join-Path $env:APPDATA "npm\claude.cmd"),
        (Join-Path $env:APPDATA "npm\claude.ps1"),
        (Join-Path $env:ProgramFiles "nodejs\claude.cmd"),
        (Join-Path $env:LOCALAPPDATA "Programs\claude\claude.exe")
    )) {
        if (Test-Path $candidate) { $ClaudeExe = $candidate; break }
    }
}

if (-not $ClaudeExe) {
    Write-Log "ERREUR : commande 'claude' introuvable (PATH different sous le Planificateur de taches)."
    Write-Log "Solution : dans une session PowerShell qui fonctionne, lancez 'Get-Command claude',"
    Write-Log "copiez le chemin (Source), puis definissez-le en variable d'environnement CLAUDE_EXE"
    Write-Log "(voir ROUTINE.md, section Windows) avant de relancer la tache planifiee."
    Write-Log "=== fin run Loc-Hunt (echec : claude introuvable) ==="
    exit 1
}
Write-Log "claude resolu : $ClaudeExe"

# --print = non-interactif ; acceptEdits = ecritures de fichiers auto-acceptees.
& $ClaudeExe --print --permission-mode acceptEdits "/loc-hunt $Slot" *>> $Log

Write-Log "=== fin run Loc-Hunt ==="
