FROM minio/minio:RELEASE.2025-04-22T22-12-26Z

# Create data directory for the user, where we will keep the data
USER root
RUN mkdir -p /home/dokku/data && chown -R 32769:32769 /home/dokku

# Run as UID 32769 without creating a user,
# required to give this user permissions to the mounted directory
USER 32769

# Add custom nginx.conf template for Dokku to use
WORKDIR /app
ADD nginx.conf.sigil .

CMD ["minio", "server", "/home/dokku/data", "--console-address", ":9001"]
