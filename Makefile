#################################################################################
# My Docker Script Makefile                                                     #
# Written by: Stephen Reaves                                                    #
#                                                                               #
# Every Docker container should have it's own dir with the '.d' suffix.  Inside #
# that dir, there should be mds.sh script that defines variables like the image.#
# From there, the parent mds.sh script should handle docker builds, runs, etc.  #
#################################################################################

usage :
	@echo "enter name of dir to build"

CMD="run"

DIR = $(wildcard *.d)
TARGET = $(DIR:.d=)

.PHONY: $(DIR) $(TARGET) new clean search

#new :
	#@new.sh

$(DIR) :
	@(cd $@ && mds.sh $(CMD))

$(TARGET) : % : %.d

clean :
	docker system prune -a

all : $(DIR)

list :
	@docker ps -a | awk '/Up/ {print $$NF}'

new :
	@mds.sh new

search :
	@mds.sh search
