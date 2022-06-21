# minio-dokku

## Server Setup

```
dokku apps:create minio
dokku config:set minio MINIO_ACCESS_KEY=$(echo `openssl rand -base64 64` | cut -c 1-64)
dokku config:set minio MINIO_SECRET_KEY=$(echo `openssl rand -base64 64` | cut -c 1-64)

dokku nginx:set minio client-max-body-size 100m

dokku config:set minio DOKKU_LETSENCRYPT_EMAIL=
dokku proxy:ports-add minio http:80:9000
dokku proxy:ports-remove minio http:9000:9000
dokku domains:set minio minio.metropolitanabolivia.org
```

> **Note:** If you don't set the access keys, Minio will generate them during startup
> and output them to the log (check if via `dokku logs minio`). You will still need
> to set them manually.

## Client Setup

```
brew install minio/stable/mc
mc alias set minio https://minio.metropolitanabolivia.org MINIO_ACCESS_KEY MINIO_SECRET_KEY --api S3v4
mc mb minio/metropolitan
```

## Push Minio to Dokku

```
git remote add production dokku@example.com:minio
git push production main
```
