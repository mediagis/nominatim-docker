<#!
.SYNOPSIS
  Prépare un fichier fusionné normandie-region.osm.pbf (Normandie + Bretagne + Pays de la Loire + Île-de-France).

.DESCRIPTION
  Repose sur prepare-normandie.ps1 pour produire normandie.osm.pbf puis ajoute d'autres régions.
  Télécharge si manquants les PBF des régions voisines pour la même date.

.PARAMETER Date
  Date yymmdd souhaitée (sinon découverte automatique identique au script Normandie).

.PARAMETER Force
  Forcer re-téléchargements et refusion.

.EXAMPLE
  ./scripts/prepare-normandie-region.ps1
#>
param(
    [string]$Date,
    [switch]$Force
)

$ErrorActionPreference='Stop'
$root = Join-Path $PSScriptRoot '..'
$dataDir = Join-Path $root 'data'
if(-not (Test-Path $dataDir)){ New-Item -ItemType Directory -Path $dataDir | Out-Null }

Write-Host "[INFO] Préparation Normandie de base" -ForegroundColor Cyan
& (Join-Path $PSScriptRoot 'prepare-normandie.ps1') @PSBoundParameters

if(-not $Date){
    # Récupère la date retenue par le script précédent via nommage d'un des fichiers téléchargés
    $haute = Get-ChildItem $dataDir -Filter 'haute-normandie-*.osm.pbf' | Sort-Object LastWriteTime -Descending | Select -First 1
    if(-not $haute){ throw "Impossible de déduire la date utilisée" }
    if($haute.BaseName -match 'haute-normandie-([0-9]{6})'){ $Date = $Matches[1] } else { throw "Format inattendu pour $($haute.Name)" }
}

$regions = @(
    @{ id='bretagne' },
    @{ id='pays-de-la-loire' },
    @{ id='ile-de-france' }
)

foreach($r in $regions){
    $fname = "$($r.id)-$Date.osm.pbf"
    $target = Join-Path $dataDir $fname
    $url = "https://download.geofabrik.de/europe/france/$fname"
  if( (Test-Path $target) -and (-not $Force) ){
        Write-Host "[INFO] $fname existe" -ForegroundColor Cyan
    } else {
        Write-Host "[INFO] Téléchargement $url" -ForegroundColor Cyan
        Invoke-WebRequest -Uri $url -OutFile $target
    }
    # MD5
    $md5Url = "$url.md5"; $md5File = "$target.md5"
    Invoke-WebRequest -Uri $md5Url -OutFile $md5File
    $expected = (Get-Content $md5File).Split(' ')[0].Trim().ToLower()
    $actual = (Get-FileHash $target -Algorithm MD5).Hash.ToLower()
    if($expected -ne $actual){ throw "MD5 mismatch $fname" }
}

$mergedBase = Join-Path $dataDir 'normandie.osm.pbf'
if(-not (Test-Path $mergedBase)){ throw "normandie.osm.pbf introuvable. Relancer prepare-normandie.ps1" }

$final = Join-Path $dataDir 'normandie-region.osm.pbf'
if( (Test-Path $final) -and (-not $Force) ){ Write-Host "[WARN] normandie-region.osm.pbf existe déjà (utiliser -Force)" -ForegroundColor Yellow; exit 0 }

Write-Host "[INFO] Fusion région étendue" -ForegroundColor Cyan
$bashCmd = "set -e; apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -yqq osmium-tool > /dev/null && ls -1 /data/*.osm.pbf | wc -l && osmium merge /data/normandie.osm.pbf /data/bretagne-$Date.osm.pbf /data/pays-de-la-loire-$Date.osm.pbf /data/ile-de-france-$Date.osm.pbf -o /data/normandie-region.osm.pbf -O && osmium fileinfo /data/normandie-region.osm.pbf | head -n 10"
docker run --rm -v "${dataDir}:/data" ubuntu:24.04 bash -lc "$bashCmd"

Write-Host "[INFO] Fichier final prêt: normandie-region.osm.pbf" -ForegroundColor Green
Write-Host "Lancez: docker compose -f contrib/docker-compose-normandie-region.yml up -d --force-recreate" -ForegroundColor Green
