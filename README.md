# My Docker Scripts
Becuase Kubernetes is hard...

## Usage

MDS is essentially a `make` wrapper for docker.  Typing `make new` will allow
you to create a new container.  It creates a new directory, and inside that
directory, it makes an `mds.sh` script.  That script is responsible for
starting, stopping, removing, building, and running the docker container(s).

After creating the new directory, typing `make <foo>` will build (if needed),
start (if needed), and run the container.  You can also type 
`make <foo> CMD=remove`, `make <foo> CMD=stop`, or `make <foo> CMD=start` to 
remove, stop, and start the container respectively.

## Here are some pretty screenshots

Starting all the containers in parellel

![make -j all](screenshots/makeAll.png) 

Searching for a new contianer image

![make search](screenshots/makeSearch.png) 
