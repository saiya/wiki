Dokuwiki docker container with S3 backup mechanism.

# Build and run container

```
docker build -t wiki .  # or use `./push_to_aws_ecr.sh` to push AWS ECR

docker run -it \
  -p 8080:80 \
  -v /tmp/dokuwiki:/dokuwiki \
  -e 'AWS_ACCESS_KEY_ID=...' \
  -e 'AWS_SECRET_ACCESS_KEY=...' \
  -e 'AWS_DEFAULT_REGION=ap-northeast-1' \
  -e 'S3_BACKUP_DIR=s3://...' \
  -e 'BACKUP_ZIP_PASSWORD=...'
  wiki
```

# dokuwiki data persistence

## Docker volume

All dokuwiki data/system are stored into `/dokuwiki` directory (in Docker).

If you want to preserve wiki data over container restart, mount any directory on it (e.g. `-v /tmp/dokuwiki:/dokuwiki`).

And also, you can use following commands to backup/restore all wiki data with S3 (recommended).

## Restore backup from S3

Run `restore_dokuwiki_from_backup` command in running container. If `/dokuwiki` directory is empty, this container automatically run this command at startup time.

## Store backup into S3

Run `backup_dokuwiki` command.

To backup wiki data of running container, mount `/dokuwiki` directory to share data among running container and `backup_dokuwiki` command container.

```
# Run below command to backup wiki
docker run -it \
  -p 8080:80 \
  -v /tmp/dokuwiki:/dokuwiki \            <- Share data among running container and `backup_dokuwiki` command container
  -e 'AWS_ACCESS_KEY_ID=...' \
  -e 'AWS_SECRET_ACCESS_KEY=...' \
  -e 'AWS_DEFAULT_REGION=ap-northeast-1' \
  -e 'S3_BACKUP_DIR=s3://...' \
  -e 'BACKUP_ZIP_PASSWORD=...'
  backup_dokuwiki                         <- Run backup_dokuwiki command instead of wiki server
```
