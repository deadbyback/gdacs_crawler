CREATE SCHEMA IF NOT EXISTS hazard;

CREATE DATABASE hazard WITH encoding = 'UTF-8';

CREATE EXTENSION postgis;

CREATE TABLE IF NOT EXISTS hazard.import_log
(
    id serial PRIMARY KEY,
    import_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    from_date DATE,
    to_date DATE,
    last_imported_date DATE
);

CREATE TABLE IF NOT EXISTS hazard.gdacs_events
(
    geom GEOGRAPHY(Point,4326),
    fid serial PRIMARY KEY,
    event_id VARCHAR(255),
    event_type VARCHAR(255),
    name VARCHAR(255),
    description TEXT,
    from_date DATE,
    to_date DATE,
    alert_level VARCHAR(255),
    alert_score FLOAT,
    episode_alert_level VARCHAR(255),
    episode_alert_score FLOAT,
    url_to_geometry TEXT,
    url_to_report TEXT,
    url_to_details TEXT,
    country VARCHAR(255),
    UNIQUE(event_id, event_type)
);

CREATE INDEX IF NOT EXISTS hazard_gdacs_events_wkb_geometry_geom_idx
    ON hazard.gdacs_events
    USING gist (geom);

CREATE INDEX IF NOT EXISTS hazard_gdacs_events_earthquake_type_idx
    ON hazard.gdacs_events
    WHERE event_type = 'EQ';

CREATE INDEX IF NOT EXISTS hazard_gdacs_events_cyclones_type_idx
    ON hazard.gdacs_events
    WHERE event_type = 'TC';

CREATE INDEX IF NOT EXISTS hazard_gdacs_events_floods_type_idx
    ON hazard.gdacs_events
    WHERE event_type = 'FL';

CREATE INDEX IF NOT EXISTS hazard_gdacs_events_volcano_type_idx
    ON hazard.gdacs_events
    WHERE event_type = 'VO';

CREATE INDEX IF NOT EXISTS hazard_gdacs_events_drought_type_idx
    ON hazard.gdacs_events
    WHERE event_type = 'DR';

CREATE TABLE IF NOT EXISTS hazard.another_service_events
(
    geom GEOGRAPHY(Point,4326),
    fid serial PRIMARY KEY,
    event_id VARCHAR(255),
    event_type VARCHAR(255),
    name VARCHAR(255),
    description TEXT,
    from_date DATE,
    to_date DATE,
    alert_level VARCHAR(255),
    alert_score FLOAT,
    episode_alert_level VARCHAR(255),
    episode_alert_score FLOAT,
    url_to_geometry TEXT,
    url_to_report TEXT,
    url_to_details TEXT,
    country VARCHAR(255),
    UNIQUE(event_id, event_type)
);


CREATE OR REPLACE VIEW hazard.earthquake_events AS
    (
        SELECT *
        FROM hazard.gdacs_events
        WHERE gdacs_events.event_type = 'EQ'
    )
    UNION ALL
    (
        SELECT *
        FROM hazard.another_service_events
        WHERE gdacs_events.event_type = 'earthquake'
    );

CREATE OR REPLACE VIEW hazard.cyclones_events AS
    SELECT *
    FROM hazard.gdacs_events
    WHERE gdacs_events.event_type = 'TC';

CREATE OR REPLACE VIEW hazard.flood_events AS
    SELECT *
    FROM hazard.gdacs_events
    WHERE gdacs_events.event_type = 'FL';

CREATE OR REPLACE VIEW hazard.volcano_events AS
    SELECT *
    FROM hazard.gdacs_events
    WHERE gdacs_events.event_type = 'VO';

CREATE OR REPLACE VIEW hazard.drought_events AS
    SELECT *
    FROM hazard.gdacs_events
    WHERE gdacs_events.event_type = 'DR';