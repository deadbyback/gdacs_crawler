FROM postgres:14

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-14-postgis-3 \
        postgresql-14-postgis-3-scripts \
        postgresql-contrib-14 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY init.sql /docker-entrypoint-initdb.d/

# You can configure env
# ENV POSTGRES_PASSWORD 123

EXPOSE 5433
