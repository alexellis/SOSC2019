### [◀](README.md)


# Working with functions

You can get a local environment ready using Vagrant for an automatic setup Virtualbox machine:

```bash
git clone https://github.com/Cloud-PG/SOSC2019.git
cd SOSC2019
# This may take few minutes
vagrant up
# Log into the created machine
vagrant ssh
```

N.B. Vangrant and Virtualbox are required on the machine of course.


## Using example functions and WebUI

Now you can go to `http://localhost:31112/ui/` and, using the password in gateway_password.txt with user `admin`, you should be able to login.

Let's start playing with some example functions. For instance you can instantiate a function the facedetection of an online image with:

```
Deploy new function -> face-detect with OpenCV -> Deploy
```

Now a new tab should appear with the function name selected. From there you can check the status and also try to invoke the function from the UI.
For instance, as soon as the status of the function is ready, lets try to put a url with a jpg image in the request body field and then press invoke.

The list of the function in store is also available from CLI with:

```bash
faas-cli store list
```


## Deployment of a python function (from [OpenFaaS workshop](https://github.com/openfaas/workshop/blob/master/lab3.md#example-function-astronaut-finder))

Hanno tutti un docker account?

```bash
mkdir astronaut-finder
cd astronaut-finder

faas-cli new --lang python3 astronaut-finder --prefix="<your-docker-username-here>"
```


### Function fundamentals

This will write three files for us:

```./astronaut-finder/handler.py```
The handler for the function - you get a req object with the raw request and can print the result of the function to the console.

```./astronaut-finder/requirements.txt```
Use this file to list any pip modules you want to install, such as requests or urllib

```./astronaut-finder.yml```
This file is used to manage the function - it has the name of the function, the Docker image and any other customisations needed.

Edit `./astronaut-finder/requirements.txt`:

```
requests
```


### Write the function's code

We'll be pulling in data from: http://api.open-notify.org/astros.json

Here's an example of the result:

```
{"number": 6, "people": [{"craft": "ISS", "name": "Alexander Misurkin"}, {"craft": "ISS", "name": "Mark Vande Hei"}, {"craft": "ISS", "name": "Joe Acaba"}, {"craft": "ISS", "name": "Anton Shkaplerov"}, {"craft": "ISS", "name": "Scott Tingle"}, {"craft": "ISS", "name": "Norishige Kanai"}], "message": "success"}
```

Update handler.py:

```python
import requests
import random

def handle(req):
    r = requests.get("http://api.open-notify.org/astros.json")
    result = r.json()
    index = random.randint(0, len(result["people"])-1)
    name = result["people"][index]["name"]

    return "%s is in space" % (name)
```


### Deploy a function

First build it:

```bash
faas-cli build -f ./astronaut-finder.yml
```

Push the function:

```bash
docker login
faas-cli push -f ./astronaut-finder.yml
```

Deploy the function:

```bash
export OPENFAAS_URL=http://127.0.0.1:31112
cat  /home/vagrant/gateway-password.txt | faas-cli login --password-stdin
faas-cli deploy -f ./astronaut-finder.yml
```

And now, just wait a bit for the function to be in `Ready` state 

```
$ faas-cli describe astronaut-finder | grep Status
Status:              Ready
```

and then try to invoke it from command line:

```
$ echo | faas-cli invoke astronaut-finder
Anton Shkaplerov is in space
```

or from the http endpoint:

```
$ curl http://localhost:31112/function/astronaut-finder
Joe Acaba is in space
```


## HOMEWORK

- Try to create a function for serving your ML model (you can also make use of: https://github.com/alexellis/tensorflow-serving-openfaas )
- Create a function in a different language if you know any