<#!
.SYNOPSIS
  Crée une archive transférable des données Normandie (PBF fusionné + métadonnées + script de vérif)

.DESCRIPTION
  Produit un répertoire ./export/normandie-<date>/ contenant:
    - normandie.osm.pbf (copie)
    - SHA256SUMS.txt
    - INFO.txt (taille, date, commande d’origine)
    - verify.ps1 / verify.sh (vérification d’intégrité)
  Puis compacte en normandie-<date>.zip prêt pour clé USB.

.PARAMETER Date
  Date yymmdd (facultative). S’il n’y a pas de PBF daté explicitement le script tente de déduire.

.EXAMPLE
  ./scripts/export-normandie.ps1
#>
param(
  [string]$Date
)

Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

$root = Join-Path $PSScriptRoot '..'
$dataDir = Join-Path $root 'data'
$pbf = Join-Path $dataDir 'normandie.osm.pbf'
if(-not (Test-Path $pbf)) { throw "normandie.osm.pbf introuvable. Generer d'abord les donnees." }

if(-not $Date) {
  $cand = Get-ChildItem $dataDir -Filter 'haute-normandie-*.osm.pbf' | Select-Object -First 1
  if($cand -and $cand.BaseName -match 'haute-normandie-([0-9]{6})') { $Date=$Matches[1] } else { $Date = (Get-Date -Format 'yyMMdd') }
}

$exportBase = Join-Path $root 'export'
New-Item -ItemType Directory -Force -Path $exportBase | Out-Null
$destDir = Join-Path $exportBase "normandie-$Date"
if(Test-Path $destDir) { Remove-Item $destDir -Recurse -Force }
New-Item -ItemType Directory -Path $destDir | Out-Null

Copy-Item $pbf $destDir
$hash = (Get-FileHash (Join-Path $destDir 'normandie.osm.pbf') -Algorithm SHA256).Hash.ToLower()
"$hash  normandie.osm.pbf" | Set-Content -Path (Join-Path $destDir 'SHA256SUMS.txt') -Encoding utf8

$sizeMB = [math]::Round((Get-Item $pbf).Length/1MB,2)
$info = @(
  'Normandie Nominatim Export'
  "Date jeu de base: $Date"
  "Genere: $(Get-Date -Format o)"
  "Taille: $sizeMB MB"
  'Hash: voir SHA256SUMS.txt'
  'Import: docker compose -f contrib/docker-compose-normandie.yml up -d'
  'Reference: scripts/prepare-normandie.ps1'
)
$info | Set-Content -Path (Join-Path $destDir 'INFO.txt') -Encoding utf8

$verifySh = @(
  '#!/usr/bin/env bash'
  'set -euo pipefail'
  "sha=$(sha256sum normandie.osm.pbf | awk '{print \$1}')"
  "ref=$(awk '{print \$1}' SHA256SUMS.txt)"
  'if [ "$sha" = "$ref" ]; then echo OK hash; else echo ECHEC hash; exit 1; fi'
)
$verifySh | Set-Content -Path (Join-Path $destDir 'verify.sh') -Encoding ascii

$verifyPs1 = @(
  "Write-Host 'Verification SHA256...' -ForegroundColor Cyan"
  "$actual=(Get-FileHash ./normandie.osm.pbf -Algorithm SHA256).Hash.ToLower()"
  "$expected=(Get-Content ./SHA256SUMS.txt).Split(' ')[0].ToLower()"
  "if($actual -eq $expected){ Write-Host 'OK hash' -ForegroundColor Green } else { Write-Host 'ECHEC hash' -ForegroundColor Red; exit 1 }"
)
$verifyPs1 | Set-Content -Path (Join-Path $destDir 'verify.ps1') -Encoding utf8

$zipFile = Join-Path $exportBase "normandie-$Date.zip"
if(Test-Path $zipFile){ Remove-Item $zipFile -Force }
Compress-Archive -Path (Join-Path $destDir '*') -DestinationPath $zipFile
Write-Host "Archive creee: $zipFile" -ForegroundColor Green
