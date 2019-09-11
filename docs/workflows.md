### [◀](README.md)

# Workflows 101 (a.k.a. functions calling functions)

## Building your first workflow (from [OpenFaaS workshop](https://github.com/openfaas/workshop/blob/master/lab4.md#kubernetes-1))

Using the CLI:

```
$ faas-cli store deploy SentimentAnalysis
```

The Sentiment Analysis function will tell you the subjectivity and polarity (positivity rating) of any sentence. The result of the function is formatted in JSON as per the example below:

```
$ echo -n "California is great, it's always sunny there." | faas-cli invoke sentimentanalysis
{"polarity": 0.8, "sentence_count": 1, "subjectivity": 0.75}
```

Now let's create a new simple function (like in the previous exercise) that will call `sentimentanalysis` just forwarding the request text.

The `handler.py` code should look like:

```python
import os
import requests
import sys

def handle(req):
    """handle a request to the function
    Args:
        req (str): request body
    """

    gateway_hostname = os.getenv("gateway_hostname", "gateway") # uses a default of "gateway" for when "gateway_hostname" is not set

    test_sentence = req

    r = requests.get("http://" + gateway_hostname + ":8080/function/sentimentanalysis", data= test_sentence)

    if r.status_code != 200:
        sys.exit("Error with sentimentanalysis, expected: %d, got: %d\n" % (200, r.status_code))

    result = r.json()
    if result["polarity"] > 0.45:
        return "That was probably positive"
    else:
        return "That was neutral or negative"
```

You can now try to invoke the new function, verifying that the request has been forwarded to `sentimentanalysis` by your custom function. We have just created a basic workflow.

# Triggers

## Example: using storage events webhook

If you are using Vagrant image you can start from here, otherwise at the end you'll find how to setup a S3 object storage on your own.

Let's configure it properly for using a webhook that points to our openfaas instance (we will use it later to trigger a function as soon as a new file appears).

```bash
mc admin config set local < /home/vagrant/config_minio.json
mc admin service restart local
```

The request sent to the function by Minio in case of a file upload will have a body in this form:

```text
{"EventName":"s3:ObjectCreated:Put","Key":"images/test7.jpg","Records":[{"eventVersion":"2.0","eventSource":"minio:s3","awsRegion":"","eventTime":"2019-09-10T14:27:46Z","eventName":"s3:ObjectCreated:Put","userIdentity":{"principalId":"dciangot"},"requestParameters":{"accessKey":"dciangot","region":"","sourceIPAddress":"192.168.0.213"},"responseElements":{"content-length":"0","x-amz-request-id":"15C319FC231726B5","x-minio-deployment-id":"f6a78fdc-8d8e-4d2c-8aca-4b0bd4082129","x-minio-origin-endpoint":"http://192.168.0.213:9000"},"s3":{"s3SchemaVersion":"1.0","configurationId":"Config","bucket":{"name":"images","ownerIdentity":{"principalId":"dciangot"},"arn":"arn:aws:s3:::images"},"object":{"key":"test7.jpg","size":1767621,"eTag":"1f9ae70259a36b5c1b5692f91386bb75-1","contentType":"image/jpeg","userMetadata":{"content-type":"image/jpeg"},"versionId":"1","sequencer":"15C319FC2679B7CB"}},"source":{"host":"192.168.0.213","port":"","userAgent":"MinIO (linux; amd64) minio-go/v6.0.32 mc/2019-09-05T23:43:50Z"}}]}
```

Now create two buckets called `incoming` and `processed`

```bash
mc mb local/incoming
mc mb local/processed
```

You can log into the WebUI at `http://localhost:9000` with username `admin` and password `adminminio`.
From there you can upload files and check the contents of the buckets.


### Trigger a facedetect function on loaded images

SPIEGA CONTENUTO DEI FILE

```bash
git clone https://github.com/Cloud-PG/miniofaas.git
cd miniofaas
faas-cli build -f processimages.yml
faas-cli push -f processimages.yml
faas-cli deploy -f processimages.yml
```

Now, once the functions will be ready you should try to upload a jpg image to the `incoming` bucket and soon you should be able to find a processed file in the `processed` bucket that you can download from the webUI and visualize.


## HOMEWORK



## EXTRA: Setting up an S3-compatible storage

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