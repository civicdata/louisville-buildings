#PYTHON=python

#NOLA_Addresses_tulane_processed.osm: NOLA_Addresses_tulane.osm
#	$(PYTHON) process_addresses.py < $< > $@

all: NOLA_Addresses_20140221 NOPD BuildingOutlines2013 directories chunks osm

NOLA_Addresses_20140221.zip:
	curl -L "https://data.nola.gov/download/div8-5v7i/application/zip" -o NOLA_Addresses_20140221.zip

NOLA_Addresses_20140221: NOLA_Addresses_20140221.zip
	rm -rf NOLA_Addresses_20140221
	unzip NOLA_Addresses_20140221.zip -d NOLA_Addresses_20140221
	ogr2ogr -t_srs EPSG:4326 -overwrite NOLA_Addresses_20140221/addresses.shp NOLA_Addresses_20140221/NOLA_Addresses_20140221.shp

NOPD_Districts.zip:
	curl -L "https://data.nola.gov/api/geospatial/8yny-6sic?method=export&format=Shapefile" -o NOPD_Districts.zip

NOPD: NOPD_Districts.zip
	rm -rf NOPD
	unzip NOPD_Districts.zip -d NOPD
	ogr2ogr -t_srs EPSG:4326 NOPD/NOPD-districts.shp NOPD/NOPD.shp

BuildingOutlines2013.zip:
	curl -L "https://data.nola.gov/download/t3vb-bbwe/application/zip" -o BuildingOutlines2013.zip

BuildingOutlines2013: BuildingOutlines2013.zip
	rm -rf BuildingOutlines2013
	unzip BuildingOutlines2013.zip -d BuildingOutlines2013
#	ogr2ogr -simplify 0.2 -t_srs EPSG:4326 -overwrite BuildingOutlines2013/buildings.shp BuildingOutlines2013/BuildingOutlines2013.shp
	ogr2ogr -t_srs EPSG:4326 -overwrite BuildingOutlines2013/buildings.shp BuildingOutlines2013/BuildingOutlines2013.shp

chunks: directories
	rm -f chunks/*
	python chunk.py BuildingOutlines2013/buildings.shp NOPD/NOPD-districts.shp chunks/buildings-%s.shp District
	python chunk.py NOLA_Addresses_20140221/addresses.shp NOPD/NOPD-districts.shp chunks/addresses-%s.shp District

osm: directories
	rm -f osm/*
	python convert.py

directories:
	mkdir -p chunks
	mkdir -p osm
