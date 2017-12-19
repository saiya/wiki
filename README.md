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

# Restore backup from S3

Run `restore_dokuwiki_from_backup` command in running container.

# Store backup into S3

Run `backup_dokuwiki` command in running container.
