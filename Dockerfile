FROM minio/minio:RELEASE.2025-04-22T22-12-26Z

# Run as UID 32769 without creating a user,
# required to give this user permissions to the mounted directory
USER 32769

# Create data directory for the user, where we will keep the data
RUN mkdir -p /home/dokku/data

# Add custom nginx.conf template for Dokku to use
WORKDIR /app
ADD nginx.conf.sigil .

CMD ["minio", "server", "/home/dokku/data", "--console-address", ":9001"]
