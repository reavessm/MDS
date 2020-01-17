TODO
====

Things to do
------------

1. Change username/password prompts to also allow reading from (base64 encoded) variables in local mds.sh
    * username="cmVhdmVzc20K" 
    * Is this secure/BP?
    * Still allow for reading from stdin if needed
    * Need a 'secret' system for long term
        * Distributed?
1. Split out VM stuffs
    * look at `alpine` for an example
    * might be as simple as changing suffix from `.d` to `.v`?
        * Don't forget about exposed ports with the proxy
            * Handle multiple ports?
1. Don't check if VM is running after we download it
1. Create `dialog` script to create vm
