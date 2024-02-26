# GDACS hazard events crawler

Crawler of the [Global Disaster Alerting and Coordination System (GDACS)](https://www.gdacs.org/feed_reference.aspx) hazard events data.

## How it works

Natural hazard events data provided by external authorities is loaded 
into the `hazard.gdacs_events` layer located in PosgreSQL/PostGIS database.

## Getting started

### Docker container

Launch Dockerfile  
   `python3 -m pip install psycopg2-binary`

OR

Install [PostGIS database](https://postgis.net/install/) and run `init.sql`.

### Setup the hazard events crawler database

Initialize database connection settings in the .env file (according to the sample).
     
### Run Crawler

Import the GDACS hazard events data by command `python3 main.py`  

## Database schema

All data by GDACS is loaded into `gdacs_events` table located in `hazard` schema. 

```
ATTRIBUTE LIST
geom                geography(Point, 4326),
fid                 serial primary key,
event_id            varchar(255),
event_type          varchar(255),
name                varchar(255),
description         text,
from_date           date,
to_date             date,
alert_level         varchar(255),
alert_score         double precision,
episode_alert_level varchar(255),
episode_alert_score double precision,
url_to_geometry     text,
url_to_report       text,
url_to_details      text,
country             varchar(255)
```


There are the sample of created views for specific hazard types:
- `earthquake_events`
- `cyclones_events`
- `flood_events`
- `volcano_events`
- `drought_events`

All views have the same attributes as `gdacs_events` table.

## Opportunities for expansion

For other similar services, you can create a new table, import the data in the same way, and then modify the views by unioning new table to the existing one.

## Additional data provider list
   - [Earth Observatory Natural Event Tracker (EONET)](https://eonet.sci.gsfc.nasa.gov/docs/v3)  
   - [USGG Earthquake Hazards Program](https://earthquake.usgs.gov/fdsnws/event/1/)  
   - [EPOS Seismic Portal](https://www.seismicportal.eu/fdsn-wsevent.html)  
