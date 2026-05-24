# This script calls the nominatim command inside the container
# - with the right user "nominatim"
# - in the project directory "/nominatim"
# - and with the environement of user root (defined in docker-compose.yml or set by docker run command)
# The name of the container may need to be adjusted.
# example: nominatim.bat replication --check-for-updates
docker exec -it -w /nominatim nominatim sudo -E -u nominatim nominatim $@
