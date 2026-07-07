@echo off
REM Wrapper .bat pour le Planificateur de taches Windows.
REM Certaines configurations de taches planifiees se comportent mieux en pointant
REM vers un .bat qui appelle powershell.exe plutot que d'appeler directement un .ps1.
REM %~dp0 = dossier de ce .bat (avec un antislash final), donc resout toujours le
REM script voisin quel que soit le "Commencer dans" configure dans la tache.
REM %* transmet l'argument (matin/soir) tel quel.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_loc_hunt.ps1" %*
