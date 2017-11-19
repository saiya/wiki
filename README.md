Dokuwiki docker container with S3 backup mechanism.

# Build and run container

```
docker build -t wiki .
```

# Restore backup from S3

```
docker run -it \
  -e 'AWS_ACCESS_KEY_ID=...' \
  -e 'AWS_SECRET_ACCESS_KEY=...' \
  -e 'AWS_DEFAULT_REGION=ap-northeast-1' \
  -e 'S3_BACKUP_DIR=s3://...' \
  -e 'BACKUP_ZIP_PASSWORD=...'
  wiki restore_dokuwiki_from_backup
```

# Store backup into S3

```
docker run -it \
  -e 'AWS_ACCESS_KEY_ID=...' \
  -e 'AWS_SECRET_ACCESS_KEY=...' \
  -e 'AWS_DEFAULT_REGION=ap-northeast-1' \
  -e 'S3_BACKUP_DIR=s3://...' \
  -e 'BACKUP_ZIP_PASSWORD=...'
  wiki backup_dokuwiki
```