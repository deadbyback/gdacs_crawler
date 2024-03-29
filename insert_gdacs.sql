INSERT INTO hazard.gdacs_events
(
    geom,
    event_id,
    event_type,
    name,
    description,
    from_date,
    to_date,
    alert_level,
    alert_score,
    episode_alert_level,
    episode_alert_score,
    url_to_geometry,
    url_to_report,
    url_to_details,
    country
)
VALUES
(
    ST_GeomFromGeoJSON(%s),
    %s,
    %s,
    %s,
    %s,
    %s::DATE,
    %s::DATE,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s
)
ON CONFLICT (event_id, event_type) DO NOTHING;
;

