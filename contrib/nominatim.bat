@ECHO OFF
REM This script calls the nominatim command inside the container
REM - with the right user "nominatim"
REM - in the project directory "/nominatim"
REM - and with the environement of user root (defined in docker-compose.yml or set by docker run command)
REM The name of the container may need to be adjusted.
REM example: nominatim.bat replication --check-for-updates
docker exec -it -w /nominatim nominatim sudo -E -u nominatim nominatim %*
