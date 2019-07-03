#################################################################################
# My Docker Script Makefile                                                     #
# Written by: Stephen Reaves                                                    #
#                                                                               #
# Every Docker container should have it's own dir with the '.d' suffix.  Inside #
# that dir, there should be mds.sh script that defines variables like the image.#
# From there, the parent mds.sh script should handle docker builds, runs, etc.  #
#################################################################################

usage :
ifneq (,$(wildcard /usr/bin/cowsay))
	@cowsay "Run 'make init' to begin creating a service. Then, run 'make <servicename>' to start that service, or 'make all' to start all services."
else
	@echo "Run 'make init' to begin creating a service. \
Then, run 'make <servicename>' to start that service, or \
'make all' to start all services." 
endif

CMD="run"

DIR = $(wildcard *.d)
TARGET = $(DIR:.d=)

.PHONY: $(DIR) $(TARGET) new clean search restart

$(DIR) :
	@(cd $@ && mds.sh $(CMD))

$(TARGET) : % : %.d

clean :
	docker system prune -a

all : $(DIR)

list :
	@dialog --title "Running services" --infobox "`docker ps -a | awk '/Up/ {print $$NF}'`" 0 0

checkPorts :
	@dialog --title "Used Ports" --infobox "`mds.sh checkPorts`" 0 0

proxyReset :
	@mds.sh proxyReset

new :
	@mds.sh new

search :
	@mds.sh search

init :
	@mds.sh init

restart :
	@: # Hide output
	$(eval CMD=restart)

start :
	@: # Hide output
	$(eval CMD=start)

stop :
	@: # Hide ouput
	$(eval CMD=stop)

remove :
	@: # Hide output
	$(eval CMD=remove)
