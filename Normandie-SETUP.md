## Nominatim – Déploiement Région Normandie (Reproductible)

Ce guide décrit une procédure reproductible pour préparer, fusionner et importer les données OpenStreetMap de la Normandie (fusion des anciens extraits Haute & Basse Normandie) dans Nominatim via Docker, avec possibilité d’étendre aux régions voisines.

---
### 1. Objectif
Obtenir une instance Nominatim limitée à la Normandie, mise à jour en continu via le flux `france-updates`, à partir d’extraits Geofabrik qui n’existent plus sous la forme d’un unique `normandie-latest.osm.pbf`.

---
### 2. Prérequis
* Docker & Docker Compose
* Windows PowerShell (5.1 ou 7) – scripts fournis en PS1
* OU un shell Bash (Linux/macOS/WSL) – scripts `.sh` équivalents
* Connexion internet stable

Optionnel (Linux/macOS) : adapter les commandes en shell (wget + osmium).

---
### 3. Fichiers ajoutés
| Fichier | Rôle |
|---------|------|
| `scripts/prepare-normandie.ps1` | Télécharge Haute + Basse Normandie, vérifie MD5, fusionne en `data/normandie.osm.pbf`. |
| `scripts/prepare-normandie-region.ps1` | Ajoute Bretagne, Pays de la Loire, Île-de-France → `data/normandie-region.osm.pbf`. |
| `contrib/docker-compose-normandie.yml` | Instance Nominatim limitée à la Normandie. |
| `contrib/docker-compose-normandie-region.yml` | Instance pour région étendue. |
| `.gitignore` | Exclut PBF et données lourdes. |

---
### 4. TL;DR (Normandie seule)
```powershell
git clone <votre-fork-ou-repo>
cd nominatim-docker
./scripts/prepare-normandie.ps1   # auto-détection date & fusion
docker compose -f contrib/docker-compose-normandie.yml up -d --force-recreate
docker logs -f nominatim-normandie   # suivre l’import
curl.exe -s 'http://localhost:8080/search?q=Rouen&format=jsonv2'
```
Version Bash (Linux / WSL / macOS) :
```bash
git clone <votre-fork-ou-repo>
cd nominatim-docker
./scripts/prepare-normandie.sh      # auto
docker compose -f contrib/docker-compose-normandie.yml up -d --force-recreate
curl -s 'http://localhost:8080/search?q=Rouen&format=jsonv2'
```

---
### 5. Génération des données (script automatisé)
Le script :
1. Détecte une date (jusqu’à J-6) pour les fichiers `haute-normandie-<date>.osm.pbf` et `basse-normandie-<date>.osm.pbf`.
2. Télécharge & vérifie les *hash* MD5.
3. Fusionne en un fichier unique.

Commande de base :
```powershell
./scripts/prepare-normandie.ps1
```
Forcer une date précise (format yymmdd) :
```powershell
./scripts/prepare-normandie.ps1 -Date 250906 -Force -Verbose
```

---
### 6. Fusion propre & doublons
Les anciens extraits peuvent avoir de faibles chevauchements → fusion naïve (concatenation) = erreurs `Input data is not ordered` ou `node id ... appears more than once`.

Le script utilise une fusion + tri. Si vous voulez le faire à la main (Ubuntu conteneur) :
```powershell
docker run --rm -v ${PWD}\data:/data ubuntu:24.04 bash -lc "apt-get update -qq && apt-get install -yqq osmium-tool >/dev/null \
  && osmium cat /data/haute-normandie-*.osm.pbf /data/basse-normandie-*.osm.pbf -o /data/_tmp-normandie.osm.pbf --overwrite \
  && osmium sort /data/_tmp-normandie.osm.pbf -o /data/normandie.osm.pbf --overwrite \
  && rm /data/_tmp-normandie.osm.pbf \
  && osmium fileinfo -e /data/normandie.osm.pbf | head -n 15"
```
Si l’erreur de doublons persiste, remplacer `osmium cat` par `osmium merge` :
```powershell
docker run --rm -v ${PWD}\data:/data ubuntu:24.04 bash -lc "apt-get update -qq && apt-get install -yqq osmium-tool >/dev/null \
  && osmium merge /data/haute-normandie-*.osm.pbf /data/basse-normandie-*.osm.pbf -o /data/_tmp-normandie.osm.pbf --overwrite \
  && osmium sort /data/_tmp-normandie.osm.pbf -o /data/normandie.osm.pbf --overwrite \
  && rm /data/_tmp-normandie.osm.pbf"
```

