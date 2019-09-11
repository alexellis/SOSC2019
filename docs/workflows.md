### [◀](README.md)

# Workflows 101

## Building your first workflow

https://github.com/openfaas/workshop/blob/master/lab4.md#kubernetes-1

## Triggers: using storage events

### Setting up an S3-compatible storage

```bash
mkdir $HOME/minio_data
docker run -d -v $HOME/minio_data:/data -p 9000:9000 -e "MINIO_ACCESS_KEY=admin" -e "MINIO_SECRET_KEY=admindciangot"  minio/minio server /data
```

prendi config da gist

```bash
./mc event add local/incoming arn:minio:sqs::1:webhook --event put --suffix .jpg
```

```bash
wget https://dl.min.io/client/mc/release/linux-amd64/mc
mv mc /usr/bin/mc
sudo chmod +x /usr/bin/mc
```
prendi config mc da gist

crea buckets

### Minio WebUI 101


### Trigger an echo function


### Trigger a facedetect function on loaded images

```bash
git clone https://github.com/Cloud-PG/miniofaas.git
cd miniofaas
faas-cli build -f processimages.yml
faas-cli push -f processimages.yml
faas-cli deploy -f processimages.yml
```