# alpine-uwsgi-flask

Minimal python Flask application uWSGI server packed into docker alpine container.

## Motivation

I found there could be found no functional servers examples of [docker alpine](https://hub.docker.com/_/alpine) [python](https://hub.docker.com/_/python) + [uWSGI](https://uwsgi-docs.readthedocs.io/) + [Flask](https://flask.palletsprojects.com/). So I decided to create the example on my own.


## Content
In the project you cna find these files:

- `hello.py` - File is basic Flask project with `app` object instance inside. 
- `requirements.txt` - Python dependencies are listed here together with your weapon of choice uWSGI <3. 
- `uwsgi.ini` - Simple uWSGI server configuration. It describes how uWSGI uses your `hello.py` so these two are closely related.
- `Dockerfile` - Blueprint of your docker image you want to create. Files `uwsgi.ini` and `Dockerfile` depend closely on each other because they include system paths.
- meta files:
    - `.gitignore` - Files listed here are not traced by your Git.
    - `.dockerignore` - Files and folders listed here are ignored during docker image building. Similar function as `.gitignore` file in Git. Do not forget on this one. Otherwise your `venv` and `.git` will be included in result image!


## Build Image

Navigate into folder with `Dockerfile`.

```bash
cd ./alpine-uwsgi-flask
```

Use standard `docker build` command. File `Dockerfile` in folder `.` is used as blueprint for build. Option `-t uwsgi_flask:latest` sets name of result `image`. ANd wait a moment until build is finished.

```bash
docker build -t uwsgi_flask:latest .
```

Verify new image `uwsgi_flask` exist with `docker images`:

```bash
$ docker images
REPOSITORY            TAG                 IMAGE ID            CREATED                 SIZE
uwsgi_flask           latest              80d6561f19c8        About a minute ago      119MB
```


### Result Image

When you compare the base image `python:3-alpine` (107MB)  with new `uwsgi_flask` (size 119MB) you found that our build process is lightweight.

```bash
$ docker images
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
uwsgi_flask           latest              80d6561f19c8        About a minute ago   119MB
python                3-alpine            d5e5ad4a4fc0        10 days ago          107MB
```

You can check how many layers (lower is better) build created and hat is their size with command `docker history <image>`. 
In in example you can see new layers are on top and oldest on bottom. Original `python:3-alpine` layers have been created `10 days ago`:

```bash
$ docker history uwsgi_flask
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
80d6561f19c8        About an hour ago   /bin/sh -c #(nop)  ENTRYPOINT ["uwsgi" "--in…   0B                  
dab62f64ba70        About an hour ago   /bin/sh -c #(nop) COPY dir:c05a6df6eb704aa63…   2.36kB              
2ff74ede30b8        About an hour ago   /bin/sh -c set -e;  apk add --no-cache --vir…   11.6MB              
4250fa106fa8        About an hour ago   /bin/sh -c #(nop) COPY file:89a90004d608dbc8…   21B                 
1b323cea6365        About an hour ago   /bin/sh -c #(nop)  VOLUME ["/etc/app"]          0B                  
f01532bd2177        About an hour ago   /bin/sh -c #(nop) WORKDIR /opt/app              0B                  
d12d1602294d        About an hour ago   /bin/sh -c mkdir -p /opt/app && mkdir -p /et…   0B                  
18fdf32f199d        About an hour ago   /bin/sh -c #(nop)  EXPOSE 5000                  0B                  
964ff302dfb9        About an hour ago   /bin/sh -c #(nop)  MAINTAINER ryu-cz            0B                  
d5e5ad4a4fc0        10 days ago         /bin/sh -c #(nop)  CMD ["python3"]              0B                  
<missing>           10 days ago         /bin/sh -c set -ex;   wget -O get-pip.py "$P…   6.34MB              
<missing>           10 days ago         /bin/sh -c #(nop)  ENV PYTHON_GET_PIP_SHA256…   0B                  
<missing>           10 days ago         /bin/sh -c #(nop)  ENV PYTHON_GET_PIP_URL=ht…   0B                  
<missing>           10 days ago         /bin/sh -c #(nop)  ENV PYTHON_PIP_VERSION=20…   0B                  
<missing>           10 days ago         /bin/sh -c cd /usr/local/bin  && ln -s idle3…   32B                 
<missing>           10 days ago         /bin/sh -c set -ex  && apk add --no-cache --…   94.7MB              
<missing>           10 days ago         /bin/sh -c #(nop)  ENV PYTHON_VERSION=3.8.2     0B                  
<missing>           10 days ago         /bin/sh -c #(nop)  ENV GPG_KEY=E3FF2839C048B…   0B                  
<missing>           10 days ago         /bin/sh -c apk add --no-cache ca-certificates   553kB               
<missing>           10 days ago         /bin/sh -c #(nop)  ENV LANG=C.UTF-8             0B                  
<missing>           10 days ago         /bin/sh -c #(nop)  ENV PATH=/usr/local/bin:/…   0B                  
<missing>           10 days ago         /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B                  
<missing>           10 days ago         /bin/sh -c #(nop) ADD file:0c4555f363c2672e3…   5.6MB 
```


## Run New Image

From new image `uwsgi_flask` you can create `container` instance with command `docker run`. Option `-p 127.0.0.1:5000:5000` publishes port `5000` from container into you localhost `127.0.0.1:5000`:

```bash
docker run -d -p 127.0.0.1:5000:5000 --name wsgi uwsgi_flask
```


Confirm there is new running container named `wsgi` base on your image `uwsgi_flask` with command `docker ps`.

```bash
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS                      NAMES
d6b97d42ba79        uwsgi_flask         "uwsgi --ini-paste /…"   About a minute ago   Up About a minute   127.0.0.1:5000->5000/tcp   wsgi
```


And test it:

```bash
$ curl "http://localhost:5000"
Hello, World!
```

