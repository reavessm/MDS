# My Docker Scripts
Becuase Kubernetes is hard...

## Usage

MDS is essentially a `make` wrapper for docker.  Typing `make new` will allow
you to create a new container.  It creates a new directory, and inside that
directory, it makes an `mds.sh` script.  That script is responsible for
starting, stopping, removing, building, and running the docker container(s).

Adding new services is as simple as `make search`.  This will start a series of
`dialog` menus to allow you to search for the docker container that you want.
MDS will then open the correct `mds.sh` script in your default editor.

After creating the new service, typing `make <foo>` will build (if needed),
start (if needed), and run the container.  You can also type 
`make <foo> CMD=remove`, `make <foo> CMD=stop`, or `make <foo> CMD=start` to 
remove, stop, and start the container respectively.

MDS also automatically handles configuring an encrypted reverse proxy based on
the 'enabled' services (enabled here means the directory ends with '.d').
Specifying the 'exposedPort' variable in an enabled directory will mean that
service gets a subdomain evertyime `make proxyReset` is run.  That command
will also prompt you for your top level domain name everytime it's run, or you
can just write in 'proxy.d/domain.txt'.

The biggest strength of MDS is it's customizability.  You can override the `run` 
command to run a `docker-compose` script instead of a single container.  You
could also override the `run` command to do nothing and just point the
exposedPort and conIP to another VM if all you need is a proxy.  The sky is the
limit!

## Here are some pretty screenshots

Starting all the containers in parellel

![make -j all](screenshots/makeAll.png) 

Searching for a new contianer image

![make search](screenshots/makeSearch.png) 
