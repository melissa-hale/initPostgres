FROM postgres:latest

# Copy the entrypoint script to the Docker image
COPY ./configure_db.sh /docker-entrypoint-initdb.d/

RUN chmod +x /docker-entrypoint-initdb.d/configure_db.sh
