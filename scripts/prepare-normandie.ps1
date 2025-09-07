<#!
.SYNOPSIS
  Télécharge, vérifie et fusionne Haute & Basse Normandie en un seul fichier normandie.osm.pbf pour Nominatim.

.DESCRIPTION
  Essaie la date du jour (UTC) au format yymmdd (ex: 250906) pour les fichiers:
    haute-normandie-<date>.osm.pbf
    basse-normandie-<date>.osm.pbf
  Recule d'un jour jusqu'à trouver une date disponible (max 7 jours) sauf si -Date est précisé.
  Vérifie les MD5, fusionne via un conteneur Alpine + osmium-tool et produit .\data\normandie.osm.pbf

.PARAMETER Date
  Date spécifique (format yymmdd). Facultatif.

.PARAMETER Force
  Écrase les fichiers existants.

.EXAMPLE
  ./scripts/prepare-normandie.ps1

.EXAMPLE
  ./scripts/prepare-normandie.ps1 -Date 250905 -Verbose -Force

#>
param(
    [string]$Date,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Write-Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Write-Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Write-Err($m){ Write-Host "[ERR ] $m" -ForegroundColor Red }

$dataDir = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'data'
if(-not (Test-Path $dataDir)){ New-Item -ItemType Directory -Path $dataDir | Out-Null }

if(-not $Date){
  $utcNow = [DateTime]::UtcNow
  $found = $false
  for($i=0;$i -lt 7 -and -not $found;$i++){
    $d = $utcNow.AddDays(-$i).ToString('yyMMdd')
    $testUrl = "https://download.geofabrik.de/europe/france/haute-normandie-$d.osm.pbf"
    try {
      $resp = Invoke-WebRequest -Uri $testUrl -Method Head -TimeoutSec 30 -ErrorAction Stop
      if($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 400){
        $Date = $d; $found = $true; Write-Info "Date trouvée: $Date"; break
      }
    } catch { }
  }
  if(-not $found){ throw "Aucune date disponible sur les 7 derniers jours." }
} else {
    if($Date -notmatch '^[0-9]{6}$'){ throw "Format -Date invalide. Utiliser yymmdd (ex: 250906)." }
}

Write-Info "Utilisation de la date $Date"

$files = @(
    @{ base='haute-normandie'; name="haute-normandie-$Date.osm.pbf" },
    @{ base='basse-normandie'; name="basse-normandie-$Date.osm.pbf" }
)

foreach($f in $files){
    $target = Join-Path $dataDir $f.name
    $url = "https://download.geofabrik.de/europe/france/$($f.name)"
  if( (Test-Path $target) -and (-not $Force) ){
        Write-Info "$($f.name) existe déjà (utiliser -Force pour re-télécharger)"
    } else {
        Write-Info "Téléchargement $url"
        Invoke-WebRequest -Uri $url -OutFile $target
    }
    # MD5
    $md5Url = "$url.md5"
    $md5File = "$target.md5"
    Write-Info "Téléchargement MD5 $md5Url"
    Invoke-WebRequest -Uri $md5Url -OutFile $md5File
    $expected = (Get-Content $md5File).Split(' ')[0].Trim()
    $actual = (Get-FileHash $target -Algorithm MD5).Hash.ToLower()
    if($expected.ToLower() -ne $actual){
        throw "Hash MD5 ne correspond pas pour $($f.name) (expected=$expected actual=$actual)"
    } else { Write-Info "MD5 ok pour $($f.name)" }
}

$haute = Join-Path $dataDir "haute-normandie-$Date.osm.pbf"
$basse = Join-Path $dataDir "basse-normandie-$Date.osm.pbf"
$merged = Join-Path $dataDir 'normandie.osm.pbf'

if( (Test-Path $merged) -and (-not $Force) ){
    Write-Warn "Fichier fusionné existe déjà: normandie.osm.pbf (utiliser -Force pour régénérer)"
} else {
    Write-Info "Fusion avec osmium"
  $hauteLeaf = [IO.Path]::GetFileName($haute)
  $basseLeaf = [IO.Path]::GetFileName($basse)
  $bashCmd = "set -e; apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -yqq osmium-tool > /dev/null && osmium cat /data/$hauteLeaf /data/$basseLeaf -o /data/_tmp-normandie-raw.osm.pbf && osmium sort -u -o /data/normandie.osm.pbf /data/_tmp-normandie-raw.osm.pbf && rm /data/_tmp-normandie-raw.osm.pbf && osmium fileinfo /data/normandie.osm.pbf | head -n 15"
  docker run --rm -v "${dataDir}:/data" ubuntu:24.04 bash -lc "$bashCmd"
    if(-not (Test-Path $merged)){ throw "Fusion échouée: normandie.osm.pbf absent." }
    $sizeMB = [math]::Round((Get-Item $merged).Length/1MB,2)
    Write-Info "Fichier fusionné créé ($sizeMB MB)."
}

Write-Info "Terminé. Lancez maintenant: docker compose -f contrib/docker-compose-normandie.yml up -d --force-recreate"
