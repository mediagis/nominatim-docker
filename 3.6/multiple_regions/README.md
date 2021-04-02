# Nominatim commands Multiple regions

1. Build Nominatim Image

```
docker build --pull --rm -t nominatim .
```

2. Update file `multiple_regions/init_multiple_regions.sh`

Replace:

```
COUNTRIES="europe/monaco europe/andorra"
```

with your regions

3. Init with multiple regions

```
docker run -t -v /Users/maximecharruel/Desktop/FT/osmFiles:/data nominatim sh /app/multiple_regions/init.sh
```

# Custom commands Multiple regions

## Add multiple regions

If you already set up the database with init script and want to add new regions, you can use add script

1. Update file `multiple_regions/add_multiple_regions.sh`

Replace:

```
COUNTRIES="europe/monaco europe/andorra"
```

with your regions

2. Add multiple regions

```
docker run -t -v /Users/maximecharruel/Desktop/FT/osmFiles:/data nominatim sh /app/multiple_regions/add.sh
```

## Update multiple regions

If you want to keep your datas updated, you can use update script

1. Update file `multiple_regions/update_multiple_regions.sh`

Replace:

```
COUNTRIES="europe/monaco europe/andorra"
```

with **ALL your regions**, the ones set into init script and the ones added with add script.

2. Update multiple regions

```
docker run -t -v /Users/maximecharruel/Desktop/FT/osmFiles:/data nominatim sh /app/multiple_regions/update.sh
```
