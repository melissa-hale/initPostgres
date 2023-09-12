FROM postgres:latest

# Copy the entrypoint script to the Docker image
COPY ./entrypoint.sh /docker-entrypoint-initdb.d/

RUN chmod +x /docker-entrypoint-initdb.d/entrypoint.sh
