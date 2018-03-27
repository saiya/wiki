Dokuwiki docker container with S3 backup mechanism.

# Build and run container

```
docker build -t wiki .  # or use `./push_to_ecr.sh` to push AWS ECR

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

## Build and upload to AWS ECR

`push_to_ecr.sh` is useful to upload this image into your ECR repository.


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

### Encrypt `BACKUP_ZIP_PASSWORD` with AWS KMS

You can use `BACKUP_ZIP_PASSWORD_ENCRYPTED` variable instead of `BACKUP_ZIP_PASSWORD`.

To use it, see following procedure:

1. Create AWS KMS master key
2. Encrypt ZIP password with it: `aws kms encrypt --key-id alias/NAME_OF_YOUR_KEY --plaintext "ZIP_PASSWORD_TO_ENCRYPT" --query CiphertextBlob --output text` (requires AWS CLI tool)
  - Don't forget to replace `NAME_OF_YOUR_KEY` and also `ZIP_PASSWORD_TO_ENCRYPT`
  - This command outputs Base64 string (encrypted password)
3. Set output of above command into `BACKUP_ZIP_PASSWORD_ENCRYPTED` variable
4. Delete `BACKUP_ZIP_PASSWORD` variable (if exists)

And also, if you set your key alias (`alias/NAME_OF_YOUR_KEY`) into `BACKUP_ZIP_PASSWORD_REENCRYPT_KEY` variable, encrypted zip password will be saved into `EncryptedZipPassword` S3 metadata. I recommend this for just in case when you lost both ZIP password and encrypted password.

If you had set `BACKUP_ZIP_PASSWORD_REENCRYPT_KEY` on backup, anytime you can recover zip password with this command: `aws kms decrypt --ciphertext-blob fileb://<(echo 'VALUE_OF_EncryptedZipPassword_METADATA' | base64 -d)` (see `PlainText` of output JSON).
