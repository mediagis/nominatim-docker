### Configuration Example

A setup example with almost all flag possibilities including a short explanation:

```sh

docker run -it \

	-v nominatim-flatnode:/nominatim/flatnode \
	#Sets the flatnode file, which is to reduce the load on the database when you plan to use multiple countrys together bigger than 6GB
	#and highly recommended if you want to import the World!
	
	-e POSTGRES_SHARED_BUFFERS=2GB \
	-e POSTGRES_MAINTAINENCE_WORK_MEM=10GB \
	-e POSTGRES_AUTOVACUUM_WORK_MEM=2GB \
	-e POSTGRES_WORK_MEM=50MB \
	-e POSTGRES_EFFECTIVE_CACHE_SIZE=24GB \
	-e POSTGRES_SYNCHRONOUS_COMMIT=off \
	-e POSTGRES_MAX_WAL_SIZE=1GB \
	-e POSTGRES_CHECKPOINT_TIMEOUT=10min \
	-e POSTGRES_CHECKPOINT_COMPLETITION_TARGET=0.9 \
	#PostgreSQL Tuning, without the need to edit the .conf after the setup(Nominatim default recommended values)

	-e PBF_URL=https://ftp5.gwdg.de/pub/misc/openstreetmap/planet.openstreetmap.org/pbf/planet-latest.osm.pbf \
	#Sets the target for the initial file for the import. If the files aleready on the local System you use:
	#-e PBF_PATH=/path/to/your/planet-latest.osm.pbf 	PBF_URL cannot be used together with PBF_PATH!

	-e REPLICATION_URL=https://ftp5.gwdg.de/pub/misc/openstreetmap/planet.openstreetmap.org/replication/day/ \
	#Sets the Path, where Nominatim gets the map updates - the REPLICATION_URL is never a file.

	-e REPLICATION_UPDATE_INTERVAL=43200
	#How often upstream publishes diffs (in seconds, default: 86400). Requires REPLICATION_URL to be set.

	-e REPLICATION_RECHECK_INTERVAL=450 
	#How long to sleep if no update found yet (in seconds, default: 900). Requires REPLICATION_URL to be set.

	-e UPDATE_MODE=continuous/once/catch-up/none
	#Configures the way the map files will be updated (default: none)

	-e FREEZE=true/false
	#Disables the updates to save space for example (default: false)

	-e REVERSE_ONLY=True/false
	#If you only want to use the Nominatim database for reverse lookups. (default: false)

	-e IMPORT_WIKIPEDIA=true\false
	#When enabled additional Wikipedia Data will be loaded (default off)

	-e IMPORT_US_POSTCODES=true\false 
	#Whether to download and import the US postcode dump (true) or path to US postcode dump in the container. (default: false)

	-e IMPORT_GB_POSTCODES=true\false 
	#Whether to download and import the GB postcode dump (true) or path to GB postcode dump in the container. (default: false)

	-e IMPORT_STYLE=admin/street/address/full/extratags
	#Sets either an importfilter for a reduced data import or the full set and the full set with additional data(default: full):
	#admin: Only import administrative boundaries and places.
	#street: Like the admin style but also adds streets.
	#address: Import all data necessary to compute addresses down to house number level.
	#full: Default style that also includes points of interest.
	#extratags: Like the full style but also adds most of the OSM tags into the extratags column.
	
	-e IMPORT_TIGER_ADDRESSES=true\false 
	#Whether to download and import the Tiger address data (true) or path to a preprocessed Tiger address set in the container. (default: false)

	-e THREADS=10 \
	#Sets the used threads at the import (default 16)

	--shm-size=60g \
	#Sets the Docker tmpfs. Highly recommended for bigger imports like Europe. At least 1GB - ideally half of aviable RAM. 

	-e NOMINATIM_PASSWORD=supersafepassword
	#The password to connect to the database with (default: qaIACxO6wMR3)

	-p 8080:8080 \
	#Sets the ports of the container guest:host

	--name nominatim \
	#Sets the name of the container

	mediagis/nominatim:4.3 
	#Here you choose the Docker image and version
	
```

