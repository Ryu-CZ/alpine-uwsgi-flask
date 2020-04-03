# alpine-uwsgi-flask  
  
Minimal python Flask application uWSGI server packed into docker alpine container.  
  

## Motivation  
  
I found there could be found no functional servers examples of [docker alpine](https://hub.docker.com/_/alpine) [python](https://hub.docker.com/_/python) + [uWSGI](https://uwsgi-docs.readthedocs.io/) + [Flask](https://flask.palletsprojects.com/). So I decided to create the example on my own.  

  
> Why uWSGI?   

It is really good web server. It is written with intention to be just web server, nothing more and nothing less. It is blazing fast in real life applications and well scalable with WSGI frameworks like Flask. 
  
> What else I need

It is good idea to put dedicated proxy between the Internet and your uWSGI server. Dedicated proxy is securite, fast and lightweigt. My APIs are using [Nginx](https://www.nginx.com/). It is good secure, free and open source option... also p---hub uses it so why not you?
 
> Why NOT Apache  
  
It does not support WSGI and python applications by default. It is not just web server but also a load balancer, proxy and traffic monitor. This makes Apache resource hungry monoolith bad for easy scalability. 

Example from real life usage of uWSGI and Apache running the same REST API code written in Flask :   
  
Hardware:  
 - CPU 4   
 - RAM 2GB  
  
| server | workers | CPU usage | RAM usage | Swapping | latency (ms) |  
|--|--|--|--|--|--|
| Apache | 12 | 100% | 100% | Yes | 1000 - 20 000 |  
| uWSGI | 32 | 20% | 60% | No | 50-125 |    
  

## Content  
In the project you find these files:  
  
- `hello.py` - File is basic Flask project with `app` object instance inside.   
- `requirements.txt` - Python dependencies are listed here together with your weapon of choice uWSGI <3.   
- `uwsgi.ini` - Simple uWSGI server configuration. It describes how uWSGI uses your `hello.py` so these two are closely related.  
- `Dockerfile` - Blueprint of docker image you want to create. Files `uwsgi.ini` and `Dockerfile` depend closely on each other because they include system paths.  
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
  
When you compare the base image `python:3-alpine` *(107MB)*  with new `uwsgi_flask` *(119MB)* you found that our build process is pretty lightweight.  
  
```bash  
$ docker images  
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE  
uwsgi_flask           latest              80d6561f19c8        About a minute ago   119MB  
python                3-alpine            d5e5ad4a4fc0        10 days ago          107MB  
```  
  
> You can check how many layers *(less is better)* build created and check their size with command `docker history <image>`.   You can see new layers are on top and oldest on bottom. 

  
## Run New Image  
  
From new image `uwsgi_flask` you can create `container` instance with command `docker run`. Option `-p 127.0.0.1:5000:5000` publishes port `5000` from container into you localhost `127.0.0.1:5000`.  
  
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
 