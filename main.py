import os
import requests
import psycopg2
from psycopg2 import sql
from dotenv import load_dotenv
import json
from datetime import datetime, timedelta


class GDACSEvent:
    def __init__(self, geometry, properties):
        self.event_id = properties.get('eventid')
        self.event_type = properties.get('eventtype')
        self.event_date = properties.get('eventdate')
        self.name = properties.get('name')
        self.description = properties.get('description')
        self.from_date = properties.get('fromdate')
        self.to_date = properties.get('todate')
        self.alert_level = properties.get('alertlevel')
        self.alert_score = properties.get('alertscore')
        self.episode_alert_level = properties.get('episodealertlevel')
        self.episode_alert_score = properties.get('episodealertscore')
        self.url_to_geometry = properties.get('url', {}).get('geometry')
        self.url_to_report = properties.get('url', {}).get('report')
        self.url_to_details = properties.get('url', {}).get('details')
        self.country = properties.get('country')

        self.geometry = geometry

    def __str__(self):
        return f"Event ID: {self.event_id}, Event Type: {self.event_type}, Coordinates: {self.geometry}, Country: {self.country}"


def crawl_gdacs_events(conn, from_date, to_date):
    base_url = "https://www.gdacs.org/gdacsapi/api/events/geteventlist/SEARCH?"
    parameters = {
        "fromDate": from_date.strftime("%Y-%m-%d"),
        "toDate": to_date.strftime("%Y-%m-%d"),
        "alertlevel": "Green;Orange;Red",
        "eventlist": "EQ;TS,TC,FL,VO,DR,WF"
    }
    url = base_url + "&".join([f"{key}={value}" for key, value in parameters.items()])

    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()

        max_to_date = from_date
        for feature in data['features']:
            geometry = json.dumps(feature.get('geometry'))
            properties = feature.get('properties')
            event = GDACSEvent(geometry, properties)
            insert_event_into_postgresql(conn, event)
            print(event)

            max_to_date = max(max_to_date,datetime.strptime(event.to_date, '%Y-%m-%dT%H:%M:%S'))

            print("-" * 50)
        return max_to_date
    else:
        print("Error:", response.status_code)
        return to_date


def insert_event_into_postgresql(conn, event):
    cursor = conn.cursor()

    with open('insert_gdacs.sql', 'r') as file:
        insert_query = file.read()

    cursor.execute(insert_query, (
        event.geometry, event.event_id, event.event_type, event.name, event.description,
        event.from_date, event.to_date, event.alert_level, event.alert_score,
        event.episode_alert_level, event.episode_alert_score, event.url_to_geometry,
        event.url_to_report, event.url_to_details, event.country
    ))

    connection.commit()
    cursor.close()


def get_start_date(conn):
    cursor = conn.cursor()
    cursor.execute("SELECT last_imported_date FROM hazard.import_log ORDER BY from_date DESC LIMIT 1;")
    latest_import_date_tuple = cursor.fetchone()
    if latest_import_date_tuple is None:
        start = datetime(2024, 1, 1)
    else:
        start = latest_import_date_tuple[0]
    cursor.close()

    return start


def log_about_import(conn, start, end, last_imported):
    cursor = conn.cursor()
    insert_query = "INSERT INTO hazard.import_log (from_date, to_date, last_imported_date) VALUES (%s, %s, %s);"
    cursor.execute(insert_query, (start, end, last_imported))
    conn.commit()
    cursor.close()


# Crawler launch
if __name__ == '__main__':
    load_dotenv()

    dbname = os.getenv("DB_NAME")
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    host = os.getenv("DB_HOST")
    port = os.getenv("DB_PORT")

    connection = psycopg2.connect(dbname=dbname, user=user, password=password, host=host, port=port)

    start_date = get_start_date(connection)
    end_date = datetime.now()

    delta = timedelta(days=1)
    current_date = start_date
    last_imported_date = start_date

    while current_date <= end_date:
        next_date = current_date + delta
        max_to_date = crawl_gdacs_events(connection, current_date, next_date)
        last_imported_date = max(last_imported_date, max_to_date)
        current_date = next_date

    log_about_import(connection, start_date, end_date, last_imported_date)

    connection.close()
