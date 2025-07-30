[![MinIO Version](https://img.shields.io/badge/Minio-latest-blue.svg)]() [![Dokku Version](https://img.shields.io/badge/Dokku-v0.35.20-blue.svg)]()

# Run MinIO on Dokku

### What is MinIO?

[MinIO](https://www.minio.io) is a high-performance, S3 compatible object storage.

### What is Dokku?

[Dokku](http://dokku.com/) is an open source PAAS alternative to Heroku. It helps you build and manage the lifecycle of applications from building to scaling.

## Getting started

We are going to use the domain `minio.example.com` and Dokku app `minio` for demonstration purposes. Make sure to replace it.

Open the connection to the remote server and run:

```bash
# Create the dokku app
dokku apps:create minio

# Set the environment variables
dokku config:set minio MINIO_ROOT_USER=$(echo `openssl rand -base64 45` | tr -d \=+ | cut -c 1-20)
dokku config:set minio MINIO_ROOT_PASSWORD=$(echo `openssl rand -base64 45` | tr -d \=+ | cut -c 1-48)
dokku config:set minio NGINX_MAX_REQUEST_BODY=100M
dokku config:set minio MINIO_DOMAIN=minio.example.com

# Set the domain
dokku domains:set minio minio.example.com
```

Close the connection to the server. Clone this repository onto your machine, and deploy the code.

```bash
git clone git@github.com:josuemontano/minio-dokku.git
cd minio-dokku

git remote add production dokku@[IP_v4]:minio
git push production
```

Now, open the connection to the remote server once again and run:

```bash
# Generate an SSL certificate with Let's Encrypt
sudo dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git
dokku letsencrypt:set minio email user@example.com
dokku letsencrypt:enable minio

# Map ports
dokku ports:set minio http:80:9000
dokku ports:set minio https:443:9000
```

Your Minio instance should now be available on [minio.example.com](https://minio.example.com).

## Persistent storage

To persists uploaded data between restarts, we create a folder on the host
machine, add write permissions to the user defined in `Dockerfile` and tell
Dokku to mount it to the app container.

```bash
sudo mkdir -p /var/lib/dokku/data/storage/minio
sudo chown 32769:32769 /var/lib/dokku/data/storage/minio
dokku storage:mount minio /var/lib/dokku/data/storage/minio:/home/dokku/data
```

## Domain setup

To get the routing working, we need to apply a few settings. First we set
the domain.

```bash
dokku domains:set minio minio.example.com
```

The parent Dockerfile, provided by the [Minio
project](https://github.com/minio/minio), exposes port `9000` for web requests.
Dokku will set up this port for outside communication, as explained in [its
documentation](http://dokku.viewdocs.io/dokku/advanced-usage/proxy-management/#proxy-port-mapping).
Because we want Minio to be available on the default port `80` (or `443` for
SSL), we need to fiddle around with the proxy settings.

First add the correct port mapping for this project as defined in the parent
`Dockerfile`.

```bash
dokku ports:add minio http:80:9000
dokku ports:add minio https:443:9000
dokku ports:add minio https:9001:9001
```

Next remove the proxy mapping added by Dokku.

```bash
dokku ports:remove minio http:80:5000
```
