TODO
====

Things to do
------------

1. Docker pull isn't working with start command?
1. Change username/password prompts to also allow reading from (base64 encoded) variables in local mds.sh
    * username="cmVhdmVzc20K" 
    * Is this secure/BP?
    * Still allow for reading from stdin if needed
    * Need a 'secret' system for long term
        * Distributed?