---
### 7. Vérifications avant import
```powershell
Get-ChildItem .\data -Filter normandie.osm.pbf | Select Name, Length
docker run --rm -v ${PWD}\data:/data ubuntu:24.04 bash -lc "apt-get update -qq && apt-get install -yqq osmium-tool >/dev/null && osmium fileinfo -e /data/normandie.osm.pbf | head -n 20"
```

---
### 8. Lancer Nominatim
```powershell
docker compose -f contrib/docker-compose-normandie.yml up -d --force-recreate
docker logs -f nominatim-normandie
```
Fichier sentinelle (fin d’import) :
```powershell
docker exec nominatim-normandie test -f /var/lib/postgresql/16/main/import-finished && echo OK || echo EN_COURS
```

---
### 9. Tests API
```powershell
curl.exe -s 'http://localhost:8080/search?q=Rouen&format=jsonv2'
curl.exe -s 'http://localhost:8080/search?q=Caen&format=jsonv2'
curl.exe -s 'http://localhost:8080/reverse?lat=49.4431&lon=1.0993&format=jsonv2'
```
PowerShell objet :
```powershell
(Invoke-RestMethod -Uri 'http://localhost:8080/search' -Body @{ q='Rouen'; format='jsonv2' }) | Select-Object -First 1 display_name, lat, lon
```

---
### 10. Mises à jour continues
`REPLICATION_URL` défini sur `https://download.geofabrik.de/europe/france-updates/`. Une fois import initial terminé, le conteneur applique les diffs (mode `continuous`).

Logs de mise à jour :
```powershell
docker logs -f nominatim-normandie | Select-String -Pattern 'diff' 
```

---
### 11. Réinitialiser / Recréer
```powershell
docker compose -f contrib/docker-compose-normandie.yml down -v
Remove-Item .\data\normandie.osm.pbf
./scripts/prepare-normandie.ps1 -Force
docker compose -f contrib/docker-compose-normandie.yml up -d --force-recreate
```

---
### 12. Problèmes fréquents
| Erreur | Cause | Solution |
|--------|-------|----------|
| `PBF error: invalid BlobHeader size` | Fichier corrompu / HTML à la place du PBF | Re-télécharger, vérifier MD5. |
| `OSM file ... does not exist` | Mauvais chemin volume (compose dans `contrib/`) | Utiliser `source: ../data` dans le volume. |
| `Input data is not ordered` | Fusion simple sans tri | Ajouter étape `osmium sort`. |
| `node id ... appears more than once` | Doublons sur frontières | Utiliser `osmium merge` puis `osmium sort`. |
| Requêtes PowerShell échouent avec `&` | & non échappé | Mettre toute l’URL entre quotes. |

---
### 13. Région étendue (facultatif)
```powershell
./scripts/prepare-normandie-region.ps1
docker compose -f contrib/docker-compose-normandie-region.yml up -d --force-recreate
```
Fichier attendu : `data/normandie-region.osm.pbf`.

Version Bash :
```bash
./scripts/prepare-normandie-region.sh
docker compose -f contrib/docker-compose-normandie-region.yml up -d --force-recreate
```

---
### 14. Bonnes pratiques
* Garder les PBF sources datés si besoin d’audit (ne pas écraser sans archive).
* Sur serveur de prod : monter un volume dédié SSD pour `/var/lib/postgresql/16/main`.
* Sur import régional : réduire `IMPORT_STYLE=address` si seuls résultats d’adressage nécessaires (plus rapide, moins gourmand).

---
### 15. Nettoyage
```powershell
docker compose -f contrib/docker-compose-normandie.yml down -v
Remove-Item .\data\*.osm.pbf -Force
```

---
### 16. Support
Ouvrir une issue (si contribution upstream) ou adapter ce fichier localement. Fournir : extrait logs d’erreur, commande de fusion utilisée, taille du fichier final, version image Docker.

---
Fin.

---
### Annexe A. Export sur clé USB
Objectif: transférer le PBF fusionné (et métadonnées) vers une machine sans accès internet.

PowerShell:
```powershell
./scripts/export-normandie.ps1
Get-ChildItem .\export\ -Filter *.zip
```

Bash:
```bash
./scripts/export-normandie.sh
ls -lh export/*.zip
```

Contenu de l’archive:
* normandie.osm.pbf
* INFO.txt
* SHA256SUMS.txt
* verify.sh / verify.ps1

Validation sur la machine cible (PowerShell):
```powershell
Expand-Archive -Path .\normandie-<date>.zip -DestinationPath .\normandie-import
cd .\normandie-import
./verify.ps1
```
Bash:
```bash
unzip normandie-<date>.zip -d normandie-import
cd normandie-import
./verify.sh
```

Ensuite copier `normandie.osm.pbf` dans `data/` et lancer le compose.
